#!/usr/bin/env python3
"""Builds assets/map/land.bin from Natural Earth land outlines (public domain).

    curl -sSLo <quelle>/ne_50m_land.geojson \
      https://raw.githubusercontent.com/nvkelso/natural-earth-vector/master/geojson/ne_50m_land.geojson
    python3 tools/build_world_map.py <quelle>/ne_50m_land.geojson assets/map/land.bin

Format (little endian), read by lib/features/map/data/world_shapes.dart:
    b"RNL1", uint32 ringCount,
    per ring: uint32 pointCount, pointCount x (int16 lon*100, int16 lat*100)

Rings are simplified (Douglas-Peucker), tiny islands and Antarctica dropped.
"""

import json
import struct
import sys

TOLERANCE = 0.04  # degrees
MIN_AREA = 0.15  # square degrees; smaller islands are left out
SOUTH_LIMIT = -60.0


def simplify(points, tol):
    if len(points) < 3:
        return points
    keep = [False] * len(points)
    keep[0] = keep[-1] = True
    stack = [(0, len(points) - 1)]
    while stack:
        a, b = stack.pop()
        ax, ay = points[a]
        bx, by = points[b]
        dx, dy = bx - ax, by - ay
        norm = (dx * dx + dy * dy) ** 0.5
        best, idx = -1.0, -1
        for i in range(a + 1, b):
            px, py = points[i]
            if norm == 0:
                d = ((px - ax) ** 2 + (py - ay) ** 2) ** 0.5
            else:
                d = abs(dy * px - dx * py + bx * ay - by * ax) / norm
            if d > best:
                best, idx = d, i
        if best > tol and idx > 0:
            keep[idx] = True
            stack.append((a, idx))
            stack.append((idx, b))
    return [p for p, k in zip(points, keep) if k]


def area(ring):
    s = 0.0
    for (x1, y1), (x2, y2) in zip(ring, ring[1:] + ring[:1]):
        s += x1 * y2 - x2 * y1
    return abs(s) / 2


def rings_of(geometry):
    if geometry["type"] == "Polygon":
        yield from geometry["coordinates"][:1]  # outer ring only
    elif geometry["type"] == "MultiPolygon":
        for poly in geometry["coordinates"]:
            yield poly[0]


def main(src, dest):
    with open(src, encoding="utf-8") as f:
        data = json.load(f)
    rings = []
    for feature in data["features"]:
        for ring in rings_of(feature["geometry"]):
            pts = [(float(x), float(y)) for x, y in ring]
            if max(y for _, y in pts) < SOUTH_LIMIT:
                continue
            if area(pts) < MIN_AREA:
                continue
            pts = simplify(pts, TOLERANCE)
            if len(pts) >= 4:
                rings.append(pts)
    out = bytearray(b"RNL1")
    out += struct.pack("<I", len(rings))
    total = 0
    for ring in rings:
        out += struct.pack("<I", len(ring))
        for x, y in ring:
            out += struct.pack("<hh", round(x * 100), round(y * 100))
        total += len(ring)
    with open(dest, "wb") as f:
        f.write(out)
    print(f"{len(rings)} rings, {total} points, {len(out)} bytes")


if __name__ == "__main__":
    main(sys.argv[1], sys.argv[2])
