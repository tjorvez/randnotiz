import 'package:flutter/foundation.dart';

/// What the preview player is doing.
enum PreviewStatus { idle, loading, playing, paused }

@immutable
class PreviewState {
  const PreviewState({this.uri, this.status = PreviewStatus.idle});

  static const idle = PreviewState();

  /// The song whose preview is loaded (null when idle).
  final String? uri;
  final PreviewStatus status;

  /// [songUri] is loading or playing (the record turns).
  bool isActive(String songUri) =>
      uri == songUri &&
      (status == PreviewStatus.playing || status == PreviewStatus.loading);

  @override
  bool operator ==(Object other) =>
      other is PreviewState && other.uri == uri && other.status == status;

  @override
  int get hashCode => Object.hash(uri, status);

  @override
  String toString() => 'PreviewState($uri, $status)';
}

/// Streams 30-second previews (one at a time). Previews are never cached.
abstract interface class PreviewPlayer {
  /// The current state; repeats the latest state to new listeners.
  Stream<PreviewState> get states;

  PreviewState get state;

  /// Plays [url] as the preview of [songUri] from the start (stops
  /// whatever played before). Throws `MusicException` if it cannot.
  Future<void> play(String songUri, Uri url);

  Future<void> pause();

  /// Continues a paused preview.
  Future<void> resume();

  /// Stops and unloads the preview.
  Future<void> stop();

  Future<void> dispose();
}
