import 'package:flutter/foundation.dart';

import 'song.dart';

/// What the music feature can do on this device.
@immutable
class MusicStatus {
  const MusicStatus({
    required this.configured,
    required this.installed,
    required this.canControl,
  });

  /// Off: the build carries no Spotify client id (spotify.local.json).
  static const off = MusicStatus(
    configured: false,
    installed: false,
    canControl: false,
  );

  /// The build carries a Spotify client id.
  final bool configured;

  /// The Spotify app is installed (needed for login and playback).
  final bool installed;

  /// Playback can be paused/resumed and followed (App Remote SDK built in);
  /// otherwise a song only opens in Spotify.
  final bool canControl;

  /// Songs can be searched, linked and played.
  bool get usable => configured && installed;
}

/// The track Spotify plays right now.
@immutable
class PlaybackState {
  const PlaybackState({required this.uri, required this.paused});

  final String? uri;
  final bool paused;

  bool isPlaying(String songUri) => uri == songUri && !paused;

  @override
  bool operator ==(Object other) =>
      other is PlaybackState && other.uri == uri && other.paused == paused;

  @override
  int get hashCode => Object.hash(uri, paused);
}

/// A failed music action. [code] is one of the constants below or an
/// unknown code from the platform.
class MusicException implements Exception {
  const MusicException(this.code, {this.detail});

  final String code;

  /// Spotify's own explanation, if it sent one (for diagnosis).
  final String? detail;

  static const cancelled = 'cancelled';
  static const notConfigured = 'notConfigured';
  static const notInstalled = 'notInstalled';
  static const notLoggedIn = 'notLoggedIn';
  static const notAuthorized = 'notAuthorized';
  static const offline = 'offline';
  static const network = 'network';

  /// The Web API answered with an error status ([httpStatus]).
  static String http(int status) => 'http$status';

  /// The HTTP status of a Web API error, or null.
  int? get httpStatus =>
      code.startsWith('http') ? int.tryParse(code.substring(4)) : null;

  @override
  String toString() =>
      'MusicException($code${detail == null ? '' : ': $detail'})';
}

/// Finds songs and plays them in the installed Spotify app.
abstract interface class MusicService {
  Future<MusicStatus> status();

  /// Up to ten tracks matching [query].
  Future<List<SongCandidate>> search(String query);

  /// The cover image of a search hit (JPEG), null if it cannot be loaded.
  Future<Uint8List?> downloadCover(String url);

  Future<void> play(String uri);
  Future<void> pause();
  Future<void> resume();

  /// Changes of what Spotify plays (only with [MusicStatus.canControl]).
  Stream<PlaybackState> get playback;
}

/// Used when the build has no Spotify configuration (and in tests).
class DisabledMusicService implements MusicService {
  const DisabledMusicService();

  @override
  Future<MusicStatus> status() async => MusicStatus.off;

  @override
  Future<List<SongCandidate>> search(String query) =>
      Future.error(const MusicException(MusicException.notConfigured));

  @override
  Future<Uint8List?> downloadCover(String url) async => null;

  @override
  Future<void> play(String uri) =>
      Future.error(const MusicException(MusicException.notConfigured));

  @override
  Future<void> pause() async {}

  @override
  Future<void> resume() async {}

  @override
  Stream<PlaybackState> get playback => const Stream.empty();
}
