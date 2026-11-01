import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

/// The last searches of the journal, newest first – stored only on this
/// device (app preferences), each removable, or all at once.
class RecentSearches {
  RecentSearches(this._prefs);

  final SharedPreferencesWithCache _prefs;

  static const preferenceKey = 'recentSearches';
  static const maxEntries = 10;

  List<String> load() {
    final raw = _prefs.getString(preferenceKey);
    if (raw == null) return const [];
    try {
      return [for (final e in jsonDecode(raw) as List) e as String];
    } on FormatException {
      return const [];
    }
  }

  /// Puts [text] first (once, ignoring case); keeps [maxEntries].
  Future<List<String>> add(String text) async {
    final clean = text.trim().replaceAll(RegExp(r'\s+'), ' ');
    if (clean.length < 2) return load();
    final next = [
      clean,
      for (final e in load())
        if (e.toLowerCase() != clean.toLowerCase()) e,
    ].take(maxEntries).toList();
    await _save(next);
    return next;
  }

  Future<List<String>> remove(String text) async {
    final next = [
      for (final e in load())
        if (e != text) e,
    ];
    await _save(next);
    return next;
  }

  Future<void> clear() => _prefs.remove(preferenceKey);

  Future<void> _save(List<String> entries) =>
      _prefs.setString(preferenceKey, jsonEncode(entries));
}
