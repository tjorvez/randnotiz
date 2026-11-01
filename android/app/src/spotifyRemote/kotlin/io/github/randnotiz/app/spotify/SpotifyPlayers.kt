package io.github.randnotiz.app.spotify

import android.app.Activity
import android.os.Handler
import android.os.Looper
import android.util.Log
import com.spotify.android.appremote.api.ConnectionParams
import com.spotify.android.appremote.api.Connector
import com.spotify.android.appremote.api.SpotifyAppRemote
import com.spotify.protocol.client.CallResult
import com.spotify.protocol.client.Subscription
import com.spotify.protocol.types.Empty
import com.spotify.protocol.types.PlayerState
import io.github.randnotiz.app.BuildConfig

/** Built with the App Remote SDK: plays and pauses inside Spotify. */
object SpotifyPlayers {
    fun create(activity: Activity, clientId: String, redirectUri: String): SpotifyPlayer =
        AppRemotePlayer(activity, clientId, redirectUri)
}

/**
 * Connects to the Spotify app on first use and disconnects when the
 * activity stops. The permission to control Spotify comes from the login
 * (scope app-remote-control, see SpotifyBridge).
 */
private class AppRemotePlayer(
    private val activity: Activity,
    private val clientId: String,
    private val redirectUri: String,
) : SpotifyPlayer {
    override val canControl = true
    override var onState: ((String?, Boolean) -> Unit)? = null

    private var remote: SpotifyAppRemote? = null
    private var subscription: Subscription<PlayerState>? = null
    private val waiting = mutableListOf<(SpotifyAppRemote?, String?) -> Unit>()
    private var connecting = false
    private val main = Handler(Looper.getMainLooper())

    /** Counts connection attempts: a late answer to an old one is ignored. */
    private var attempt = 0

    init {
        SpotifyAppRemote.setDebugMode(BuildConfig.DEBUG)
    }

    private fun withRemote(action: (SpotifyAppRemote?, String?) -> Unit) {
        val current = remote
        if (current != null && current.isConnected) {
            action(current, null)
            return
        }
        waiting.add(action)
        if (connecting) return
        connecting = true
        val thisAttempt = ++attempt
        Log.i(TAG, "connecting to Spotify")
        // Spotify may never answer (e.g. the system froze it in the
        // background): give up after a while instead of waiting forever.
        main.postDelayed({
            if (connecting && attempt == thisAttempt) {
                Log.w(TAG, "connection timed out")
                connecting = false
                attempt++
                flush(null, "timeout")
            }
        }, CONNECT_TIMEOUT_MS)
        val params = ConnectionParams.Builder(clientId)
            .setRedirectUri(redirectUri)
            // Never Spotify's own permission view: it would be opened from
            // the background and blocked by Android, and the connection
            // would hang. Without permission the connection fails at once
            // (notAuthorized) and SpotifyBridge asks through the login.
            .showAuthView(false)
            .build()
        SpotifyAppRemote.connect(
            activity,
            params,
            object : Connector.ConnectionListener {
                override fun onConnected(appRemote: SpotifyAppRemote) {
                    if (attempt != thisAttempt) {
                        SpotifyAppRemote.disconnect(appRemote)
                        return
                    }
                    Log.i(TAG, "connected")
                    connecting = false
                    remote = appRemote
                    subscription = appRemote.playerApi.subscribeToPlayerState()
                        .setEventCallback { state ->
                            onState?.invoke(state.track?.uri, state.isPaused)
                        }
                    flush(appRemote, null)
                }

                override fun onFailure(error: Throwable) {
                    if (attempt != thisAttempt) return
                    Log.w(TAG, "connection failed: ${error.javaClass.simpleName} ${error.message}")
                    connecting = false
                    remote = null
                    flush(null, errorCode(error))
                }
            },
        )
    }

    private fun flush(appRemote: SpotifyAppRemote?, error: String?) {
        val actions = waiting.toList()
        waiting.clear()
        actions.forEach { it(appRemote, error) }
    }

    private fun run(
        done: (String?) -> Unit,
        call: (SpotifyAppRemote) -> CallResult<Empty>,
    ) = withRemote { appRemote, error ->
        if (appRemote == null) {
            done(error ?: "notConnected")
            return@withRemote
        }
        call(appRemote)
            .setResultCallback { done(null) }
            .setErrorCallback {
                Log.w(TAG, "call failed: ${it.javaClass.simpleName} ${it.message}")
                done(errorCode(it))
            }
    }

    override fun play(uri: String, done: (String?) -> Unit) =
        run(done) { it.playerApi.play(uri) }

    override fun pause(done: (String?) -> Unit) = run(done) { it.playerApi.pause() }

    override fun resume(done: (String?) -> Unit) = run(done) { it.playerApi.resume() }

    override fun disconnect() {
        if (connecting) {
            // Abandons the attempt: callers learn it now, not never.
            connecting = false
            attempt++
            flush(null, "notConnected")
        }
        subscription?.cancel()
        subscription = null
        remote?.let { SpotifyAppRemote.disconnect(it) }
        remote = null
    }

    /** Short, stable codes for the Flutter side (class names of the SDK). */
    private fun errorCode(error: Throwable): String = when (error.javaClass.simpleName) {
        "CouldNotFindSpotifyApp" -> "notInstalled"
        "NotLoggedInException" -> "notLoggedIn"
        "UserNotAuthorizedException" -> "notAuthorized"
        "AuthenticationFailedException" -> "notAuthorized"
        "OfflineModeException" -> "offline"
        else -> error.javaClass.simpleName.ifEmpty { "failed" }
    }

    private companion object {
        const val TAG = "RandnotizSpotify"
        const val CONNECT_TIMEOUT_MS = 20_000L
    }
}
