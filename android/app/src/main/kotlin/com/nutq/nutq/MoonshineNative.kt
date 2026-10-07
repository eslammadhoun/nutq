package com.nutq.nutq

/**
 * Moonshine's C API, through the app's own JNI layer (src/main/cpp).
 *
 * Moonshine's Java binding is not used: it copies every line's audio into
 * the JVM on each pass. See nutq_moonshine.cpp.
 */
object MoonshineNative {
    /** `MOONSHINE_MODEL_ARCH_TINY_STREAMING` in moonshine-c-api.h. */
    const val MODEL_ARCH_TINY_STREAMING = 2

    /** Why the native libraries could not be loaded, or null if they were. */
    val loadError: String? = try {
        // Dependency order: our layer finds libmoonshine.so with dlopen, and
        // libmoonshine.so needs libonnxruntime.so.
        System.loadLibrary("onnxruntime")
        System.loadLibrary("moonshine")
        System.loadLibrary("nutq_moonshine")
        if (ready()) null else "libmoonshine.so is missing part of the C API"
    } catch (e: UnsatisfiedLinkError) {
        e.message ?: e.toString()
    }

    @JvmStatic external fun ready(): Boolean
    @JvmStatic external fun version(): Int
    @JvmStatic external fun errorToString(code: Int): String
    @JvmStatic external fun loadTranscriber(path: String, modelArch: Int): Int
    @JvmStatic external fun freeTranscriber(handle: Int)
    @JvmStatic external fun createStream(handle: Int): Int
    @JvmStatic external fun freeStream(handle: Int, stream: Int): Int
    @JvmStatic external fun startStream(handle: Int, stream: Int): Int
    @JvmStatic external fun stopStream(handle: Int, stream: Int): Int

    /** Appends the first [count] samples of [samples] to the stream, uncopied. */
    @JvmStatic external fun addAudio(
        handle: Int,
        stream: Int,
        samples: FloatArray,
        count: Int,
        sampleRate: Int,
    ): Int

    /** Runs one analysis pass; null only if the JVM ran out of memory. */
    @JvmStatic external fun transcribeStream(handle: Int, stream: Int): NativeTranscript?
}

/**
 * One analysis pass: each line's text, timing and completion, but not its
 * audio. Built by nutq_moonshine.cpp; the constructor signature is fixed there.
 */
class NativeTranscript(
    @JvmField val error: Int,
    texts: Array<ByteArray>,
    @JvmField val starts: FloatArray,
    @JvmField val durations: FloatArray,
    @JvmField val complete: BooleanArray,
) {
    /** Decoded as UTF-8, with invalid sequences replaced rather than fatal. */
    val texts: List<String> = texts.map { String(it, Charsets.UTF_8).trim() }

    val lineCount: Int get() = texts.size

    /** Index of the last line Moonshine has finished with, or -1. */
    fun lastCompleteIndex(): Int = complete.indexOfLast { it }

    /** End of line [index] in seconds from the start of the stream. */
    fun endOf(index: Int): Double = starts[index].toDouble() + durations[index].toDouble()
}
