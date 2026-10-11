# Moonshine's Java binding ships in the same AAR as the native libraries the
# app uses, and refers to libraries left out on purpose (appcompat, OkHttp,
# WorkManager). The app never calls that binding, so R8 may drop it.
-dontwarn ai.moonshine.voice.**
-dontwarn androidx.appcompat.**
-dontwarn androidx.work.**
-dontwarn okhttp3.**
-dontwarn com.google.android.material.**

# Called from C++ by name.
-keep class com.nutq.nutq.NativeTranscript { *; }
-keepclasseswithmembernames class com.nutq.nutq.MoonshineNative {
    native <methods>;
}
