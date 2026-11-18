import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:randnotiz/features/dictation/domain/dictation_insertion.dart';
import 'package:randnotiz/features/dictation/domain/dictation_service.dart';

TextEditingValue at(String text, int cursor) => TextEditingValue(
  text: text,
  selection: TextSelection.collapsed(offset: cursor),
);

void main() {
  group('DictationInsertion', () {
    test('empty field: capitalised, cursor at end', () {
      final s = DictationInsertion.start(at('', 0));
      final v = s.apply('heute war ein schöner tag');
      expect(v.text, 'Heute war ein schöner tag');
      expect(v.selection.baseOffset, v.text.length);
    });

    test('appends after a word with one space', () {
      final s = DictationInsertion.start(at('Wir waren', 9));
      expect(s.apply('am See').text, 'Wir waren am See');
    });

    test('capitalises after sentence end', () {
      final s = DictationInsertion.start(at('Es regnete.', 11));
      expect(
        s.apply('danach kam die sonne').text,
        'Es regnete. Danach kam die sonne',
      );
    });

    test('capitalises at start of a new line', () {
      final s = DictationInsertion.start(at('Zeile eins\n', 11));
      expect(s.apply('zweite zeile').text, 'Zeile eins\nZweite zeile');
    });

    test('inserts in the middle with spaces on both sides', () {
      final s = DictationInsertion.start(at('Wir gingen nach Hause', 10));
      final v = s.apply('langsam');
      expect(v.text, 'Wir gingen langsam nach Hause');
      expect(v.selection.baseOffset, 'Wir gingen langsam'.length);
    });

    test('no extra space before following punctuation', () {
      final s = DictationInsertion.start(at('Es war schön.', 12));
      expect(s.apply('und warm').text, 'Es war schön und warm.');
    });

    test('partial results replace each other instead of piling up', () {
      final s = DictationInsertion.start(at('Notiz:', 6));
      s.apply('wir');
      s.apply('wir fahren');
      final v = s.apply('wir fahren morgen');
      expect(v.text, 'Notiz: wir fahren morgen');
    });

    test('a selection is replaced', () {
      const value = TextEditingValue(
        text: 'Das war XXX gut',
        selection: TextSelection(baseOffset: 8, extentOffset: 11),
      );
      final s = DictationInsertion.start(value);
      expect(s.apply('richtig').text, 'Das war richtig gut');
    });

    test('invalid selection appends at the end', () {
      final s = DictationInsertion.start(const TextEditingValue(text: 'Ende'));
      expect(s.apply('noch etwas').text, 'Ende noch etwas');
    });

    test('empty result restores original text', () {
      final s = DictationInsertion.start(at('abc', 3));
      s.apply('hallo');
      expect(s.apply('  ').text, 'abc');
    });

    test('whitespace in recognized text is normalised', () {
      final s = DictationInsertion.start(at('', 0));
      expect(s.apply('  zwei   leerzeichen ').text, 'Zwei leerzeichen');
    });

    test('detects manual edits', () {
      final s = DictationInsertion.start(at('', 0));
      final v = s.apply('hallo');
      expect(s.isUnchanged(v), isTrue);
      expect(s.isUnchanged(at('hallo!', 6)), isFalse);
    });
  });

  group('error mapping', () {
    test('known Android error codes', () {
      expect(
        problemFromErrorCode('error_no_match'),
        DictationProblem.noSpeechRecognized,
      );
      expect(
        problemFromErrorCode('error_speech_timeout'),
        DictationProblem.noSpeechRecognized,
      );
      expect(
        problemFromErrorCode('error_network_timeout'),
        DictationProblem.network,
      );
      expect(
        problemFromErrorCode('error_server_disconnected'),
        DictationProblem.network,
      );
      expect(
        problemFromErrorCode('error_permission'),
        DictationProblem.permissionDenied,
      );
      expect(problemFromErrorCode('error_busy'), DictationProblem.busy);
      expect(
        problemFromErrorCode('error_language_unavailable'),
        DictationProblem.languageUnsupported,
      );
      expect(problemFromErrorCode('error_audio_error'), DictationProblem.audio);
      expect(
        problemFromErrorCode('error_unknown (13)'),
        DictationProblem.unknown,
      );
    });

    test('on-device language errors trigger the fallback', () {
      expect(isOnDeviceLanguageError('error_language_not_supported'), isTrue);
      expect(isOnDeviceLanguageError('error_no_match'), isFalse);
    });
  });
}
