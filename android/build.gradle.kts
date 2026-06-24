group = "com.example.my_llama_plugin"
version = "1.0-SNAPSHOT"

buildscript {
    val kotlinVersion = "2.2.20"
    repositories {
        google()
        mavenCentral()
    }

    dependencies {
        classpath("com.android.tools.build:gradle:8.11.1")
        classpath("org.jetbrains.kotlin:kotlin-gradle-plugin:$kotlinVersion")
    }
}

allprojects {
    repositories {
        google()
        mavenCentral()
    }
}

plugins {
    id("com.android.library")
    id("kotlin-android")
}

android {
    namespace = "com.example.my_llama_plugin"

    compileSdk = 36
    ndkVersion = "28.2.13676358"

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_17.toString()
    }

    sourceSets {
        getByName("main") {
            java.srcDirs("src/main/kotlin")
            // Flutter 專案的 rootProject 在 android/ 資料夾，其上層有 pubspec.yaml。
            // 只有偵測到 Flutter 專案時，才把 Flutter bridge 加進 source set；
            // 純 Android 專案不需要也無法引用 Flutter SDK，所以 src/flutter/ 不加入。
            val pubspec = rootProject.projectDir.parentFile?.resolve("pubspec.yaml")
            if (pubspec?.exists() == true) {
                java.srcDirs("src/flutter/kotlin")
            }
        }
        getByName("test") {
            java.srcDirs("src/test/kotlin")
        }
    }

    defaultConfig {
        minSdk = 24
        externalNativeBuild {
            cmake {
                // 由於 llama.cpp 支援 Vulkan 和 OpenMP，這裡先保留基本設定
                cppFlags("-std=c++17")
            }
        }
        ndk {
            abiFilters.add("arm64-v8a") // 絕大多數現代 Android 實機
            abiFilters.add("x86_64")    // 電腦上的 Android 模擬器
        }
    }

    externalNativeBuild {
        cmake {
            // 指定 CMakeLists.txt 的路徑
            path = file("src/main/cpp/CMakeLists.txt")
        }
    }

    testOptions {
        unitTests {
            isIncludeAndroidResources = true
            all {
                it.useJUnitPlatform()

                it.outputs.upToDateWhen { false }

                it.testLogging {
                    events("passed", "skipped", "failed", "standardOut", "standardError")
                    showStandardStreams = true
                }
            }
        }
    }
}

dependencies {
    testImplementation("org.jetbrains.kotlin:kotlin-test")
    testImplementation("org.mockito:mockito-core:5.0.0")
}
