import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:drift/native.dart';
import 'package:path/path.dart' as p;
import 'package:randnotiz/core/database/app_database.dart';
import 'package:randnotiz/features/backup/data/backup_hash_cache.dart';
import 'package:randnotiz/features/backup/data/backup_restorer.dart';
import 'package:randnotiz/features/backup/data/backup_writer.dart';
import 'package:randnotiz/features/backup/data/crypto/key_ring.dart';
import 'package:randnotiz/features/backup/data/remote/remote_store.dart';
import 'package:randnotiz/features/library/data/imported_photo_store.dart';
import 'package:randnotiz/features/library/domain/photo_repository.dart';
import 'package:randnotiz/features/notes/data/drift_note_repository.dart';
import 'package:randnotiz/features/notes/data/thumbnail_store.dart';
import 'package:randnotiz/features/notes/domain/note.dart';

/// Cheap Argon2 parameters: the tests check the logic, not the cost.
const fastKdf = KdfParams(memoryKiB: 64, iterations: 1, parallelism: 1);

/// Looks like a JPEG (magic bytes + JFIF marker) and is unique per [seed].
Uint8List jpeg(int seed) => Uint8List.fromList([
  0xFF, 0xD8, 0xFF, 0xE0, ...ascii.encode('JFIF'), //
  ...List.generate(200, (i) => (i * seed) % 251),
]);

/// One phone: database, photo folders and the hash cache.
class Device {
  Device(this.dir) : db = AppDatabase(NativeDatabase.memory()) {
    thumbnails = ThumbnailStore(Directory(p.join(dir.path, 'thumbnails')));
    imported = ImportedPhotoStore(Directory(p.join(dir.path, 'imported')));
    cache = BackupHashCache(File(p.join(dir.path, 'backup_cache.json')));
  }

  final Directory dir;
  final AppDatabase db;
  late final ThumbnailStore thumbnails;
  late final ImportedPhotoStore imported;
  late final BackupHashCache cache;
  final gallery = <String, PhotoItem>{};
  var _t = DateTime.utc(2026, 1, 1).millisecondsSinceEpoch;

  DateTime clock() => DateTime.fromMillisecondsSinceEpoch(_t += 1000);

  DriftNoteRepository get notes => DriftNoteRepository(db, clock: clock);

  BackupWriter writer(RemoteStore remote) => BackupWriter(
    db: db,
    remote: remote,
    thumbnails: thumbnails,
    imported: imported,
    cache: cache,
    clock: clock,
    photoInfo: (id) async {
      final item = gallery[id] ?? await imported.find(id);
      return item == null
          ? null
          : (takenAt: item.createdAt, width: item.width, height: item.height);
    },
  );

  BackupRestorer restorer(RemoteStore remote) => BackupRestorer(
    db: db,
    remote: remote,
    thumbnails: thumbnails,
    imported: imported,
    galleryPhoto: (id) async => gallery[id],
    clock: clock,
  );

  Future<Note> addGalleryNote(
    String assetId,
    String body, {
    int seed = 1,
  }) async {
    gallery[assetId] = PhotoItem(
      id: assetId,
      createdAt: DateTime.utc(2025, 7, 1, 12),
      width: 4000,
      height: 3000,
    );
    final note = await notes.save(
      NoteDraft(assetId: assetId, body: body, date: DateTime(2025, 7, 1)),
    );
    final name = await thumbnails.save(assetId, jpeg(seed));
    await notes.setThumbnailFile(note.id, name);
    return note;
  }
}
