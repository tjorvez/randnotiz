import 'package:drift/drift.dart' show driftRuntimeOptions;
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:randnotiz/app/providers.dart';
import 'package:randnotiz/core/database/app_database.dart';
import 'package:randnotiz/core/format/formatters.dart';
import 'package:randnotiz/core/theme/app_theme.dart';
import 'package:randnotiz/core/theme/season.dart';
import 'package:randnotiz/features/journal/presentation/calendar_screen.dart';
import 'package:randnotiz/features/library/domain/photo_repository.dart';
import 'package:randnotiz/features/notes/data/drift_note_repository.dart';
import 'package:randnotiz/features/notes/domain/note.dart';
import 'package:randnotiz/features/settings/presentation/settings_controller.dart';
import 'package:randnotiz/l10n/generated/app_localizations.dart';

class _Photos implements PhotoRepository {
  @override
  ImageProvider imageFor(PhotoItem item, {int? size}) =>
      const AssetImage('assets/branding/icon_512.png');

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;
  late AppDatabase db;
  final now = DateTime(2026, 11, 2, 10);

  setUp(() async {
    Fmt.locale = 'de';
    db = AppDatabase(NativeDatabase.memory());
    final notes = DriftNoteRepository(db);
    Future<void> add(String id, String body, DateTime date) =>
        notes.save(NoteDraft(assetId: id, body: body, date: date)).then((_) {});
    await add('heute', 'Kaffee am Fenster', DateTime(2026, 11, 2, 8));
    await add('vorige', 'Laub im Park', DateTime(2026, 10, 28, 15));
    await add('doppelt', 'Abends noch Suppe', DateTime(2026, 10, 28, 20));
    await add('alt', 'Sommerreise', DateTime(2025, 8, 14));
  });

  tearDown(() => db.close());

  Future<void> settle(WidgetTester t) async {
    for (var i = 0; i < 8; i++) {
      await t.runAsync(
        () => Future<void>.delayed(const Duration(milliseconds: 20)),
      );
      await t.pump(const Duration(milliseconds: 120));
    }
  }

  Future<void> unmount(WidgetTester t) async {
    await t.pumpWidget(const SizedBox());
    await t.pump(const Duration(seconds: 1));
  }

  Future<void> pump(WidgetTester t, {DateTime? birthday}) async {
    await t.pumpWidget(
      ProviderScope(
        overrides: [
          databaseProvider.overrideWithValue(db),
          clockProvider.overrideWithValue(() => now),
          photoRepositoryProvider.overrideWithValue(_Photos()),
          birthdayProvider.overrideWithValue(birthday),
        ],
        child: MaterialApp(
          theme: AppTheme.build(Brightness.light, Season.autumn),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          locale: const Locale('de'),
          home: const CalendarScreen(),
        ),
      ),
    );
    await settle(t);
  }

  Finder day(int n) => find.bySemanticsLabel(RegExp('^$n\\. '));

  testWidgets('opens on today and says how far away it is', (t) async {
    await pump(t);
    expect(find.text('November 2026'), findsOneWidget);
    expect(find.text('2 Einträge in diesem Monat'), findsNothing);
    expect(find.text('1 Eintrag in diesem Monat'), findsOneWidget);
    expect(find.text('Montag, 2. November 2026'), findsOneWidget);
    expect(find.text('Heute'), findsOneWidget);
    expect(find.textContaining('Kaffee am Fenster'), findsOneWidget);
    await unmount(t);
  });

  testWidgets('a tapped day shows its entries and the days since', (t) async {
    await pump(t);
    // Go back to October and pick the 28th (two entries, 5 days ago).
    await t.tap(find.byTooltip('Voriger Monat'));
    await settle(t);
    expect(find.text('Oktober 2026'), findsOneWidget);
    expect(find.text('2 Einträge in diesem Monat'), findsOneWidget);

    await t.tap(day(28));
    await settle(t);
    expect(find.text('Mittwoch, 28. Oktober 2026'), findsOneWidget);
    expect(find.text('Vor 5 Tagen'), findsOneWidget);
    expect(find.textContaining('Laub im Park'), findsOneWidget);
    expect(find.textContaining('Abends noch Suppe'), findsOneWidget);

    // A day without entries.
    await t.tap(day(27));
    await settle(t);
    expect(find.text('Vor 6 Tagen'), findsOneWidget);
    expect(find.text('Keine Einträge an diesem Tag'), findsOneWidget);
    expect(find.textContaining('Laub im Park'), findsNothing);
    await unmount(t);
  });

  testWidgets('with a birthday the day shows the share of life', (t) async {
    // 25 years old today.
    await pump(t, birthday: DateTime(2001, 11, 2));
    expect(find.text('100\u00a0% deines Lebens'), findsOneWidget);

    await t.tap(find.byTooltip('Voriger Monat'));
    await settle(t);
    await t.tap(day(28));
    await settle(t);
    // 99.95 % – but only today is 100.
    expect(find.text('99\u00a0% deines Lebens'), findsOneWidget);
    expect(find.text('Vor 5 Tagen'), findsOneWidget);
    await unmount(t);
  });

  testWidgets('without a birthday there is no share of life', (t) async {
    await pump(t);
    expect(find.textContaining('deines Lebens'), findsNothing);
    await unmount(t);
  });

  testWidgets('the arrows stop at the first entry and at the current month', (
    t,
  ) async {
    await pump(t);
    final next = find.widgetWithIcon(IconButton, Icons.chevron_right);
    final previous = find.widgetWithIcon(IconButton, Icons.chevron_left);
    expect(t.widget<IconButton>(next).onPressed, isNull);

    // November 2026 back to August 2025: 15 months.
    for (var i = 0; i < 15; i++) {
      await t.tap(previous);
      await settle(t);
    }
    expect(find.text('August 2025'), findsOneWidget);
    expect(t.widget<IconButton>(previous).onPressed, isNull);
    await t.tap(day(14));
    await settle(t);
    expect(find.text('Vor 445 Tagen'), findsOneWidget);
    expect(find.textContaining('Sommerreise'), findsOneWidget);

    // "Go to today" leads back.
    await t.tap(find.byTooltip('Zu heute springen'));
    await settle(t);
    expect(find.text('November 2026'), findsOneWidget);
    expect(find.text('Heute'), findsOneWidget);
    await unmount(t);
  });

  testWidgets('swiping to the right turns to the earlier month', (t) async {
    await pump(t);
    await t.fling(day(10), const Offset(300, 0), 1000);
    await settle(t);
    expect(find.text('Oktober 2026'), findsOneWidget);
    await unmount(t);
  });

  testWidgets('the year overview jumps to any month without paging', (t) async {
    await pump(t);
    // Tapping the month title shows the year with entries per month.
    await t.tap(find.text('November 2026'));
    await settle(t);
    expect(find.text('2026'), findsOneWidget);
    expect(find.text('3 Einträge in diesem Jahr'), findsOneWidget);
    expect(find.text('Okt'), findsOneWidget);

    // One year back: only August 2025 has an entry.
    await t.tap(find.byTooltip('Voriges Jahr'));
    await settle(t);
    expect(find.text('2025'), findsOneWidget);
    expect(find.text('1 Eintrag in diesem Jahr'), findsOneWidget);
    // Earlier than the first entry: no further back.
    expect(
      t
          .widget<IconButton>(
            find.widgetWithIcon(IconButton, Icons.chevron_left),
          )
          .onPressed,
      isNull,
    );

    await t.tap(find.text('Aug'));
    await settle(t);
    expect(find.text('August 2025'), findsOneWidget);
    await t.tap(day(14));
    await settle(t);
    expect(find.textContaining('Sommerreise'), findsOneWidget);
    await unmount(t);
  });

  testWidgets('back leaves the year overview before the calendar', (t) async {
    await pump(t);
    await t.tap(find.text('November 2026'));
    await settle(t);
    expect(find.text('2026'), findsOneWidget);
    await t.binding.handlePopRoute();
    await settle(t);
    expect(find.text('November 2026'), findsOneWidget);
    expect(find.text('2026'), findsNothing);
    await unmount(t);
  });
}
