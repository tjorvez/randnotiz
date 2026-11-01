import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:randnotiz/features/music/domain/music_service.dart';
import 'package:randnotiz/features/music/domain/song.dart';

/// Records what the app asks of Spotify; the test drives the player state.
class FakeMusicService implements MusicService {
  FakeMusicService({
    this.status_ = const MusicStatus(
      configured: true,
      installed: true,
      canControl: true,
    ),
    this.results = const [],
    this.cover,
  });

  final MusicStatus status_;
  List<SongCandidate> results;
  Uint8List? cover;

  final searches = <String>[];
  final calls = <String>[];
  final _playback = StreamController<PlaybackState>.broadcast();

  void emit(PlaybackState state) => _playback.add(state);

  @override
  Future<MusicStatus> status() async => status_;

  @override
  Future<List<SongCandidate>> search(String query) async {
    searches.add(query);
    return results;
  }

  @override
  Future<Uint8List?> downloadCover(String url) async => cover;

  @override
  Future<void> play(String uri) async => calls.add('play $uri');

  @override
  Future<void> pause() async => calls.add('pause');

  @override
  Future<void> resume() async => calls.add('resume');

  @override
  Stream<PlaybackState> get playback => _playback.stream;
}
