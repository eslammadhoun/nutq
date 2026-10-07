package com.nutq.nutq

import android.content.Context
import android.os.Build
import android.os.PowerManager
import android.system.Os
import android.system.OsConstants
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import java.io.File

class MainActivity : FlutterActivity() {
    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        // Not pub packages, so registered by hand rather than by the generated
        // registrant. Same channels as the iOS app.
        flutterEngine.plugins.add(MoonshinePlugin())
        flutterEngine.plugins.add(JobPlugin())

        // Same methods as `nutq/device` in AppDelegate.swift.
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, "nutq/device")
            .setMethodCallHandler { call, result ->
                when (call.method) {
                    // An emulator's GPU is emulated: Gemma there writes about a
                    // token a second, against 20 on the CPU.
                    "isSimulator" -> result.success(isEmulator())
                    "status" -> result.success(
                        mapOf("footprintMB" to residentMegabytes(), "thermal" to thermalState()),
                    )
                    else -> result.notImplemented()
                }
            }
    }

    override fun onResume() {
        super.onResume()
        AppVisibility.foreground = true
        JobService.clearResult(this)
    }

    override fun onPause() {
        AppVisibility.foreground = false
        super.onPause()
    }

    private fun isEmulator(): Boolean =
        Build.HARDWARE.contains("ranchu") || Build.HARDWARE.contains("goldfish") ||
            Build.FINGERPRINT.startsWith("generic") || Build.PRODUCT.contains("sdk")

    /** Resident memory, from /proc: what the low-memory killer looks at. */
    private fun residentMegabytes(): Long = try {
        val pages = File("/proc/self/statm").readText().trim().split(' ')[1].toLong()
        pages * Os.sysconf(OsConstants._SC_PAGESIZE) / 1_048_576
    } catch (e: Exception) {
        -1
    }

    /** In the same words as iOS: nominal, fair, serious, critical. */
    private fun thermalState(): String {
        if (Build.VERSION.SDK_INT < Build.VERSION_CODES.Q) return "nominal"
        val power = getSystemService(Context.POWER_SERVICE) as PowerManager
        return when (power.currentThermalStatus) {
            PowerManager.THERMAL_STATUS_NONE, PowerManager.THERMAL_STATUS_LIGHT -> "nominal"
            PowerManager.THERMAL_STATUS_MODERATE -> "fair"
            PowerManager.THERMAL_STATUS_SEVERE -> "serious"
            else -> "critical"
        }
    }
}
