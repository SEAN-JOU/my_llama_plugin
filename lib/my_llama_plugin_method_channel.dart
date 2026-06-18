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
}
