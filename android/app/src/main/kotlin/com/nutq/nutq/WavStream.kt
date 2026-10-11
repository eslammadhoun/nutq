package com.nutq.nutq

import java.io.Closeable
import java.io.File
import java.io.IOException
import java.io.RandomAccessFile
import java.nio.ByteBuffer
import java.nio.ByteOrder
import java.nio.channels.FileChannel

/**
 * Reads a 16-bit PCM WAV one chunk at a time, so a two-hour file costs the
 * same memory as a short clip. The app's FFmpeg step always writes 16 kHz mono
 * s16, so anything else is a bug worth surfacing rather than resampling.
 *
 * Mirrors `WavStream` in MoonshineBridge.swift.
 */
class WavStream(path: String) : Closeable {
    private val file = RandomAccessFile(File(path), "r")
    private val channel: FileChannel = file.channel
    private val channels: Int
    private val dataStart: Long
    private var bytesRemaining: Long

    /** Direct buffer reused for every chunk; grown only if a chunk is larger. */
    private var buffer: ByteBuffer = ByteBuffer.allocateDirect(0)

    /** Total frames of audio, i.e. samples per channel. */
    val frameCount: Int

    init {
        try {
            val riff = readExactly(12)
            if (riff.tag(0) != "RIFF" || riff.tag(8) != "WAVE") {
                throw IOException("not a RIFF/WAVE file: $path")
            }

            var channels = 0
            var sampleRate = 0
            var bitsPerSample = 0
            var declaredDataBytes: Long? = null

            // Walk the chunk table, seeking past bodies we do not need.
            while (declaredDataBytes == null) {
                val header = readExactly(8)
                val id = header.tag(0)
                val size = header.getInt(4).toLong() and 0xFFFFFFFFL
                when (id) {
                    "fmt " -> {
                        val body = readExactly(minOf(size, 16L).toInt())
                        channels = body.getShort(2).toInt() and 0xFFFF
                        sampleRate = body.getInt(4)
                        bitsPerSample = body.getShort(14).toInt() and 0xFFFF
                        skip(size - minOf(size, 16L))
                    }
                    "data" -> {
                        // The channel is now positioned at the first audio byte.
                        declaredDataBytes = size
                        continue
                    }
                    else -> skip(size)
                }
                if (size % 2 == 1L) skip(1) // chunks are word-aligned
            }

            if (bitsPerSample != 16) throw IOException("expected 16-bit PCM, got $bitsPerSample-bit")
            if (channels != 1 && channels != 2) throw IOException("expected mono or stereo, got $channels channels")
            if (sampleRate != 16_000) throw IOException("expected 16 kHz, got $sampleRate Hz")

            // A streamed WAV can declare a placeholder size, so trust the file
            // length when it is shorter. A partial trailing frame is dropped.
            dataStart = channel.position()
            val available = channel.size() - dataStart
            val usable = minOf(declaredDataBytes, available)
            val frameBytes = 2 * channels
            this.channels = channels
            frameCount = (usable / frameBytes).toInt()
            bytesRemaining = frameCount.toLong() * frameBytes
        } catch (e: Throwable) {
            file.close()
            throw e
        }
    }

    /** Positions the next [read] at [frame], counted from the start of the audio. */
    fun seek(frame: Int) {
        val target = frame.coerceIn(0, frameCount)
        val frameBytes = 2 * channels
        channel.position(dataStart + target.toLong() * frameBytes)
        bytesRemaining = (frameCount - target).toLong() * frameBytes
    }

    /**
     * Reads up to [maxFrames] frames as normalised floats into [out], returning
     * how many were written. Zero means the audio ended.
     */
    fun read(maxFrames: Int, out: FloatArray): Int {
        val frameBytes = 2 * channels
        val wanted = (minOf(maxFrames.toLong(), bytesRemaining / frameBytes) * frameBytes).toInt()
        if (wanted <= 0) return 0

        if (buffer.capacity() < wanted) {
            buffer = ByteBuffer.allocateDirect(wanted).order(ByteOrder.LITTLE_ENDIAN)
        }
        buffer.clear().limit(wanted)
        while (buffer.hasRemaining()) {
            if (channel.read(buffer) < 0) break
        }
        buffer.flip()
        val read = buffer.remaining()
        // A short read means the file ended early; stop rather than loop forever.
        bytesRemaining = if (read < wanted) 0 else bytesRemaining - read

        val frames = read / frameBytes
        val samples = buffer.asShortBuffer()
        if (channels == 1) {
            for (i in 0 until frames) out[i] = samples.get(i) / 32768f
        } else {
            for (i in 0 until frames) {
                out[i] = (samples.get(2 * i) + samples.get(2 * i + 1)) / 2f / 32768f
            }
        }
        return frames
    }

    override fun close() = file.close()

    private fun readExactly(count: Int): ByteBuffer {
        val bytes = ByteBuffer.allocate(count).order(ByteOrder.LITTLE_ENDIAN)
        while (bytes.hasRemaining()) {
            if (channel.read(bytes) < 0) throw IOException("truncated WAV header")
        }
        bytes.flip()
        return bytes
    }

    private fun skip(count: Long) {
        if (count > 0) channel.position(channel.position() + count)
    }

    private fun ByteBuffer.tag(offset: Int): String =
        String(ByteArray(4) { get(offset + it) }, Charsets.US_ASCII)
}
