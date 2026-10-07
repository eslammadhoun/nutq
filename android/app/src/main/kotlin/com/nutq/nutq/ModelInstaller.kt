package com.nutq.nutq

import android.content.Context
import android.util.Log
import java.io.File
import java.io.FileOutputStream
import java.io.IOException
import java.util.Locale

/**
 * Makes a bundled Moonshine model available as real files.
 *
 * Moonshine loads models from a directory, but APK assets are not files, so
 * each model is copied out once, on first use. It goes to the no-backup
 * folder: 30-45 MB per model has no business in the user's cloud backup, and
 * the APK can always provide it again.
 *
 * A stamp records which install of the app the copy came from, so an update
 * that ships new weights replaces the old copy rather than using it.
 */
object ModelInstaller {
    private const val ASSET_ROOT = "moonshine_models"
    private const val STAMP = ".installed"

    /** Resolves [model] to a directory: absolute paths as-is, bare names from the APK. */
    @Synchronized
    fun resolve(context: Context, model: String): File {
        if (model.startsWith("/")) return File(model)

        val root = File(context.noBackupFilesDir, ASSET_ROOT)
        val target = File(root, model)
        val version = installVersion(context)
        if (File(target, STAMP).readTextOrNull() == version) return target

        val assetDir = "$ASSET_ROOT/$model"
        val files = context.assets.list(assetDir).orEmpty()
        if (files.isEmpty()) throw IOException("no bundled model '$model' (assets/$assetDir)")

        // Copied into a scratch folder and renamed into place, so a copy cut
        // short by a kill never looks like an installed model.
        val started = System.nanoTime()
        val scratch = File(root, ".$model.partial").apply { deleteRecursively(); mkdirs() }
        var bytes = 0L
        for (name in files) {
            context.assets.open("$assetDir/$name").use { input ->
                FileOutputStream(File(scratch, name)).use { output ->
                    bytes += input.copyTo(output, 1 shl 20)
                    output.fd.sync()
                }
            }
        }
        File(scratch, STAMP).writeText(version)
        target.deleteRecursively()
        if (!scratch.renameTo(target)) throw IOException("could not install model '$model'")

        Log.i(
            "moonshine",
            "installed model=$model %.1fMB in %.2fs".format(
                Locale.ROOT,
                bytes / 1_048_576.0, (System.nanoTime() - started) / 1e9,
            ),
        )
        return target
    }

    /** Changes on every install or update of the app. */
    private fun installVersion(context: Context): String {
        val info = context.packageManager.getPackageInfo(context.packageName, 0)
        return info.lastUpdateTime.toString()
    }

    private fun File.readTextOrNull(): String? = if (isFile) readText() else null
}
