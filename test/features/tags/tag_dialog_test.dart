import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:randnotiz/core/theme/app_theme.dart';
import 'package:randnotiz/core/theme/season.dart';
import 'package:randnotiz/features/tags/domain/tag.dart';
import 'package:randnotiz/features/tags/presentation/tag_dialogs.dart';
import 'package:randnotiz/l10n/generated/app_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  Future<void> openDialog(WidgetTester tester, Brightness brightness) async {
    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          theme: AppTheme.build(brightness, Season.autumn),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          locale: const Locale('de'),
          home: Builder(
            builder: (context) => Scaffold(
              body: TextButton(
                onPressed: () => showTagEditDialog(context),
                child: const Text('open'),
              ),
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();
  }

  for (final brightness in Brightness.values) {
    testWidgets('new Stimmung: emoji follows the name until one is picked '
        '($brightness)', (tester) async {
      await openDialog(tester, brightness);
      expect(find.text('😊'), findsOneWidget, reason: 'default emoji');

      await tester.enterText(find.byType(TextField), 'Pflanzen');
      await tester.pumpAndSettle();
      expect(find.text('🌱'), findsOneWidget);

      // The full picker: categories, search, recently used.
      await tester.tap(find.text('🌱'));
      await tester.pumpAndSettle();
      expect(find.byType(EmojiPicker), findsOneWidget);
      expect(find.text('Emoji wählen'), findsOneWidget);
      await tester.tap(find.text('😀').first);
      await tester.pumpAndSettle();
      expect(find.byType(EmojiPicker), findsNothing);
      expect(find.text('😀'), findsOneWidget);

      // A picked emoji is kept even if the name changes.
      await tester.enterText(find.byType(TextField), 'Garten');
      await tester.pumpAndSettle();
      expect(find.text('😀'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  }

  test('there is no fixed emoji set any more', () {
    // Stimmungen take any emoji (the old 32-emoji list is gone).
    const tag = Tag(id: 1, name: 'Weltraum', emoji: '🪐');
    expect(tag.label, '🪐 Weltraum');
  });
}
