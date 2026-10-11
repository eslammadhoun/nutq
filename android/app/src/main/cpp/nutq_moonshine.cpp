// A thin JNI layer over Moonshine's C API (moonshine-c-api.h).
//
// Moonshine's own Android binding copies the audio of every transcript line
// into a new Java float[] on every moonshine_transcribe_stream call: with a
// 5-minute stream that is up to ~19 MB per 5-second chunk, allocated and
// thrown away. This layer hands Kotlin only what it uses — each line's text,
// timing and completion — and reads the audio it is given without copying.
//
// The C API is resolved from libmoonshine.so with dlsym, so this library has
// no link-time dependency on the AAR that ships it. Kotlin loads
// libmoonshine.so before this library, and dlopen returns that same handle.

#include <android/log.h>
#include <dlfcn.h>
#include <jni.h>

#include <cstring>
#include <vector>

#include "moonshine-c-api.h"

namespace {

constexpr const char *kTag = "moonshine";
constexpr const char *kClass = "com/nutq/nutq/MoonshineNative";
constexpr const char *kTranscriptClass = "com/nutq/nutq/NativeTranscript";

struct Api {
  decltype(&moonshine_get_version) get_version = nullptr;
  decltype(&moonshine_error_to_string) error_to_string = nullptr;
  decltype(&moonshine_load_transcriber_from_files) load_transcriber = nullptr;
  decltype(&moonshine_free_transcriber) free_transcriber = nullptr;
  decltype(&moonshine_create_stream) create_stream = nullptr;
  decltype(&moonshine_free_stream) free_stream = nullptr;
  decltype(&moonshine_start_stream) start_stream = nullptr;
  decltype(&moonshine_stop_stream) stop_stream = nullptr;
  decltype(&moonshine_transcribe_add_audio_to_stream) add_audio = nullptr;
  decltype(&moonshine_transcribe_stream) transcribe_stream = nullptr;
};

Api api;
bool api_ready = false;

jclass transcript_class = nullptr;
jmethodID transcript_ctor = nullptr;
jclass byte_array_class = nullptr;

template <typename T>
bool resolve(void *library, const char *name, T &slot) {
  slot = reinterpret_cast<T>(dlsym(library, name));
  if (slot == nullptr) {
    __android_log_print(ANDROID_LOG_ERROR, kTag, "libmoonshine.so lacks %s", name);
    return false;
  }
  return true;
}

bool load_api() {
  void *library = dlopen("libmoonshine.so", RTLD_NOW);
  if (library == nullptr) {
    __android_log_print(ANDROID_LOG_ERROR, kTag, "dlopen libmoonshine.so: %s", dlerror());
    return false;
  }
  // Every call below must resolve, or none is used.
  bool ok = true;
  ok &= resolve(library, "moonshine_get_version", api.get_version);
  ok &= resolve(library, "moonshine_error_to_string", api.error_to_string);
  ok &= resolve(library, "moonshine_load_transcriber_from_files", api.load_transcriber);
  ok &= resolve(library, "moonshine_free_transcriber", api.free_transcriber);
  ok &= resolve(library, "moonshine_create_stream", api.create_stream);
  ok &= resolve(library, "moonshine_free_stream", api.free_stream);
  ok &= resolve(library, "moonshine_start_stream", api.start_stream);
  ok &= resolve(library, "moonshine_stop_stream", api.stop_stream);
  ok &= resolve(library, "moonshine_transcribe_add_audio_to_stream", api.add_audio);
  ok &= resolve(library, "moonshine_transcribe_stream", api.transcribe_stream);
  return ok;
}

jboolean native_ready(JNIEnv *, jclass) { return api_ready ? JNI_TRUE : JNI_FALSE; }

jint native_version(JNIEnv *, jclass) { return api.get_version(); }

jstring native_error_to_string(JNIEnv *env, jclass, jint code) {
  const char *message = api.error_to_string(code);
  return env->NewStringUTF(message != nullptr ? message : "unknown error");
}

jint native_load_transcriber(JNIEnv *env, jclass, jstring path, jint arch) {
  const char *chars = env->GetStringUTFChars(path, nullptr);
  if (chars == nullptr) return MOONSHINE_ERROR_INVALID_ARGUMENT;
  // Default options: decode_incomplete_lines must stay on, or the last phrase
  // of every file is dropped (see MoonshineBridge.swift).
  const int32_t handle = api.load_transcriber(
      chars, static_cast<uint32_t>(arch), nullptr, 0, MOONSHINE_HEADER_VERSION);
  env->ReleaseStringUTFChars(path, chars);
  return handle;
}

void native_free_transcriber(JNIEnv *, jclass, jint handle) { api.free_transcriber(handle); }

jint native_create_stream(JNIEnv *, jclass, jint handle) { return api.create_stream(handle, 0); }

jint native_free_stream(JNIEnv *, jclass, jint handle, jint stream) {
  return api.free_stream(handle, stream);
}

jint native_start_stream(JNIEnv *, jclass, jint handle, jint stream) {
  return api.start_stream(handle, stream);
}

jint native_stop_stream(JNIEnv *, jclass, jint handle, jint stream) {
  return api.stop_stream(handle, stream);
}

jint native_add_audio(JNIEnv *env, jclass, jint handle, jint stream, jfloatArray samples,
                      jint count, jint sample_rate) {
  if (count < 0 || count > env->GetArrayLength(samples)) {
    return MOONSHINE_ERROR_INVALID_ARGUMENT;
  }
  // Critical access: the buffer is used in place, not copied. The call only
  // appends to the stream's buffer, so the JVM is held up for microseconds.
  auto *data = static_cast<float *>(env->GetPrimitiveArrayCritical(samples, nullptr));
  if (data == nullptr) return MOONSHINE_ERROR_UNKNOWN;
  const int32_t result = api.add_audio(handle, stream, data, static_cast<uint64_t>(count),
                                       sample_rate, 0);
  env->ReleasePrimitiveArrayCritical(samples, data, JNI_ABORT);  // read only
  return result;
}

/// Runs one analysis pass and returns the transcript's lines as a
/// NativeTranscript: text as UTF-8 bytes, times in seconds from the start of
/// the stream, and whether each line is complete. Text is returned as bytes
/// because NewStringUTF expects modified UTF-8 and aborts on anything else;
/// Kotlin decodes it, replacing invalid sequences.
jobject native_transcribe_stream(JNIEnv *env, jclass, jint handle, jint stream) {
  transcript_t *transcript = nullptr;
  const int32_t error = api.transcribe_stream(handle, stream, 0, &transcript);
  const jsize count =
      (error == 0 && transcript != nullptr) ? static_cast<jsize>(transcript->line_count) : 0;

  jobjectArray texts = env->NewObjectArray(count, byte_array_class, nullptr);
  jfloatArray starts = env->NewFloatArray(count);
  jfloatArray durations = env->NewFloatArray(count);
  jbooleanArray complete = env->NewBooleanArray(count);
  if (texts == nullptr || starts == nullptr || durations == nullptr || complete == nullptr) {
    return nullptr;  // OutOfMemoryError is pending
  }

  std::vector<jfloat> start_values(count);
  std::vector<jfloat> duration_values(count);
  std::vector<jboolean> complete_values(count);
  for (jsize i = 0; i < count; ++i) {
    const transcript_line_t &line = transcript->lines[i];
    const char *text = line.text != nullptr ? line.text : "";
    const auto length = static_cast<jsize>(std::strlen(text));
    jbyteArray bytes = env->NewByteArray(length);
    if (bytes == nullptr) return nullptr;
    env->SetByteArrayRegion(bytes, 0, length, reinterpret_cast<const jbyte *>(text));
    env->SetObjectArrayElement(texts, i, bytes);
    env->DeleteLocalRef(bytes);  // a long transcript would exhaust local refs
    start_values[i] = line.start_time;
    duration_values[i] = line.duration;
    complete_values[i] = line.is_complete != 0 ? JNI_TRUE : JNI_FALSE;
  }
  env->SetFloatArrayRegion(starts, 0, count, start_values.data());
  env->SetFloatArrayRegion(durations, 0, count, duration_values.data());
  env->SetBooleanArrayRegion(complete, 0, count, complete_values.data());

  return env->NewObject(transcript_class, transcript_ctor, error, texts, starts, durations,
                        complete);
}

const JNINativeMethod kMethods[] = {
    {"ready", "()Z", reinterpret_cast<void *>(native_ready)},
    {"version", "()I", reinterpret_cast<void *>(native_version)},
    {"errorToString", "(I)Ljava/lang/String;", reinterpret_cast<void *>(native_error_to_string)},
    {"loadTranscriber", "(Ljava/lang/String;I)I",
     reinterpret_cast<void *>(native_load_transcriber)},
    {"freeTranscriber", "(I)V", reinterpret_cast<void *>(native_free_transcriber)},
    {"createStream", "(I)I", reinterpret_cast<void *>(native_create_stream)},
    {"freeStream", "(II)I", reinterpret_cast<void *>(native_free_stream)},
    {"startStream", "(II)I", reinterpret_cast<void *>(native_start_stream)},
    {"stopStream", "(II)I", reinterpret_cast<void *>(native_stop_stream)},
    {"addAudio", "(II[FII)I", reinterpret_cast<void *>(native_add_audio)},
    {"transcribeStream", "(II)Lcom/nutq/nutq/NativeTranscript;",
     reinterpret_cast<void *>(native_transcribe_stream)},
};

}  // namespace

extern "C" JNIEXPORT jint JNI_OnLoad(JavaVM *vm, void *) {
  JNIEnv *env = nullptr;
  if (vm->GetEnv(reinterpret_cast<void **>(&env), JNI_VERSION_1_6) != JNI_OK) return JNI_ERR;

  jclass native_class = env->FindClass(kClass);
  jclass local_transcript = env->FindClass(kTranscriptClass);
  jclass local_bytes = env->FindClass("[B");
  if (native_class == nullptr || local_transcript == nullptr || local_bytes == nullptr) {
    return JNI_ERR;
  }
  transcript_class = static_cast<jclass>(env->NewGlobalRef(local_transcript));
  byte_array_class = static_cast<jclass>(env->NewGlobalRef(local_bytes));
  transcript_ctor = env->GetMethodID(transcript_class, "<init>", "(I[[B[F[F[Z)V");
  if (transcript_ctor == nullptr) return JNI_ERR;

  constexpr jint method_count = sizeof(kMethods) / sizeof(kMethods[0]);
  if (env->RegisterNatives(native_class, kMethods, method_count) != JNI_OK) return JNI_ERR;

  // Registered even when the C API is missing, so Kotlin can ask ready()
  // and fail with a message instead of crashing on the first call.
  api_ready = load_api();
  return JNI_VERSION_1_6;
}
