import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:randnotiz/features/weather/data/open_meteo_place_search.dart';

void main() {
  const sample = {
    'results': [
      {
        'name': 'Münster',
        'latitude': 51.96236,
        'longitude': 7.62571,
        'country': 'Deutschland',
        'admin1': 'Nordrhein-Westfalen',
      },
      {'name': 'Kaputt'}, // incomplete entry is skipped
      {
        'name': 'Münster',
        'latitude': 49.92,
        'longitude': 8.86,
        'country': 'Deutschland',
        'admin1': 'Hessen',
      },
    ],
  };

  test('request carries only the search text and language', () {
    final uri = OpenMeteoPlaceSearch.buildUri('  Münster ', 'de');
    expect(uri.host, 'geocoding-api.open-meteo.com');
    expect(uri.queryParameters['name'], 'Münster');
    expect(uri.queryParameters['language'], 'de');
  });

  test('parses results and builds readable labels', () async {
    final search = OpenMeteoPlaceSearch(
      MockClient(
        (_) async => http.Response.bytes(
          utf8.encode(jsonEncode(sample)),
          200,
          headers: {'content-type': 'application/json'},
        ),
      ),
    );
    final places = await search.search('Münster');
    expect(places.map((p) => p.label), [
      'Münster, Nordrhein-Westfalen, Deutschland',
      'Münster, Hessen, Deutschland',
    ]);
    expect(places.first.location.latitude, closeTo(51.96, 0.01));
  });

  test('short queries do not hit the network', () async {
    var calls = 0;
    final search = OpenMeteoPlaceSearch(
      MockClient((_) async {
        calls++;
        return http.Response('{}', 200);
      }),
    );
    expect(await search.search(' a '), isEmpty);
    expect(calls, 0);
  });

  test('offline, errors and empty answers give an empty list', () async {
    expect(
      await OpenMeteoPlaceSearch(
        MockClient((_) async => throw const SocketException('offline')),
      ).search('Berlin'),
      isEmpty,
    );
    expect(
      await OpenMeteoPlaceSearch(
        MockClient((_) async => http.Response('x', 500)),
      ).search('Berlin'),
      isEmpty,
    );
    expect(
      await OpenMeteoPlaceSearch(
        MockClient((_) async => http.Response('{}', 200)),
      ).search('Xyzzy'),
      isEmpty,
    );
  });
}
