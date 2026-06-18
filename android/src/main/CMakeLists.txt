cmake_minimum_required(VERSION 3.10.2)
project("my_llama_plugin")

# 1. 指向我們放在 iOS 資料夾的 llama.cpp 源碼
set(LLAMA_SRC_DIR ${CMAKE_CURRENT_SOURCE_DIR}/../../../ios/Classes/core)

set(BUILD_SHARED_LIBS OFF CACHE BOOL "" FORCE)
set(LLAMA_BUILD_COMMON OFF CACHE BOOL "" FORCE)
set(LLAMA_BUILD_TESTS OFF CACHE BOOL "" FORCE)
set(LLAMA_BUILD_TOOLS OFF CACHE BOOL "" FORCE)
set(LLAMA_BUILD_EXAMPLES OFF CACHE BOOL "" FORCE)
set(LLAMA_BUILD_SERVER OFF CACHE BOOL "" FORCE)
set(LLAMA_BUILD_APP OFF CACHE BOOL "" FORCE)
set(GGML_VULKAN OFF CACHE BOOL "" FORCE)
set(GGML_OPENCL OFF CACHE BOOL "" FORCE)
set(GGML_METAL OFF CACHE BOOL "" FORCE)
set(GGML_CUDA OFF CACHE BOOL "" FORCE)
set(GGML_CURL OFF CACHE BOOL "" FORCE)

# 2. 引入 llama.cpp 官方寫好的 CMake 邏輯
add_subdirectory(${LLAMA_SRC_DIR} llama_cpp_build)

# 3. 編譯我們寫給 Android 的 JNI 橋樑
add_library(my_llama_plugin SHARED
    cpp/llama_bridge.cpp
    ${CMAKE_CURRENT_SOURCE_DIR}/../../../ios/Classes/LlamaEngine.cpp
)

target_include_directories(my_llama_plugin PRIVATE
    ${CMAKE_CURRENT_SOURCE_DIR}/../../../ios/Classes
)

# 4. 將 llama.cpp 連結到我們的橋樑上
target_link_libraries(my_llama_plugin llama android log)
