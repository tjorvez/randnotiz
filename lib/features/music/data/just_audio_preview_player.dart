import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:just_audio/just_audio.dart';

import '../domain/music_service.dart';
import '../domain/preview_player.dart';

/// Streams previews with just_audio – straight from Apple's servers, never
/// cached (Apple's terms). The underlying player is created on first use.
class JustAudioPreviewPlayer implements PreviewPlayer {
  AudioPlayer? _player;
  StreamSubscription<PlayerState>? _sub;
  final _states = StreamController<PreviewState>.broadcast();
  PreviewState _state = PreviewState.idle;

  @override
  PreviewState get state => _state;

  @override
  Stream<PreviewState> get states async* {
    yield _state;
    yield* _states.stream;
  }

  void _emit(PreviewState next) {
    if (next == _state) return;
    _state = next;
    _states.add(next);
  }

  AudioPlayer get _audio {
    final existing = _player;
    if (existing != null) return existing;
    final player = AudioPlayer();
    _sub = player.playerStateStream.listen(_onPlayerState);
    return _player = player;
  }

  void _onPlayerState(PlayerState s) {
    final uri = _state.uri;
    if (uri == null) return;
    if (s.processingState == ProcessingState.completed) {
      // The 30 seconds are over: back to the start, quietly.
      _emit(PreviewState.idle);
      unawaited(_player?.stop());
      return;
    }
    final status = !s.playing
        ? (_state.status == PreviewStatus.loading
              ? PreviewStatus.loading
              : PreviewStatus.paused)
        : s.processingState == ProcessingState.loading ||
              s.processingState == ProcessingState.buffering
        ? PreviewStatus.loading
        : PreviewStatus.playing;
    _emit(PreviewState(uri: uri, status: status));
  }

  @override
  Future<void> play(String songUri, Uri url) async {
    final player = _audio;
    _emit(PreviewState(uri: songUri, status: PreviewStatus.loading));
    try {
      await player.stop();
      await player.setUrl(url.toString());
      if (_state.uri != songUri) return; // Another song was started meanwhile.
      unawaited(player.play());
    } on Exception catch (e) {
      debugPrint('Preview failed: $e');
      if (_state.uri == songUri) _emit(PreviewState.idle);
      throw MusicException(MusicException.playback, detail: '$e');
    }
  }

  @override
  Future<void> pause() async {
    await _player?.pause();
    if (_state.uri case final uri?) {
      _emit(PreviewState(uri: uri, status: PreviewStatus.paused));
    }
  }

  @override
  Future<void> resume() async {
    final player = _player;
    if (player == null || _state.uri == null) return;
    unawaited(player.play());
  }

  @override
  Future<void> stop() async {
    _emit(PreviewState.idle);
    await _player?.stop();
  }

  @override
  Future<void> dispose() async {
    await _sub?.cancel();
    await _player?.dispose();
    _player = null;
    await _states.close();
  }
}
