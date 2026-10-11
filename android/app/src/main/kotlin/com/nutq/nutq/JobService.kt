package com.nutq.nutq

import android.app.Notification
import android.app.NotificationChannel
import android.app.NotificationManager
import android.app.PendingIntent
import android.app.Service
import android.content.Context
import android.content.Intent
import android.content.pm.ServiceInfo
import android.os.Build
import android.os.IBinder
import android.os.PowerManager
import android.os.Process
import androidx.core.app.NotificationCompat
import androidx.core.app.NotificationManagerCompat
import androidx.core.app.ServiceCompat
import androidx.core.content.ContextCompat
import java.text.NumberFormat
import java.util.Locale

/**
 * Keeps a media job alive while the user is elsewhere, from transcription
 * through the summary, as an ongoing notification with a progress bar and
 * Pause/Resume and Cancel buttons.
 *
 * Android's own answer to what iOS needs a silent-audio workaround for: a
 * foreground service raises the process to foreground priority, and a partial
 * wake lock keeps the CPU running with the screen off. Unlike iOS, Android
 * lets it use the GPU, so the summary carries on in the background too. The
 * work runs in Dart and [MoonshinePlugin]; this service only holds it up.
 * Ported from whisper_playground's TranscriptionService.
 */
class JobService : Service() {
    companion object {
        private const val ACTION_START = "com.nutq.nutq.JOB_START"
        private const val ACTION_STOP = "com.nutq.nutq.JOB_STOP"
        private const val ACTION_COMMAND = "com.nutq.nutq.JOB_COMMAND"
        private const val EXTRA_COMMAND = "command"

        private const val PROGRESS_CHANNEL = "job_progress"
        private const val RESULT_CHANNEL = "job_result"
        private const val PROGRESS_ID = 1
        private const val RESULT_ID = 2

        /** Longer than any job; released at the end anyway. */
        private const val WAKE_LOCK_TIMEOUT_MS = 6 * 60 * 60 * 1000L

        /** What the notification shows. Main thread only. */
        internal var state = JobState()
            private set

        /** Receives the notification's button presses. Main thread only. */
        internal var onCommand: ((String) -> Unit)? = null

        fun start(context: Context, state: JobState) {
            this.state = state
            createChannels(context, state)
            ContextCompat.startForegroundService(
                context,
                Intent(context, JobService::class.java).setAction(ACTION_START),
            )
        }

        /** Redraws the notification; Dart sends at most one update per percent. */
        fun update(context: Context, state: JobState) {
            this.state = state
            if (canNotify(context)) {
                NotificationManagerCompat.from(context).notify(PROGRESS_ID, build(context, state))
            }
        }

        fun stop(context: Context) {
            context.startService(Intent(context, JobService::class.java).setAction(ACTION_STOP))
        }

        /** Says the summary is ready, when the app is not on screen. */
        fun postResult(context: Context, state: JobState) {
            if (!canNotify(context)) return
            createChannels(context, state)
            val notification = NotificationCompat.Builder(context, RESULT_CHANNEL)
                .setSmallIcon(R.drawable.ic_stat_nutq)
                .setContentTitle(state.text("doneTitle"))
                .setContentText(state.text("doneBody"))
                .setContentIntent(openApp(context))
                .setAutoCancel(true)
                .build()
            NotificationManagerCompat.from(context).notify(RESULT_ID, notification)
        }

        fun clearResult(context: Context) = NotificationManagerCompat.from(context).cancel(RESULT_ID)

        private fun canNotify(context: Context) = NotificationManagerCompat.from(context).areNotificationsEnabled()

        private fun createChannels(context: Context, state: JobState) {
            if (Build.VERSION.SDK_INT < Build.VERSION_CODES.O) return
            val manager = context.getSystemService(NotificationManager::class.java)
            manager.createNotificationChannel(
                NotificationChannel(
                    PROGRESS_CHANNEL,
                    state.text("progressChannel").ifEmpty { "Job progress" },
                    NotificationManager.IMPORTANCE_LOW,
                ).apply { setShowBadge(false) },
            )
            manager.createNotificationChannel(
                NotificationChannel(
                    RESULT_CHANNEL,
                    state.text("doneChannel").ifEmpty { "Finished jobs" },
                    NotificationManager.IMPORTANCE_DEFAULT,
                ),
            )
        }

        private fun build(context: Context, state: JobState): Notification {
            val builder = NotificationCompat.Builder(context, PROGRESS_CHANNEL)
                .setSmallIcon(R.drawable.ic_stat_nutq)
                .setContentTitle(state.title)
                .setContentText(state.text(if (state.paused) "paused" else state.phase))
                .setContentIntent(openApp(context))
                .setOngoing(true)
                .setOnlyAlertOnce(true)
                .setSilent(true)
                .setCategory(NotificationCompat.CATEGORY_PROGRESS)
                // Shown straight away rather than after Android's 10 s grace.
                .setForegroundServiceBehavior(NotificationCompat.FOREGROUND_SERVICE_IMMEDIATE)
            if (state.progress <= 0.0) {
                builder.setProgress(0, 0, true)
            } else {
                builder.setProgress(100, state.percent, false)
            }
            // Only transcription can pause; the summary runs to the end.
            if (state.phase == "transcribing") {
                builder.addAction(
                    if (state.paused) {
                        action(context, R.drawable.ic_stat_play, state.text("resumeAction"), "resume")
                    } else {
                        action(context, R.drawable.ic_stat_pause, state.text("pauseAction"), "pause")
                    },
                )
            }
            builder.addAction(action(context, R.drawable.ic_stat_close, state.text("cancelAction"), "cancel"))
            return builder.build()
        }

        private fun action(context: Context, icon: Int, label: String, command: String) =
            NotificationCompat.Action(
                icon,
                label,
                PendingIntent.getService(
                    context,
                    command.hashCode(),
                    Intent(context, JobService::class.java)
                        .setAction(ACTION_COMMAND)
                        .putExtra(EXTRA_COMMAND, command),
                    PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE,
                ),
            )

        private fun openApp(context: Context): PendingIntent = PendingIntent.getActivity(
            context,
            0,
            context.packageManager.getLaunchIntentForPackage(context.packageName)!!
                .addFlags(Intent.FLAG_ACTIVITY_SINGLE_TOP),
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE,
        )
    }

    private var wakeLock: PowerManager.WakeLock? = null

    override fun onBind(intent: Intent?): IBinder? = null

    override fun onStartCommand(intent: Intent?, flags: Int, startId: Int): Int {
        when (intent?.action) {
            ACTION_START -> goForeground()
            ACTION_COMMAND -> intent.getStringExtra(EXTRA_COMMAND)?.let { onCommand?.invoke(it) }
            ACTION_STOP -> shutDown()
            // Restarted by the system after the process died: the job died with
            // it and is marked interrupted when the app next opens.
            null -> shutDown()
        }
        return START_NOT_STICKY
    }

    private fun goForeground() {
        val notification = build(this, state)
        // The platform call, not ServiceCompat.startForeground: on Android 14+
        // that masks the type with the ones its androidx version knows, which
        // turns mediaProcessing (Android 15) into "none", and Android refuses
        // to start a typeless service for apps targeting 14+.
        when {
            Build.VERSION.SDK_INT >= Build.VERSION_CODES.VANILLA_ICE_CREAM ->
                startForeground(PROGRESS_ID, notification, ServiceInfo.FOREGROUND_SERVICE_TYPE_MEDIA_PROCESSING)
            Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q ->
                startForeground(PROGRESS_ID, notification, ServiceInfo.FOREGROUND_SERVICE_TYPE_DATA_SYNC)
            else -> startForeground(PROGRESS_ID, notification)
        }
        if (wakeLock == null) {
            val power = getSystemService(Context.POWER_SERVICE) as PowerManager
            wakeLock = power.newWakeLock(PowerManager.PARTIAL_WAKE_LOCK, "Nutq:job").apply {
                setReferenceCounted(false)
                acquire(WAKE_LOCK_TIMEOUT_MS)
            }
        }
    }

    private fun shutDown() {
        wakeLock?.let { if (it.isHeld) it.release() }
        wakeLock = null
        ServiceCompat.stopForeground(this, ServiceCompat.STOP_FOREGROUND_REMOVE)
        stopSelf()
    }

    /**
     * The user swiped the app away. As on iOS, that ends the job: the process
     * goes, and the next launch marks the job interrupted. Without this the
     * service would keep the process alive with no UI to receive the result.
     */
    override fun onTaskRemoved(rootIntent: Intent?) {
        shutDown()
        Process.killProcess(Process.myPid())
    }

    /** Android 15+ ends these service types after 6 hours a day. */
    override fun onTimeout(startId: Int, fgsType: Int) {
        onCommand?.invoke("pause")
        shutDown()
    }

    override fun onDestroy() {
        wakeLock?.let { if (it.isHeld) it.release() }
        super.onDestroy()
    }
}

/** What the progress notification shows. */
data class JobState(
    val title: String = "Nutq",
    /** Dart's strings for the notification, in the app's language. */
    val labels: Map<String, String> = emptyMap(),
    /** `transcribing`, `summarizing` or `waitingForApp`. */
    val phase: String = "transcribing",
    val progress: Double = 0.0,
    val paused: Boolean = false,
    val durationSeconds: Double = 0.0,
) {
    val percent: Int get() = (progress * 100).toInt().coerceIn(0, 100)

    /** The label [key] with its `{percent}` and `{title}` filled in. */
    fun text(key: String): String {
        val locale = Locale.forLanguageTag(labels["locale"] ?: "en")
        val percentText = NumberFormat.getPercentInstance(locale).format(percent / 100.0)
        return (labels[key] ?: "")
            .replace("{percent}", percentText)
            .replace("{title}", title)
    }
}
