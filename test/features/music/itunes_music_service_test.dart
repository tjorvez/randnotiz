import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:randnotiz/features/music/data/itunes_music_service.dart';
import 'package:randnotiz/features/music/domain/music_service.dart';

const _art =
    'https://is1-ssl.mzstatic.com/image/thumb/Music/ab/cd/source/100x100bb.jpg';

Map<String, Object?> _song(int id, {String? preview}) => {
  'wrapperType': 'track',
  'kind': 'song',
  'trackId': id,
  'trackName': ' Lied $id ',
  'artistName': 'Band',
  'collectionName': 'Album',
  'artworkUrl100': _art,
  'trackViewUrl': 'https://music.apple.com/de/album/x/1?i=$id&uo=4',
  'previewUrl': ?preview,
};

http.Response _json(Object body, [int status = 200]) => http.Response.bytes(
  utf8.encode(jsonEncode(body)),
  status,
  headers: {'content-type': 'text/javascript; charset=utf-8'},
);

void main() {
  test('search asks the store of the country and parses songs only', () async {
    late Uri asked;
    final service = ItunesMusicService(
      MockClient((request) async {
        asked = request.url;
        return _json({
          'resultCount': 3,
          'results': [
            _song(1),
            {'wrapperType': 'collection', 'collectionId': 9},
            {'kind': 'song', 'trackName': 'without id'},
          ],
        });
      }),
      country: 'at',
    );

    final results = await service.search('  Sommer ');
    expect(asked.host, 'itunes.apple.com');
    expect(asked.path, '/search');
    expect(asked.queryParameters, {
      'term': 'Sommer',
      'media': 'music',
      'entity': 'song',
      'limit': '15',
      'country': 'AT',
    });
    expect(results, hasLength(1));
    final hit = results.single;
    expect(hit.uri, 'itunes:track:1');
    expect(hit.title, 'Lied 1');
    expect(hit.artist, 'Band');
    expect(hit.album, 'Album');
    expect(hit.coverUrl, endsWith('/source/600x600bb.jpg'));
    expect(hit.thumbnailUrl, endsWith('/source/100x100bb.jpg'));
  });

  test('an empty query asks nothing', () async {
    var asked = false;
    final service = ItunesMusicService(
      MockClient((_) async {
        asked = true;
        return _json({});
      }),
    );
    expect(await service.search('  '), isEmpty);
    expect(asked, isFalse);
  });

  test('an unknown country falls back to DE', () {
    expect(
      ItunesMusicService(MockClient((_) async => _json({}))).country,
      'DE',
    );
    expect(
      ItunesMusicService(
        MockClient((_) async => _json({})),
        country: '419',
      ).country,
      'DE',
    );
  });

  test('links: preview and store page, looked up once per session', () async {
    var lookups = 0;
    final service = ItunesMusicService(
      MockClient((request) async {
        lookups++;
        expect(request.url.path, '/lookup');
        expect(request.url.queryParameters['id'], '7');
        return _json({
          'results': [
            _song(7, preview: 'https://audio-ssl.itunes.apple.com/p.m4a'),
          ],
        });
      }),
    );
    final links = await service.links('itunes:track:7');
    expect(
      links.previewUrl.toString(),
      'https://audio-ssl.itunes.apple.com/p.m4a',
    );
    expect(links.storeUrl.host, 'music.apple.com');
    await service.links('itunes:track:7');
    expect(lookups, 1);
  });

  test('links: a song without preview, or no longer in the store', () async {
    final service = ItunesMusicService(
      MockClient((request) async {
        final id = int.parse(request.url.queryParameters['id']!);
        return _json({
          'results': [if (id == 2) _song(2)],
        });
      }),
    );
    expect((await service.links('itunes:track:2')).previewUrl, isNull);
    await expectLater(
      service.links('itunes:track:3'),
      throwsA(isA<MusicException>().having((e) => e.code, 'code', 'notFound')),
    );
    await expectLater(
      service.links('spotify:track:abc'),
      throwsA(isA<MusicException>()),
    );
  });

  test('errors: throttling, no connection, no JSON', () async {
    Future<MusicException> failure(http.Client client) async {
      try {
        await ItunesMusicService(client).search('x');
      } on MusicException catch (e) {
        return e;
      }
      fail('no MusicException');
    }

    expect(
      (await failure(MockClient((_) async => http.Response('', 403))))
          .httpStatus,
      403,
    );
    expect(
      (await failure(
        MockClient((_) async => throw http.ClientException('offline')),
      )).code,
      MusicException.network,
    );
    expect(
      (await failure(
        MockClient((_) async => http.Response('<html>Portal</html>', 200)),
      )).code,
      MusicException.network,
    );
  });

  test('covers only from Apple image servers', () async {
    final asked = <Uri>[];
    final service = ItunesMusicService(
      MockClient((request) async {
        asked.add(request.url);
        return http.Response.bytes([1, 2, 3], 200);
      }),
    );
    expect(await service.downloadCover(_art), [1, 2, 3]);
    expect(
      await service.downloadCover('https://evilmzstatic.com/x.jpg'),
      isNull,
    );
    expect(
      await service.downloadCover('http://is1.mzstatic.com/x.jpg'),
      isNull,
    );
    expect(asked, hasLength(1));
  });

  test('other services: song.link for the iTunes id', () {
    final service = ItunesMusicService(MockClient((_) async => _json({})));
    expect(
      service.otherServicesUrl('itunes:track:42').toString(),
      'https://song.link/i/42',
    );
  });
}
