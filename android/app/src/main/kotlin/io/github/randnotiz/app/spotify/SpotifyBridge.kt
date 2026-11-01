package io.github.randnotiz.app.spotify

import android.content.pm.PackageManager
import android.util.Log
import androidx.activity.ComponentActivity
import androidx.activity.result.ActivityResultLauncher
import androidx.activity.result.contract.ActivityResultContracts
import com.spotify.sdk.android.auth.AuthorizationClient
import com.spotify.sdk.android.auth.AuthorizationRequest
import com.spotify.sdk.android.auth.AuthorizationResponse
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodChannel
import io.github.randnotiz.app.BuildConfig

/**
 * Spotify for the Flutter side (channel `io.github.randnotiz.app/spotify`):
 *
 * * `status` → configured (client id built in), installed (Spotify app),
 *   canControl (App Remote SDK built in)
 * * `authorize` → access token for the Web API search, obtained through the
 *   installed Spotify app (token flow, no client secret); falls back to
 *   the browser if the app cannot be used
 * * `play` (uri), `pause`, `resume`
 *
 * Player state updates (`uri`, `paused`) arrive on the event channel
 * `io.github.randnotiz.app/spotify/player`.
 *
 * Must be created in the activity's onCreate (it registers for an
 * activity result).
 */
class SpotifyBridge(private val activity: ComponentActivity) {

    private val clientId = BuildConfig.SPOTIFY_CLIENT_ID
    private val redirectUri = BuildConfig.SPOTIFY_REDIRECT_URI
    private val player: SpotifyPlayer = SpotifyPlayers.create(activity, clientId, redirectUri)
    private var events: EventChannel.EventSink? = null

    /** Waiting for the login activity: gets its response (null = none). */
    private var pendingLogin: ((AuthorizationResponse?) -> Unit)? = null

    private val login: ActivityResultLauncher<android.content.Intent> =
        activity.registerForActivityResult(ActivityResultContracts.StartActivityForResult()) {
            val callback = pendingLogin ?: return@registerForActivityResult
            pendingLogin = null
            val response = AuthorizationClient.getResponse(it.resultCode, it.data)
            // Diagnostics only: type and error, never the token.
            Log.i(TAG, "login: resultCode=${it.resultCode} type=${response.type} error=${response.error}")
            callback(response)
        }

    init {
        player.onState = { uri, paused ->
            events?.success(mapOf("uri" to uri, "paused" to paused))
        }
    }

    fun attach(messenger: BinaryMessenger) {
        MethodChannel(messenger, CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                "status" -> result.success(
                    mapOf(
                        "configured" to clientId.isNotEmpty(),
                        "installed" to isSpotifyInstalled(),
                        "canControl" to player.canControl,
                    ),
                )
                "authorize" -> authorize(result)
                "play" -> {
                    val uri = call.argument<String>("uri")
                    if (uri == null || !uri.startsWith("spotify:")) {
                        result.error("args", "spotify uri required", null)
                    } else {
                        play(uri, result)
                    }
                }
                "pause" -> player.pause { answer(result, it) }
                "resume" -> player.resume { answer(result, it) }
                else -> result.notImplemented()
            }
        }
        EventChannel(messenger, PLAYER_CHANNEL).setStreamHandler(
            object : EventChannel.StreamHandler {
                override fun onListen(arguments: Any?, sink: EventChannel.EventSink) {
                    events = sink
                }

                override fun onCancel(arguments: Any?) {
                    events = null
                }
            },
        )
    }

    /** The activity stopped: let go of the connection to Spotify. */
    fun onStop() = player.disconnect()

    private fun answer(result: MethodChannel.Result, error: String?) {
        activity.runOnUiThread {
            if (error == null) result.success(true) else result.error(error, null, null)
        }
    }

    /**
     * Plays [uri]. If Spotify has not yet allowed Randnotiz to control it,
     * asks for that permission first – through the login activity, opened
     * from Randnotiz in the foreground. App Remote's own permission view
     * cannot be used: Spotify would have to open it from the background,
     * which Android (10+) blocks, so the connection would never finish.
     */
    private fun play(uri: String, result: MethodChannel.Result) {
        player.play(uri) { error ->
            if (error != "notAuthorized" || clientId.isEmpty()) {
                answer(result, error)
                return@play
            }
            Log.i(TAG, "playback needs permission: logging in")
            activity.runOnUiThread {
                login { response ->
                    if (response == null) {
                        answer(result, "cancelled")
                        return@login
                    }
                    // Tried again whatever the login reported: on some
                    // devices Spotify stores the permission but answers
                    // "empty" – the second connection tells for sure.
                    player.play(uri) { answer(result, it) }
                }
            }
        }
    }

    private fun authorize(result: MethodChannel.Result) {
        if (clientId.isEmpty()) {
            result.error("notConfigured", null, null)
            return
        }
        login { response ->
            when (response?.type) {
                AuthorizationResponse.Type.TOKEN -> result.success(
                    mapOf(
                        "accessToken" to response.accessToken,
                        "expiresIn" to response.expiresIn,
                    ),
                )
                AuthorizationResponse.Type.CANCELLED, null -> result.success(null)
                else -> result.error("auth", response.error ?: response.type.name, null)
            }
        }
    }

    /**
     * Opens Spotify's login (a no-op screen if everything was allowed
     * before). An earlier, unanswered login is answered with null.
     */
    private fun login(callback: (AuthorizationResponse?) -> Unit) {
        pendingLogin?.invoke(null)
        pendingLogin = callback
        // Since 2026 the Web API rejects tokens without any scope
        // ("Insufficient client scope"), even for the search: the smallest
        // one is asked for (country and subscription of the account), plus
        // the permission to control playback in the Spotify app.
        val request = AuthorizationRequest.Builder(
            clientId,
            AuthorizationResponse.Type.TOKEN,
            redirectUri,
        ).setScopes(SCOPES).build()
        login.launch(AuthorizationClient.createLoginActivityIntent(activity, request))
    }

    private fun isSpotifyInstalled(): Boolean = try {
        activity.packageManager.getPackageInfo(SPOTIFY_PACKAGE, 0)
        true
    } catch (e: PackageManager.NameNotFoundException) {
        false
    }

    private companion object {
        const val CHANNEL = "io.github.randnotiz.app/spotify"
        const val PLAYER_CHANNEL = "io.github.randnotiz.app/spotify/player"
        const val SPOTIFY_PACKAGE = "com.spotify.music"
        const val TAG = "RandnotizSpotify"
        val SCOPES = arrayOf("user-read-private", "app-remote-control")
    }
}
