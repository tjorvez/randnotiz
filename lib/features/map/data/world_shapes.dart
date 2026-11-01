import 'dart:isolate';
import 'dart:typed_data';
import 'dart:ui';

import 'package:flutter/services.dart';

import '../domain/projection.dart';

/// Simplified land outlines of the world (Natural Earth 1:50m, public
/// domain), bundled as `assets/map/land.bin` – the map works offline and
/// needs no tile server. Built by `tools/build_world_map.py`.
class WorldShapes {
  WorldShapes(this.rings);

  /// Each ring as interleaved longitude/latitude pairs in degrees.
  final List<Float32List> rings;

  static const asset = 'assets/map/land.bin';

  static Future<WorldShapes> load([AssetBundle? bundle]) async {
    final data = await (bundle ?? rootBundle).load(asset);
    // Decoding all rings takes a noticeable moment – not on the UI thread.
    return WorldShapes(await Isolate.run(() => parse(data)));
  }

  static List<Float32List> parse(ByteData data) {
    const magic = [0x52, 0x4E, 0x4C, 0x31]; // "RNL1"
    for (var i = 0; i < 4; i++) {
      if (data.getUint8(i) != magic[i]) {
        throw const FormatException('Not a Randnotiz land file');
      }
    }
    var offset = 4;
    final count = data.getUint32(offset, Endian.little);
    offset += 4;
    final rings = <Float32List>[];
    for (var r = 0; r < count; r++) {
      final n = data.getUint32(offset, Endian.little);
      offset += 4;
      final ring = Float32List(n * 2);
      for (var i = 0; i < n; i++) {
        ring[i * 2] = data.getInt16(offset, Endian.little) / 100;
        ring[i * 2 + 1] = data.getInt16(offset + 2, Endian.little) / 100;
        offset += 4;
      }
      rings.add(ring);
    }
    return rings;
  }

  /// All land as one path in the coordinates of [projection].
  Path toPath(EqualEarth projection) {
    final path = Path()..fillType = PathFillType.nonZero;
    for (final ring in rings) {
      final first = projection.project(ring[0], ring[1]);
      path.moveTo(first.dx, first.dy);
      for (var i = 2; i < ring.length; i += 2) {
        final p = projection.project(ring[i], ring[i + 1]);
        path.lineTo(p.dx, p.dy);
      }
      path.close();
    }
    return path;
  }
}
