import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter/scheduler.dart';

/// Development helpers. Everything here is inert in release builds.
abstract final class DevTools {
  /// Debug builds: `--dart-define=RANDNOTIZ_DEBUG_SLOW_ANIMATIONS=5` starts
  /// with all animations five times slower (to look at them frame by frame).
  static const _slowFactor = String.fromEnvironment(
    'RANDNOTIZ_DEBUG_SLOW_ANIMATIONS',
  );

  static void install() {
    if (kDebugMode) {
      final factor = double.tryParse(_slowFactor);
      if (factor != null && factor >= 1) timeDilation = factor;
    }
    if (kProfileMode) FrameStatsLogger.install();
  }
}

/// Profile builds only: writes a short frame summary to the log every
/// [window] frames in which something happened, e.g.
/// `RandnotizFrames: 120 frames, build p90 3.1 ms, raster p90 5.2 ms,
/// slowest 9.8 ms, janky 0`. A frame is janky if build or raster takes
/// longer than one 60 Hz frame (16.7 ms). Read with `adb logcat -s flutter`.
class FrameStatsLogger {
  FrameStatsLogger._();

  static const window = 120;
  static const budget = Duration(microseconds: 16667);

  static final _frames = <FrameTiming>[];

  static void install() {
    SchedulerBinding.instance.addTimingsCallback(_onTimings);
  }

  static void _onTimings(List<FrameTiming> timings) {
    _frames.addAll(timings);
    if (_frames.length < window) return;
    debugPrint(summarize(_frames));
    _frames.clear();
  }

  /// One log line for [frames] (public for tests).
  static String summarize(List<FrameTiming> frames) {
    List<int> sorted(Iterable<int> v) => v.toList()..sort();
    final build = sorted(frames.map((f) => f.buildDuration.inMicroseconds));
    final raster = sorted(frames.map((f) => f.rasterDuration.inMicroseconds));
    int p90(List<int> v) => v[min(v.length - 1, (v.length * 0.9).floor())];
    String ms(int us) => (us / 1000).toStringAsFixed(1);
    final janky = frames
        .where((f) => f.buildDuration > budget || f.rasterDuration > budget)
        .length;
    final slowest = max(build.last, raster.last);
    return 'RandnotizFrames: ${frames.length} frames, '
        'build p90 ${ms(p90(build))} ms, raster p90 ${ms(p90(raster))} ms, '
        'slowest ${ms(slowest)} ms, janky $janky';
  }
}
