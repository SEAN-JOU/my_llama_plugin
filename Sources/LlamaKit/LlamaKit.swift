import Foundation
import LlamaCore

public enum LlamaError: Error, LocalizedError {
    case modelLoadFailed
    case emptyPrompt

    public var errorDescription: String? {
        switch self {
        case .modelLoadFailed: return "無法從指定路徑載入模型"
        case .emptyPrompt:     return "Prompt 不可為空"
        }
    }
}

/// 執行緒安全的 llama.cpp 推理封裝，提供 async/await 介面。
/// 不依賴 Flutter，可直接整合進原生 iOS 專案。
public final class LlamaKit: @unchecked Sendable {

    private let bridge = LlamaBridge()
    private let queue = DispatchQueue(
        label: "com.llamakit.inference",
        qos: .userInteractive,
        autoreleaseFrequency: .workItem
    )

    public init() {}

    // MARK: - Public API

    /// 載入 GGUF 模型檔案。
    /// - Parameters:
    ///   - path: 模型檔案的絕對路徑
    ///   - contextSize: KV-cache 上下文長度，預設 2048
    ///   - gpuLayers: 卸載到 GPU 的層數（0 = 全 CPU）
    ///   - threads: 推理執行緒數（0 = 自動）
    @discardableResult
    public func loadModel(
        path: String,
        contextSize: Int = 2048,
        gpuLayers: Int = 0,
        threads: Int = 0
    ) async throws -> Bool {
        try await withCheckedThrowingContinuation { continuation in
            queue.async { [bridge = self.bridge] in
                let ok = bridge.loadModel(
                    atPath: path,
                    contextSize: Int32(contextSize),
                    gpuLayers: Int32(gpuLayers),
                    threads: Int32(threads)
                )
                if ok {
                    continuation.resume(returning: true)
                } else {
                    continuation.resume(throwing: LlamaError.modelLoadFailed)
                }
            }
        }
    }

    /// 生成文字回應。
    /// - Parameters:
    ///   - prompt: 輸入提示詞
    ///   - maxTokens: 最多生成的 token 數，預設 128
    ///   - temperature: 溫度（隨機性），預設 0.8
    ///   - topK: Top-K 採樣，預設 40
    ///   - topP: Top-P (nucleus) 採樣，預設 0.95
    /// - Returns: 生成的文字
    public func generate(
        prompt: String,
        maxTokens: Int = 128,
        temperature: Double = 0.8,
        topK: Int = 40,
        topP: Double = 0.95
    ) async throws -> String {
        guard !prompt.isEmpty else { throw LlamaError.emptyPrompt }
        return await withCheckedContinuation { continuation in
            queue.async { [bridge = self.bridge] in
                let result = bridge.generate(
                    withPrompt: prompt,
                    maxTokens: Int32(maxTokens),
                    temperature: Float(temperature),
                    topK: Int32(topK),
                    topP: Float(topP)
                )
                continuation.resume(returning: result)
            }
        }
    }

    /// 釋放模型記憶體。呼叫後須重新 loadModel 才可繼續使用。
    public func dispose() {
        queue.async { [bridge = self.bridge] in
            bridge.disposeModel()
        }
    }

    deinit {
        queue.sync { [bridge = self.bridge] in
            bridge.disposeModel()
        }
    }
}
