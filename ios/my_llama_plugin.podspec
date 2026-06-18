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

  # --- 我們剛剛設定好的編譯邏輯 ---
  # 1. 包含所有原始碼
  s.source_files = 'Classes/**/*.{swift,h,m,mm,c,cpp}'
  
  # 2. 排除會導致編譯衝突的範例與測試檔
  s.exclude_files = 'Classes/core/examples/**/*', 'Classes/core/tests/**/*', 'Classes/core/pocs/**/*'

  # 3. 將 llama.cpp 的標頭檔標記為私有，避免 Xcode 扁平化匯出產生碰撞
  s.private_header_files = 'Classes/core/**/*.h'

  # 4. Flutter 與平台設定
  s.dependency 'Flutter'
  s.platform = :ios, '12.0'
  
  # 5. 引入 Metal 加速框架
  s.frameworks = 'Metal', 'Foundation'

  # 6. 開啟 Metal 加速與 C++17 標準
  s.compiler_flags = '-DGGML_USE_METAL'
  s.pod_target_xcconfig = {
    'DEFINES_MODULE' => 'YES',
    'CLANG_CXX_LANGUAGE_STANDARD' => 'c++17'
  }
end