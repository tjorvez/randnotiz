import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/providers.dart';
import '../data/geo_backfill.dart';

enum GeoBackfillStatus { idle, running, done, cancelled }

@immutable
class GeoBackfillState {
  const GeoBackfillState({
    this.status = GeoBackfillStatus.idle,
    this.done = 0,
    this.total = 0,
  });

  final GeoBackfillStatus status;
  final int done;
  final int total;

  bool get running => status == GeoBackfillStatus.running;
  double get progress => total == 0 ? 0 : done / total;
}

final geoBackfillProvider =
    NotifierProvider<GeoBackfillController, GeoBackfillState>(
      GeoBackfillController.new,
    );

/// Runs [GeoBackfill] in the background with progress and a cancel button.
/// It starts by itself once (after the update); afterwards only from the
/// settings. The outcome is remembered on the device.
class GeoBackfillController extends Notifier<GeoBackfillState> {
  /// Preference key; value "done" or "cancelled".
  static const preferenceKey = 'geoBackfill';

  bool _cancel = false;

  @override
  GeoBackfillState build() {
    final saved = ref.read(preferencesProvider).getString(preferenceKey);
    return GeoBackfillState(
      status: switch (saved) {
        'done' => GeoBackfillStatus.done,
        'cancelled' => GeoBackfillStatus.cancelled,
        _ => GeoBackfillStatus.idle,
      },
    );
  }

  /// Starts once after the update, unless it ran or was cancelled before.
  Future<void> startIfNeeded() async {
    if (state.status != GeoBackfillStatus.idle) return;
    final waiting = await ref.read(noteRepositoryProvider).notesNeedingGeo();
    if (waiting.isEmpty) {
      await _remember('done');
      state = const GeoBackfillState(status: GeoBackfillStatus.done);
      return;
    }
    await start();
  }

  /// Starts (or restarts) the back-fill now.
  Future<void> start() async {
    if (state.running) return;
    _cancel = false;
    state = const GeoBackfillState(status: GeoBackfillStatus.running);
    try {
      final result =
          await GeoBackfill(
            notes: ref.read(noteRepositoryProvider),
            photos: ref.read(photoRepositoryProvider),
            geo: await ref.read(geoDatabaseProvider.future),
          ).run(
            isCancelled: () => _cancel,
            onProgress: (done, total) => state = GeoBackfillState(
              status: GeoBackfillStatus.running,
              done: done,
              total: total,
            ),
          );
      final cancelled = _cancel && result.done < result.total;
      await _remember(cancelled ? 'cancelled' : 'done');
      state = GeoBackfillState(
        status: cancelled
            ? GeoBackfillStatus.cancelled
            : GeoBackfillStatus.done,
        done: result.done,
        total: result.total,
      );
    } on Exception catch (e) {
      debugPrint('Geo back-fill failed: $e');
      state = GeoBackfillState(
        status: GeoBackfillStatus.cancelled,
        done: state.done,
        total: state.total,
      );
    }
  }

  void cancel() => _cancel = true;

  Future<void> _remember(String value) =>
      ref.read(preferencesProvider).setString(preferenceKey, value);
}
