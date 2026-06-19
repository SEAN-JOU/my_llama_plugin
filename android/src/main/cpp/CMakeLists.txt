cmake_minimum_required(VERSION 3.14)
project("my_llama_plugin" LANGUAGES C CXX)

set(CMAKE_C_STANDARD 11)
set(CMAKE_C_STANDARD_REQUIRED ON)
set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

add_compile_options(
    "$<$<COMPILE_LANGUAGE:C>:-O3>"
    "$<$<COMPILE_LANGUAGE:CXX>:-O3>"
    "$<$<COMPILE_LANGUAGE:C>:-DNDEBUG>"
    "$<$<COMPILE_LANGUAGE:CXX>:-DNDEBUG>"
)

# 1. 指向我們放在 iOS 資料夾的 llama.cpp 源碼
set(LLAMA_SRC_DIR ${CMAKE_CURRENT_SOURCE_DIR}/../../../../ios/Classes/core)

set(BUILD_SHARED_LIBS OFF CACHE BOOL "" FORCE)
set(LLAMA_BUILD_COMMON OFF CACHE BOOL "" FORCE)
set(LLAMA_BUILD_TESTS OFF CACHE BOOL "" FORCE)
set(LLAMA_BUILD_TOOLS OFF CACHE BOOL "" FORCE)
set(LLAMA_BUILD_EXAMPLES OFF CACHE BOOL "" FORCE)
set(LLAMA_BUILD_SERVER OFF CACHE BOOL "" FORCE)
set(LLAMA_BUILD_APP OFF CACHE BOOL "" FORCE)
set(GGML_LLAMAFILE OFF CACHE BOOL "" FORCE)
set(GGML_OPENMP OFF CACHE BOOL "" FORCE)
set(GGML_VULKAN OFF CACHE BOOL "" FORCE)
set(GGML_OPENCL OFF CACHE BOOL "" FORCE)
set(GGML_METAL OFF CACHE BOOL "" FORCE)
set(GGML_CUDA OFF CACHE BOOL "" FORCE)
set(GGML_CURL OFF CACHE BOOL "" FORCE)

if(DEFINED ANDROID_ABI)
    message(STATUS "Detected Android ABI: ${ANDROID_ABI}")
    if(ANDROID_ABI STREQUAL "arm64-v8a")
        set(GGML_SYSTEM_ARCH "ARM" CACHE STRING "" FORCE)
        set(GGML_CPU_ARM_ARCH "" CACHE STRING "" FORCE)
        set(GGML_CPU_KLEIDIAI OFF CACHE BOOL "" FORCE)
    elseif(ANDROID_ABI STREQUAL "x86_64")
        set(GGML_SYSTEM_ARCH "x86" CACHE STRING "" FORCE)
        set(GGML_CPU_KLEIDIAI OFF CACHE BOOL "" FORCE)
    endif()
endif()

# 2. 引入 llama.cpp 官方寫好的 CMake 邏輯
add_subdirectory(${LLAMA_SRC_DIR} llama_cpp_build)

# 3. 編譯我們寫給 Android 的 JNI 橋樑
add_library(my_llama_plugin SHARED
    llama_bridge.cpp
    ${CMAKE_CURRENT_SOURCE_DIR}/../../../../ios/Classes/LlamaEngine.cpp
)

target_include_directories(my_llama_plugin PRIVATE
    ${CMAKE_CURRENT_SOURCE_DIR}/../../../../ios/Classes
)

# 4. 將 llama.cpp 連結到我們的橋樑上
target_link_libraries(my_llama_plugin llama android log)
