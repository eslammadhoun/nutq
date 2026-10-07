package com.nutq.nutq

import android.Manifest
import android.app.Activity
import android.content.Context
import android.content.pm.PackageManager
import android.os.Build
import androidx.core.app.ActivityCompat
import androidx.core.content.ContextCompat
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.embedding.engine.plugins.activity.ActivityAware
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel

/**
 * A job's presence outside the app, on the same channel as
 * ios/Runner/JobBridge.swift (`BackgroundJob` in Dart): runs [JobService] for
 * the length of a media job, keeps its notification current, and forwards the
 * notification's buttons to Dart as commands. Ported from whisper_playground.
 *
 * Every word the notification shows comes from Dart (`labels` in `begin`),
 * already in the app's language.
 */
class JobPlugin : FlutterPlugin, ActivityAware, MethodChannel.MethodCallHandler {
    companion object {
        private const val CHANNEL = "nutq/background_job"
        private const val PERMISSION_REQUEST = 7301
    }

    private lateinit var context: Context
    private lateinit var channel: MethodChannel
    private var activity: Activity? = null
    private var active = false
    private var state = JobState()

    override fun onAttachedToEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        context = binding.applicationContext
        channel = MethodChannel(binding.binaryMessenger, CHANNEL).apply {
            setMethodCallHandler(this@JobPlugin)
        }
        JobService.onCommand = { command -> channel.invokeMethod("command", command) }
    }

    override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        // Dart is gone and the job with it; nothing is left to show.
        JobService.onCommand = null
        if (active) JobService.stop(context)
        active = false
        channel.setMethodCallHandler(null)
    }

    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        when (call.method) {
            "begin" -> {
                active = true
                @Suppress("UNCHECKED_CAST")
                state = JobState(
                    title = call.argument<String>("title") ?: "Nutq",
                    labels = (call.argument<Map<String, String>>("labels") ?: emptyMap()),
                )
                requestNotificationPermission()
                JobService.clearResult(context)
                JobService.start(context, state)
            }
            "update" -> if (active) {
                state = state.copy(
                    progress = call.argument<Double>("progress") ?: state.progress,
                    durationSeconds = call.argument<Double>("duration") ?: state.durationSeconds,
                )
                JobService.update(context, state)
            }
            "setPhase" -> if (active) {
                state = state.copy(phase = call.argument<String>("phase") ?: state.phase, paused = false)
                JobService.update(context, state)
            }
            "setPaused" -> if (active) {
                state = state.copy(paused = call.argument<Boolean>("paused") ?: false)
                JobService.update(context, state)
            }
            "end" -> if (active) {
                active = false
                JobService.stop(context)
                if (call.argument<Boolean>("completed") == true && !AppVisibility.foreground) {
                    JobService.postResult(context, state)
                }
            }
            else -> {
                result.notImplemented()
                return
            }
        }
        result.success(null)
    }

    /**
     * Android 13+ hides notifications, the progress one included, until the
     * user allows them. Asked when the first job starts, when it is obvious
     * why; the job runs either way.
     */
    private fun requestNotificationPermission() {
        if (Build.VERSION.SDK_INT < Build.VERSION_CODES.TIRAMISU) return
        val activity = activity ?: return
        val permission = Manifest.permission.POST_NOTIFICATIONS
        if (ContextCompat.checkSelfPermission(activity, permission) != PackageManager.PERMISSION_GRANTED) {
            ActivityCompat.requestPermissions(activity, arrayOf(permission), PERMISSION_REQUEST)
        }
    }

    override fun onAttachedToActivity(binding: ActivityPluginBinding) {
        activity = binding.activity
    }

    override fun onDetachedFromActivityForConfigChanges() {
        activity = null
    }

    override fun onReattachedToActivityForConfigChanges(binding: ActivityPluginBinding) {
        activity = binding.activity
    }

    override fun onDetachedFromActivity() {
        activity = null
    }
}

/** Whether the app's screen is showing, for the "summary ready" notice. */
object AppVisibility {
    @Volatile
    var foreground = false
}
