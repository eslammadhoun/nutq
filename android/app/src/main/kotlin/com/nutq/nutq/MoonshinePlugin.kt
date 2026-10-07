package com.nutq.nutq

import android.content.Context
import android.os.Build
import android.os.Handler
import android.os.Looper
import android.os.PowerManager
import android.os.SystemClock
import android.system.Os
import android.system.OsConstants
import android.util.Log
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import java.io.File
import java.util.Locale
import java.util.concurrent.ExecutorService
import java.util.concurrent.Executors

/**
 * Moonshine transcription for Dart, on the same channels as
 * ios/Runner/MoonshineBridge.swift, so the Dart side is shared.
 *
 * A finished file is fed through Moonshine's streaming API in chunks, which is
 * what gives a real progress fraction, live text and cancellation. The run is
 * split across [STREAM_ROTATION_SECONDS]-long streams, because a stream keeps
 * the raw audio of every line it produced until it is freed; one stream over a
 * 2.5-hour file ran an iPhone out of memory. The swap happens at the end of the
 * last completed line, and the next stream re-reads the file from there, so no
 * word is cut at the seam.
 */
class MoonshinePlugin : FlutterPlugin, MethodChannel.MethodCallHandler, EventChannel.StreamHandler {
    companion object {
        private const val CHANNEL = "nutq/moonshine"
        private const val TAG = "moonshine"
        private const val SAMPLE_RATE = 16_000
        private const val DEFAULT_CHUNK_SECONDS = 5.0

        /** Caps the audio a stream holds at ~20 MB; see the class comment. */
        private const val STREAM_ROTATION_SECONDS = 300.0

        private const val CANCELLED = "moonshine_cancelled"
        private const val ERROR = "moonshine_error"
    }

    private lateinit var context: Context
    private lateinit var methods: MethodChannel
    private lateinit var progress: EventChannel
    private val main = Handler(Looper.getMainLooper())

    /** Runs transcriptions one at a time, off the main thread. */
    private val worker: ExecutorService = Executors.newSingleThreadExecutor { runnable ->
        Thread(runnable, "moonshine-transcribe")
    }

    private val control = RunControl()

    /** Main thread only. */
    private var progressSink: EventChannel.EventSink? = null

    // Worker thread only.
    private var handle = -1
    private var loadedModelDir: String? = null
    private var furthestFraction = 0.0
    private var unsentFinished = ArrayList<Map<String, Any>>()

    override fun onAttachedToEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        context = binding.applicationContext
        methods = MethodChannel(binding.binaryMessenger, CHANNEL).apply {
            setMethodCallHandler(this@MoonshinePlugin)
        }
        progress = EventChannel(binding.binaryMessenger, "$CHANNEL/progress").apply {
            setStreamHandler(this@MoonshinePlugin)
        }
    }

    override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        // Dart is gone, so nobody can use the result: stop working. The job
        // is marked interrupted on the next launch.
        control.cancel()
        methods.setMethodCallHandler(null)
        progress.setStreamHandler(null)
        worker.execute { releaseTranscriber() }
        worker.shutdown()
    }

    // region EventChannel.StreamHandler

    override fun onListen(arguments: Any?, events: EventChannel.EventSink) {
        progressSink = events
    }

    override fun onCancel(arguments: Any?) {
        progressSink = null
    }

    // endregion

    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        when (call.method) {
            "version" -> {
                val error = MoonshineNative.loadError
                if (error != null) result.error(ERROR, error, null) else result.success(MoonshineNative.version())
            }
            "transcribe" -> startTranscription(call, result)
            "cancel" -> {
                // Only takes effect between chunks, so a run stops within one chunk.
                control.cancel()
                result.success(null)
            }
            "pause" -> {
                control.setPaused(true)
                result.success(null)
            }
            "resume" -> {
                control.setPaused(false)
                result.success(null)
            }
            // For benchmarks, as on iOS: CPU time of the whole app, and heat.
            "cpuSeconds" -> result.success(android.os.Process.getElapsedCpuTime() / 1000.0)
            "thermalState" -> result.success(
                when (thermalState()) {
                    "none", "light" -> "nominal"
                    "moderate" -> "fair"
                    "severe" -> "serious"
                    "unknown" -> "nominal"
                    else -> "critical"
                },
            )
            "release" -> {
                worker.execute { releaseTranscriber() }
                result.success(null)
            }
            else -> result.notImplemented()
        }
    }

    private fun startTranscription(call: MethodCall, result: MethodChannel.Result) {
        val audioPath = call.argument<String>("audioPath")
        val modelPath = call.argument<String>("modelPath")
        if (audioPath == null || modelPath == null) {
            result.error(ERROR, "transcribe requires audioPath and modelPath", null)
            return
        }
        MoonshineNative.loadError?.let {
            result.error(ERROR, "Moonshine could not be loaded: $it", null)
            return
        }
        val keepLoaded = call.argument<Boolean>("keepLoaded") ?: false
        val modelArch = call.argument<Int>("modelArch") ?: MoonshineNative.MODEL_ARCH_TINY_STREAMING
        val chunkSeconds = call.argument<Double>("chunkSeconds") ?: DEFAULT_CHUNK_SECONDS
        // Non-zero when resuming a run the app was killed in the middle of.
        // Dart ints arrive as Integer or Long depending on size.
        val startFrame = (call.argument<Number>("startFrame") ?: 0).toInt()

        // Reset here rather than on the worker so a cancel or pause arriving
        // in between is not swallowed.
        control.reset()

        worker.execute {
            try {
                val segments = transcribe(audioPath, modelPath, modelArch, keepLoaded, chunkSeconds, startFrame)
                main.post { result.success(segments) }
            } catch (e: TranscriptionCancelled) {
                main.post { result.error(CANCELLED, "Transcription cancelled", null) }
            } catch (e: Throwable) {
                Log.e(TAG, "transcription failed", e)
                main.post { result.error(ERROR, e.message ?: e.toString(), null) }
            }
        }
    }

    // region Transcription (worker thread)

    private fun transcribe(
        audioPath: String,
        modelPath: String,
        modelArch: Int,
        keepLoaded: Boolean,
        chunkSeconds: Double,
        startFrame: Int,
    ): List<Map<String, Any>> {
        val openStarted = SystemClock.elapsedRealtimeNanos()
        WavStream(audioPath).use { audio ->
            val openSeconds = secondsSince(openStarted)

            // Model install and load are broken out: the Dart stopwatch
            // includes them, and the first run also copies the model out of
            // the APK.
            val loadStarted = SystemClock.elapsedRealtimeNanos()
            val transcriber = ensureTranscriber(modelPath, modelArch)
            val loadSeconds = secondsSince(loadStarted)

            // Time spent paused is left out, so the figures describe the work.
            val inferStarted = SystemClock.elapsedRealtimeNanos()
            val (segments, streams) = transcribeAsStreams(transcriber, audio, chunkSeconds, startFrame)
            val inferSeconds = secondsSince(inferStarted) - control.pausedSeconds

            // Same fields as the iOS log, so the platforms compare directly.
            // `covered` is the end of the last line as a fraction of the
            // audio: a run that stops early still looks fast, so the RTF only
            // means something next to it.
            val audioSeconds = audio.frameCount.toDouble() / SAMPLE_RATE
            val processedSeconds = audioSeconds - startFrame.toDouble() / SAMPLE_RATE
            val words = segments.sumOf { (it["text"] as String).split(' ').count { w -> w.isNotEmpty() } }
            val lastEnd = segments.lastOrNull()?.let { (it["start"] as Double) + (it["duration"] as Double) } ?: 0.0
            Log.i(
                TAG,
                "[moonshine] model=%s open=%.3fs load=%.3fs infer=%.3fs paused=%.1fs audio=%.1fs from=%.1fs rtf=%.3f lines=%d words=%d covered=%.3f streams=%d thermal=%s rss=%dMB".format(Locale.ROOT, 
                    modelPath, openSeconds, loadSeconds, inferSeconds, control.pausedSeconds,
                    audioSeconds, startFrame.toDouble() / SAMPLE_RATE,
                    if (processedSeconds > 0) inferSeconds / processedSeconds else 0.0,
                    segments.size, words,
                    if (audioSeconds > 0) minOf(lastEnd / audioSeconds, 1.0) else 0.0,
                    streams, thermalState(), residentMegabytes(),
                ),
            )

            if (!keepLoaded) releaseTranscriber()
            return segments
        }
    }

    /**
     * Feeds [audio] from [firstFrame] to the end through successive streams,
     * reporting progress and the transcript as it goes, and returns the lines
     * from [firstFrame] on with times measured from the start of the file.
     */
    private fun transcribeAsStreams(
        transcriber: Int,
        audio: WavStream,
        chunkSeconds: Double,
        firstFrame: Int,
    ): Pair<List<Map<String, Any>>, Int> {
        val chunkFrames = maxOf(1, (chunkSeconds * SAMPLE_RATE).toInt())
        val buffer = FloatArray(chunkFrames)
        val finished = ArrayList<Map<String, Any>>()
        var startFrame = firstFrame.coerceIn(0, audio.frameCount)
        var streams = 0
        furthestFraction = 0.0
        unsentFinished = ArrayList()

        while (true) {
            audio.seek(startFrame)
            val started = SystemClock.elapsedRealtimeNanos()
            val pausedBefore = control.pausedSeconds
            val (lines, resumeFrame) = transcribeOneStream(transcriber, audio, startFrame, chunkFrames, buffer)
            streams += 1
            finished += lines
            unsentFinished.addAll(lines)

            // One line per stream, so a long run shows where its time went.
            // If rtf climbs while thermal rises, the phone is throttling.
            val endFrame = resumeFrame ?: audio.frameCount
            val streamAudio = (endFrame - startFrame).toDouble() / SAMPLE_RATE
            val streamSeconds = secondsSince(started) - (control.pausedSeconds - pausedBefore)
            Log.i(
                TAG,
                "[moonshine] stream %d audio=%.0f-%.0fs infer=%.1fs rtf=%.3f thermal=%s rss=%dMB".format(Locale.ROOT, 
                    streams, startFrame.toDouble() / SAMPLE_RATE, endFrame.toDouble() / SAMPLE_RATE,
                    streamSeconds, if (streamAudio > 0) streamSeconds / streamAudio else 0.0,
                    thermalState(), residentMegabytes(),
                ),
            )

            startFrame = resumeFrame ?: break
        }

        // Flushes the last stream's lines, so the transcript Dart assembled
        // from the events matches the value returned.
        reportProgress(1.0, emptyList(), null)
        return finished to streams
    }

    /**
     * Runs one stream from [startFrame] until the file ends (returning a null
     * resume frame, after draining the tail) or the stream is due to retire
     * (returning its complete lines and where the last of them ends).
     */
    private fun transcribeOneStream(
        transcriber: Int,
        audio: WavStream,
        startFrame: Int,
        chunkFrames: Int,
        buffer: FloatArray,
    ): Pair<List<Map<String, Any>>, Int?> {
        val stream = MoonshineNative.createStream(transcriber)
        if (stream < 0) throw MoonshineException("create_stream", stream)
        try {
            check(MoonshineNative.startStream(transcriber, stream), "start_stream")

            val offset = startFrame.toDouble() / SAMPLE_RATE
            val rotationFrames = (STREAM_ROTATION_SECONDS * SAMPLE_RATE).toInt()
            var fed = 0
            var transcript: NativeTranscript? = null

            while (true) {
                // Blocks here while paused; throws once cancelled.
                control.checkpoint()

                val frames = audio.read(chunkFrames, buffer)
                if (frames == 0) break

                check(MoonshineNative.addAudio(transcriber, stream, buffer, frames, SAMPLE_RATE), "add_audio_to_stream")
                transcript = MoonshineNative.transcribeStream(transcriber, stream)
                    ?: throw OutOfMemoryError("transcribe_stream")
                check(transcript.error, "transcribe_stream")
                fed += frames

                // Where a killed run could pick up: the end of this stream's
                // last finished line, or its start before any has finished.
                val lastComplete = transcript.lastCompleteIndex()
                val endFrame = if (lastComplete >= 0) (transcript.endOf(lastComplete) * SAMPLE_RATE).toInt() else 0
                val live = copySegments(transcript, offset)
                val checkpoint = if (endFrame > 0) {
                    Checkpoint(startFrame + endFrame, copySegments(transcript, offset, lastComplete).size)
                } else {
                    Checkpoint(startFrame, 0)
                }
                reportProgress(
                    if (audio.frameCount > 0) (startFrame + fed).toDouble() / audio.frameCount else 1.0,
                    live,
                    checkpoint,
                )

                // Retire the stream at a line boundary. With no line complete
                // yet (one unbroken stretch of speech) keep going: cutting
                // mid-phrase would lose words.
                if (fed >= rotationFrames && endFrame > 0) {
                    return copySegments(transcript, offset, lastComplete) to startFrame + endFrame
                }
            }

            // Stopping keeps the leftover audio and the final call analyses it
            // even when shorter than the library's 0.5 s throttle, so the tail
            // of the file is not dropped.
            check(MoonshineNative.stopStream(transcriber, stream), "stop_stream")
            transcript = MoonshineNative.transcribeStream(transcriber, stream)
                ?: throw OutOfMemoryError("final drain")
            check(transcript.error, "final drain")
            return copySegments(transcript, offset) to null
        } finally {
            MoonshineNative.freeStream(transcriber, stream)
        }
    }

    private data class Checkpoint(val frame: Int, val stable: Int)

    /**
     * Each event carries only the lines finished since the last one plus the
     * current stream's, so its size does not grow with the file; see
     * `reportProgress` in MoonshineBridge.swift for why that matters.
     */
    private fun reportProgress(fraction: Double, live: List<Map<String, Any>>, checkpoint: Checkpoint?) {
        // A new stream re-reads a few seconds the previous one had already
        // fed, which would move the bar backwards; never report less.
        furthestFraction = maxOf(furthestFraction, fraction.coerceIn(0.0, 1.0))
        val event = HashMap<String, Any>(6).apply {
            put("progress", furthestFraction)
            put("finished", unsentFinished)
            put("live", live)
            if (checkpoint != null) {
                put("checkpointFrame", checkpoint.frame)
                put("stable", checkpoint.stable)
            }
        }
        unsentFinished = ArrayList()
        main.post { progressSink?.success(event) }
    }

    /**
     * The transcript's non-empty lines up to and including [throughLine] (all
     * of them by default), shifted by [offset] seconds so times count from the
     * start of the file rather than the stream.
     */
    private fun copySegments(
        transcript: NativeTranscript,
        offset: Double,
        throughLine: Int = transcript.lineCount - 1,
    ): List<Map<String, Any>> {
        val segments = ArrayList<Map<String, Any>>(throughLine + 1)
        for (i in 0..throughLine) {
            val text = transcript.texts[i]
            if (text.isEmpty()) continue
            segments += mapOf(
                "text" to text,
                "start" to offset + transcript.starts[i],
                "duration" to transcript.durations[i].toDouble(),
            )
        }
        return segments
    }

    /** Loads the model unless it is already resident. */
    private fun ensureTranscriber(model: String, modelArch: Int): Int {
        val dir = ModelInstaller.resolve(context, model).absolutePath
        if (handle >= 0 && loadedModelDir == dir) return handle
        releaseTranscriber()
        val loaded = MoonshineNative.loadTranscriber(dir, modelArch)
        if (loaded < 0) throw MoonshineException("load $dir", loaded)
        handle = loaded
        loadedModelDir = dir
        return loaded
    }

    private fun releaseTranscriber() {
        if (handle >= 0) {
            MoonshineNative.freeTranscriber(handle)
            handle = -1
            loadedModelDir = null
        }
    }

    // endregion

    private fun check(code: Int, what: String) {
        if (code != 0) throw MoonshineException(what, code)
    }

    private class MoonshineException(what: String, code: Int) :
        Exception("$what: ${MoonshineNative.errorToString(code)}")

    private fun secondsSince(startNanos: Long) = (SystemClock.elapsedRealtimeNanos() - startNanos) / 1e9

    /** How hot the device is; from `severe` up it throttles the CPU. */
    private fun thermalState(): String {
        if (Build.VERSION.SDK_INT < Build.VERSION_CODES.Q) return "unknown"
        val power = context.getSystemService(Context.POWER_SERVICE) as PowerManager
        return when (power.currentThermalStatus) {
            PowerManager.THERMAL_STATUS_NONE -> "none"
            PowerManager.THERMAL_STATUS_LIGHT -> "light"
            PowerManager.THERMAL_STATUS_MODERATE -> "moderate"
            PowerManager.THERMAL_STATUS_SEVERE -> "severe"
            PowerManager.THERMAL_STATUS_CRITICAL -> "critical"
            PowerManager.THERMAL_STATUS_EMERGENCY -> "emergency"
            PowerManager.THERMAL_STATUS_SHUTDOWN -> "shutdown"
            else -> "unknown"
        }
    }

    /** Resident memory, from /proc: what the low-memory killer looks at. */
    private fun residentMegabytes(): Long = try {
        val pages = File("/proc/self/statm").readText().trim().split(' ')[1].toLong()
        // Not always 4 KB: devices launching with Android 15 may use 16 KB pages.
        pages * Os.sysconf(OsConstants._SC_PAGESIZE) / 1_048_576
    } catch (e: Exception) {
        -1
    }
}
