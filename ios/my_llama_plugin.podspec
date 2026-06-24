Pod::Spec.new do |s|
  s.name             = 'my_llama_plugin'
  s.version          = '0.0.1'
  s.summary          = 'A new Flutter plugin project for llama.cpp.'
  s.description      = 'A Flutter plugin linking llama.cpp via Objective-C++.'
  s.homepage         = 'http://example.com'
  s.license          = { :type => 'MIT', :file => '../LICENSE' }
  s.author           = { 'Your Company' => 'email@example.com' }
  s.source           = { :path => '.' }

  # ── Core subspec ────────────────────────────────────────────────────────────
  # 純原生 llama.cpp 引擎 + Objective-C++ 橋樑，不依賴 Flutter。
  # 純 iOS App 或 macOS App 只需要加這個 subspec。
  s.subspec 'Core' do |core|
    core.source_files = [
      'Classes/LlamaBridge.h',
      'Classes/LlamaBridge.mm',
      'Classes/LlamaEngine.cpp',
      'Classes/LlamaEngine.hpp',
      'Classes/core/include/**/*.h',
      'Classes/core/src/**/*.{h,cpp}',
      'Classes/core/ggml/include/**/*.h',
      'Classes/core/ggml/src/*.{h,c,cpp}',
      'Classes/core/ggml/src/ggml-cpu/*.{h,c,cpp}',
      'Classes/core/ggml/src/ggml-cpu/arch/arm/*.{h,c,cpp}'
    ]
    core.private_header_files = 'Classes/LlamaEngine.hpp', 'Classes/core/**/*.h'
    core.frameworks = 'Foundation', 'Accelerate'
    core.compiler_flags = '-DGGML_USE_CPU -DGGML_VERSION=\"0.15.1\" -DGGML_COMMIT=\"unknown\"'
    core.pod_target_xcconfig = {
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

  # ── Flutter subspec ──────────────────────────────────────────────────────────
  # Flutter MethodChannel bridge，只有 Flutter 專案才需要這個 subspec。
  # Flutter plugin 機制會自動以此為預設 subspec（pubspec.yaml 裡的 plugin: platforms: ios）。
  s.subspec 'Flutter' do |fl|
    fl.dependency 'my_llama_plugin/Core'
    fl.dependency 'Flutter'
    fl.source_files  = 'Classes/MyLlamaPlugin.swift'
    fl.pod_target_xcconfig = {
      'DEFINES_MODULE' => 'YES'
    }
  end

  # Flutter plugin 工具鏈預設抓第一個 subspec；明確指定讓行為可預期。
  s.default_subspec = 'Flutter'

  s.platform = :ios, '12.0'
end
