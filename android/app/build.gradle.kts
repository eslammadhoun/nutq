plugins {
    id("com.android.application")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.nutq.nutq"
    // whisper_ggml's native build (whisper.cpp via CMake) requires NDK
    // 29.0.13113456 and compileSdk 34 — pin explicitly rather than
    // trusting `flutter.ndkVersion`/`flutter.compileSdkVersion` to already
    // be new enough, since a mismatch fails the Gradle build outright
    // rather than just warning.
    compileSdk = maxOf(flutter.compileSdkVersion, 34)
    ndkVersion = "29.0.13113456"

    // `llama_cpp_dart` (Gemma summarization) bundles its Android
    // `libllama.so` via Flutter's native-assets build hook rather than a
    // Gradle/CMake step — no further config needed here, but the *Flutter
    // SDK/toolchain* running the build must have that feature turned on:
    // `flutter config --enable-native-assets`. This is a machine-level
    // toolchain flag, not a project file, so it can't be pinned in this
    // repo — CI/dev machines building this app for Android need to have run
    // it once. Not verified against a real Android build in this
    // workstream (no device/emulator available).

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    defaultConfig {
        // TODO: Specify your own unique Application ID (https://developer.android.com/studio/build/application-id.html).
        applicationId = "com.nutq.nutq"
        // You can update the following values to match your application needs.
        // For more information, see: https://flutter.dev/to/review-gradle-config.
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    buildTypes {
        release {
            // TODO: Add your own signing config for the release build.
            // Signing with the debug keys for now, so `flutter run --release` works.
            signingConfig = signingConfigs.getByName("debug")
        }
    }
}

kotlin {
    compilerOptions {
        jvmTarget = org.jetbrains.kotlin.gradle.dsl.JvmTarget.JVM_17
    }
}

flutter {
    source = "../.."
}
