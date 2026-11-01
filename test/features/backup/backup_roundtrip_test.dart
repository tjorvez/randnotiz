import 'dart:convert';
import 'dart:io';

import 'package:drift/drift.dart' show Value, driftRuntimeOptions;
import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;
import 'package:randnotiz/core/database/app_database.dart';
import 'package:randnotiz/features/backup/data/backup_restorer.dart';
import 'package:randnotiz/features/backup/data/backup_snapshot.dart';
import 'package:randnotiz/features/backup/data/backup_writer.dart';
import 'package:randnotiz/features/backup/data/crypto/backup_cipher.dart';
import 'package:randnotiz/features/backup/data/remote/remote_store.dart';
import 'package:randnotiz/features/collections/data/drift_collection_repository.dart';
import 'package:randnotiz/features/library/domain/photo_repository.dart';
import 'package:randnotiz/features/music/domain/song.dart';
import 'package:randnotiz/features/notes/domain/note.dart';
import 'package:randnotiz/features/tags/data/drift_tag_repository.dart';

import 'backup_fixtures.dart';
import 'fake_remote_store.dart';

void main() {
  driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;
  late Directory tmp;
  late FakeRemoteStore remote;
  late BackupCipher cipher;
  late Device phone;

  setUp(() async {
    tmp = await Directory.systemTemp.createTemp('randnotiz_backup_');
    remote = FakeRemoteStore();
    cipher = await BackupCipher.create(List.filled(32, 3), keyId: 'key1');
    phone = Device(Directory(p.join(tmp.path, 'phone')));
  });

  tearDown(() async {
    await phone.db.close();
    await tmp.delete(recursive: true);
  });

  /// A diary with a gallery note (Stimmung, song with cover), a note from
  /// Google Photos and a collection with both.
  Future<void> fillDiary(Device d) async {
    final tag = await DriftTagRepository(d.db).createTag('froh', emoji: '😊');
    final beach = await d.addGalleryNote(
      '101',
      'Liebes Tagebuch, heute am Meer.',
    );
    final cover = await d.thumbnails.saveCover('trk1', jpeg(7));
    await d.notes.save(
      NoteDraft(
        assetId: '101',
        body: 'Liebes Tagebuch, heute am Meer.',
        title: 'Strandtag',
        date: DateTime(2025, 7, 1),
        tagIds: {tag.id},
        placeName: 'Sylt',
        countryCode: 'DE',
        geoChecked: true,
        photoAspect: 4 / 3,
        song: Song(
          uri: 'spotify:track:trk1',
          title: 'Wonderwall',
          artist: 'Oasis',
          coverFile: cover,
        ),
      ),
    );
    const pickedId = 'picked:abc';
    await d.imported.restore(
      pickedId,
      jpeg(9),
      createdAt: DateTime.utc(2024, 3, 3),
      width: 1600,
      height: 1200,
    );
    final picked = await d.notes.save(
      NoteDraft(
        assetId: pickedId,
        body: 'Aus Google Fotos',
        date: DateTime(2024, 3, 3),
      ),
    );
    await d.notes.setThumbnailFile(
      picked.id,
      await d.thumbnails.save(pickedId, jpeg(10)),
    );
    final collections = DriftCollectionRepository(d.db);
    final trip = await collections.create('Sommerreise');
    await collections.addNotes(trip.id, [beach.id, picked.id]);
  }

  group('BackupWriter', () {
    test('uploads only encrypted objects with meaningless names', () async {
      await fillDiary(phone);
      final result = await phone.writer(remote).run(cipher);
      expect(result.unchanged, isFalse);
      expect(result.notes, 2);
      // Thumbnail ×2, cover, imported photo.
      expect(result.photos, 4);
      expect(remote.names.where(BackupLayout.isBlob), hasLength(4));
      expect(remote.names.where(BackupLayout.isSnapshot), hasLength(1));
      for (final name in remote.names) {
        expect(name, anyOf(startsWith('b-'), startsWith('snapshot-')));
      }
      for (final f in remote.files.values) {
        final text = latin1.decode(f.bytes);
        for (final secret in [
          'Tagebuch',
          'Strandtag',
          'Sylt',
          'froh',
          'Wonderwall',
          'Sommerreise',
          'JFIF',
          'picked',
        ]) {
          expect(text, isNot(contains(secret)), reason: '${f.name}: $secret');
        }
        expect(f.bytes.take(3), isNot([0xFF, 0xD8, 0xFF]));
      }
    });

    test('a second run without changes uploads nothing', () async {
      await fillDiary(phone);
      final first = await phone.writer(remote).run(cipher);
      final uploads = remote.uploads.length;
      final second = await phone
          .writer(remote)
          .run(cipher, previous: first.mark);
      expect(second.unchanged, isTrue);
      expect(remote.uploads, hasLength(uploads));
    });

    test('a changed text uploads only the snapshot, keeps two', () async {
      await fillDiary(phone);
      var mark = (await phone.writer(remote).run(cipher)).mark;
      for (final text in ['Zweite Fassung', 'Dritte Fassung']) {
        await phone.notes.save(
          NoteDraft(
            assetId: 'picked:abc',
            body: text,
            date: DateTime(2024, 3, 3),
          ),
        );
        final before = remote.uploads.length;
        final r = await phone.writer(remote).run(cipher, previous: mark);
        mark = r.mark;
        expect(remote.uploads.skip(before), [r.mark.snapshotName]);
      }
      expect(remote.names.where(BackupLayout.isSnapshot), hasLength(2));
      expect(remote.names.where(BackupLayout.isBlob), hasLength(4));
    });

    test(
      'photos of deleted notes go once no kept snapshot needs them',
      () async {
        await fillDiary(phone);
        await phone.addGalleryNote('202', 'Wird gelöscht', seed: 22);
        await phone.writer(remote).run(cipher);
        expect(remote.names.where(BackupLayout.isBlob), hasLength(5));

        await phone.notes.deleteByAsset('202');
        await phone.writer(remote).run(cipher);
        // The previous snapshot still refers to it.
        expect(remote.names.where(BackupLayout.isBlob), hasLength(5));

        await phone.notes.save(
          NoteDraft(
            assetId: 'picked:abc',
            body: 'Neu',
            date: DateTime(2024, 3, 3),
          ),
        );
        await phone.writer(remote).run(cipher);
        expect(remote.names.where(BackupLayout.isBlob), hasLength(4));
      },
    );

    test('an interrupted backup leaves the previous one complete', () async {
      await fillDiary(phone);
      final first = await phone.writer(remote).run(cipher);
      await phone.addGalleryNote('303', 'Noch nicht gesichert', seed: 33);

      remote.failAfterWrites = 0; // the new photo upload fails
      await expectLater(
        phone.writer(remote).run(cipher, previous: first.mark),
        throwsA(isA<RemoteUnavailableException>()),
      );
      remote.failAfterWrites = 1; // photo uploads, snapshot fails
      await expectLater(
        phone.writer(remote).run(cipher, previous: first.mark),
        throwsA(isA<RemoteUnavailableException>()),
      );

      final found = await BackupRestorer.latest(remote, cipher);
      expect(found!.file.name, first.mark.snapshotName);
      for (final f in found.snapshot.files) {
        expect(remote.names, contains(f.blob));
      }

      remote.failAfterWrites = null;
      final retry = await phone
          .writer(remote)
          .run(cipher, previous: first.mark);
      expect(retry.notes, 3);
      // The photo from the interrupted attempt is reused.
      expect(remote.uploads.where((n) => n.startsWith('b-')), hasLength(5));
    });
  });

  group('BackupRestorer', () {
    test('restores everything on a new phone', () async {
      await fillDiary(phone);
      await phone.writer(remote).run(cipher);
      final original = await phone.db.select(phone.db.notes).get();

      final newPhone = Device(Directory(p.join(tmp.path, 'new')));
      addTearDown(newPhone.db.close);
      final report = await newPhone.restorer(remote).restore(cipher);
      expect(report!.added, 2);
      expect(report.updated, 0);

      final rows = await newPhone.db.select(newPhone.db.notes).get();
      expect(
        rows.map((r) => r.uid).toSet(),
        original.map((r) => r.uid).toSet(),
      );
      final beach = rows.firstWhere((r) => r.title == 'Strandtag');
      // Gallery id 101 means nothing on another phone: private copy.
      expect(beach.assetId, startsWith('picked:'));
      expect(beach.body, 'Liebes Tagebuch, heute am Meer.');
      expect(beach.placeName, 'Sylt');
      expect(beach.countryCode, 'DE');
      expect(beach.geoChecked, isTrue);
      expect(beach.photoAspect, closeTo(4 / 3, 1e-9));
      expect(beach.songTitle, 'Wonderwall');
      expect(
        await newPhone.thumbnails.fileFor(beach.songCoverFile!).readAsBytes(),
        jpeg(7),
      );
      expect(
        await newPhone.thumbnails.fileFor(beach.thumbnailFile!).readAsBytes(),
        jpeg(1),
      );
      final copy = await newPhone.imported.find(beach.assetId);
      expect(
        copy!.createdAt.isAtSameMomentAs(DateTime.utc(2025, 7, 1, 12)),
        isTrue,
      );
      expect((copy.width, copy.height), (4000, 3000));

      final fromPhotos = rows.firstWhere((r) => r.body == 'Aus Google Fotos');
      expect(fromPhotos.assetId, 'picked:abc');
      expect(
        await newPhone.imported.imageFile('picked:abc').readAsBytes(),
        jpeg(9),
      );

      final note = await newPhone.notes.findByAsset(beach.assetId);
      expect(note!.tags.single.name, 'froh');
      expect(note.tags.single.emoji, '😊');
      final collections = await DriftCollectionRepository(newPhone.db)
          .watchCollections()
          .first;
      expect(collections.single.name, 'Sommerreise');
      expect(collections.single.noteCount, 2);

      final found = await newPhone.notes
          .watchJournal(const JournalQuery(text: 'wonderwall'))
          .first;
      expect(found.single.assetId, beach.assetId);
    });

    test('keeps the gallery id on the same phone after reinstalling', () async {
      await fillDiary(phone);
      await phone.writer(remote).run(cipher);

      final reinstalled = Device(Directory(p.join(tmp.path, 'again')));
      addTearDown(reinstalled.db.close);
      reinstalled.gallery.addAll(phone.gallery);
      await reinstalled.restorer(remote).restore(cipher);
      final rows = await reinstalled.db.select(reinstalled.db.notes).get();
      expect(rows.map((r) => r.assetId), containsAll(['101', 'picked:abc']));
      // Only the Google Photos note needs a private copy.
      expect(
        await reinstalled.imported.directory
            .list()
            .map((e) => p.basename(e.path))
            .toList(),
        unorderedEquals(['abc.jpg', 'abc.json']),
      );
    });

    test('a different photo under the same id is not mixed up', () async {
      await fillDiary(phone);
      await phone.writer(remote).run(cipher);

      final other = Device(Directory(p.join(tmp.path, 'other')));
      addTearDown(other.db.close);
      other.gallery['101'] = PhotoItem(
        id: '101',
        createdAt: DateTime.utc(2019, 1, 1),
        width: 4000,
        height: 3000,
      );
      await other.restorer(remote).restore(cipher);
      final rows = await other.db.select(other.db.notes).get();
      expect(rows.map((r) => r.assetId), isNot(contains('101')));
    });

    test('merges: newer local changes stay, newer backup wins', () async {
      await fillDiary(phone);
      await phone.writer(remote).run(cipher);

      // The phone edits one note after the backup ...
      await phone.notes.save(
        NoteDraft(
          assetId: 'picked:abc',
          body: 'Lokal neuer',
          date: DateTime(2024, 3, 3),
        ),
      );
      // ... and loses the text of the other one in a way the backup can
      // repair (older timestamp than the backup).
      await (phone.db.update(
        phone.db.notes,
      )..where((n) => n.assetId.equals('101'))).write(
        NotesCompanion(
          body: const Value('kaputt'),
          updatedAt: Value(DateTime.utc(2020)),
        ),
      );
      // A new note for a photo the backup also has under another uid.
      final report = await phone.restorer(remote).restore(cipher);
      expect(report!.added, 0);
      expect(report.updated, 1);
      expect(report.unchanged, 1);
      final rows = await phone.db.select(phone.db.notes).get();
      expect(rows, hasLength(2));
      expect(
        rows.firstWhere((r) => r.assetId == 'picked:abc').body,
        'Lokal neuer',
      );
      expect(
        rows.firstWhere((r) => r.assetId == '101').body,
        'Liebes Tagebuch, heute am Meer.',
      );
      // Collections are not duplicated.
      expect(await phone.db.select(phone.db.collections).get(), hasLength(1));
      expect(await phone.db.select(phone.db.tags).get(), hasLength(1));
    });

    test('a photo noted again locally does not collide', () async {
      await fillDiary(phone);
      await phone.writer(remote).run(cipher);

      final again = Device(Directory(p.join(tmp.path, 'again')));
      addTearDown(again.db.close);
      again.gallery.addAll(phone.gallery);
      await again.addGalleryNote('101', 'Neu geschrieben', seed: 5);
      final report = await again.restorer(remote).restore(cipher);
      expect(report!.added, 2);
      final rows = await again.db.select(again.db.notes).get();
      expect(rows, hasLength(3));
      expect(
        rows.where((r) => r.assetId == '101').single.body,
        'Neu geschrieben',
      );
    });

    test('another key finds no backup', () async {
      await fillDiary(phone);
      await phone.writer(remote).run(cipher);
      final other = await BackupCipher.create(
        List.filled(32, 4),
        keyId: 'key1',
      );
      expect(await BackupRestorer.latest(remote, other), isNull);
    });

    test('snapshots of format v1 can still be read', () {
      final s = BackupSnapshot.decode(
        jsonEncode({
          'format': 'randnotiz-backup',
          'version': 1,
          'createdAt': '2026-01-01T00:00:00.000Z',
          'tags': [],
          'notes': [
            {'assetId': '1', 'body': 'alt'},
          ],
        }),
      );
      expect(s.version, 1);
      expect(s.notes.single['body'], 'alt');
      expect(s.collections, isEmpty);
      expect(s.files, isEmpty);
    });
  });
}
