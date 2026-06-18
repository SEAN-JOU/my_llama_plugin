import 'package:flutter_test/flutter_test.dart';
import 'package:my_llama_plugin/my_llama_plugin.dart';
import 'package:my_llama_plugin/my_llama_plugin_platform_interface.dart';
import 'package:my_llama_plugin/my_llama_plugin_method_channel.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

class MockMyLlamaPluginPlatform
    with MockPlatformInterfaceMixin
    implements MyLlamaPluginPlatform {
  @override
  Future<String?> getPlatformVersion() => Future.value('42');
}

void main() {
  final MyLlamaPluginPlatform initialPlatform = MyLlamaPluginPlatform.instance;

  test('$MethodChannelMyLlamaPlugin is the default instance', () {
    expect(initialPlatform, isInstanceOf<MethodChannelMyLlamaPlugin>());
  });

  test('getPlatformVersion', () async {
    MyLlamaPlugin myLlamaPlugin = MyLlamaPlugin();
    MockMyLlamaPluginPlatform fakePlatform = MockMyLlamaPluginPlatform();
    MyLlamaPluginPlatform.instance = fakePlatform;

    expect(await myLlamaPlugin.getPlatformVersion(), '42');
  });
}
