import 'dart:async';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:randnotiz/app/providers.dart';
import 'package:randnotiz/core/theme/app_theme.dart';
import 'package:randnotiz/core/theme/season.dart';
import 'package:randnotiz/features/library/domain/photo_repository.dart';
import 'package:randnotiz/features/memories/presentation/memories_screen.dart';
import 'package:randnotiz/features/notes/domain/note.dart';
import 'package:randnotiz/l10n/generated/app_localizations.dart';

/// A 1×1 transparent PNG.
final _pixel = Uint8List.fromList(const [
  0x89,
  0x50,
  0x4E,
  0x47,
  0x0D,
  0x0A,
  0x1A,
  0x0A,
  0x00,
  0x00,
  0x00,
  0x0D,
  0x49,
  0x48,
  0x44,
  0x52,
  0x00,
  0x00,
  0x00,
  0x01,
  0x00,
  0x00,
  0x00,
  0x01,
  0x08,
  0x06,
  0x00,
  0x00,
  0x00,
  0x1F,
  0x15,
  0xC4,
  0x89,
  0x00,
  0x00,
  0x00,
  0x0D,
  0x49,
  0x44,
  0x41,
  0x54,
  0x78,
  0x9C,
  0x63,
  0x00,
  0x01,
  0x00,
  0x00,
  0x05,
  0x00,
  0x01,
  0x0D,
  0x0A,
  0x2D,
  0xB4,
  0x00,
  0x00,
  0x00,
  0x00,
  0x49,
  0x45,
  0x4E,
  0x44,
  0xAE,
  0x42,
  0x60,
  0x82,
]);

class _Photos implements PhotoRepository {
  @override
  ImageProvider imageFor(PhotoItem item, {int? size}) => MemoryImage(_pixel);

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

NoteSummary _note(int id, DateTime date, {String? title}) => NoteSummary(
  id: id,
  assetId: 'a$id',
  date: date,
  preview: 'Notiz Nummer $id',
  tags: const [],
  title: title,
  photoAspect: 0.75,
);

void main() {
  final today = DateTime(2026, 10, 31, 10);

  Future<void> pump(
    WidgetTester t,
    List<NoteSummary> notes, {
    Brightness brightness = Brightness.light,
  }) async {
    t.view.physicalSize = const Size(1080, 2412);
    t.view.devicePixelRatio = 3;
    addTearDown(t.view.reset);
    await t.pumpWidget(
      ProviderScope(
        overrides: [
          allNotesProvider.overrideWith((ref) => Stream.value(notes)),
          clockProvider.overrideWithValue(() => today),
          photoRepositoryProvider.overrideWithValue(_Photos()),
          memorySessionSeedProvider.overrideWithValue(42),
        ],
        child: MaterialApp(
          theme: AppTheme.build(brightness, Season.autumn),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          locale: const Locale('de'),
          home: const Scaffold(body: MemoriesScreen()),
        ),
      ),
    );
    await t.pump();
    await t.pump();
  }

  testWidgets('no entries: a friendly empty state', (t) async {
    await pump(t, const []);
    expect(find.text('Noch keine Erinnerungen'), findsOneWidget);
    expect(find.byType(PageView), findsNothing);
  });

  for (final brightness in Brightness.values) {
    testWidgets('pages snap vertically, sections are marked ($brightness)', (
      t,
    ) async {
      await pump(t, [
        _note(1, DateTime(2024, 10, 31), title: 'Kürbisfest'),
        _note(2, DateTime(2025, 10, 31)),
        _note(3, DateTime(2025, 11, 2)),
        for (var i = 4; i < 12; i++) _note(i, DateTime(2026, 2, i)),
      ], brightness: brightness);

      // Page 1: one year ago, with the quiet divider of the first part.
      expect(find.text('An diesem Tag'), findsOneWidget);
      // The divider's label sits in the middle of the page.
      expect(
        t.getCenter(find.text('An diesem Tag')).dx,
        closeTo(t.getCenter(find.byType(PageView)).dx, 1),
      );
      expect(find.text('Vor 1 Jahr'), findsOneWidget);
      expect(find.text('Nach oben wischen für mehr'), findsOneWidget);

      final height = t.getSize(find.byType(PageView)).height;
      double page() =>
          t.widget<PageView>(find.byType(PageView)).controller!.page!;

      // A short drag is not enough: it snaps back.
      await t.drag(find.byType(PageView), Offset(0, -height * 0.2));
      await t.pumpAndSettle();
      expect(page(), 0);

      // A longer one snaps to the next page.
      await t.drag(find.byType(PageView), Offset(0, -height * 0.6));
      await t.pumpAndSettle();
      expect(page(), 1);
      expect(find.text('Vor 2 Jahren'), findsOneWidget);
      expect(find.text('Kürbisfest'), findsOneWidget);

      await t.drag(find.byType(PageView), Offset(0, -height * 0.6));
      await t.pumpAndSettle();
      expect(find.text('Rund um diesen Tag'), findsOneWidget);
      expect(find.textContaining('Jahrestag in 2 Tagen'), findsOneWidget);

      await t.drag(find.byType(PageView), Offset(0, -height * 0.6));
      await t.pumpAndSettle();
      expect(find.text('Weitere Erinnerungen'), findsOneWidget);
      expect(t.takeException(), isNull);
    });
  }

  testWidgets('at most three pages are built at a time', (t) async {
    await pump(t, [
      for (var i = 1; i < 30; i++) _note(i, DateTime(2020 + i % 6, 10, 31)),
    ]);
    final height = t.getSize(find.byType(PageView)).height;
    for (var step = 0; step < 6; step++) {
      final built = find
          .byType(MemoryPageView, skipOffstage: false)
          .evaluate()
          .length;
      expect(built, lessThanOrEqualTo(3), reason: 'step $step');
      await t.drag(find.byType(PageView), Offset(0, -height * 0.6));
      await t.pumpAndSettle();
    }
  });
}
