import 'dart:io';
import 'dart:typed_data';

import 'package:drift/drift.dart' show driftRuntimeOptions;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:randnotiz/core/database/app_database.dart';
import 'package:randnotiz/features/geo/data/geo_backfill.dart';
import 'package:randnotiz/features/geo/data/geo_database.dart';
import 'package:randnotiz/features/library/domain/photo_repository.dart';
import 'package:randnotiz/features/notes/data/drift_note_repository.dart';
import 'package:randnotiz/features/notes/domain/note.dart';
import 'package:randnotiz/features/weather/domain/weather.dart';

/// Gallery whose photos have the given GPS positions.
class _Gallery implements PhotoRepository {
  _Gallery(this.positions);

  final Map<String, GeoPoint> positions;
  int lookups = 0;

  @override
  Future<GeoPoint?> locationOf(String id) async {
    lookups++;
    return positions[id];
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;
  late GeoDatabase geo;
  late AppDatabase db;
  late DriftNoteRepository notes;

  setUpAll(() {
    ByteData read(String path) =>
        ByteData.sublistView(File(path).readAsBytesSync());
    geo = GeoDatabase.parse(
      read(GeoDatabase.countriesAsset),
      read(GeoDatabase.placesAsset),
    );
  });

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
    notes = DriftNoteRepository(db);
  });
  tearDown(() => db.close());

  Future<void> note(String assetId, {String? place}) => notes.save(
    NoteDraft(
      assetId: assetId,
      body: 'x',
      date: DateTime(2024),
      placeName: place,
    ),
  );

  test('fills country and place from GPS, else from the typed place', () async {
    await note('gps'); // photo taken in Oslo
    await note('typed', place: 'Wien'); // imported photo, no GPS
    await note('kept', place: 'Unser Ferienhaus'); // GPS in Norway
    await note('nothing');
    final gallery = _Gallery({
      'gps': const GeoPoint(59.913, 10.752),
      'kept': const GeoPoint(60.39, 5.32),
    });
    final progress = <(int, int)>[];

    final result = await GeoBackfill(
      notes: notes,
      photos: gallery,
      geo: geo,
    ).run(onProgress: (d, t) => progress.add((d, t)));

    expect(result, (done: 4, total: 4));
    expect(progress.first, (0, 4));
    expect(progress.last, (4, 4));

    final gps = (await notes.findByAsset('gps'))!;
    expect([gps.countryCode, gps.placeName], ['NO', 'Oslo']);
    final typed = (await notes.findByAsset('typed'))!;
    expect(
      [typed.countryCode, typed.placeName, typed.placeNameAlt],
      ['AT', 'Wien', 'Vienna'],
    );
    final kept = (await notes.findByAsset('kept'))!;
    expect(kept.placeName, 'Unser Ferienhaus', reason: 'never overwritten');
    expect(kept.countryCode, 'NO');
    final nothing = (await notes.findByAsset('nothing'))!;
    expect(nothing.countryCode, isNull);
    // Nothing found: it stays waiting, a later run may find it.
    expect(nothing.geoChecked, isFalse);
    expect((await notes.notesNeedingGeo()).single.assetId, 'nothing');
  });

  test('can be cancelled; the rest waits for the next run', () async {
    for (var i = 0; i < 10; i++) {
      await note('n$i');
    }
    final gallery = _Gallery({
      for (var i = 0; i < 10; i++) 'n$i': const GeoPoint(48.137, 11.575),
    });
    var calls = 0;
    final result = await GeoBackfill(
      notes: notes,
      photos: gallery,
      geo: geo,
    ).run(isCancelled: () => ++calls > 3);
    expect(result.done, 3);
    expect(result.total, 10);
    expect(await notes.notesNeedingGeo(), hasLength(7));
  });
}
