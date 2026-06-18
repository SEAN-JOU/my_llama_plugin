#include <jni.h>

#include <cstdint>
#include <string>

#include "LlamaEngine.hpp"

namespace {
LlamaEngine g_engine;

std::string jstringToString(JNIEnv *env, jstring value) {
    if (value == nullptr) {
        return "";
    }

    const char *chars = env->GetStringUTFChars(value, nullptr);
    if (chars == nullptr) {
        return "";
    }

    std::string result(chars);
    env->ReleaseStringUTFChars(value, chars);
    return result;
}

jstring stringToJString(JNIEnv *env, const std::string &value) {
    jbyteArray bytes = env->NewByteArray(static_cast<jsize>(value.size()));
    if (bytes == nullptr) {
        return env->NewStringUTF("");
    }

    env->SetByteArrayRegion(
        bytes,
        0,
        static_cast<jsize>(value.size()),
        reinterpret_cast<const jbyte *>(value.data())
    );

    jclass stringClass = env->FindClass("java/lang/String");
    jmethodID constructor = env->GetMethodID(stringClass, "<init>", "([BLjava/lang/String;)V");
    jstring charset = env->NewStringUTF("UTF-8");
    auto result = static_cast<jstring>(env->NewObject(stringClass, constructor, bytes, charset));

    env->DeleteLocalRef(bytes);
    env->DeleteLocalRef(charset);
    env->DeleteLocalRef(stringClass);

    return result != nullptr ? result : env->NewStringUTF("");
}
} // namespace

extern "C" JNIEXPORT jboolean JNICALL
Java_com_example_my_1llama_1plugin_MyLlamaPlugin_loadModelNative(
    JNIEnv *env,
    jobject /* this */,
    jstring path,
    jint contextSize,
    jint gpuLayers,
    jint threads
) {
    const std::string modelPath = jstringToString(env, path);
    const bool success = g_engine.loadModel(modelPath, contextSize, gpuLayers, threads);
    return success ? JNI_TRUE : JNI_FALSE;
}

extern "C" JNIEXPORT jstring JNICALL
Java_com_example_my_1llama_1plugin_MyLlamaPlugin_generateNative(
    JNIEnv *env,
    jobject /* this */,
    jstring prompt,
    jint maxTokens,
    jfloat temperature,
    jint topK,
    jfloat topP
) {
    const std::string promptString = jstringToString(env, prompt);
    const std::string response = g_engine.generate(
        promptString,
        maxTokens,
        temperature,
        topK,
        topP
    );
    return stringToJString(env, response);
}

extern "C" JNIEXPORT void JNICALL
Java_com_example_my_1llama_1plugin_MyLlamaPlugin_disposeModelNative(
    JNIEnv * /* env */,
    jobject /* this */
) {
    g_engine.dispose();
}
