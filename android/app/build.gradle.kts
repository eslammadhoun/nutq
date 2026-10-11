plugins {
    id("com.android.application")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.nutq.nutq"
    compileSdk = maxOf(flutter.compileSdkVersion, 35)
    ndkVersion = "29.0.13113456"

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    defaultConfig {
        applicationId = "com.nutq.nutq"
        // Moonshine's Android library needs API 26.
        minSdk = 26
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName

        externalNativeBuild {
            cmake {
                // libmoonshine.so links libc++ statically, and so does FFmpegKit;
                // a static runtime here keeps libc++_shared.so out of the APK.
                arguments += "-DANDROID_STL=c++_static"
            }
        }
    }

    externalNativeBuild {
        cmake {
            path = file("src/main/cpp/CMakeLists.txt")
        }
    }

    packaging {
        jniLibs {
            // Moonshine's Java binding's JNI library; the app uses its own.
            excludes += "**/libmoonshine-jni.so"
            // Vulkan validation layer Flutter adds to debug builds: 15 MB per ABI.
            excludes += "**/libVkLayer_khronos_validation.so"
            // Qualcomm NPU (QNN) runtimes LiteRT-LM ships, ~54 MB: Nutq runs
            // Gemma on the GPU, falling back to the CPU, never on the NPU.
            excludes += "**/libQnn*.so"

            // `--target-platform` trims only Flutter's engine: the AARs
            // (FFmpegKit, Moonshine, LiteRT-LM) would still ship every ABI.
            // Drop the ABIs not asked for. Without the flag, all are kept.
            val requested = (project.findProperty("target-platform") as String?)
                ?.split(",")?.map { it.trim() }.orEmpty()
            if (requested.isNotEmpty()) {
                mapOf(
                    "android-arm64" to "arm64-v8a",
                    "android-arm" to "armeabi-v7a",
                    "android-x64" to "x86_64",
                ).filterKeys { it !in requested }.values.forEach { excludes += "lib/$it/**" }
            }
        }
    }

    buildTypes {
        release {
            // TODO: Add your own signing config for the release build.
            // Signing with the debug keys for now, so `flutter run --release` works.
            signingConfig = signingConfigs.getByName("debug")
            proguardFiles(
                getDefaultProguardFile("proguard-android-optimize.txt"),
                "proguard-rules.pro",
            )
        }
    }
}

dependencies {
    // Only for its native libraries: libmoonshine.so (the C API) and
    // libonnxruntime.so. Its Java binding copies every line's audio into the
    // JVM on each pass, so the app calls the C API through its own JNI layer
    // (src/main/cpp) instead. Not transitive: the binding's own dependencies
    // (appcompat, OkHttp, WorkManager, ...) are unused.
    implementation("ai.moonshine:moonshine-voice:0.1.5") { isTransitive = false }
    implementation("androidx.core:core:1.16.0")
}

kotlin {
    compilerOptions {
        jvmTarget = org.jetbrains.kotlin.gradle.dsl.JvmTarget.JVM_17
    }
}

flutter {
    source = "../.."
}
