import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'my_llama_plugin_platform_interface.dart';

/// An implementation of [MyLlamaPluginPlatform] that uses method channels.
class MethodChannelMyLlamaPlugin extends MyLlamaPluginPlatform {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final methodChannel = const MethodChannel('my_llama_plugin');

  @override
  Future<String?> getPlatformVersion() async {
    final version = await methodChannel.invokeMethod<String>(
      'getPlatformVersion',
    );
    return version;
  }

  @override
  Future<bool> loadModel(
    String path, {
    int contextSize = 2048,
    int? gpuLayers,
    int threads = 0,
  }) async {
    final args = <String, Object?>{
      'path': path,
      'contextSize': contextSize,
      'threads': threads,
    };
    if (gpuLayers != null) {
      args['gpuLayers'] = gpuLayers;
    }

    final result = await methodChannel.invokeMethod<bool>('loadModel', args);
    return result ?? false;
  }

  @override
  Future<String?> generate(
    String prompt, {
    int maxTokens = 128,
    double temperature = 0.8,
    int topK = 40,
    double topP = 0.95,
  }) {
    return methodChannel.invokeMethod<String>('generate', {
      'prompt': prompt,
      'maxTokens': maxTokens,
      'temperature': temperature,
      'topK': topK,
      'topP': topP,
    });
  }

  @override
  Future<bool> disposeModel() async {
    final result = await methodChannel.invokeMethod<bool>('disposeModel');
    return result ?? true;
  }
}
