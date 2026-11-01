import 'dart:ui';

import 'package:flutter_test/flutter_test.dart';
import 'package:randnotiz/core/debug/dev_tools.dart';

FrameTiming _frame({required int buildMs, required int rasterMs}) {
  const start = 1000000;
  return FrameTiming(
    vsyncStart: start,
    buildStart: start,
    buildFinish: start + buildMs * 1000,
    rasterStart: start + buildMs * 1000,
    rasterFinish: start + (buildMs + rasterMs) * 1000,
    rasterFinishWallTime: start + (buildMs + rasterMs) * 1000,
  );
}

void main() {
  test('frame summary reports p90 and janky frames', () {
    final frames = [
      for (var i = 0; i < 9; i++) _frame(buildMs: 2, rasterMs: 4),
      _frame(buildMs: 3, rasterMs: 20), // janky
    ];
    expect(
      FrameStatsLogger.summarize(frames),
      'RandnotizFrames: 10 frames, build p90 3.0 ms, raster p90 20.0 ms, '
      'slowest 20.0 ms, janky 1',
    );
  });
}
