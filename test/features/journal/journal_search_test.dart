import 'dart:io';
import 'dart:typed_data';

import 'package:drift/drift.dart' show driftRuntimeOptions;
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:randnotiz/app/providers.dart';
import 'package:randnotiz/core/database/app_database.dart';
import 'package:randnotiz/core/theme/app_theme.dart';
import 'package:randnotiz/core/theme/season.dart';
import 'package:randnotiz/features/geo/data/country_names_sync.dart';
import 'package:randnotiz/features/geo/data/geo_database.dart';
import 'package:randnotiz/features/journal/presentation/journal_screen.dart';
import 'package:randnotiz/features/library/domain/photo_repository.dart';
import 'package:randnotiz/features/notes/data/drift_note_repository.dart';
import 'package:randnotiz/features/notes/domain/note.dart';
import 'package:randnotiz/l10n/generated/app_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shared_preferences_platform_interface/in_memory_shared_preferences_async.dart';
import 'package:shared_preferences_platform_interface/shared_preferences_async_platform_interface.dart';

class _Photos implements PhotoRepository {
  @override
  ImageProvider imageFor(PhotoItem item, {int? size}) =>
      const AssetImage('assets/branding/icon_512.png');

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;
  late GeoDatabase geo;
  late AppDatabase db;
  late SharedPreferencesWithCache prefs;

  setUpAll(() {
    ByteData read(String path) =>
        ByteData.sublistView(File(path).readAsBytesSync());
    geo = GeoDatabase.parse(
      read(GeoDatabase.countriesAsset),
      read(GeoDatabase.placesAsset),
    );
  });

  setUp(() async {
    db = AppDatabase(NativeDatabase.memory());
    SharedPreferencesAsyncPlatform.instance =
        InMemorySharedPreferencesAsync.empty();
    prefs = await SharedPreferencesWithCache.create(
      cacheOptions: const SharedPreferencesWithCacheOptions(
        allowList: {'recentSearches', 'geoBackfill'},
      ),
    );
    final notes = DriftNoteRepository(db);
    await CountryNamesSync(db).sync(geo.countries);
    await notes.save(
      NoteDraft(
        assetId: 'oslo',
        body: 'Fähre zur Museumsinsel',
        date: DateTime(2024, 7, 2),
        placeName: 'Oslo',
        countryCode: 'NO',
        geoChecked: true,
      ),
    );
    await notes.save(
      NoteDraft(
        assetId: 'wien',
        body: 'Melange im Kaffeehaus',
        date: DateTime(2024, 3, 2),
        placeName: 'Wien',
        placeNameAlt: 'Vienna',
        countryCode: 'AT',
        geoChecked: true,
      ),
    );
  });

  tearDown(() => db.close());

  /// Lets the database answer (real time) and the UI catch up – a bounded
  /// loop instead of pumpAndSettle, which never settles while a progress
  /// indicator spins.
  Future<void> settle(WidgetTester t) async {
    for (var i = 0; i < 8; i++) {
      await t.runAsync(
        () => Future<void>.delayed(const Duration(milliseconds: 20)),
      );
      await t.pump(const Duration(milliseconds: 120));
    }
  }

  /// Drift closes its query streams with a short delay: let it happen.
  Future<void> unmount(WidgetTester t) async {
    await t.pumpWidget(const SizedBox());
    await t.pump(const Duration(seconds: 1));
  }

  Future<void> pump(WidgetTester t) async {
    await t.pumpWidget(
      ProviderScope(
        overrides: [
          databaseProvider.overrideWithValue(db),
          preferencesProvider.overrideWithValue(prefs),
          photoRepositoryProvider.overrideWithValue(_Photos()),
          geoDatabaseProvider.overrideWith((ref) async => geo),
        ],
        child: MaterialApp(
          theme: AppTheme.build(Brightness.light, Season.autumn),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          locale: const Locale('de'),
          home: const Scaffold(body: JournalScreen()),
        ),
      ),
    );
    await settle(t);
  }

  testWidgets('a country suggestion (English name) becomes a filter chip', (
    t,
  ) async {
    await pump(t);
    expect(find.textContaining('Fähre'), findsOneWidget);
    expect(find.textContaining('Melange'), findsOneWidget);

    await t.tap(find.byType(SearchBar));
    await t.enterText(find.byType(TextField).first, 'norw');
    await settle(t);

    // Grouped suggestions while typing.
    expect(find.text('Länder'), findsOneWidget);
    expect(find.text('Norwegen'), findsOneWidget);
    expect(find.text('Norway'), findsOneWidget);
    await t.tap(find.text('Norwegen'));
    await settle(t);

    // The chip filters; the search text is gone.
    expect(find.widgetWithText(InputChip, 'Norwegen'), findsOneWidget);
    expect(find.textContaining('Fähre'), findsOneWidget);
    expect(find.textContaining('Melange'), findsNothing);

    // Removing the chip shows everything again.
    await t.tap(find.byTooltip('Filter entfernen'));
    await settle(t);
    expect(find.byType(InputChip), findsNothing);
    expect(find.textContaining('Melange'), findsOneWidget);
    await unmount(t);
  });

  testWidgets('places by their English name; earlier searches can be removed', (
    t,
  ) async {
    await pump(t);
    await t.tap(find.byType(SearchBar));
    await t.enterText(find.byType(TextField).first, 'vienna');
    await settle(t);
    // Full-text search finds the second name of the place, too.
    await t.testTextInput.receiveAction(TextInputAction.search);
    await settle(t);
    expect(find.textContaining('Melange'), findsOneWidget);
    expect(find.textContaining('Fähre'), findsNothing);
    expect(prefs.getString('recentSearches'), contains('vienna'));

    // Back in the empty field: the earlier search is offered…
    await t.tap(find.byType(SearchBar));
    await t.enterText(find.byType(TextField).first, '');
    await settle(t);
    expect(find.text('Frühere Suchen'), findsOneWidget);
    expect(find.text('vienna'), findsWidgets);

    // …and can be deleted on its own.
    await t.tap(find.byTooltip('Aus den früheren Suchen löschen'));
    await settle(t);
    expect(find.text('Frühere Suchen'), findsNothing);
    expect(prefs.getString('recentSearches'), '[]');
    await unmount(t);
  });
}
