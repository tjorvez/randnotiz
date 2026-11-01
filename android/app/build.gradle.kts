import java.io.FileInputStream
import java.util.Properties
import java.net.URI

plugins {
    id("com.android.application")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

// Release signing: uses the upload key from android/key.properties if that
// file exists (never committed, see README.md, "Signieren"). Otherwise the release
// build is signed with the debug key, which is fine for private use.
val keystorePropertiesFile = rootProject.file("key.properties")
val keystoreProperties = Properties().apply {
    if (keystorePropertiesFile.exists()) {
        FileInputStream(keystorePropertiesFile).use { load(it) }
    }
}
val hasUploadKey = keystorePropertiesFile.exists()

// Spotify (optional): client id and redirect URI come from spotify.local.json
// in the project root (never committed, see spotify.example.json and the
// README). Without it the app builds and runs without the music feature.
val spotifyConfigFile = rootProject.file("../spotify.local.json")
@Suppress("UNCHECKED_CAST")
val spotifyConfig: Map<String, Any?> = if (spotifyConfigFile.exists()) {
    groovy.json.JsonSlurper().parse(spotifyConfigFile) as Map<String, Any?>
} else {
    emptyMap()
}
val spotifyClientId = (spotifyConfig["clientId"] as? String).orEmpty().trim()
val spotifyRedirectUri = (spotifyConfig["redirectUri"] as? String).orEmpty().trim()
    .ifEmpty { "randnotiz://spotify-callback" }
val spotifyRedirect = URI(spotifyRedirectUri)

// Google Drive backup (optional): the web OAuth client id (serverClientId for
// google_sign_in) comes from google.local.json in the project root (never
// committed, see google.example.json and README.md). Without it the backup
// stays switched off. The Android client ids are matched by package name and
// SHA-1 on Google's side and need no entry here.
val googleConfigFile = rootProject.file("../google.local.json")
@Suppress("UNCHECKED_CAST")
val googleConfig: Map<String, Any?> = if (googleConfigFile.exists()) {
    groovy.json.JsonSlurper().parse(googleConfigFile) as Map<String, Any?>
} else {
    emptyMap()
}
val googleWebClientId = (googleConfig["webClientId"] as? String).orEmpty().trim()

// The Spotify App Remote SDK (plays songs in the installed Spotify app) is
// not on Maven and may not be redistributed: download it into
// android/app/libs/ (see README). Without it, songs open in Spotify instead.
val spotifyAppRemoteAar = file("libs/spotify-app-remote-release-0.8.0.aar")
val hasSpotifyAppRemote = spotifyAppRemoteAar.exists()

// Development only: a separate app "Randnotiz Dev"
// (io.github.randnotiz.app.dev) with its own, empty database – for trying out
// changes without touching the real diary.
//
// `-P randnotizDev=true` applies to debug and profile builds only (signed with
// the debug key). A plain release build must never turn into the test app by
// accident – a property set in ~/.gradle/gradle.properties or via
// ORG_GRADLE_PROJECT_randnotizDev would otherwise rename every release.
//
// `-P randnotizDevRelease=true` is the deliberate exception: the release build
// becomes the test app as well. It behaves exactly like the real release
// (FLAG_SECURE, no debug switches) – that is the point: testing the upload key,
// its SHA-1 in the Cloud Console and a restore without touching the real
// diary. It must be signed with the upload key from key.properties (no silent
// fallback to the debug key) and is never built as an App Bundle.
val devInstall = project.hasProperty("randnotizDev")
val devReleaseValue = project.findProperty("randnotizDevRelease")?.toString()?.trim()?.lowercase()
val devRelease = when (devReleaseValue) {
    null, "false" -> false
    "true" -> true
    else -> throw GradleException(
        "randnotizDevRelease: bitte ausdrücklich -P randnotizDevRelease=true angeben " +
            "(erhalten: \"$devReleaseValue\").",
    )
}
if (devRelease) {
    val missing = listOf("storeFile", "storePassword", "keyAlias", "keyPassword")
        .filter { keystoreProperties.getProperty(it).isNullOrBlank() }
    val storeFile = keystoreProperties.getProperty("storeFile")
        ?.takeIf { it.isNotBlank() }
        ?.let { file(it) } // same resolution as signingConfigs below
    val problem = when {
        !hasUploadKey -> "android/key.properties fehlt."
        missing.isNotEmpty() -> "In android/key.properties fehlt: ${missing.joinToString()}."
        storeFile == null || !storeFile.exists() ->
            "Der Keystore aus android/key.properties (storeFile) wurde nicht gefunden: $storeFile"
        else -> null
    }
    if (problem != null) {
        throw GradleException(
            "-P randnotizDevRelease=true muss mit dem Upload-Schlüssel signiert werden. " +
                "$problem Ohne ihn würde mit dem Debug-Schlüssel signiert – das ist für " +
                "diese Variante bewusst ausgeschlossen. Einrichtung: README.md, Abschnitt „Signieren“.",
        )
    }
    if (gradle.startParameter.taskNames.any { it.contains("bundle", ignoreCase = true) }) {
        throw GradleException(
            "-P randnotizDevRelease=true baut nur APKs zum Testen, kein App Bundle für den Play Store.",
        )
    }
    logger.lifecycle(
        "Randnotiz Dev (io.github.randnotiz.app.dev) – Release-Build, signiert mit dem Upload-Schlüssel.",
    )
}

android {
    namespace = "io.github.randnotiz.app"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    // BuildConfig.BUILD_TYPE tells MainActivity whether FLAG_SECURE may be set.
    buildFeatures {
        buildConfig = true
    }

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    defaultConfig {
        applicationId = "io.github.randnotiz.app"
        // You can update the following values to match your application needs.
        // For more information, see: https://flutter.dev/to/review-gradle-config.
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        // Uses the version code from pubspec.yaml. When using split APKs, 1000 * ABI_VERSION
        // is added automatically by Flutter. (https://developer.android.com/studio/build/configure-apk-splits#configure-APK-versions)
        // You can force using the value of versionCode by specifying the `-P force-version-code-ignoring-abi=true`
        // flag during build.
        versionCode = flutter.versionCode
        versionName = flutter.versionName
        manifestPlaceholders["appLabel"] = "@string/app_name"
        manifestPlaceholders["spotifyRedirectScheme"] = spotifyRedirect.scheme ?: "randnotiz"
        manifestPlaceholders["spotifyRedirectHost"] = spotifyRedirect.host ?: "spotify-callback"
        manifestPlaceholders["spotifyRedirectPath"] =
            spotifyRedirect.path.orEmpty().ifEmpty { ".*" }
        buildConfigField("String", "SPOTIFY_CLIENT_ID", "\"$spotifyClientId\"")
        buildConfigField("String", "SPOTIFY_REDIRECT_URI", "\"$spotifyRedirectUri\"")
        buildConfigField("String", "GOOGLE_WEB_CLIENT_ID", "\"$googleWebClientId\"")
    }

    // Playback through App Remote if its SDK is present, else a deep link.
    sourceSets.getByName("main").kotlin.directories.add(
        if (hasSpotifyAppRemote) "src/spotifyRemote/kotlin" else "src/spotifyDeepLink/kotlin",
    )

    signingConfigs {
        if (hasUploadKey) {
            create("release") {
                keyAlias = keystoreProperties.getProperty("keyAlias")
                keyPassword = keystoreProperties.getProperty("keyPassword")
                storeFile = file(keystoreProperties.getProperty("storeFile"))
                storePassword = keystoreProperties.getProperty("storePassword")
            }
        }
    }

    buildTypes {
        release {
            signingConfig = if (hasUploadKey) {
                signingConfigs.getByName("release")
            } else {
                signingConfigs.getByName("debug")
            }
        }
    }
}

// The dev install: debug and profile builds with -P randnotizDev, every build
// type (including release) only with -P randnotizDevRelease=true.
android.buildTypes.configureEach {
    if ((devInstall && name != "release") || devRelease) {
        applicationIdSuffix = ".dev"
        manifestPlaceholders["appLabel"] = "Randnotiz Dev"
    }
}

dependencies {
    implementation("com.spotify.android:auth:5.0.0")
    if (hasSpotifyAppRemote) {
        implementation(files(spotifyAppRemoteAar))
        implementation("com.google.code.gson:gson:2.11.0")
    }
}

kotlin {
    compilerOptions {
        jvmTarget = org.jetbrains.kotlin.gradle.dsl.JvmTarget.JVM_17
    }
}

flutter {
    source = "../.."
}
