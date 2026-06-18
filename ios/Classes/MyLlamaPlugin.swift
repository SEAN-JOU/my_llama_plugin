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
            // 解析從 Dart 端傳過來的路徑字串
            guard let args = call.arguments as? [String: Any],
                  let path = args["path"] as? String else {
                result(FlutterError(code: "INVALID_ARGUMENT", message: "缺少模型路徑", details: nil))
                return
            }
            
            // 執行載入
            let success = bridge.loadModel(atPath: path)
            result(success)
        } else {
            result(FlutterMethodNotImplemented)
        }
    }
}