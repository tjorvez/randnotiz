import 'package:flutter/foundation.dart';

import '../../notes/domain/song.dart';

/// A search hit: a song plus the addresses of its cover (downloaded only
/// when the song is linked).
@immutable
class SongCandidate {
  const SongCandidate({
    required this.uri,
    required this.title,
    required this.artist,
    this.album,
    this.coverUrl,
    this.thumbnailUrl,
  });

  final String uri;
  final String title;
  final String artist;
  final String? album;

  /// A large cover (600 px), stored with the note.
  final String? coverUrl;

  /// A small cover (100 px) for the result list.
  final String? thumbnailUrl;

  Song toSong({String? coverFile}) =>
      Song(uri: uri, title: title, artist: artist, coverFile: coverFile);

  @override
  String toString() => 'SongCandidate($title – $artist, $uri)';
}
