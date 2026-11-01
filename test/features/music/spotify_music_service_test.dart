import 'dart:async';
import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:randnotiz/features/music/data/spotify_music_service.dart';
import 'package:randnotiz/features/music/domain/music_service.dart';
import 'package:randnotiz/features/music/domain/song.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  const channel = MethodChannel('test/spotify');
  final messenger =
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;

  final searchAnswer = jsonEncode({
    'tracks': {
      'items': [
        {
          'uri': 'spotify:track:4uLU6hMCjMI75M1A2tKUQC',
          'name': 'Never Gonna Give You Up',
          'artists': [
            {'name': 'Rick Astley'},
          ],
          'album': {
            'name': 'Whenever You Need Somebody',
            'images': [
              {'url': 'https://i.scdn.co/image/small', 'width': 64},
              {'url': 'https://i.scdn.co/image/large', 'width': 640},
              {'url': 'https://i.scdn.co/image/mid', 'width': 300},
            ],
          },
        },
        {
          'uri': 'spotify:track:duet',
          'name': 'Under Pressure ',
          'artists': [
            {'name': 'Queen'},
            {'name': 'David Bowie'},
          ],
          'album': {'name': 'Hot Space', 'images': <Object>[]},
        },
        {'name': 'no uri – skipped'},
      ],
    },
  });

  test('search answers become candidates (largest and smallest cover)', () {
    final hits = SpotifyMusicService.parseSearch(searchAnswer);
    expect(hits, hasLength(2));
    expect(hits[0].title, 'Never Gonna Give You Up');
    expect(hits[0].artist, 'Rick Astley');
    expect(hits[0].album, 'Whenever You Need Somebody');
    expect(hits[0].coverUrl, 'https://i.scdn.co/image/large');
    expect(hits[0].thumbnailUrl, 'https://i.scdn.co/image/small');
    expect(hits[1].title, 'Under Pressure');
    expect(hits[1].artist, 'Queen, David Bowie');
    expect(hits[1].coverUrl, isNull);
    expect(SpotifyMusicService.parseSearch('{}'), isEmpty);
  });

  test(
    'Spotify error answers are reported with their status and text',
    () async {
      final spotify = SpotifyMusicService(
        MockClient(
          (_) async => http.Response.bytes(
            utf8.encode(
              jsonEncode({
                'error': {
                  'status': 403,
                  'message':
                      'Check settings on developer.spotify.com/dashboard',
                },
              }),
            ),
            403,
          ),
        ),
        channel: channel,
      );
      messenger.setMockMethodCallHandler(
        channel,
        (_) async => {'accessToken': 't', 'expiresIn': 3600},
      );
      addTearDown(() => messenger.setMockMethodCallHandler(channel, null));
      await expectLater(
        spotify.search('rick'),
        throwsA(
          isA<MusicException>()
              .having((e) => e.httpStatus, 'status', 403)
              .having((e) => e.detail, 'detail', contains('dashboard')),
        ),
      );
      expect(SpotifyMusicService.errorMessage(utf8.encode('not json')), isNull);
    },
  );

  group('network trouble is reported as such', () {
    setUp(
      () => messenger.setMockMethodCallHandler(
        channel,
        (_) async => {'accessToken': 't', 'expiresIn': 3600},
      ),
    );
    tearDown(() => messenger.setMockMethodCallHandler(channel, null));

    Matcher network() => throwsA(
      isA<MusicException>().having(
        (e) => e.code,
        'code',
        MusicException.network,
      ),
    );

    test('no answer in time', () async {
      final spotify = SpotifyMusicService(
        MockClient((_) => Completer<http.Response>().future),
        channel: channel,
        timeout: const Duration(milliseconds: 20),
      );
      await expectLater(spotify.search('rick'), network());
    });

    test('an answer that is not JSON', () async {
      final spotify = SpotifyMusicService(
        MockClient((_) async => http.Response('<html>Login</html>', 200)),
        channel: channel,
      );
      await expectLater(spotify.search('rick'), network());
    });
  });

  test('only scdn.co and its subdomains count as Spotify image hosts', () {
    expect(SpotifyMusicService.isSpotifyImageHost('i.scdn.co'), isTrue);
    expect(SpotifyMusicService.isSpotifyImageHost('scdn.co'), isTrue);
    expect(SpotifyMusicService.isSpotifyImageHost('evilscdn.co'), isFalse);
    expect(SpotifyMusicService.isSpotifyImageHost('scdn.co.evil.com'), isFalse);
  });

  test('track ids come from track URIs only', () {
    expect(Song.trackIdOf('spotify:track:abc'), 'abc');
    expect(Song.trackIdOf('spotify:album:abc'), isNull);
    expect(Song.trackIdOf('https://open.spotify.com/track/abc'), isNull);
  });

  group('token', () {
    late int authorizations;
    late List<String> tokensSent;
    late DateTime now;

    SpotifyMusicService service({int firstStatus = 200}) {
      var first = true;
      return SpotifyMusicService(
        MockClient((request) async {
          tokensSent.add(request.headers['Authorization']!);
          expect(request.url.queryParameters['limit'], '10');
          expect(request.url.queryParameters['type'], 'track');
          expect(request.url.queryParameters.containsKey('market'), isFalse);
          final status = first ? firstStatus : 200;
          first = false;
          return http.Response.bytes(
            utf8.encode(status == 200 ? searchAnswer : ''),
            status,
          );
        }),
        channel: channel,
        clock: () => now,
      );
    }

    setUp(() {
      authorizations = 0;
      tokensSent = [];
      now = DateTime(2026, 10, 31, 12);
      messenger.setMockMethodCallHandler(channel, (call) async {
        expect(call.method, 'authorize');
        authorizations++;
        return {'accessToken': 't$authorizations', 'expiresIn': 3600};
      });
    });
    tearDown(() => messenger.setMockMethodCallHandler(channel, null));

    test('is fetched once and reused until shortly before expiry', () async {
      final spotify = service();
      await spotify.search('rick');
      await spotify.search('queen');
      expect(authorizations, 1);
      now = now.add(const Duration(minutes: 59, seconds: 30));
      await spotify.search('bowie');
      expect(authorizations, 2);
      expect(tokensSent, ['Bearer t1', 'Bearer t1', 'Bearer t2']);
    });

    test('a rejected token is renewed once', () async {
      final hits = await service(firstStatus: 401).search('rick');
      expect(hits, hasLength(2));
      expect(tokensSent, ['Bearer t1', 'Bearer t2']);
    });

    test('a token refused with 403 is replaced on the next search', () async {
      final spotify = service(firstStatus: 403);
      await expectLater(spotify.search('rick'), throwsA(isA<MusicException>()));
      expect(await spotify.search('rick'), hasLength(2));
      expect(tokensSent, ['Bearer t1', 'Bearer t2']);
    });

    test('a cancelled login is reported, nothing is searched', () async {
      messenger.setMockMethodCallHandler(channel, (call) async => null);
      await expectLater(
        service().search('rick'),
        throwsA(
          isA<MusicException>().having(
            (e) => e.code,
            'code',
            MusicException.cancelled,
          ),
        ),
      );
      expect(tokensSent, isEmpty);
    });
  });

  test('without the platform side the feature is simply off', () async {
    final spotify = SpotifyMusicService(
      MockClient((_) async => http.Response('', 500)),
      channel: const MethodChannel('test/nothing-here'),
    );
    final status = await spotify.status();
    expect(status.usable, isFalse);
  });

  test('covers are only downloaded from Spotify image servers', () async {
    final requested = <Uri>[];
    final spotify = SpotifyMusicService(
      MockClient((r) async {
        requested.add(r.url);
        return http.Response.bytes([1, 2, 3], 200);
      }),
      channel: channel,
    );
    expect(await spotify.downloadCover('https://i.scdn.co/image/x'), [1, 2, 3]);
    expect(await spotify.downloadCover('https://example.com/x.jpg'), isNull);
    expect(await spotify.downloadCover('http://i.scdn.co/image/x'), isNull);
    expect(requested, hasLength(1));
  });
}
