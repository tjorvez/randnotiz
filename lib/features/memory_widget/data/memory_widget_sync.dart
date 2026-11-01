import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart' show Locale;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:home_widget/home_widget.dart';

import '../../../app/providers.dart';
import '../../../core/format/formatters.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../../notes/domain/note.dart';
import '../../settings/presentation/settings_controller.dart';
import '../domain/widget_entries.dart';

const memoryWidgetProvider =
    'io.github.randnotiz.app.widget.MemoryWidgetProvider';
const memoryWidgetUri = 'randnotiz://memories';

/// Writes the pre-computed widget entries for the next days into the widget's
/// SharedPreferences and asks Android to redraw the widget.
///
/// The note text is only written if the user enabled "Textvorschau im
/// Widget"; otherwise it never leaves the app's database.
class MemoryWidgetSync {
  MemoryWidgetSync(this._ref);

  final Ref _ref;
  Timer? _debounce;

  void scheduleRefresh() {
    _debounce?.cancel();
    _debounce = Timer(const Duration(seconds: 1), () => unawaited(refresh()));
  }

  Future<void> refresh() async {
    try {
      final notes = await _ref
          .read(noteRepositoryProvider)
          .watchJournal(const JournalQuery())
          .first;
      final settings = _ref.read(settingsProvider);
      final store = _ref.read(thumbnailStoreProvider);
      final l10n = lookupAppLocalizations(const Locale('de'));
      final today = _ref.read(clockProvider)();

      final entries = buildWidgetEntries(
        notes: notes,
        today: today,
        includeText: settings.widgetShowsText,
        dateLabel: Fmt.longDate,
        agoLabel: (note, day, years) => years != null
            ? l10n.yearsAgo(years)
            : Fmt.ago(l10n, note.date, day),
        photoPath: (note) => note.thumbnailFile == null
            ? null
            : store.fileFor(note.thumbnailFile!).path,
      );

      await HomeWidget.saveWidgetData<String>(
        'memory_entries',
        jsonEncode([for (final e in entries) e.toJson()]),
      );
      await HomeWidget.updateWidget(qualifiedAndroidName: memoryWidgetProvider);
      // Redraw shortly after each upcoming midnight so the widget switches to
      // the next day's memory even if the app is not opened.
      await HomeWidget.scheduleWidgetUpdates([
        for (var i = 1; i <= 7; i++)
          DateTime(today.year, today.month, today.day + i, 0, 1),
      ], qualifiedAndroidName: memoryWidgetProvider);
    } on PlatformException catch (e) {
      debugPrint('Widget sync failed: $e');
    } on MissingPluginException {
      // tests
    }
  }

  void dispose() => _debounce?.cancel();
}

/// Keeps the widget in sync while the app runs: on notes and settings changes.
final memoryWidgetSyncProvider = Provider<MemoryWidgetSync>((ref) {
  final sync = MemoryWidgetSync(ref);
  ref.listen(allNotesProvider, (_, _) => sync.scheduleRefresh());
  ref.listen(
    settingsProvider.select((s) => s.widgetShowsText),
    (_, _) => sync.scheduleRefresh(),
  );
  ref.onDispose(sync.dispose);
  return sync;
});
