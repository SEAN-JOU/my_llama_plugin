import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

class MyLlamaPlugin {
  // 建立與原生層 (iOS/Android) 溝通的專屬通道
  static const MethodChannel _channel = MethodChannel('my_llama_plugin');

  /// 載入模型
  /// 傳入模型在設備上的「實體絕對路徑」
  Future<bool> loadModel(
    String path, {
    int contextSize = 2048,
    int? gpuLayers,
    int threads = 0,
  }) async {
    try {
      final args = <String, Object?>{
        'path': path,
        'contextSize': contextSize,
        'threads': threads,
      };
      if (gpuLayers != null) {
        args['gpuLayers'] = gpuLayers;
      }

      // 透過 invokeMethod 呼叫原生的 'loadModel'，並傳遞參數 map
      final bool? result = await _channel.invokeMethod<bool>('loadModel', args);
      return result ?? false;
    } on PlatformException catch (e) {
      debugPrint("🤖 [Dart 端] 載入模型發生平台例外: ${e.message}");
      return false;
    } catch (e) {
      debugPrint("🤖 [Dart 端] 載入模型失敗: $e");
      return false;
    }
  }

  /// 產生對話回覆
  /// 傳入已經組裝好的 Prompt 字串
  Future<String?> generate(
    String prompt, {
    int maxTokens = 128,
    double temperature = 0.8,
    int topK = 40,
    double topP = 0.95,
  }) async {
    try {
      // 透過 invokeMethod 呼叫原生的 'generate'
      final String? result = await _channel.invokeMethod<String>('generate', {
        'prompt': prompt,
        'maxTokens': maxTokens,
        'temperature': temperature,
        'topK': topK,
        'topP': topP,
      });
      return result;
    } on PlatformException catch (e) {
      debugPrint("🤖 [Dart 端] 產生對話發生平台例外: ${e.message}");
      return null;
    } catch (e) {
      debugPrint("🤖 [Dart 端] 產生對話失敗: $e");
      return null;
    }
  }

  /// 釋放模型記憶體
  /// 在 App 退出或切換模型前務必呼叫，避免 OOM (Out Of Memory) 閃退
  Future<bool> disposeModel() async {
    try {
      // 呼叫原生的 'disposeModel'，不需要傳遞參數
      await _channel.invokeMethod('disposeModel');
      debugPrint("🤖 [推論引擎] 請求釋放記憶體成功");
      return true;
    } on PlatformException catch (e) {
      debugPrint("🤖 [推論引擎] 釋放記憶體發生平台例外: ${e.message}");
      return false;
    } catch (e) {
      debugPrint("🤖 [推論引擎] 釋放模型失敗: $e");
      return false;
    }
  }
}
