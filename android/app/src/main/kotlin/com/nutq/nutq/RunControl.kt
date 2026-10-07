package com.nutq.nutq

import android.os.SystemClock
import java.util.concurrent.locks.ReentrantLock
import kotlin.concurrent.withLock

/** Thrown out of the chunk loop once the run is cancelled. */
class TranscriptionCancelled : Exception("Transcription cancelled")

/**
 * Pause and cancel requests for the run in flight. Requests arrive on the
 * main thread; the chunk loop polls them between chunks. A pause parks the
 * loop on a condition rather than spinning, so a paused run costs no CPU.
 *
 * Mirrors `RunControl` in MoonshineBridge.swift.
 */
class RunControl {
    private val lock = ReentrantLock()
    private val changed = lock.newCondition()
    private var cancelled = false
    private var paused = false
    private var pausedTotalMs = 0L

    /** Seconds the current run has spent paused, so timings can leave it out. */
    val pausedSeconds: Double get() = lock.withLock { pausedTotalMs / 1000.0 }

    fun reset() = lock.withLock {
        cancelled = false
        paused = false
        pausedTotalMs = 0
    }

    fun cancel() = lock.withLock {
        cancelled = true
        changed.signalAll() // wake a paused loop so it can stop
    }

    fun setPaused(value: Boolean) = lock.withLock {
        paused = value
        changed.signalAll()
    }

    /**
     * Returns straight away unless paused, in which case it waits for resume or
     * cancel. Throws [TranscriptionCancelled] once the run is cancelled.
     */
    fun checkpoint() = lock.withLock {
        if (paused && !cancelled) {
            val started = SystemClock.elapsedRealtime()
            while (paused && !cancelled) changed.await()
            pausedTotalMs += SystemClock.elapsedRealtime() - started
        }
        if (cancelled) throw TranscriptionCancelled()
    }
}
