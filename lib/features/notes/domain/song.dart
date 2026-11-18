import 'package:flutter/foundation.dart';

/// A song linked to a note (schema v8). Only what the note shows is kept:
/// the iTunes track id (in [uri]), title, artist and a local copy of the
/// cover – the note stays complete offline. The 30-second preview is never
/// stored; it is looked up and streamed from Apple each time.
@immutable
class Song {
  const Song({
    required this.uri,
    required this.title,
    required this.artist,
    this.coverFile,
  });

  /// `itunes:track:<id>`, see [itunesUri].
  final String uri;
  final String title;

  /// The artist as the iTunes Search API names it.
  final String artist;

  /// File name of the stored cover (see `ThumbnailStore.saveCover`), if any.
  final String? coverFile;

  static const _prefix = 'itunes:track:';

  /// The [uri] of the iTunes track [trackId].
  static String itunesUri(int trackId) => '$_prefix$trackId';

  /// The id of an `itunes:track:<id>` URI, or null for anything else.
  static int? trackIdOf(String uri) => uri.startsWith(_prefix)
      ? int.tryParse(uri.substring(_prefix.length))
      : null;

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
