import Flutter
import UIKit

public class MyLlamaPlugin: NSObject, FlutterPlugin {
    // 實體化我們的 Objective-C++ 橋樑
    let bridge = LlamaBridge()

    public static func register(with registrar: FlutterPluginRegistrar) {
        let channel = FlutterMethodChannel(name: "my_llama_plugin", binaryMessenger: registrar.messenger())
        let instance = MyLlamaPlugin()
        registrar.addMethodCallDelegate(instance, channel: channel)
    }

    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        if call.method == "loadModel" {
            guard let args = call.arguments as? [String: Any],
                  let path = args["path"] as? String else {
                result(FlutterError(code: "INVALID_ARGUMENT", message: "缺少模型路徑", details: nil))
                return
            }

            let contextSize = args["contextSize"] as? Int ?? 2048
            let gpuLayers = args["gpuLayers"] as? Int ?? 0
            let threads = args["threads"] as? Int ?? 0

            let success = bridge.loadModel(
                atPath: path,
                contextSize: Int32(contextSize),
                gpuLayers: Int32(gpuLayers),
                threads: Int32(threads)
            )
            result(success)
        } else if call.method == "generate" {
            guard let args = call.arguments as? [String: Any],
                  let prompt = args["prompt"] as? String else {
                result(FlutterError(code: "INVALID_ARGUMENT", message: "缺少 prompt", details: nil))
                return
            }

            let maxTokens = args["maxTokens"] as? Int ?? 128
            let temperature = args["temperature"] as? Double ?? 0.8
            let topK = args["topK"] as? Int ?? 40
            let topP = args["topP"] as? Double ?? 0.95

            let response = bridge.generate(
                withPrompt: prompt,
                maxTokens: Int32(maxTokens),
                temperature: Float(temperature),
                topK: Int32(topK),
                topP: Float(topP)
            )
            result(response)
        } else if call.method == "disposeModel" {
            bridge.disposeModel()
            result(true)
        } else if call.method == "getPlatformVersion" {
            result("iOS " + UIDevice.current.systemVersion)
        } else {
            result(FlutterMethodNotImplemented)
        }
    }
}
