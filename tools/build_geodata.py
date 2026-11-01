#!/usr/bin/env python3
"""Builds the offline geodata of Randnotiz from public sources.

Output (checked in, read by lib/features/geo/data/geo_assets.dart):
  assets/geo/countries.bin  country outlines + German/English names
  assets/geo/places.bin     towns with >= 15 000 inhabitants

Sources (NOT checked in – download them into one directory):
  Natural Earth 1:50m, public domain (https://www.naturalearthdata.com):
    https://raw.githubusercontent.com/nvkelso/natural-earth-vector/master/geojson/ne_50m_admin_0_countries.geojson
    https://raw.githubusercontent.com/nvkelso/natural-earth-vector/master/geojson/ne_50m_admin_0_tiny_countries.geojson
  GeoNames, CC BY 4.0 (https://www.geonames.org):
    https://download.geonames.org/export/dump/cities15000.zip
    https://download.geonames.org/export/dump/alternateNamesV2.zip  (~200 MB)

Usage:
    python3 -I tools/build_geodata.py <source-dir> assets/geo

Formats (little endian; strings are uint8 length + UTF-8):
  countries.bin: b"RNC1", uint16 count, per country:
      2 bytes ISO 3166-1 alpha-2 code, uint8 flags (1 = small: draw a marker),
      int16 markerLon*100, int16 markerLat*100, str nameDe, str nameEn,
      uint16 ringCount, per ring: uint32 n, n x (int16 lon*100, int16 lat*100)
  places.bin: b"RNP1", uint32 count, per place:
      int32 lat*1e5, int32 lon*1e5, 2 bytes country code, uint32 population,
      str nameDe, str nameEn (empty if equal to nameDe)

Outlines are simplified (Douglas-Peucker) and rounded to 0.01 degrees
(about 1 km) – enough for a 1:50m world map and for telling countries
apart. Rings of a country are stored together; holes (e.g. Lesotho in
South Africa) work with the even-odd rule.
"""

import io
import json
import math
import struct
import sys
import zipfile

TOLERANCE = 0.01  # degrees, Douglas-Peucker
SMALL_AREA = 1.2  # square degrees: below this a country also gets a marker

# Natural Earth uses -99 for a few ISO codes; these are the codes we use.
CODE_FIXES = {
    'Somaliland': 'SO',
    'N. Cyprus': 'CY',
}
SKIP = {'Siachen Glacier'}

# GeoNames feature codes left out: sections of a city ("Hamburg-Rotherbaum"
# instead of Hamburg), historical, abandoned and destroyed places.
SKIP_FEATURES = {'PPLX', 'PPLH', 'PPLQ', 'PPLW'}

# Names where merged areas (e.g. Northern Cyprus into Cyprus) would otherwise
# name the country after a part of it.
NAME_OVERRIDES = {
    'CY': ('Zypern', 'Cyprus'),
    'SO': ('Somalia', 'Somalia'),
    'US': ('Vereinigte Staaten', 'United States'),
}


def simplify(points, tol):
    """Douglas-Peucker on a closed ring (first point == last point)."""
    if len(points) <= 4:
        return points
    keep = [False] * len(points)
    keep[0] = keep[-1] = True
    stack = [(0, len(points) - 1)]
    while stack:
        a, b = stack.pop()
        ax, ay = points[a]
        bx, by = points[b]
        dx, dy = bx - ax, by - ay
        norm = math.hypot(dx, dy)
        best, idx = -1.0, -1
        for i in range(a + 1, b):
            px, py = points[i]
            if norm == 0:
                d = math.hypot(px - ax, py - ay)
            else:
                d = abs(dy * px - dx * py + bx * ay - by * ax) / norm
            if d > best:
                best, idx = d, i
        if best > tol and idx > 0:
            keep[idx] = True
            stack.append((a, idx))
            stack.append((idx, b))
    out = [p for p, k in zip(points, keep) if k]
    return out if len(out) >= 4 else points


def ring_area(points):
    s = 0.0
    for (x1, y1), (x2, y2) in zip(points, points[1:]):
        s += x1 * y2 - x2 * y1
    return abs(s) / 2


def quantize(points):
    q = []
    for lon, lat in points:
        p = (round(lon * 100), round(lat * 100))
        if not q or q[-1] != p:
            q.append(p)
    return q


def code_of(props):
    name = props.get('NAME')
    if name in CODE_FIXES:
        return CODE_FIXES[name]
    for key in ('ISO_A2', 'ISO_A2_EH'):
        code = props.get(key)
        if code and len(code) == 2 and code.isalpha():
            return code.upper()
    return None


def put_str(out, s):
    data = (s or '').encode('utf-8')[:255]
    out += struct.pack('<B', len(data))
    out += data


def build_countries(src):
    countries = {}
    with open(f'{src}/ne_50m_admin_0_countries.geojson', encoding='utf-8') as f:
        features = json.load(f)['features']
    for ft in features:
        props = ft['properties']
        if props.get('NAME') in SKIP:
            continue
        code = code_of(props)
        if code is None:
            print('skipped (no code):', props.get('NAME'), file=sys.stderr)
            continue
        geom = ft['geometry']
        polys = geom['coordinates'] if geom['type'] == 'MultiPolygon' else [geom['coordinates']]
        c = countries.setdefault(code, {
            'de': props.get('NAME_DE') or props.get('NAME'),
            'en': props.get('NAME_EN') or props.get('NAME'),
            'rings': [],
            'area': 0.0,
            'label': (props.get('LABEL_X'), props.get('LABEL_Y')),
            'small': False,
        })
        # The main entry (the sovereign state itself) names the country.
        if props.get('TYPE') in ('Sovereign country', 'Country'):
            c['de'] = props.get('NAME_DE') or c['de']
            c['en'] = props.get('NAME_EN') or c['en']
            c['label'] = (props.get('LABEL_X'), props.get('LABEL_Y'))
        for poly in polys:
            for ring in poly:
                pts = [(float(x), float(y)) for x, y in ring]
                c['area'] += ring_area(pts)
                q = quantize(simplify(pts, TOLERANCE))
                if len(q) >= 4:
                    c['rings'].append(q)

    with open(f'{src}/ne_50m_admin_0_tiny_countries.geojson', encoding='utf-8') as f:
        tiny = json.load(f)['features']
    for ft in tiny:
        props = ft['properties']
        code = code_of(props)
        if code is None:
            continue
        lon, lat = ft['geometry']['coordinates']
        c = countries.get(code)
        if c is None:
            countries[code] = {
                'de': props.get('NAME_DE') or props.get('NAME'),
                'en': props.get('NAME_EN') or props.get('NAME'),
                'rings': [],
                'area': 0.0,
                'label': (lon, lat),
                'small': True,
            }
        elif c['area'] < SMALL_AREA:
            c['small'] = True
            c['label'] = (lon, lat)
    for code, c in countries.items():
        if c['area'] < SMALL_AREA:
            c['small'] = True
        if code in NAME_OVERRIDES:
            c['de'], c['en'] = NAME_OVERRIDES[code]
    return countries


def write_countries(countries, path):
    out = bytearray(b'RNC1')
    out += struct.pack('<H', len(countries))
    points = 0
    for code in sorted(countries):
        c = countries[code]
        lon, lat = c['label']
        out += code.encode('ascii')
        out += struct.pack('<B', 1 if c['small'] else 0)
        out += struct.pack('<hh', round((lon or 0) * 100), round((lat or 0) * 100))
        put_str(out, c['de'])
        put_str(out, c['en'])
        out += struct.pack('<H', len(c['rings']))
        for ring in c['rings']:
            out += struct.pack('<I', len(ring))
            for x, y in ring:
                out += struct.pack('<hh', x, y)
            points += len(ring)
    with open(path, 'wb') as f:
        f.write(out)
    print(f'{path}: {len(countries)} countries, {points} points, {len(out)} bytes')


def read_places(src, codes):
    with zipfile.ZipFile(f'{src}/cities15000.zip') as z:
        text = z.read('cities15000.txt').decode('utf-8')
    places = {}
    for line in text.splitlines():
        f = line.split('\t')
        gid, name, lat, lon, cc, pop = f[0], f[1], f[4], f[5], f[8], f[14]
        if f[7] in SKIP_FEATURES:
            continue
        if cc not in codes:
            continue  # no name for that country in our table
        places[gid] = {
            'name': name, 'lat': float(lat), 'lon': float(lon),
            'cc': cc, 'pop': int(pop or 0), 'de': None, 'en': None,
        }
    return places


def add_alternate_names(src, places):
    """Adds the preferred German and English names (alternateNamesV2)."""
    best = {}  # (gid, lang) -> (rank, name)
    with zipfile.ZipFile(f'{src}/alternateNamesV2.zip') as z:
        with z.open('alternateNamesV2.txt') as raw:
            for line in io.TextIOWrapper(raw, encoding='utf-8'):
                f = line.rstrip('\n').split('\t')
                if len(f) < 8 or f[2] not in ('de', 'en') or f[1] not in places:
                    continue
                preferred, short, colloquial, historic = f[4], f[5], f[6], f[7]
                if colloquial == '1' or historic == '1':
                    continue
                # Preferred names first, then short names, then the rest.
                rank = (0 if preferred == '1' else 2) + (0 if short == '1' else 1)
                key = (f[1], f[2])
                if key not in best or rank < best[key][0]:
                    best[key] = (rank, f[3])
    for (gid, lang), (_, name) in best.items():
        places[gid][lang] = name


def write_places(places, path):
    rows = sorted(places.values(), key=lambda p: -p['pop'])
    out = bytearray(b'RNP1')
    out += struct.pack('<I', len(rows))
    german = 0
    for p in rows:
        de = p['de'] or p['name']
        en = p['en'] or p['name']
        german += p['de'] is not None
        out += struct.pack('<ii', round(p['lat'] * 1e5), round(p['lon'] * 1e5))
        out += p['cc'].encode('ascii')
        out += struct.pack('<I', p['pop'])
        put_str(out, de)
        put_str(out, '' if en == de else en)
    with open(path, 'wb') as f:
        f.write(out)
    print(f'{path}: {len(rows)} places ({german} with a German name), {len(out)} bytes')


def main():
    if len(sys.argv) != 3:
        sys.exit(__doc__)
    src, dest = sys.argv[1], sys.argv[2]
    countries = build_countries(src)
    write_countries(countries, f'{dest}/countries.bin')
    places = read_places(src, set(countries))
    add_alternate_names(src, places)
    write_places(places, f'{dest}/places.bin')


if __name__ == '__main__':
    main()
