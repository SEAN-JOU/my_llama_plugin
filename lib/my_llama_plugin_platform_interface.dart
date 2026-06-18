import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'my_llama_plugin_method_channel.dart';

abstract class MyLlamaPluginPlatform extends PlatformInterface {
  /// Constructs a MyLlamaPluginPlatform.
  MyLlamaPluginPlatform() : super(token: _token);

  static final Object _token = Object();

  static MyLlamaPluginPlatform _instance = MethodChannelMyLlamaPlugin();

  /// The default instance of [MyLlamaPluginPlatform] to use.
  ///
  /// Defaults to [MethodChannelMyLlamaPlugin].
  static MyLlamaPluginPlatform get instance => _instance;

  /// Platform-specific implementations should set this with their own
  /// platform-specific class that extends [MyLlamaPluginPlatform] when
  /// they register themselves.
  static set instance(MyLlamaPluginPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  Future<String?> getPlatformVersion() {
    throw UnimplementedError('platformVersion() has not been implemented.');
  }

  Future<bool> loadModel(
    String path, {
    int contextSize = 2048,
    int? gpuLayers,
    int threads = 0,
  }) {
    throw UnimplementedError('loadModel() has not been implemented.');
  }

  Future<String?> generate(
    String prompt, {
    int maxTokens = 128,
    double temperature = 0.8,
    int topK = 40,
    double topP = 0.95,
  }) {
    throw UnimplementedError('generate() has not been implemented.');
  }

  Future<bool> disposeModel() {
    throw UnimplementedError('disposeModel() has not been implemented.');
  }
}
