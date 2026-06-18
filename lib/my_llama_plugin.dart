import 'package:flutter/services.dart';

class MyLlamaPlugin {
  // 建立一條與 iOS (Swift) 溝通的專屬通道
  static const MethodChannel _channel = MethodChannel('my_llama_plugin');

  /// 載入模型 (傳入本地 .gguf 的絕對實體路徑)
  Future<bool> loadModel(String path) async {
    try {
      // 呼叫 Swift 端的 'loadModel'
      final bool? result = await _channel.invokeMethod<bool>('loadModel', {
        'path': path,
      });
      return result ?? false;
    } catch (e) {
      print("🤖 [Dart 端] 載入模型失敗: $e");
      return false;
    }
  }

  /// 產生對話 (預先寫好，準備接下一個階段的推論邏輯)
  Future<String?> generate(String prompt) async {
    try {
      // 呼叫 Swift 端的 'generate'
      final String? result = await _channel.invokeMethod<String>('generate', {
        'prompt': prompt,
      });
      return result;
    } catch (e) {
      print("🤖 [Dart 端] 產生對話失敗: $e");
      return null;
    }
  }
}
