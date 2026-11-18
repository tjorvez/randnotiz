import 'package:flutter/foundation.dart';

import 'song_candidate.dart';

/// Where a linked song can be heard right now: Apple's 30-second preview
/// (streamed, never stored) and its page in Apple Music.
@immutable
class SongLinks {
  const SongLinks({required this.storeUrl, this.previewUrl});

  /// The song in Apple Music (opens the app or the browser).
  final Uri storeUrl;

  /// The preview, null if Apple offers none for this song.
  final Uri? previewUrl;
}

/// A failed music action. [code] is one of the constants below.
class MusicException implements Exception {
  const MusicException(this.code, {this.detail});

  final String code;

  /// More detail for diagnosis, if any.
  final String? detail;

  static const network = 'network';

  /// The song is not (or no longer) available in this country.
  static const notFound = 'notFound';

  /// Apple has no preview for this song.
  static const noPreview = 'noPreview';

  /// The preview could not be played.
  static const playback = 'playback';

  /// The API answered with an error status ([httpStatus]).
  static String http(int status) => 'http$status';

  /// The HTTP status of an API error, or null.
  int? get httpStatus =>
      code.startsWith('http') ? int.tryParse(code.substring(4)) : null;

  @override
  String toString() =>
      'MusicException($code${detail == null ? '' : ': $detail'})';
}

/// Finds songs (iTunes Search API) and where to hear them.
abstract interface class MusicService {
  /// Songs matching [query], best matches first.
  Future<List<SongCandidate>> search(String query);

  /// The cover image of a search hit (JPEG), null if it cannot be loaded.
  Future<Uint8List?> downloadCover(String url);

  /// Preview and store page of the linked song [uri] (asked fresh each
  /// time: Apple's terms forbid storing previews).
  Future<SongLinks> links(String uri);

  /// The page that offers [uri] in other streaming services (song.link).
  Uri otherServicesUrl(String uri);
}
