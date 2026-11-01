package io.github.randnotiz.app

import android.Manifest
import android.content.Intent
import android.content.pm.PackageManager
import android.net.Uri
import android.os.Bundle
import android.provider.MediaStore
import androidx.activity.result.ActivityResultLauncher
import androidx.activity.result.PickVisualMediaRequest
import androidx.activity.result.contract.ActivityResultContracts
import android.os.Handler
import android.os.Looper
import android.provider.Settings
import android.view.WindowManager
import androidx.core.app.ActivityCompat
import androidx.core.content.ContextCompat
import io.flutter.embedding.android.FlutterFragmentActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import io.github.randnotiz.app.spotify.SpotifyBridge
import java.util.concurrent.Executors

/**
 * FlutterFragmentActivity is required by local_auth (BiometricPrompt).
 *
 * FLAG_SECURE follows the app lock: while the lock is in effect, the app
 * content does not appear in the recents overview, screenshots or screen
 * recordings. Without the lock, screenshots and screen casting are allowed.
 * The last state is remembered so the flag is right before the first frame;
 * on a fresh install the window starts secure until Flutter reports.
 * Only release builds ever set the flag: debug and profile builds keep
 * screenshots possible for development and testing.
 *
 * Also hosts the small microphone-permission bridge used for dictation
 * (channel io.github.randnotiz.app/permissions): status, request, open settings,
 * and the Spotify bridge (see spotify/SpotifyBridge).
 */
class MainActivity : FlutterFragmentActivity() {

    override fun onCreate(savedInstanceState: Bundle?) {
        // Registers for an activity result: before the engine is configured.
        spotify = SpotifyBridge(this)
        val secure = getSharedPreferences(WINDOW_PREFS, MODE_PRIVATE)
            .getBoolean(KEY_SECURE, true)
        if (secure && SECURE_ALLOWED) {
            window.setFlags(
                WindowManager.LayoutParams.FLAG_SECURE,
                WindowManager.LayoutParams.FLAG_SECURE,
            )
        }
        super.onCreate(savedInstanceState)
        pickMedia = registerForActivityResult(ActivityResultContracts.PickVisualMedia()) { uri ->
            onPhotoPicked(uri)
        }
    }

    /** Optional music feature (login, playback in the Spotify app). */
    private lateinit var spotify: SpotifyBridge

    override fun onStop() {
        super.onStop()
        spotify.onStop()
    }

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL)
            .setMethodCallHandler { call, result ->
                when (call.method) {
                    "setSecure" -> {
                        val secure = (call.argument<Boolean>("secure") ?: true) && SECURE_ALLOWED
                        getSharedPreferences(WINDOW_PREFS, MODE_PRIVATE).edit()
                            .putBoolean(KEY_SECURE, secure).apply()
                        if (secure) {
                            window.addFlags(WindowManager.LayoutParams.FLAG_SECURE)
                        } else {
                            window.clearFlags(WindowManager.LayoutParams.FLAG_SECURE)
                        }
                        result.success(true)
                    }
                    "appVersion" -> result.success(BuildConfig.VERSION_NAME)
                    // ".dev" for the test app "Randnotiz Dev" (shares the
                    // Drive backup folder with the real app).
                    "applicationId" -> result.success(BuildConfig.APPLICATION_ID)
                    "googleWebClientId" -> result.success(BuildConfig.GOOGLE_WEB_CLIENT_ID)
                    else -> result.notImplemented()
                }
            }
        spotify.attach(flutterEngine.dartExecutor.binaryMessenger)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, PERMISSION_CHANNEL)
            .setMethodCallHandler { call, result -> handlePermissionCall(call.method, result) }
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, IMAGES_CHANNEL)
            .setMethodCallHandler { call, result ->
                val dest = call.argument<String>("dest")
                val maxSide = call.argument<Int>("maxSide") ?: 1600
                val quality = call.argument<Int>("quality") ?: 88
                if (dest == null) {
                    result.error("args", "dest required", null)
                    return@setMethodCallHandler
                }
                when (call.method) {
                    "importImage" -> {
                        val src = call.argument<String>("src")
                        if (src == null) {
                            result.error("args", "src required", null)
                            return@setMethodCallHandler
                        }
                        runImageJob(result) { ImageTools.importImage(src, dest, maxSide, quality) }
                    }
                    "pickImage" -> {
                        pendingPick?.result?.success(null)
                        pendingPick = PendingPick(result, dest, maxSide, quality)
                        pickMedia.launch(
                            PickVisualMediaRequest(ActivityResultContracts.PickVisualMedia.ImageOnly),
                        )
                    }
                    else -> result.notImplemented()
                }
            }
    }

    // --- photo picker (also shows Google Photos if set as cloud media app) --

    private class PendingPick(
        val result: MethodChannel.Result,
        val dest: String,
        val maxSide: Int,
        val quality: Int,
    )

    private var pendingPick: PendingPick? = null
    private lateinit var pickMedia: ActivityResultLauncher<PickVisualMediaRequest>

    private fun onPhotoPicked(uri: Uri?) {
        val pick = pendingPick ?: return
        pendingPick = null
        if (uri == null) {
            pick.result.success(null) // cancelled
            return
        }
        runImageJob(pick.result) {
            // The picker exposes the capture date even when the file itself
            // has no EXIF date (e.g. photos coming from Google Photos).
            val takenAt = try {
                contentResolver.query(uri, arrayOf(MediaStore.MediaColumns.DATE_TAKEN), null, null, null)
                    ?.use { c -> if (c.moveToFirst() && !c.isNull(0)) c.getLong(0) else null }
            } catch (e: Exception) {
                null
            }?.takeIf { it > 0 }
            ImageTools.importStream(
                { contentResolver.openInputStream(uri) ?: throw IllegalStateException("No stream") },
                pick.dest, pick.maxSide, pick.quality, takenAt,
            )
        }
    }

    /** Runs image work off the UI thread and answers on the main thread. */
    private fun runImageJob(result: MethodChannel.Result, job: () -> Map<String, Any?>) {
        imageExecutor.execute {
            try {
                val info = job()
                mainHandler.post { result.success(info) }
            } catch (e: Exception) {
                mainHandler.post { result.error("image", e.message, null) }
            }
        }
    }

    private val imageExecutor = Executors.newSingleThreadExecutor()
    private val mainHandler = Handler(Looper.getMainLooper())

    // --- microphone permission -------------------------------------------

    private var pendingPermissionResult: MethodChannel.Result? = null

    private fun micStatus(): String {
        val granted = ContextCompat.checkSelfPermission(this, Manifest.permission.RECORD_AUDIO) ==
            PackageManager.PERMISSION_GRANTED
        if (granted) return "granted"
        if (ActivityCompat.shouldShowRequestPermissionRationale(this, Manifest.permission.RECORD_AUDIO)) {
            return "canAsk"
        }
        // Not granted, no rationale: either never asked or "don't ask again".
        val askedBefore = getSharedPreferences(PERMISSION_PREFS, MODE_PRIVATE)
            .getBoolean(KEY_MIC_ASKED, false)
        return if (askedBefore) "permanentlyDenied" else "canAsk"
    }

    private fun handlePermissionCall(method: String, result: MethodChannel.Result) {
        when (method) {
            "micStatus" -> result.success(micStatus())
            "requestMic" -> {
                if (micStatus() == "granted") {
                    result.success("granted")
                    return
                }
                pendingPermissionResult?.success(micStatus())
                pendingPermissionResult = result
                getSharedPreferences(PERMISSION_PREFS, MODE_PRIVATE).edit()
                    .putBoolean(KEY_MIC_ASKED, true).apply()
                ActivityCompat.requestPermissions(
                    this, arrayOf(Manifest.permission.RECORD_AUDIO), REQUEST_MIC,
                )
            }
            "openAppSettings" -> {
                startActivity(
                    Intent(Settings.ACTION_APPLICATION_DETAILS_SETTINGS)
                        .setData(Uri.fromParts("package", packageName, null))
                        .addFlags(Intent.FLAG_ACTIVITY_NEW_TASK),
                )
                result.success(true)
            }
            else -> result.notImplemented()
        }
    }

    override fun onRequestPermissionsResult(
        requestCode: Int,
        permissions: Array<out String>,
        grantResults: IntArray,
    ) {
        super.onRequestPermissionsResult(requestCode, permissions, grantResults)
        if (requestCode == REQUEST_MIC) {
            pendingPermissionResult?.success(micStatus())
            pendingPermissionResult = null
        }
    }

    private companion object {
        const val CHANNEL = "io.github.randnotiz.app/window"
        const val PERMISSION_CHANNEL = "io.github.randnotiz.app/permissions"
        const val IMAGES_CHANNEL = "io.github.randnotiz.app/images"
        const val PERMISSION_PREFS = "randnotiz_permissions"
        const val WINDOW_PREFS = "randnotiz_window"
        const val KEY_SECURE = "secure"
        const val KEY_MIC_ASKED = "mic_asked"
        const val REQUEST_MIC = 4711

        /** FLAG_SECURE is only ever set in release builds. */
        val SECURE_ALLOWED = BuildConfig.BUILD_TYPE == "release"
    }
}
