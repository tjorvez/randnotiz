import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'app/app.dart';
import 'app/providers.dart';
import 'core/database/app_database.dart';
import 'core/debug/dev_tools.dart';
import 'core/platform/app_info.dart';
import 'features/backup/data/drive_backup_service.dart';
import 'features/geo/presentation/geo_backfill_controller.dart';
import 'features/intro/presentation/intro_controller.dart';
import 'features/journal/data/recent_searches.dart';
import 'features/library/data/imported_photo_store.dart';
import 'features/map/presentation/map_preferences.dart';
import 'features/notes/data/thumbnail_store.dart';
import 'features/settings/data/settings_repository.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  Intl.defaultLocale = 'de';
  await initializeDateFormatting('de');
  _registerLicenses();
  DevTools.install();

  final prefs = await SharedPreferencesWithCache.create(
    cacheOptions: const SharedPreferencesWithCacheOptions(
      allowList: {
        ...SettingsRepository.keys,
        GeoBackfillController.preferenceKey,
        IntroController.preferenceKey,
        RecentSearches.preferenceKey,
        MapPreferences.bordersKey,
        ...DriveBackupService.preferenceKeys,
      },
    ),
  );
  final docs = await getApplicationDocumentsDirectory();
  final devInstall = await readIsDevInstall();

  runApp(
    ProviderScope(
      overrides: [
        databaseProvider.overrideWithValue(AppDatabase.open()),
        preferencesProvider.overrideWithValue(prefs),
        devInstallProvider.overrideWithValue(devInstall),
        importedPhotoStoreProvider.overrideWithValue(
          ImportedPhotoStore(Directory(p.join(docs.path, 'imported'))),
        ),
        thumbnailStoreProvider.overrideWithValue(
          ThumbnailStore(Directory(p.join(docs.path, 'thumbnails'))),
        ),
      ],
      child: const RandnotizApp(),
    ),
  );
}

/// Bundled fonts and geodata appear on the licence page ("Über Randnotiz").
void _registerLicenses() {
  LicenseRegistry.addLicense(() async* {
    yield const LicenseEntryWithLineBreaks(
      ['Natural Earth (Kartendaten)'],
      'Ländergrenzen und Küsten: Made with Natural Earth. Free vector and '
      'raster map data @ naturalearthdata.com. Gemeinfrei (public domain). '
      'Für Randnotiz vereinfacht (Maßstab 1:50 Mio.).',
    );
    yield const LicenseEntryWithLineBreaks(
      ['GeoNames (Ortsnamen)'],
      'Orte und Ortsnamen: GeoNames, www.geonames.org – lizenziert unter '
      'Creative Commons Namensnennung 4.0 International (CC BY 4.0), '
      'https://creativecommons.org/licenses/by/4.0/deed.de. Verändert: '
      'beschränkt auf Orte ab 15 000 Einwohnern, deutsche und englische '
      'Namen ausgewählt, Koordinaten gerundet.',
    );
    yield const LicenseEntryWithLineBreaks(
      ['Open-Meteo (Wetter und Ortssuche)'],
      'Wetterdaten und Ortssuche: Open-Meteo.com, open-meteo.com – Daten '
      'lizenziert unter Creative Commons Namensnennung 4.0 International '
      '(CC BY 4.0), https://creativecommons.org/licenses/by/4.0/deed.de.',
    );
    yield LicenseEntryWithLineBreaks([
      'Kalam (Schrift)',
    ], await rootBundle.loadString('assets/fonts/OFL-kalam.txt'));
    yield LicenseEntryWithLineBreaks([
      'Crimson Text (Schrift)',
    ], await rootBundle.loadString('assets/fonts/OFL-crimsontext.txt'));
  });
}
