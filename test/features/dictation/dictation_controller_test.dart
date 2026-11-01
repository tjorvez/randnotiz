import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:randnotiz/features/dictation/domain/dictation_service.dart';
import 'package:randnotiz/features/dictation/presentation/dictation_controller.dart';

import 'fake_dictation_service.dart';

void main() {
  late FakeDictationService service;
  late TextEditingController text;
  late DictationController controller;
  var changes = 0;

  setUp(() {
    service = FakeDictationService();
    text = TextEditingController(text: 'Am Strand.')
      ..selection = const TextSelection.collapsed(offset: 10);
    changes = 0;
    controller = DictationController(
      service: service,
      textController: text,
      onTextChanged: () => changes++,
    );
  });

  tearDown(() {
    controller.dispose();
    text.dispose();
  });

  group('permission flow', () {
    test('asks for a rationale before the system dialog', () async {
      expect(await controller.start(), DictationStartOutcome.needsRationale);
      expect(service.requestCount, 0, reason: 'no system dialog yet');

      expect(
        await controller.start(rationaleShown: true),
        DictationStartOutcome.started,
      );
      expect(service.requestCount, 1);
      expect(controller.isActive, isTrue);
    });

    test('declined system dialog is reported, not silent', () async {
      service.answerToRequest = MicPermission.canAsk;
      expect(
        await controller.start(rationaleShown: true),
        DictationStartOutcome.permissionDenied,
      );
      expect(controller.isActive, isFalse);
    });

    test('permanently denied leads to settings hint', () async {
      service.permission = MicPermission.permanentlyDenied;
      expect(
        await controller.start(),
        DictationStartOutcome.permissionPermanentlyDenied,
      );
    });

    test('no recognizer available', () async {
      service
        ..permission = MicPermission.granted
        ..available = false;
      expect(await controller.start(), DictationStartOutcome.unavailable);
      expect(controller.isActive, isFalse);
    });
  });

  group('while listening', () {
    setUp(() async {
      service.permission = MicPermission.granted;
      await controller.start();
    });

    test('partial and final results are inserted at the cursor', () {
      service.emit(const DictationText('die wellen', isFinal: false));
      expect(text.text, 'Am Strand. Die wellen');
      service.emit(const DictationText('die wellen waren hoch', isFinal: true));
      expect(text.text, 'Am Strand. Die wellen waren hoch');
      expect(controller.isActive, isFalse);
      expect(changes, 2);
    });

    test('interruption keeps the partial text (e.g. incoming call)', () async {
      service.emit(
        const DictationText('kurz bevor das telefon', isFinal: false),
      );
      await controller.interrupt();
      expect(service.stopped, isTrue);
      expect(controller.isActive, isFalse);
      expect(text.text, 'Am Strand. Kurz bevor das telefon');
    });

    test('a late final result after stop still lands', () async {
      service.emit(const DictationText('erst', isFinal: false));
      await controller.stop();
      service.emit(const DictationText('erst danach', isFinal: true));
      expect(text.text, 'Am Strand. Erst danach');
    });

    test('typing ends dictation and late results are ignored', () async {
      service.emit(const DictationText('hallo', isFinal: false));
      text.value = text.value.copyWith(text: '${text.text}!');
      await Future<void>.delayed(Duration.zero);
      expect(controller.isActive, isFalse);
      service.emit(const DictationText('hallo welt', isFinal: true));
      expect(text.text, 'Am Strand. Hallo!');
    });

    test('audio error ends the session but keeps text', () {
      service.emit(const DictationText('etwas', isFinal: false));
      service.emit(const DictationFailed('error_audio_error'));
      expect(controller.isActive, isFalse);
      expect(controller.lastProblem, DictationProblem.audio);
      expect(text.text, 'Am Strand. Etwas');
    });

    test('missing on-device German model falls back to system recognizer', () {
      service.emit(const DictationFailed('error_language_unavailable'));
      expect(service.starts, [true, false]);
      expect(controller.lastProblem, isNull);
      service.emit(const DictationText('geht doch', isFinal: true));
      expect(text.text, 'Am Strand. Geht doch');
    });

    test('a silent session that just ends is reported as "nothing heard"', () {
      service.emit(const DictationDone());
      expect(controller.isActive, isFalse);
      expect(controller.lastProblem, DictationProblem.noSpeechRecognized);
    });

    test('stopping by the user without speaking is not an error', () async {
      await controller.stop();
      service.emit(const DictationDone());
      expect(controller.lastProblem, isNull);
    });

    test('done after recognized text is not an error', () {
      service.emit(const DictationText('hallo', isFinal: false));
      service.emit(const DictationDone());
      expect(controller.lastProblem, isNull);
      expect(text.text, 'Am Strand. Hallo');
    });

    test('nothing recognized is reported', () {
      service.emit(const DictationFailed('error_no_match'));
      expect(controller.lastProblem, DictationProblem.noSpeechRecognized);
      expect(text.text, 'Am Strand.');
    });
  });
}
