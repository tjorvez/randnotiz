import 'package:flutter/foundation.dart';

/// A song linked to a note (schema v8). Only what the note shows is kept:
/// the Spotify URI to play it, title, artist and a local copy of the cover
/// – the note stays complete offline and without Spotify.
@immutable
class Song {
  const Song({
    required this.uri,
    required this.title,
    required this.artist,
    this.coverFile,
  });

  /// Spotify URI, e.g. `spotify:track:4uLU6hMCjMI75M1A2tKUQC`.
  final String uri;
  final String title;

  /// The artists, joined by ", ".
  final String artist;

  /// File name of the stored cover (see `ThumbnailStore.saveCover`), if any.
  final String? coverFile;

  /// The id part of a `spotify:track:<id>` URI, or null.
  static String? trackIdOf(String uri) {
    final parts = uri.split(':');
    return parts.length == 3 && parts[0] == 'spotify' && parts[1] == 'track'
        ? parts[2]
        : null;
  }

  Song copyWith({String? Function()? coverFile}) => Song(
    uri: uri,
    title: title,
    artist: artist,
    coverFile: coverFile != null ? coverFile() : this.coverFile,
  );

  @override
  bool operator ==(Object other) =>
      other is Song &&
      other.uri == uri &&
      other.title == title &&
      other.artist == artist &&
      other.coverFile == coverFile;

  @override
  int get hashCode => Object.hash(uri, title, artist, coverFile);

  @override
  String toString() => 'Song($title – $artist, $uri)';
}

/// A search hit: a song plus the address of its cover (downloaded only
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

  /// The largest cover (~640 px), stored with the note.
  final String? coverUrl;

  /// A small cover (~64 px) for the result list.
  final String? thumbnailUrl;

  Song toSong({String? coverFile}) =>
      Song(uri: uri, title: title, artist: artist, coverFile: coverFile);
}
