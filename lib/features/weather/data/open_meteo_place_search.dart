import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../domain/place_search.dart';
import '../domain/weather.dart';

/// [PlaceSearch] backed by the Open-Meteo Geocoding API
/// (https://open-meteo.com/en/docs/geocoding-api). Only the typed search
/// text is sent; no API key needed.
class OpenMeteoPlaceSearch implements PlaceSearch {
  OpenMeteoPlaceSearch(
    this._client, {
    this.timeout = const Duration(seconds: 8),
  });

  final http.Client _client;
  final Duration timeout;

  static const minQueryLength = 2;

  @visibleForTesting
  static Uri buildUri(String query, String language) =>
      Uri.https('geocoding-api.open-meteo.com', '/v1/search', {
        'name': query.trim(),
        'count': '8',
        'language': language,
        'format': 'json',
      });

  @override
  Future<List<Place>> search(String query, {String language = 'de'}) async {
    if (query.trim().length < minQueryLength) return const [];
    try {
      final response = await _client
          .get(buildUri(query, language))
          .timeout(timeout);
      if (response.statusCode != 200) return const [];
      return parse(jsonDecode(utf8.decode(response.bodyBytes)));
    } on Exception catch (e) {
      debugPrint('Place search failed: ${e.runtimeType}');
      return const [];
    }
  }

  @visibleForTesting
  static List<Place> parse(Object? json) {
    if (json is! Map<String, Object?>) return const [];
    final results = json['results'];
    if (results is! List) return const [];
    final places = <Place>[];
    for (final r in results) {
      if (r is! Map<String, Object?>) continue;
      final name = r['name'];
      final lat = r['latitude'];
      final lon = r['longitude'];
      if (name is! String || lat is! num || lon is! num) continue;
      places.add(
        Place(
          name: name,
          region: r['admin1'] is String ? r['admin1']! as String : null,
          country: r['country'] is String ? r['country']! as String : null,
          location: GeoPoint(lat.toDouble(), lon.toDouble()),
        ),
      );
    }
    return places;
  }
}
