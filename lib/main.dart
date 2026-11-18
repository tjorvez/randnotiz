import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'app/app.dart';
import 'app/database_unavailable_app.dart';
import 'app/providers.dart';
import 'core/database/app_database.dart';
import 'core/database/database_encryption.dart';
import 'core/database/database_key_store.dart';
import 'core/debug/dev_tools.dart';
import 'core/platform/app_info.dart';
import 'features/backup/data/drive_backup_service.dart';
import 'features/backup/presentation/lost_notes_prompt.dart';
import 'features/geo/presentation/geo_backfill_controller.dart';
import 'features/intro/presentation/intro_controller.dart';
import 'features/journal/data/recent_searches.dart';
import 'features/library/data/imported_photo_store.dart';
import 'features/map/presentation/map_preferences.dart';
import 'features/notes/data/thumbnail_store.dart';
import 'features/settings/data/settings_repository.dart';
import 'features/settings/data/system_language_sync.dart';
import 'features/whats_new/presentation/whats_new_controller.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Date symbols for every language; the app's language is set in
  // RandnotizApp (Intl.defaultLocale, Fmt.locale).
  await initializeDateFormatting();
  _registerLicenses();
  DevTools.install();

  final prefs = await SharedPreferencesWithCache.create(
    cacheOptions: const SharedPreferencesWithCacheOptions(
      allowList: {
        ...SettingsRepository.keys,
        SystemLanguageSync.preferenceKey,
        GeoBackfillController.preferenceKey,
        IntroController.preferenceKey,
        WhatsNewController.preferenceKey,
        RecentSearches.preferenceKey,
        MapPreferences.bordersKey,
        ...DriveBackupService.preferenceKeys,
        LostNotesController.preferenceKey,
      },
    ),
  );
  await SettingsRepository(prefs).keepGermanForEarlierInstalls(
    existingInstall: prefs.getBool(IntroController.preferenceKey) ?? false,
  );
  await _start(prefs);
}

/// Opens the notes and starts the app – or, while the notes cannot be opened
/// right now, a page that says so and tries again ([DatabaseUnavailable]).
Future<void> _start(SharedPreferencesWithCache prefs) async {
  final docs = await getApplicationDocumentsDirectory();
  final dbFile = await AppDatabase.file();
  final prepared = await DatabaseEncryption(keys: SecureDatabaseKeyStore())
      .prepare(dbFile);
  final String? dbKey;
  switch (prepared) {
    case DatabaseUnavailable():
      runApp(
        DatabaseUnavailableApp(prefs: prefs, onRetry: () => _start(prefs)),
      );
      return;
    case OpenEncrypted(:final key, :final replacedUnreadable):
      dbKey = key;
      if (replacedUnreadable) {
        await prefs.setBool(LostNotesController.preferenceKey, true);
      }
    case OpenUnencrypted():
      dbKey = null; // as before; the next start encrypts it
  }
  final devInstall = await readIsDevInstall();

  runApp(
    ProviderScope(
      overrides: [
        databaseProvider.overrideWithValue(AppDatabase.open(dbFile, dbKey)),
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

/// Randnotiz itself, the bundled fonts and the geodata appear on the
/// licence page ("About Randnotiz"). In English: the page is shown in every
/// app language.
void _registerLicenses() {
  LicenseRegistry.addLicense(() async* {
    yield const LicenseEntryWithLineBreaks(
      ['Randnotiz'],
      '$appCopyright\n\n'
      'This program is free software: you can redistribute it and/or modify '
      'it under the terms of the GNU General Public License as published by '
      'the Free Software Foundation, either version 3 of the License, or (at '
      'your option) any later version.\n\n'
      'This program is distributed in the hope that it will be useful, but '
      'WITHOUT ANY WARRANTY; without even the implied warranty of '
      'MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU '
      'General Public License for more details: '
      'https://www.gnu.org/licenses/gpl-3.0.html\n\n'
      'Source code: https://$sourceCodeLabel',
    );
    yield const LicenseEntryWithLineBreaks(
      ['Natural Earth (map data)'],
      'Borders, coastlines and country names: Made with Natural Earth. Free '
      'vector and raster map data @ naturalearthdata.com. Public domain. '
      'Simplified for Randnotiz (scale 1:50m).',
    );
    yield const LicenseEntryWithLineBreaks(
      ['GeoNames (place names)'],
      'Places and place names: GeoNames, www.geonames.org – licensed under '
      'Creative Commons Attribution 4.0 International (CC BY 4.0), '
      'https://creativecommons.org/licenses/by/4.0/. Modified: limited to '
      'places with at least 15,000 inhabitants, German and English names '
      'selected, coordinates rounded.',
    );
    yield const LicenseEntryWithLineBreaks(
      ['Open-Meteo (weather and place search)'],
      'Weather data and place search: Open-Meteo.com, open-meteo.com – data '
      'licensed under Creative Commons Attribution 4.0 International '
      '(CC BY 4.0), https://creativecommons.org/licenses/by/4.0/.',
    );
    yield const LicenseEntryWithLineBreaks(
      ['SQLite3MultipleCiphers (encrypted database)'],
      'MIT License\n\n'
      'Copyright (c) 2019-2026 Ulrich Telle\n\n'
      'Permission is hereby granted, free of charge, to any person obtaining '
      'a copy of this software and associated documentation files (the '
      '"Software"), to deal in the Software without restriction, including '
      'without limitation the rights to use, copy, modify, merge, publish, '
      'distribute, sublicense, and/or sell copies of the Software, and to '
      'permit persons to whom the Software is furnished to do so, subject to '
      'the following conditions:\n\n'
      'The above copyright notice and this permission notice shall be '
      'included in all copies or substantial portions of the Software.\n\n'
      'THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, '
      'EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF '
      'MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND '
      'NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE '
      'LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION '
      'OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION '
      'WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.\n\n'
      'Includes SQLite, which is in the public domain.',
    );
    yield LicenseEntryWithLineBreaks([
      'Kalam (font)',
    ], await rootBundle.loadString('assets/fonts/OFL-kalam.txt'));
    yield LicenseEntryWithLineBreaks([
      'Crimson Text (font)',
    ], await rootBundle.loadString('assets/fonts/OFL-crimsontext.txt'));
  });
}
