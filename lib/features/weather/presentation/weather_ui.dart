import 'package:flutter/material.dart';

import '../../../core/format/formatters.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../domain/weather.dart';

IconData weatherIcon(WeatherKind kind) => switch (kind) {
  WeatherKind.clear => Icons.wb_sunny_outlined,
  WeatherKind.partlyCloudy => Icons.wb_cloudy_outlined,
  WeatherKind.cloudy => Icons.cloud_outlined,
  WeatherKind.fog => Icons.foggy,
  WeatherKind.drizzle => Icons.grain,
  WeatherKind.rain => Icons.water_drop_outlined,
  WeatherKind.snow => Icons.ac_unit,
  WeatherKind.thunderstorm => Icons.thunderstorm_outlined,
};

/// "Sonnig, 21,5 °C"
String weatherLabel(AppLocalizations l10n, WeatherSnapshot w) {
  final kind = l10n.weatherKind(w.kind.name);
  final t = w.temperatureC;
  return t == null
      ? kind
      : '$kind, ${l10n.weatherTemperature(Fmt.temperature(t))}';
}
