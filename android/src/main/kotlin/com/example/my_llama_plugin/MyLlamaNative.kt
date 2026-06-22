package com.example.my_llama_plugin

object MyLlamaNative {
  private val nativeLock = Any()

  init {
    System.loadLibrary("my_llama_plugin")
  }

  @JvmStatic
  @JvmOverloads
  fun loadModel(
    path: String,
    contextSize: Int = 2048,
    gpuLayers: Int = 0,
    threads: Int = 0
  ): Boolean = synchronized(nativeLock) {
    require(path.isNotBlank()) { "Model path must not be blank." }
    loadModelNative(path, contextSize, gpuLayers, threads)
  }

  @JvmStatic
  @JvmOverloads
  fun generate(
    prompt: String,
    maxTokens: Int = 128,
    temperature: Float = 0.8f,
    topK: Int = 40,
    topP: Float = 0.95f
  ): String = synchronized(nativeLock) {
    generateNative(prompt, maxTokens, temperature, topK, topP)
  }

  @JvmStatic
  fun disposeModel() = synchronized(nativeLock) {
    disposeModelNative()
  }

  private external fun loadModelNative(
    path: String,
    contextSize: Int,
    gpuLayers: Int,
    threads: Int
  ): Boolean

  private external fun generateNative(
    prompt: String,
    maxTokens: Int,
    temperature: Float,
    topK: Int,
    topP: Float
  ): String

  private external fun disposeModelNative()
}
