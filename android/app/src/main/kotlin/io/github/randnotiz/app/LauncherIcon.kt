package io.github.randnotiz.app

import android.content.ComponentName
import android.content.Context
import android.content.pm.PackageManager

/**
 * The launcher icon follows the [Season]. Each icon is an activity-alias
 * of MainActivity in AndroidManifest.xml; exactly one is enabled. "Standard" is the manifest
 * default, so it shows only until the app is left for the first time.
 *
 * Switching has side effects, so it only happens when the person has left
 * the app (see MainActivity.onStop), and only when the season changed:
 * Android removes the task that was started through the old alias from the
 * recents, and depending on the launcher the home-screen shortcut moves to
 * the new icon or disappears.
 */
internal object LauncherIcon {

    private const val STANDARD = "IconStandard"
    private val ALIASES = listOf(STANDARD) + Season.entries.map { it.alias }

    /** Enables today's alias and disables the others; nothing if already so. */
    fun update(context: Context) {
        val wanted = Season.now().alias
        val pm = context.packageManager
        // Aliases live in the Kotlin namespace, not under the application ID.
        val namespace = MainActivity::class.java.name.substringBeforeLast('.')
        fun component(alias: String) = ComponentName(context, "$namespace.$alias")
        fun enabled(alias: String) = when (pm.getComponentEnabledSetting(component(alias))) {
            PackageManager.COMPONENT_ENABLED_STATE_ENABLED -> true
            PackageManager.COMPONENT_ENABLED_STATE_DEFAULT -> alias == STANDARD
            else -> false
        }
        val others = ALIASES.filter { it != wanted }
        if (enabled(wanted) && others.none(::enabled)) return
        // Enable first, so there is never a moment without a launcher entry.
        pm.setComponentEnabledSetting(
            component(wanted),
            PackageManager.COMPONENT_ENABLED_STATE_ENABLED,
            PackageManager.DONT_KILL_APP,
        )
        for (alias in others) {
            if (!enabled(alias)) continue
            pm.setComponentEnabledSetting(
                component(alias),
                PackageManager.COMPONENT_ENABLED_STATE_DISABLED,
                PackageManager.DONT_KILL_APP,
            )
        }
    }
}
