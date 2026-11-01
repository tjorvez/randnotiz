# Release builds are shrunk with R8 (Flutter adds this file automatically).

# Spotify App Remote SDK (optional, downloaded into android/app/libs/, see
# README). It references Jackson and its own annotation classes without
# shipping them; it uses its Gson mappers at runtime. Without these lines R8
# aborts every release build while the SDK is present ("Missing class …").
-dontwarn com.fasterxml.jackson.**
-dontwarn com.spotify.base.annotations.**

# The SDK maps its protocol types to JSON by reflection (Gson) – renamed
# fields would break playback state and commands.
-keep class com.spotify.protocol.** { *; }
-keep class com.spotify.android.appremote.** { *; }
