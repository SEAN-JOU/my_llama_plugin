package com.example.my_llama_plugin

import android.os.Handler
import android.os.Looper
import androidx.annotation.NonNull
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result
import java.util.concurrent.ExecutorService
import java.util.concurrent.Executors

class MyLlamaPlugin: FlutterPlugin, MethodCallHandler {
  private lateinit var channel : MethodChannel
  private val executor: ExecutorService = Executors.newSingleThreadExecutor()
  private val mainHandler = Handler(Looper.getMainLooper())

  override fun onAttachedToEngine(@NonNull flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
    channel = MethodChannel(flutterPluginBinding.binaryMessenger, "my_llama_plugin")
    channel.setMethodCallHandler(this)
  }

  override fun onMethodCall(@NonNull call: MethodCall, @NonNull result: Result) {
    when (call.method) {
      "loadModel" -> {
        val path = call.argument<String>("path") ?: ""
        val contextSize = call.argument<Int>("contextSize") ?: 2048
        val gpuLayers = call.argument<Int>("gpuLayers") ?: 0
        val threads = call.argument<Int>("threads") ?: 0
        runOnNativeThread(result) {
          MyLlamaNative.loadModel(path, contextSize, gpuLayers, threads)
        }
      }
      "generate" -> {
        val prompt = call.argument<String>("prompt") ?: ""
        val maxTokens = call.argument<Int>("maxTokens") ?: 128
        val temperature = call.argument<Double>("temperature")?.toFloat() ?: 0.8f
        val topK = call.argument<Int>("topK") ?: 40
        val topP = call.argument<Double>("topP")?.toFloat() ?: 0.95f
        runOnNativeThread(result) {
          MyLlamaNative.generate(prompt, maxTokens, temperature, topK, topP)
        }
      }
      "disposeModel" -> {
        runOnNativeThread(result) {
          MyLlamaNative.disposeModel()
          true
        }
      }
      "getPlatformVersion" -> {
        result.success("Android " + android.os.Build.VERSION.RELEASE)
      }
      else -> {
        result.notImplemented()
      }
    }
  }

  override fun onDetachedFromEngine(@NonNull binding: FlutterPlugin.FlutterPluginBinding) {
    channel.setMethodCallHandler(null)
    executor.shutdown()
  }

  private fun <T> runOnNativeThread(result: Result, block: () -> T) {
    executor.execute {
      try {
        val value = block()
        mainHandler.post {
          result.success(value)
        }
      } catch (error: Throwable) {
        mainHandler.post {
          result.error("NATIVE_ERROR", error.message, null)
        }
      }
    }
  }
}
