import 'dart:async';

import 'package:randnotiz/features/music/domain/preview_player.dart';

/// Records what the app asks of the player; the test can end a preview.
class FakePreviewPlayer implements PreviewPlayer {
  final calls = <String>[];
  final _states = StreamController<PreviewState>.broadcast();
  PreviewState _state = PreviewState.idle;

  @override
  PreviewState get state => _state;

  @override
  Stream<PreviewState> get states async* {
    yield _state;
    yield* _states.stream;
  }

  void emit(PreviewState next) {
    _state = next;
    _states.add(next);
  }

  @override
  Future<void> play(String songUri, Uri url) async {
    calls.add('play $url');
    emit(PreviewState(uri: songUri, status: PreviewStatus.playing));
  }

  @override
  Future<void> pause() async {
    calls.add('pause');
    emit(PreviewState(uri: _state.uri, status: PreviewStatus.paused));
  }

  @override
  Future<void> resume() async {
    calls.add('resume');
    emit(PreviewState(uri: _state.uri, status: PreviewStatus.playing));
  }

  @override
  Future<void> stop() async {
    calls.add('stop');
    emit(PreviewState.idle);
  }

  @override
  Future<void> dispose() async => _states.close();
}
