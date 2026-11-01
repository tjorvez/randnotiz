package io.github.randnotiz.app.spotify

import android.app.Activity
import android.content.ActivityNotFoundException
import android.content.Intent
import android.net.Uri

/** Built without the App Remote SDK: songs open in the Spotify app. */
object SpotifyPlayers {
    fun create(activity: Activity, clientId: String, redirectUri: String): SpotifyPlayer =
        DeepLinkPlayer(activity)
}

private class DeepLinkPlayer(private val activity: Activity) : SpotifyPlayer {
    override val canControl = false
    override var onState: ((String?, Boolean) -> Unit)? = null

    override fun play(uri: String, done: (String?) -> Unit) {
        try {
            activity.startActivity(
                Intent(Intent.ACTION_VIEW, Uri.parse(uri))
                    .putExtra(
                        Intent.EXTRA_REFERRER,
                        Uri.parse("android-app://${activity.packageName}"),
                    ),
            )
            done(null)
        } catch (e: ActivityNotFoundException) {
            done("notInstalled")
        }
    }

    override fun pause(done: (String?) -> Unit) = done("unsupported")
    override fun resume(done: (String?) -> Unit) = done("unsupported")
    override fun disconnect() {}
}
