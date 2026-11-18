import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../domain/weather.dart';

/// [WeatherProvider] backed by Open-Meteo (https://open-meteo.com).
///
/// * Days older than [archiveThreshold] use the historical archive API
///   (ERA5 reanalysis, available with a delay of a few days).
/// * Recent days use the forecast API, which also serves the past ~3 months.
///
/// No API key is needed. Only date and a coarse location (~1 km) are sent.
/// Licence note: the free tier is for non-commercial use (see NOTICE.md).
class OpenMeteoWeatherProvider implements WeatherProvider {
  OpenMeteoWeatherProvider(
    this._client, {
    DateTime Function()? clock,
    this.timeout = const Duration(seconds: 8),
  }) : _clock = clock ?? DateTime.now;

  final http.Client _client;
  final DateTime Function() _clock;
  final Duration timeout;

  static const archiveThreshold = Duration(days: 7);
  static final _archiveStart = DateTime(1940);

  @visibleForTesting
  Uri buildUri(GeoPoint location, DateTime time) {
    final coarse = location.coarse();
    final day = _isoDate(time);
    final age = _clock().difference(time);
    final useArchive = age > archiveThreshold;
    final host = useArchive
        ? 'archive-api.open-meteo.com'
        : 'api.open-meteo.com';
    final path = useArchive ? '/v1/archive' : '/v1/forecast';
    return Uri.https(host, path, {
      'latitude': coarse.latitude.toStringAsFixed(2),
      'longitude': coarse.longitude.toStringAsFixed(2),
      'hourly': 'temperature_2m,weather_code',
      'start_date': day,
      'end_date': day,
      'timezone': 'auto',
    });
  }

  @override
  Future<WeatherSnapshot?> weatherAt(GeoPoint location, DateTime time) async {
    if (!location.isValid) return null;
    final now = _clock();
    if (time.isAfter(now.add(const Duration(days: 1)))) return null;
    if (time.isBefore(_archiveStart)) return null;
    try {
      final response = await _client
          .get(buildUri(location, time))
          .timeout(timeout);
      if (response.statusCode != 200) return null;
      final json = jsonDecode(utf8.decode(response.bodyBytes));
      return parseHourly(json, time);
    } on Exception catch (e) {
      debugPrint('Weather lookup failed: ${e.runtimeType}');
      return null;
    }
  }

  /// Picks the hourly value closest to the local hour of [time].
  @visibleForTesting
  static WeatherSnapshot? parseHourly(Object? json, DateTime time) {
    if (json is! Map<String, Object?>) return null;
    final hourly = json['hourly'];
    if (hourly is! Map<String, Object?>) return null;
    final times = hourly['time'];
    final codes = hourly['weather_code'];
    final temps = hourly['temperature_2m'];
    if (times is! List || codes is! List || times.isEmpty) return null;

    final wanted = time.hour;
    int? bestIndex;
    var bestDistance = 1 << 30;
    for (var i = 0; i < times.length && i < codes.length; i++) {
      if (codes[i] is! num) continue;
      final parsed = DateTime.tryParse('${times[i]}');
      if (parsed == null) continue;
      final distance = (parsed.hour - wanted).abs();
      if (distance < bestDistance) {
        bestDistance = distance;
        bestIndex = i;
      }
    }
    if (bestIndex == null) return null;
    final kind = WeatherKind.fromWmoCode((codes[bestIndex] as num).toInt());
    if (kind == null) return null;
    final temp = temps is List && bestIndex < temps.length
        ? temps[bestIndex]
        : null;
    return WeatherSnapshot(
      kind: kind,
      temperatureC: temp is num
          ? (temp.toDouble() * 10).roundToDouble() / 10
          : null,
    );
  }

  static String _isoDate(DateTime d) =>
      '${d.year.toString().padLeft(4, '0')}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
}
