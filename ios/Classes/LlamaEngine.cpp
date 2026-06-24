#include "LlamaEngine.hpp"

#include "core/include/llama.h"

#include <algorithm>
#include <clocale>
#include <cstdint>
#include <string>
#include <vector>

namespace {
constexpr int kDefaultContextSize = 2048;
constexpr int kDefaultMaxTokens = 128;
constexpr int kDefaultTopK = 40;
constexpr float kDefaultTemperature = 0.8f;
constexpr float kDefaultTopP = 0.95f;

void ensureBackendInitialized() {
    static const bool initialized = [] {
        std::setlocale(LC_NUMERIC, "C");
        llama_backend_init();
        return true;
    }();
    (void) initialized;
}

int normalizePositive(int value, int fallback) {
    return value > 0 ? value : fallback;
}
} // namespace

LlamaEngine::LlamaEngine() {
    ensureBackendInitialized();
}

LlamaEngine::~LlamaEngine() {
    dispose();
}

bool LlamaEngine::loadModel(const std::string & path, int contextSize, int gpuLayers, int threads) {
    std::lock_guard<std::mutex> lock(mutex_);

    cancelled_.store(false, std::memory_order_relaxed);
    disposeLocked();
    ensureBackendInitialized();

    llama_model_params modelParams = llama_model_default_params();
    modelParams.n_gpu_layers = std::max(0, gpuLayers);

    llama_model * model = llama_model_load_from_file(path.c_str(), modelParams);
    if (model == nullptr) {
        return false;
    }

    const int nCtx = normalizePositive(contextSize, kDefaultContextSize);

    llama_context_params ctxParams = llama_context_default_params();
    ctxParams.n_ctx              = static_cast<uint32_t>(nCtx);
    ctxParams.n_batch            = std::min(static_cast<uint32_t>(nCtx), 512u);
    ctxParams.n_ubatch           = std::min(ctxParams.n_batch, 512u);
    ctxParams.flash_attn_type    = LLAMA_FLASH_ATTN_TYPE_ENABLED;
    ctxParams.offload_kqv        = (gpuLayers > 0);
    ctxParams.type_k             = GGML_TYPE_F16;
    ctxParams.type_v             = GGML_TYPE_F16;
    if (threads > 0) {
        ctxParams.n_threads       = threads;
        ctxParams.n_threads_batch = threads;
    }

    llama_context * ctx = llama_init_from_model(model, ctxParams);
    if (ctx == nullptr) {
        llama_model_free(model);
        return false;
    }

    model_ = model;
    ctx_ = ctx;
    return true;
}

std::string LlamaEngine::generate(
    const std::string & prompt,
    int maxTokens,
    float temperature,
    int topK,
    float topP
) {
    std::lock_guard<std::mutex> lock(mutex_);

    if (model_ == nullptr || ctx_ == nullptr || prompt.empty()) {
        return "";
    }

    const llama_vocab * vocab = llama_model_get_vocab(model_);
    if (vocab == nullptr) {
        return "";
    }

    llama_memory_clear(llama_get_memory(ctx_), true);

    int tokenCount = llama_tokenize(
        vocab,
        prompt.c_str(),
        static_cast<int32_t>(prompt.size()),
        nullptr,
        0,
        true,
        true
    );
    if (tokenCount == INT32_MIN) {
        return "";
    }
    if (tokenCount < 0) {
        tokenCount = -tokenCount;
    }
    if (tokenCount <= 0) {
        return "";
    }

    const int nCtx = static_cast<int>(llama_n_ctx(ctx_));
    if (tokenCount >= nCtx) {
        return "";
    }

    std::vector<llama_token> promptTokens(static_cast<size_t>(tokenCount));
    const int encoded = llama_tokenize(
        vocab,
        prompt.c_str(),
        static_cast<int32_t>(prompt.size()),
        promptTokens.data(),
        static_cast<int32_t>(promptTokens.size()),
        true,
        true
    );
    if (encoded < 0) {
        return "";
    }
    promptTokens.resize(static_cast<size_t>(encoded));

    int tokensToGenerate = normalizePositive(maxTokens, kDefaultMaxTokens);
    tokensToGenerate = std::min(tokensToGenerate, nCtx - static_cast<int>(promptTokens.size()));
    if (tokensToGenerate <= 0) {
        return "";
    }

    const float temp = temperature > 0.0f ? temperature : kDefaultTemperature;
    const int k = normalizePositive(topK, kDefaultTopK);
    const float p = topP > 0.0f && topP <= 1.0f ? topP : kDefaultTopP;

    llama_sampler * sampler = llama_sampler_chain_init(llama_sampler_chain_default_params());
    if (sampler == nullptr) {
        return "";
    }

    if (temperature <= 0.0f) {
        llama_sampler_chain_add(sampler, llama_sampler_init_greedy());
    } else {
        llama_sampler_chain_add(sampler, llama_sampler_init_top_k(k));
        llama_sampler_chain_add(sampler, llama_sampler_init_top_p(p, 1));
        llama_sampler_chain_add(sampler, llama_sampler_init_temp(temp));
        llama_sampler_chain_add(sampler, llama_sampler_init_dist(LLAMA_DEFAULT_SEED));
    }

    std::string response;
    llama_batch batch = llama_batch_get_one(promptTokens.data(), static_cast<int32_t>(promptTokens.size()));
    llama_token nextToken = LLAMA_TOKEN_NULL;

    for (int i = 0; i < tokensToGenerate; ++i) {
        if (cancelled_.load(std::memory_order_relaxed)) {
            break;
        }

        if (llama_decode(ctx_, batch) != 0) {
            break;
        }

        nextToken = llama_sampler_sample(sampler, ctx_, -1);
        if (llama_vocab_is_eog(vocab, nextToken)) {
            break;
        }

        response += tokenToPiece(nextToken);
        batch = llama_batch_get_one(&nextToken, 1);
    }

    llama_sampler_free(sampler);
    return response;
}

void LlamaEngine::generateStream(
    const std::string & prompt,
    int maxTokens,
    float temperature,
    int topK,
    float topP,
    std::function<bool(const std::string &)> tokenCallback
) {
    std::lock_guard<std::mutex> lock(mutex_);

    if (model_ == nullptr || ctx_ == nullptr || prompt.empty() || !tokenCallback) {
        return;
    }

    const llama_vocab * vocab = llama_model_get_vocab(model_);
    if (vocab == nullptr) {
        return;
    }

    llama_memory_clear(llama_get_memory(ctx_), true);

    int tokenCount = llama_tokenize(vocab, prompt.c_str(), static_cast<int32_t>(prompt.size()), nullptr, 0, true, true);
    if (tokenCount == INT32_MIN) return;
    if (tokenCount < 0) tokenCount = -tokenCount;
    if (tokenCount <= 0) return;

    const int nCtx = static_cast<int>(llama_n_ctx(ctx_));
    if (tokenCount >= nCtx) return;

    std::vector<llama_token> promptTokens(static_cast<size_t>(tokenCount));
    const int encoded = llama_tokenize(vocab, prompt.c_str(), static_cast<int32_t>(prompt.size()), promptTokens.data(), static_cast<int32_t>(promptTokens.size()), true, true);
    if (encoded < 0) return;
    promptTokens.resize(static_cast<size_t>(encoded));

    int tokensToGenerate = normalizePositive(maxTokens, kDefaultMaxTokens);
    tokensToGenerate = std::min(tokensToGenerate, nCtx - static_cast<int>(promptTokens.size()));
    if (tokensToGenerate <= 0) return;

    const float temp = temperature > 0.0f ? temperature : kDefaultTemperature;
    const int k = normalizePositive(topK, kDefaultTopK);
    const float p = topP > 0.0f && topP <= 1.0f ? topP : kDefaultTopP;

    llama_sampler * sampler = llama_sampler_chain_init(llama_sampler_chain_default_params());
    if (sampler == nullptr) return;

    if (temperature <= 0.0f) {
        llama_sampler_chain_add(sampler, llama_sampler_init_greedy());
    } else {
        llama_sampler_chain_add(sampler, llama_sampler_init_top_k(k));
        llama_sampler_chain_add(sampler, llama_sampler_init_top_p(p, 1));
        llama_sampler_chain_add(sampler, llama_sampler_init_temp(temp));
        llama_sampler_chain_add(sampler, llama_sampler_init_dist(LLAMA_DEFAULT_SEED));
    }

    llama_batch batch = llama_batch_get_one(promptTokens.data(), static_cast<int32_t>(promptTokens.size()));
    llama_token nextToken = LLAMA_TOKEN_NULL;

    for (int i = 0; i < tokensToGenerate; ++i) {
        if (cancelled_.load(std::memory_order_relaxed)) break;
        if (llama_decode(ctx_, batch) != 0) break;

        nextToken = llama_sampler_sample(sampler, ctx_, -1);
        if (llama_vocab_is_eog(vocab, nextToken)) break;

        std::string piece = tokenToPiece(nextToken);
        if (!tokenCallback(piece)) break;

        batch = llama_batch_get_one(&nextToken, 1);
    }

    llama_sampler_free(sampler);
}

void LlamaEngine::dispose() {
    cancelled_.store(true, std::memory_order_relaxed);
    std::lock_guard<std::mutex> lock(mutex_);
    disposeLocked();
}

void LlamaEngine::disposeLocked() {
    if (ctx_ != nullptr) {
        llama_free(ctx_);
        ctx_ = nullptr;
    }
    if (model_ != nullptr) {
        llama_model_free(model_);
        model_ = nullptr;
    }
}

std::string LlamaEngine::tokenToPiece(int token) const {
    const llama_vocab * vocab = llama_model_get_vocab(model_);
    if (vocab == nullptr) {
        return "";
    }

    char smallBuffer[256];
    int length = llama_token_to_piece(vocab, token, smallBuffer, sizeof(smallBuffer), 0, true);
    if (length >= 0) {
        return std::string(smallBuffer, static_cast<size_t>(length));
    }

    const int required = -length;
    if (required <= 0) {
        return "";
    }

    std::vector<char> buffer(static_cast<size_t>(required));
    length = llama_token_to_piece(vocab, token, buffer.data(), required, 0, true);
    if (length < 0) {
        return "";
    }
    return std::string(buffer.data(), static_cast<size_t>(length));
}
