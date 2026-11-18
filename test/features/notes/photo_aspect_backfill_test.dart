import 'dart:io';
import 'dart:typed_data';

import 'package:drift/drift.dart' show driftRuntimeOptions;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:randnotiz/core/database/app_database.dart';
import 'package:randnotiz/features/library/domain/photo_repository.dart';
import 'package:randnotiz/features/notes/data/drift_note_repository.dart';
import 'package:randnotiz/features/notes/data/photo_aspect_backfill.dart';
import 'package:randnotiz/features/notes/data/thumbnail_store.dart';
import 'package:randnotiz/features/notes/domain/note.dart';

/// Gallery with only a few photos left.
class _Gallery implements PhotoRepository {
  _Gallery(this.photos);

  final Map<String, PhotoItem> photos;

  @override
  Future<PhotoItem?> findById(String id) async => photos[id];

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;
  late AppDatabase db;
  late DriftNoteRepository notes;
  late Directory dir;

  setUp(() async {
    db = AppDatabase(NativeDatabase.memory());
    notes = DriftNoteRepository(db);
    dir = await Directory.systemTemp.createTemp('randnotiz_aspect');
  });
  tearDown(() async {
    await db.close();
    await dir.delete(recursive: true);
  });

  Future<Note> note(String assetId, {String? thumb}) async {
    final n = await notes.save(
      NoteDraft(assetId: assetId, body: 'x', date: DateTime(2024)),
    );
    if (thumb != null) await notes.setThumbnailFile(n.id, thumb);
    return n;
  }

  test('takes the gallery photo first, then the stored copy', () async {
    final store = ThumbnailStore(dir);
    final copy = await store.save('only-copy', Uint8List.fromList([1, 2, 3]));
    await note('in-gallery', thumb: 'missing.jpg');
    await note('only-copy', thumb: copy);
    await note('nothing');
    final readFiles = <String>[];

    final updated = await PhotoAspectBackfill(
      notes: notes,
      photos: _Gallery({
        'in-gallery': PhotoItem(
          id: 'in-gallery',
          createdAt: DateTime(2024),
          width: 3000,
          height: 4000,
        ),
      }),
      thumbnails: store,
      readFileAspect: (f) async {
        readFiles.add(f.path);
        return 1.5;
      },
    ).run();

    expect(updated, 2);
    expect((await notes.findByAsset('in-gallery'))!.photoAspect, 0.75);
    expect((await notes.findByAsset('only-copy'))!.photoAspect, 1.5);
    expect(readFiles.single, endsWith(copy));
    // Without photo and copy the note stays square (and is retried later).
    expect((await notes.notesWithoutPhotoAspect()).single.assetId, 'nothing');
  });
}
