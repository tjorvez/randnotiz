import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:randnotiz/features/weather/data/open_meteo_weather_provider.dart';
import 'package:randnotiz/features/weather/domain/weather.dart';

Map<String, Object?> hourly(List<int> codes, List<double> temps, String day) =>
    {
      'hourly': {
        'time': [
          for (var h = 0; h < codes.length; h++)
            '${day}T${h.toString().padLeft(2, '0')}:00',
        ],
        'weather_code': codes,
        'temperature_2m': temps,
      },
    };

void main() {
  final now = DateTime(2026, 10, 31, 12);
  const berlin = GeoPoint(52.520008, 13.404954);

  OpenMeteoWeatherProvider provider(http.Client c) =>
      OpenMeteoWeatherProvider(c, clock: () => now);

  test('old photos use the archive API with a coarse location', () {
    final uri = provider(MockClient((_) async => http.Response('', 500)))
        .buildUri(berlin, DateTime(2019, 8, 3, 15));
    expect(uri.host, 'archive-api.open-meteo.com');
    expect(uri.path, '/v1/archive');
    expect(uri.queryParameters['latitude'], '52.52');
    expect(uri.queryParameters['longitude'], '13.40');
    expect(uri.queryParameters['start_date'], '2019-08-03');
    expect(uri.queryParameters['end_date'], '2019-08-03');
    expect(uri.toString(), isNot(contains('52.520008')));
  });

  test('recent photos use the forecast API', () {
    final uri = provider(MockClient((_) async => http.Response('', 500)))
        .buildUri(berlin, DateTime(2026, 10, 29, 8));
    expect(uri.host, 'api.open-meteo.com');
    expect(uri.path, '/v1/forecast');
  });

  test('picks the hour of the photo', () async {
    final codes = List.filled(24, 0)..[15] = 63;
    final temps = List.generate(24, (h) => 10.0 + h);
    final client = MockClient(
      (req) async =>
          http.Response(jsonEncode(hourly(codes, temps, '2019-08-03')), 200),
    );
    final result = await provider(client)
        .weatherAt(berlin, DateTime(2019, 8, 3, 15, 40));
    expect(
      result,
      const WeatherSnapshot(kind: WeatherKind.rain, temperatureC: 25.0),
    );
  });

  test('server error, timeout and offline give null', () async {
    expect(
      await provider(MockClient((_) async => http.Response('nope', 503)))
          .weatherAt(berlin, DateTime(2020)),
      isNull,
    );
    expect(
      await provider(
        MockClient((_) async => throw const SocketException('offline')),
      ).weatherAt(berlin, DateTime(2020)),
      isNull,
    );
    expect(
      await provider(MockClient((_) async => http.Response('{broken', 200)))
          .weatherAt(berlin, DateTime(2020)),
      isNull,
    );
  });

  test('no request for invalid locations or future dates', () async {
    var calls = 0;
    final p = provider(
      MockClient((_) async {
        calls++;
        return http.Response('{}', 200);
      }),
    );
    expect(await p.weatherAt(const GeoPoint(0, 0), DateTime(2020)), isNull);
    expect(await p.weatherAt(berlin, DateTime(2027)), isNull);
    expect(calls, 0);
  });

  test('WMO codes map to kinds', () {
    expect(WeatherKind.fromWmoCode(0), WeatherKind.clear);
    expect(WeatherKind.fromWmoCode(2), WeatherKind.partlyCloudy);
    expect(WeatherKind.fromWmoCode(3), WeatherKind.cloudy);
    expect(WeatherKind.fromWmoCode(48), WeatherKind.fog);
    expect(WeatherKind.fromWmoCode(55), WeatherKind.drizzle);
    expect(WeatherKind.fromWmoCode(81), WeatherKind.rain);
    expect(WeatherKind.fromWmoCode(75), WeatherKind.snow);
    expect(WeatherKind.fromWmoCode(95), WeatherKind.thunderstorm);
    expect(WeatherKind.fromWmoCode(1234), isNull);
  });

  test('persisted names round-trip', () {
    for (final k in WeatherKind.values) {
      expect(WeatherKind.fromName(k.name), k);
    }
    expect(WeatherKind.fromName('tornado'), isNull);
  });
}
