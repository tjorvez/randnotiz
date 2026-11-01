import 'package:drift/drift.dart' show driftRuntimeOptions;
import 'package:drift/native.dart';
import 'package:flutter/gestures.dart' show kLongPressTimeout;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:randnotiz/app/providers.dart';
import 'package:randnotiz/core/database/app_database.dart';
import 'package:randnotiz/features/collections/data/drift_collection_repository.dart';
import 'package:randnotiz/features/collections/presentation/collections_screen.dart';
import 'package:randnotiz/l10n/generated/app_localizations.dart';

void main() {
  driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;
  late AppDatabase db;
  late DriftCollectionRepository repo;

  setUp(() async {
    db = AppDatabase(NativeDatabase.memory());
    repo = DriftCollectionRepository(db);
    for (final name in ['Alt', 'Mitte', 'Neu']) {
      await repo.create(name);
    }
  });
  tearDown(() => db.close());

  /// Real time for the database, then let the UI catch up.
  Future<void> settle(WidgetTester t) async {
    for (var i = 0; i < 6; i++) {
      await t.runAsync(
        () => Future<void>.delayed(const Duration(milliseconds: 30)),
      );
      await t.pump(const Duration(milliseconds: 200));
    }
  }

  Future<void> pump(WidgetTester t) async {
    await t.pumpWidget(
      ProviderScope(
        overrides: [databaseProvider.overrideWithValue(db)],
        child: const MaterialApp(
          locale: Locale('de'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Scaffold(body: CollectionsScreen()),
        ),
      ),
    );
    await settle(t);
  }

  Future<List<String>> stored() async =>
      (await repo.watchCollections().first).map((c) => c.name).toList();

  Future<void> unmount(WidgetTester t) async {
    await t.pumpWidget(const SizedBox());
    await t.pump(const Duration(seconds: 1));
  }

  testWidgets('a collection is dragged onto another place', (t) async {
    await pump(t);
    expect(await t.runAsync(stored), ['Neu', 'Mitte', 'Alt']);

    // Long-press "Neu" (first) and drop it on "Alt" (third).
    final gesture = await t.startGesture(t.getCenter(find.text('Neu')));
    await t.pump(kLongPressTimeout + const Duration(milliseconds: 100));
    final target = t.getCenter(find.text('Alt'));
    for (var i = 1; i <= 8; i++) {
      await gesture.moveTo(
        Offset.lerp(t.getCenter(find.text('Mitte')), target, i / 8)!,
      );
      await t.pump(const Duration(milliseconds: 16));
    }
    await gesture.up();
    await settle(t);

    expect(await t.runAsync(stored), ['Mitte', 'Alt', 'Neu']);
    // The grid shows the new order (one row in the test window).
    final xs = [
      for (final name in ['Mitte', 'Alt', 'Neu'])
        t.getCenter(find.text(name)).dx,
    ];
    expect(xs, orderedEquals([...xs]..sort()));
    await unmount(t);
  });

  testWidgets('a quick swipe scrolls and does not reorder', (t) async {
    await pump(t);
    await t.drag(find.text('Neu'), const Offset(0, 300));
    await settle(t);
    expect(await t.runAsync(stored), ['Neu', 'Mitte', 'Alt']);
    await unmount(t);
  });
}
