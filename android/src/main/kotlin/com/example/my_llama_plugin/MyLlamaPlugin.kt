package com.example.my_llama_plugin

import androidx.annotation.NonNull
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result

class MyLlamaPlugin: FlutterPlugin, MethodCallHandler {
  private lateinit var channel : MethodChannel

  // 1. 載入 CMake 編譯出來的 C++ 庫
  init {
      System.loadLibrary("my_llama_plugin")
  }

  // 2. 宣告 JNI 原生方法
  private external fun loadModelNative(path: String): Boolean

  override fun onAttachedToEngine(@NonNull flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
    channel = MethodChannel(flutterPluginBinding.binaryMessenger, "my_llama_plugin")
    channel.setMethodCallHandler(this)
  }

  override fun onMethodCall(@NonNull call: MethodCall, @NonNull result: Result) {
    if (call.method == "loadModel") {
      val path = call.argument<String>("path") ?: ""
      // 3. 呼叫 C++ 層
      val success = loadModelNative(path)
      result.success(success)
    } else {
      result.notImplemented()
    }
  }

  override fun onDetachedFromEngine(@NonNull binding: FlutterPlugin.FlutterPluginBinding) {
    channel.setMethodCallHandler(null)
  }
}