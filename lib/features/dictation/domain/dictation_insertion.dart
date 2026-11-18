import 'package:flutter/services.dart';

/// Inserts dictated text at the cursor position of a text field.
///
/// A session is created when dictation starts. It remembers the text before
/// and after the cursor (a selection is replaced). Every recognition result –
/// partial or final – is applied relative to that start state, so a newer
/// partial result simply replaces the older one and no text is duplicated.
///
/// Because partial results are written into the field immediately, nothing
/// is lost if recognition stops unexpectedly (call, app in background): the
/// last applied value simply stays.
class DictationInsertion {
  DictationInsertion._(this._before, this._after);

  /// Starts a session at the current cursor/selection of [value]. Without a
  /// valid selection the text is appended at the end.
  factory DictationInsertion.start(TextEditingValue value) {
    final text = value.text;
    final sel = value.selection;
    if (!sel.isValid) return DictationInsertion._(text, '');
    final start = sel.start.clamp(0, text.length);
    final end = sel.end.clamp(start, text.length);
    return DictationInsertion._(text.substring(0, start), text.substring(end));
  }

  final String _before;
  final String _after;

  /// The value last produced by [apply], used to detect manual edits.
  TextEditingValue? lastApplied;

  static final _sentenceEnd = RegExp(r'[.!?…]\s*$');
  static final _startsWithPunctuation = RegExp(r'^[.,;:!?…)\]}»“"]');

  /// Returns the field value with [recognized] inserted.
  TextEditingValue apply(String recognized) {
    var insert = recognized.trim().replaceAll(RegExp(r'\s+'), ' ');
    if (insert.isEmpty) {
      final value = TextEditingValue(
        text: _before + _after,
        selection: TextSelection.collapsed(offset: _before.length),
      );
      return lastApplied = value;
    }

    if (_shouldCapitalize()) {
      insert = insert[0].toUpperCase() + insert.substring(1);
    }

    final needsSpaceBefore =
        _before.isNotEmpty &&
        !_before.endsWith(' ') &&
        !_before.endsWith('\n') &&
        !_before.endsWith('\t') &&
        !_before.endsWith('(') &&
        !_startsWithPunctuation.hasMatch(insert);
    final needsSpaceAfter =
        _after.isNotEmpty &&
        !_after.startsWith(' ') &&
        !_after.startsWith('\n') &&
        !_startsWithPunctuation.hasMatch(_after);

    final inserted =
        '${needsSpaceBefore ? ' ' : ''}$insert${needsSpaceAfter ? ' ' : ''}';
    final cursor =
        _before.length +
        inserted.length -
        (needsSpaceAfter ? 1 : 0); // cursor right after the dictated words
    final value = TextEditingValue(
      text: _before + inserted + _after,
      selection: TextSelection.collapsed(offset: cursor),
    );
    return lastApplied = value;
  }

  /// Whether [current] still equals what dictation wrote last. If not, the
  /// user edited the text and the session should end.
  bool isUnchanged(TextEditingValue current) =>
      lastApplied == null || current.text == lastApplied!.text;

  bool _shouldCapitalize() {
    final trimmed = _before.trimRight();
    if (trimmed.isEmpty) return true;
    if (_before.endsWith('\n')) return true;
    return _sentenceEnd.hasMatch(trimmed);
  }
}
