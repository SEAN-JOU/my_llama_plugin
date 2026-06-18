#pragma once

#include <mutex>
#include <string>

struct llama_context;
struct llama_model;

class LlamaEngine {
public:
    LlamaEngine();
    ~LlamaEngine();

    LlamaEngine(const LlamaEngine &) = delete;
    LlamaEngine & operator=(const LlamaEngine &) = delete;

    bool loadModel(const std::string & path, int contextSize, int gpuLayers, int threads);
    std::string generate(const std::string & prompt, int maxTokens, float temperature, int topK, float topP);
    void dispose();

private:
    void disposeLocked();
    std::string tokenToPiece(int token) const;

    std::mutex mutex_;
    llama_model * model_ = nullptr;
    llama_context * ctx_ = nullptr;
};
