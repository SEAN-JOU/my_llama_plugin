#include <jni.h>
#include <string>
#include "../../../../../ios/Classes/core/include/llama.h"

extern "C" JNIEXPORT jboolean JNICALL
// 這裡的函式名稱必須嚴格對應您的 Kotlin Package 名稱
// 假設您的 package 是 com.example.my_llama_plugin
Java_com_example_my_1llama_1plugin_MyLlamaPlugin_loadModelNative(JNIEnv *env, jobject /* this */, jstring path) {
    
    // 將 Kotlin 傳來的字串轉成 C 字串
    const char *nativeString = env->GetStringUTFChars(path, nullptr);
    
    // 初始化 llama
    llama_backend_init();
    
    // 這裡先回傳 true 測試編譯
    bool success = true; 

    // 釋放記憶體
    env->ReleaseStringUTFChars(path, nativeString);
    
    return success;
}