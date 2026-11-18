import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../../notes/domain/song.dart';
import '../domain/music_service.dart';
import '../domain/song_candidate.dart';

/// Songs from Apple's iTunes Search API: no account, no key. Apple allows
/// about 20 requests a minute per client (search is debounced) and asks
/// that covers and previews are shown next to a link to Apple Music.
class ItunesMusicService implements MusicService {
  ItunesMusicService(
    this._http, {
    String? country,
    this.timeout = const Duration(seconds: 15),
  }) : country = _validCountry(country);

  static const _host = 'itunes.apple.com';

  final http.Client _http;

  /// Two-letter store country (upper case), e.g. `DE`.
  final String country;

  /// Longest wait for an answer.
  final Duration timeout;

  /// Lookups of this session: a song played again needs no new request.
  final _links = <int, SongLinks>{};

  static String _validCountry(String? code) =>
      code != null && RegExp(r'^[A-Za-z]{2}$').hasMatch(code)
      ? code.toUpperCase()
      : 'DE';

  @override
  Future<List<SongCandidate>> search(String query) async {
    final term = query.trim();
    if (term.isEmpty) return const [];
    final body = await _get(
      Uri.https(_host, '/search', {
        'term': term,
        'media': 'music',
        'entity': 'song',
        'limit': '15',
        'country': country,
      }),
    );
    return parseSearch(body);
  }

  @override
  Future<SongLinks> links(String uri) async {
    final id = Song.trackIdOf(uri);
    if (id == null) throw const MusicException(MusicException.notFound);
    final known = _links[id];
    if (known != null) return known;
    final body = await _get(
      Uri.https(_host, '/lookup', {'id': '$id', 'country': country}),
    );
    final links = parseLookup(body, id, country: country);
    _links[id] = links;
    return links;
  }

  @override
  Uri otherServicesUrl(String uri) {
    final id = Song.trackIdOf(uri);
    return Uri.https('song.link', id == null ? '/' : '/i/$id');
  }

  @override
  Future<Uint8List?> downloadCover(String url) async {
    final uri = Uri.tryParse(url);
    // Covers come from Apple's image servers only.
    if (uri == null || uri.scheme != 'https' || !isAppleImageHost(uri.host)) {
      return null;
    }
    try {
      final response = await _http.get(uri).timeout(timeout);
      return response.statusCode == 200 ? response.bodyBytes : null;
    } on Exception {
      return null;
    }
  }

  Future<String> _get(Uri uri) async {
    final http.Response response;
    try {
      response = await _http.get(uri).timeout(timeout);
    } on http.ClientException catch (e) {
      throw MusicException(MusicException.network, detail: e.message);
    } on TimeoutException {
      throw const MusicException(MusicException.network, detail: 'timeout');
    }
    if (response.statusCode != 200) {
      debugPrint('iTunes ${uri.path} failed: ${response.statusCode}');
      throw MusicException(MusicException.http(response.statusCode));
    }
    return utf8.decode(response.bodyBytes, allowMalformed: true);
  }

  static List<Map<String, Object?>> _results(String body) {
    final Object? json;
    try {
      json = jsonDecode(body);
    } on FormatException {
      // Not the JSON Apple promised (e.g. a captive portal's page).
      throw const MusicException(MusicException.network, detail: 'no json');
    }
    final results = json is Map ? json['results'] : null;
    return [
      if (results is List)
        for (final r in results)
          if (r is Map<String, Object?> && r['kind'] == 'song') r,
    ];
  }

  /// The songs of a search answer (public for tests).
  @visibleForTesting
  static List<SongCandidate> parseSearch(String body) => [
    for (final r in _results(body))
      if ((r['trackId'], r['trackName']) case (
        final int id,
        final String title,
      ))
        SongCandidate(
          uri: Song.itunesUri(id),
          title: title.trim(),
          artist: (r['artistName'] as String?)?.trim() ?? '',
          album: (r['collectionName'] as String?)?.trim(),
          coverUrl: artworkUrl(r['artworkUrl100'], 600),
          thumbnailUrl: artworkUrl(r['artworkUrl100'], 100),
        ),
  ];

  /// The links of a lookup answer for track [id] (public for tests).
  @visibleForTesting
  static SongLinks parseLookup(String body, int id, {required String country}) {
    final track = _results(body).where((r) => r['trackId'] == id).firstOrNull;
    if (track == null) throw const MusicException(MusicException.notFound);
    final store = _https(track['trackViewUrl']);
    return SongLinks(
      storeUrl:
          store ??
          Uri.https('music.apple.com', '/${country.toLowerCase()}/song/$id'),
      previewUrl: _https(track['previewUrl']),
    );
  }

  static Uri? _https(Object? url) {
    final uri = url is String ? Uri.tryParse(url) : null;
    return uri != null && uri.scheme == 'https' ? uri : null;
  }

  /// [artwork] (Apple's 100 px cover) in [size] × [size] px.
  @visibleForTesting
  static String? artworkUrl(Object? artwork, int size) {
    if (artwork is! String || artwork.isEmpty) return null;
    return artwork.replaceFirst(
      RegExp(r'/\d+x\d+(bb)?\.(jpg|png|webp)$'),
      '/${size}x${size}bb.jpg',
    );
  }

  /// mzstatic.com or one of its subdomains (not merely ending in it).
  @visibleForTesting
  static bool isAppleImageHost(String host) =>
      host == 'mzstatic.com' || host.endsWith('.mzstatic.com');
}
