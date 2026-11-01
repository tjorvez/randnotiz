import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/providers.dart';

/// Settings of the world map that are remembered on the device.
abstract final class MapPreferences {
  static const bordersKey = 'mapShowBorders';
}

/// Whether the world map draws the country borders (on by default).
final mapShowBordersProvider = NotifierProvider<MapBordersController, bool>(
  MapBordersController.new,
);

class MapBordersController extends Notifier<bool> {
  @override
  bool build() =>
      ref.read(preferencesProvider).getBool(MapPreferences.bordersKey) ?? true;

  Future<void> toggle() async {
    state = !state;
    await ref
        .read(preferencesProvider)
        .setBool(MapPreferences.bordersKey, state);
  }
}
