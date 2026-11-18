import 'package:flutter/foundation.dart';
import 'package:randnotiz/features/music/domain/music_service.dart';
import 'package:randnotiz/features/music/domain/song_candidate.dart';

/// Records what the app asks of Apple; answers with what the test set.
class FakeMusicService implements MusicService {
  FakeMusicService({
    this.results = const [],
    this.cover,
    this.preview,
    this.linksError,
  });

  List<SongCandidate> results;
  Uint8List? cover;

  /// The preview [links] offers (none if null).
  Uri? preview;

  /// Thrown by [links] instead of answering.
  MusicException? linksError;

  final searches = <String>[];
  final lookups = <String>[];

  static final storeUrl = Uri.parse('https://music.apple.com/de/song/1');

  @override
  Future<List<SongCandidate>> search(String query) async {
    searches.add(query);
    return results;
  }

  @override
  Future<Uint8List?> downloadCover(String url) async => cover;

  @override
  Future<SongLinks> links(String uri) async {
    lookups.add(uri);
    if (linksError case final error?) throw error;
    return SongLinks(storeUrl: storeUrl, previewUrl: preview);
  }

  @override
  Uri otherServicesUrl(String uri) => Uri.parse('https://song.link/i/1');
}
