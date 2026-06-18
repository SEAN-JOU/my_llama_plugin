Pod::Spec.new do |s|
  # --- 必要的基礎資訊 (剛剛遺失的部分) ---
  s.name             = 'my_llama_plugin'
  s.version          = '0.0.1'
  s.summary          = 'A new Flutter plugin project for llama.cpp.'
  s.description      = 'A Flutter plugin linking llama.cpp via Objective-C++.'
  s.homepage         = 'http://example.com'
  s.license          = { :type => 'MIT', :file => '../LICENSE' }
  s.author           = { 'Your Company' => 'email@example.com' }
  s.source           = { :path => '.' }

  # 1. 只編進 Flutter bridge 與 llama.cpp/ggml 核心，避免 tools/examples/tests 裡的 main() 進入 plugin。
  s.source_files = [
    'Classes/*.{swift,h,hpp,mm,cpp}',
    'Classes/core/include/**/*.h',
    'Classes/core/src/**/*.{h,cpp}',
    'Classes/core/ggml/include/**/*.h',
    'Classes/core/ggml/src/*.{h,c,cpp}',
    'Classes/core/ggml/src/ggml-cpu/*.{h,c,cpp}',
    'Classes/core/ggml/src/ggml-cpu/arch/arm/*.{h,c,cpp}'
  ]

  # 2. 將 llama.cpp 的標頭檔標記為私有，避免 Xcode 扁平化匯出產生碰撞
  s.private_header_files = 'Classes/LlamaEngine.hpp', 'Classes/core/**/*.h'

  # 3. Flutter 與平台設定
  s.dependency 'Flutter'
  s.platform = :ios, '12.0'
  
  # 4. 第一版先走 CPU backend，後續可再加入 Metal/Vulkan 加速。
  s.frameworks = 'Foundation', 'Accelerate'

  # 5. 開啟 CPU backend 與 C++17 標準
  s.compiler_flags = '-DGGML_USE_CPU -DGGML_VERSION=\"0.15.1\" -DGGML_COMMIT=\"unknown\"'
  s.pod_target_xcconfig = {
    'DEFINES_MODULE' => 'YES',
    'CLANG_CXX_LANGUAGE_STANDARD' => 'c++17',
    'HEADER_SEARCH_PATHS' => [
      '$(PODS_TARGET_SRCROOT)/Classes',
      '$(PODS_TARGET_SRCROOT)/Classes/core/include',
      '$(PODS_TARGET_SRCROOT)/Classes/core/src',
      '$(PODS_TARGET_SRCROOT)/Classes/core/ggml/include',
      '$(PODS_TARGET_SRCROOT)/Classes/core/ggml/src',
      '$(PODS_TARGET_SRCROOT)/Classes/core/ggml/src/ggml-cpu'
    ].join(' ')
  }
end
