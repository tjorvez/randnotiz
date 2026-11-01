import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;

import '../domain/music_service.dart';
import '../domain/song.dart';

/// Spotify through the Android bridge (login and playback in the Spotify
/// app, see `SpotifyBridge.kt`) and the Web API (search).
///
/// The access token lives only in memory; when it expires, the Spotify app
/// hands out a new one without asking again.
class SpotifyMusicService implements MusicService {
  SpotifyMusicService(
    this._http, {
    this._channel = const MethodChannel(_channelName),
    this._events = const EventChannel('$_channelName/player'),
    DateTime Function()? clock,
    this.timeout = const Duration(seconds: 15),
  }) : _clock = clock ?? DateTime.now;

  static const _channelName = 'io.github.randnotiz.app/spotify';
  static final _api = Uri.parse('https://api.spotify.com/v1/search');

  final http.Client _http;
  final MethodChannel _channel;
  final EventChannel _events;
  final DateTime Function() _clock;

  /// Longest wait for an answer of the Web API.
  final Duration timeout;

  String? _token;
  DateTime _tokenExpires = DateTime.fromMillisecondsSinceEpoch(0);
  Future<String>? _authorizing;
  Stream<PlaybackState>? _playback;

  @override
  Future<MusicStatus> status() async {
    try {
      final map = await _channel.invokeMapMethod<String, Object?>('status');
      if (map == null) return MusicStatus.off;
      return MusicStatus(
        configured: map['configured'] == true,
        installed: map['installed'] == true,
        canControl: map['canControl'] == true,
      );
    } on MissingPluginException {
      return MusicStatus.off;
    } on PlatformException {
      return MusicStatus.off;
    }
  }

  Future<String> _accessToken({bool renew = false}) {
    final token = _token;
    // A minute of margin: a search must not run into the expiry.
    if (!renew &&
        token != null &&
        _clock().isBefore(_tokenExpires.subtract(const Duration(minutes: 1)))) {
      return Future.value(token);
    }
    return _authorizing ??= _authorize().whenComplete(
      () => _authorizing = null,
    );
  }

  Future<String> _authorize() async {
    final Map<String, Object?>? map;
    try {
      map = await _channel.invokeMapMethod<String, Object?>('authorize');
    } on PlatformException catch (e) {
      debugPrint('Spotify login failed: ${e.code} ${e.message}');
      throw MusicException(
        e.code == 'auth' ? MusicException.notAuthorized : e.code,
        detail: e.message,
      );
    }
    final token = map?['accessToken'];
    if (token is! String || token.isEmpty) {
      throw const MusicException(MusicException.cancelled);
    }
    final seconds = map?['expiresIn'];
    _token = token;
    _tokenExpires = _clock().add(
      Duration(seconds: seconds is int && seconds > 0 ? seconds : 3600),
    );
    return token;
  }

  @override
  Future<List<SongCandidate>> search(String query) async {
    final q = query.trim();
    if (q.isEmpty) return const [];
    final uri = _api.replace(
      queryParameters: {
        'q': q,
        'type': 'track',
        // The maximum for apps in development mode (since 2026). No
        // market: with a user token Spotify uses the account's country.
        'limit': '10',
      },
    );
    Future<http.Response> get(String token) => _http
        .get(uri, headers: {'Authorization': 'Bearer $token'})
        .timeout(timeout);

    try {
      var response = await get(await _accessToken());
      if (response.statusCode == 401) {
        response = await get(await _accessToken(renew: true));
      }
      if (response.statusCode != 200) {
        final detail = errorMessage(response.bodyBytes);
        // A token Spotify refuses (e.g. missing scope) is not tried again.
        if (response.statusCode == 403) _token = null;
        debugPrint('Spotify search failed: ${response.statusCode} $detail');
        throw MusicException(
          MusicException.http(response.statusCode),
          detail: detail,
        );
      }
      return parseSearch(utf8.decode(response.bodyBytes));
    } on FormatException {
      // Not the JSON Spotify promised (e.g. a captive portal's page).
      throw const MusicException(MusicException.network);
    } on http.ClientException {
      throw const MusicException(MusicException.network);
    } on TimeoutException {
      throw const MusicException(MusicException.network);
    }
  }

  /// Spotify's error text (`{"error": {"message": …}}`), if any.
  @visibleForTesting
  static String? errorMessage(List<int> body) {
    try {
      final json = jsonDecode(utf8.decode(body));
      final error = json is Map ? json['error'] : null;
      final message = error is Map ? error['message'] : error;
      return message is String && message.isNotEmpty ? message : null;
    } on FormatException {
      return null;
    }
  }

  /// The tracks of a Web API search answer (public for tests).
  @visibleForTesting
  static List<SongCandidate> parseSearch(String body) {
    final json = jsonDecode(body);
    final items =
        ((json is Map ? json['tracks'] : null) as Map?)?['items'] as List? ??
        const [];
    return [
      for (final item in items.whereType<Map<String, Object?>>())
        if (item['uri'] case final String uri when uri.startsWith('spotify:'))
          _candidate(uri, item),
    ];
  }

  static SongCandidate _candidate(String uri, Map<String, Object?> item) {
    final artists = [
      for (final a in (item['artists'] as List? ?? const []))
        if (a is Map && a['name'] is String) a['name'] as String,
    ];
    final album = item['album'] as Map?;
    final images = [
      for (final i in (album?['images'] as List? ?? const []))
        if (i is Map && i['url'] is String)
          (url: i['url'] as String, width: (i['width'] as num?)?.toInt() ?? 0),
    ]..sort((a, b) => b.width.compareTo(a.width));
    return SongCandidate(
      uri: uri,
      title: (item['name'] as String?)?.trim() ?? '',
      artist: artists.join(', '),
      album: album?['name'] as String?,
      coverUrl: images.isEmpty ? null : images.first.url,
      thumbnailUrl: images.isEmpty ? null : images.last.url,
    );
  }

  @override
  Future<Uint8List?> downloadCover(String url) async {
    final uri = Uri.tryParse(url);
    // Covers come from Spotify's image servers only.
    if (uri == null || uri.scheme != 'https' || !isSpotifyImageHost(uri.host)) {
      return null;
    }
    try {
      final response = await _http
          .get(uri)
          .timeout(const Duration(seconds: 15));
      return response.statusCode == 200 ? response.bodyBytes : null;
    } on Exception {
      return null;
    }
  }

  /// scdn.co or one of its subdomains (not merely ending in "scdn.co").
  @visibleForTesting
  static bool isSpotifyImageHost(String host) =>
      host == 'scdn.co' || host.endsWith('.scdn.co');

  Future<void> _call(String method, [Map<String, Object?>? args]) async {
    try {
      await _channel.invokeMethod<bool>(method, args);
    } on PlatformException catch (e) {
      throw MusicException(e.code);
    } on MissingPluginException {
      throw const MusicException(MusicException.notConfigured);
    }
  }

  @override
  Future<void> play(String uri) => _call('play', {'uri': uri});

  @override
  Future<void> pause() => _call('pause');

  @override
  Future<void> resume() => _call('resume');

  @override
  Stream<PlaybackState> get playback => _playback ??= _events
      .receiveBroadcastStream()
      .map((event) {
        final map = event is Map ? event : const {};
        return PlaybackState(
          uri: map['uri'] as String?,
          paused: map['paused'] != false,
        );
      })
      .distinct()
      .asBroadcastStream();
}
