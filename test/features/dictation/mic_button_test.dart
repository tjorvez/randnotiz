import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:randnotiz/features/dictation/domain/dictation_service.dart';
import 'package:randnotiz/features/dictation/presentation/dictation_controller.dart';
import 'package:randnotiz/features/dictation/presentation/mic_button.dart';
import 'package:randnotiz/l10n/generated/app_localizations.dart';

import 'fake_dictation_service.dart';

void main() {
  late FakeDictationService service;
  late TextEditingController text;
  late DictationController controller;

  setUp(() {
    service = FakeDictationService()..permission = MicPermission.granted;
    text = TextEditingController(text: 'Am Hafen.')
      ..selection = const TextSelection.collapsed(offset: 9);
    controller = DictationController(service: service, textController: text);
  });

  tearDown(() {
    controller.dispose();
    text.dispose();
  });

  Future<void> pumpEditor(WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        locale: const Locale('de'),
        home: Scaffold(
          body: TextField(controller: text),
          floatingActionButton: MicButton(
            controller: controller,
            service: service,
          ),
        ),
      ),
    );
  }

  double opacityOfButton(WidgetTester tester) => tester
      .widget<AnimatedOpacity>(
        find.ancestor(
          of: find.byType(FloatingActionButton),
          matching: find.byType(AnimatedOpacity),
        ),
      )
      .opacity;

  bool ignoresTaps(WidgetTester tester) => tester
      .widget<IgnorePointer>(
        find
            .ancestor(
              of: find.byType(FloatingActionButton),
              matching: find.byType(IgnorePointer),
            )
            .first,
      )
      .ignoring;

  void openKeyboard(WidgetTester tester) =>
      tester.view.viewInsets = const FakeViewPadding(bottom: 900);

  testWidgets(
    'opening the keyboard hides the button and ends dictation without '
    'losing text',
    (tester) async {
      addTearDown(tester.view.reset);
      await pumpEditor(tester);
      expect(opacityOfButton(tester), 1);

      await tester.tap(find.byType(FloatingActionButton));
      await tester.pump();
      expect(controller.isActive, isTrue);

      service.emit(const DictationText('möwen kreischen', isFinal: false));
      await tester.pump();
      expect(text.text, 'Am Hafen. Möwen kreischen');

      // The user taps into the text: the keyboard comes up.
      openKeyboard(tester);
      await tester.pump();
      expect(service.stopped, isTrue);
      expect(controller.isActive, isFalse);
      expect(text.text, 'Am Hafen. Möwen kreischen', reason: 'nothing lost');

      // A final result arriving after the stop is still applied.
      service.emit(const DictationText('möwen kreischen laut', isFinal: true));
      await tester.pump();
      expect(text.text, 'Am Hafen. Möwen kreischen laut');

      await tester.pumpAndSettle();
      expect(opacityOfButton(tester), 0);
      expect(ignoresTaps(tester), isTrue);

      // Keyboard closes: the button comes back.
      tester.view.resetViewInsets();
      await tester.pumpAndSettle();
      expect(opacityOfButton(tester), 1);
      expect(ignoresTaps(tester), isFalse);
    },
  );

  testWidgets('opening the keyboard while idle only hides the button', (
    tester,
  ) async {
    addTearDown(tester.view.reset);
    await pumpEditor(tester);
    openKeyboard(tester);
    await tester.pumpAndSettle();
    expect(service.stopped, isFalse);
    expect(opacityOfButton(tester), 0);
  });
}
