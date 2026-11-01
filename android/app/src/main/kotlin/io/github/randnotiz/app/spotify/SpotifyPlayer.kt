package io.github.randnotiz.app.spotify

/**
 * Plays songs in the installed Spotify app. Two implementations, chosen at
 * build time (see android/app/build.gradle.kts): App Remote (play, pause,
 * player state – needs the App Remote SDK in android/app/libs/) or a plain
 * deep link that opens the song in Spotify.
 */
interface SpotifyPlayer {
    /** Whether playback can be controlled (pause/resume, state updates). */
    val canControl: Boolean

    /** Called with the URI of the current track and whether it is paused. */
    var onState: ((uri: String?, paused: Boolean) -> Unit)?

    /** Each call reports null on success or an error code. */
    fun play(uri: String, done: (String?) -> Unit)
    fun pause(done: (String?) -> Unit)
    fun resume(done: (String?) -> Unit)

    /** Releases the connection (activity stopped). */
    fun disconnect()
}
