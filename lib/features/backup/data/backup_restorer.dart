import 'package:drift/drift.dart';

import '../../../core/database/app_database.dart';
import '../../../core/database/tables.dart' show defaultTagEmoji;
import '../../library/data/imported_photo_store.dart';
import '../../library/domain/photo_repository.dart';
import '../../notes/data/thumbnail_store.dart';
import 'backup_snapshot.dart';
import 'backup_writer.dart';
import 'crypto/backup_cipher.dart';
import 'remote/remote_store.dart';

/// A decrypted snapshot and the server file it came from.
typedef FoundSnapshot = ({RemoteFile file, BackupSnapshot snapshot});

class RestoreReport {
  const RestoreReport({
    required this.added,
    required this.updated,
    required this.unchanged,
    required this.photos,
    required this.snapshotAt,
  });

  /// Notes that did not exist on this device.
  final int added;

  /// Notes replaced by a newer version from the backup.
  final int updated;

  /// Notes kept because the device has the same or a newer version.
  final int unchanged;
  final int photos;
  final DateTime snapshotAt;
}

/// Merges a backup into the local diary. Never overwrites newer local
/// changes: notes are matched by their uid and only replaced if the backup
/// version is newer; Stimmungen are matched by name, collections by uid.
///
/// Gallery asset ids are per device. A note keeps its id only if this
/// device has a photo with that id and the same capture date and size –
/// otherwise its photo becomes a private copy (`picked:` id) made from the
/// backed-up thumbnail, exactly like a photo picked from Google Photos.
class BackupRestorer {
  BackupRestorer({
    required this.db,
    required this.remote,
    required this.thumbnails,
    required this.imported,
    required this.galleryPhoto,
    DateTime Function()? clock,
  }) : _clock = clock ?? DateTime.now;

  final AppDatabase db;
  final RemoteStore remote;
  final ThumbnailStore thumbnails;
  final ImportedPhotoStore imported;

  /// A gallery photo of this device, null if there is none with that id or
  /// no access.
  final Future<PhotoItem?> Function(String assetId) galleryPhoto;
  final DateTime Function() _clock;

  /// The newest snapshot that [cipher] can open, or null if there is none.
  static Future<FoundSnapshot?> latest(
    RemoteStore remote,
    BackupCipher cipher, {
    List<RemoteFile>? files,
  }) async {
    for (final f in BackupLayout.snapshots(files ?? await remote.list())) {
      try {
        final plain = await cipher.open(
          await remote.read(f.id),
          objectName: f.name,
        );
        return (file: f, snapshot: BackupLayout.decodeSnapshot(plain));
      } on BackupIntegrityException {
        continue; // broken or from another key: try the one before
      } on FormatException {
        continue;
      }
    }
    return null;
  }

  Future<RestoreReport?> restore(
    BackupCipher cipher, {
    BackupProgress? onProgress,
  }) async {
    final files = await remote.list();
    final found = await latest(remote, cipher, files: files);
    if (found == null) return null;
    final snapshot = found.snapshot;
    final remoteByName = {for (final f in files) f.name: f};
    final fileByKey = {
      for (final f in snapshot.files) '${f.kind.name}/${f.name}': f,
    };
    final downloaded = <String, Uint8List?>{};

    Future<Uint8List?> blob(BackupFileKind kind, String? name) async {
      if (name == null) return null;
      final entry = fileByKey['${kind.name}/$name'];
      if (entry == null) return null;
      if (downloaded.containsKey(entry.blob)) return downloaded[entry.blob];
      final remoteFile = remoteByName[entry.blob];
      Uint8List? bytes;
      if (remoteFile != null) {
        try {
          bytes = await cipher.open(
            await remote.read(remoteFile.id),
            objectName: entry.blob,
          );
        } on BackupIntegrityException {
          bytes = null;
        } on RemoteNotFoundException {
          bytes = null;
        }
      }
      return downloaded[entry.blob] = bytes;
    }

    final localNotes = await db.select(db.notes).get();
    final byUid = {for (final n in localNotes) n.uid: n};
    final usedAssetIds = {for (final n in localNotes) n.assetId};

    // Work out every note first and write its files; the database changes
    // follow in one transaction.
    final plans = <_NotePlan>[];
    var unchanged = 0;
    var photos = 0;
    for (final (i, n) in snapshot.notes.indexed) {
      onProgress?.call(i, snapshot.notes.length);
      final uid = n['uid'] as String?;
      final updatedAt = DateTime.parse(n['updatedAt']! as String);
      final local = uid == null ? null : byUid[uid];
      if (local != null && !updatedAt.isAfter(local.updatedAt)) {
        unchanged++;
        continue;
      }
      final backupAssetId = n['assetId']! as String;
      final info = _photoInfo(n['photo']);
      final String assetId;
      if (local != null) {
        assetId = local.assetId; // same note, its photo stays
      } else {
        assetId = await _targetAssetId(backupAssetId, info, usedAssetIds);
        usedAssetIds.add(assetId);
      }

      // Thumbnail: keep the local one of an existing note if it is there.
      String? thumbnail = local?.thumbnailFile;
      if (!await thumbnails.exists(thumbnail)) {
        final bytes = await blob(
          BackupFileKind.thumbnail,
          n['thumbnailFile'] as String?,
        );
        thumbnail = bytes == null
            ? null
            : await thumbnails.saveNamed(
                ThumbnailStore.fileNameFor(assetId),
                bytes,
              );
        if (bytes != null) photos++;
      }

      String? cover = n['songCoverFile'] as String?;
      if (cover != null && !await thumbnails.exists(cover)) {
        final bytes = await blob(BackupFileKind.thumbnail, cover);
        cover = bytes == null ? null : await thumbnails.saveNamed(cover, bytes);
      }

      // The photo itself for private copies.
      if (ImportedPhotoStore.isImportedId(assetId) &&
          !await imported.imageFile(assetId).exists()) {
        final original = ImportedPhotoStore.isImportedId(backupAssetId)
            ? await blob(BackupFileKind.imported, backupAssetId)
            : null;
        final jpeg =
            original ??
            (thumbnail == null
                ? null
                : await thumbnails.fileFor(thumbnail).readAsBytes());
        if (jpeg != null) {
          final aspect = (n['photoAspect'] as num?)?.toDouble() ?? 1;
          await imported.restore(
            assetId,
            jpeg,
            createdAt: info?.takenAt ?? DateTime.parse(n['date']! as String),
            width:
                info?.width ?? (aspect >= 1 ? 1600 : (1600 * aspect).round()),
            height:
                info?.height ?? (aspect >= 1 ? (1600 / aspect).round() : 1600),
          );
        }
      }

      plans.add(
        _NotePlan(
          json: n,
          localId: local?.id,
          assetId: assetId,
          thumbnailFile: thumbnail,
          songCoverFile: cover,
        ),
      );
    }

    await db.transaction(() async {
      // Stimmungen by name.
      final tagIdByName = {
        for (final t in await db.select(db.tags).get()) t.name: t.id,
      };
      final tagIdMap = <int, int>{};
      for (final t in snapshot.tags) {
        final name = t['name']! as String;
        tagIdMap[t['id']! as int] =
            tagIdByName[name] ??
            await db
                .into(db.tags)
                .insert(
                  TagsCompanion.insert(
                    name: name,
                    emoji: Value((t['emoji'] as String?) ?? defaultTagEmoji),
                  ),
                );
        tagIdByName[name] = tagIdMap[t['id']! as int]!;
      }

      for (final plan in plans) {
        final n = plan.json;
        final companion = NotesCompanion(
          uid: n['uid'] == null
              ? const Value.absent()
              : Value(n['uid']! as String),
          assetId: Value(plan.assetId),
          body: Value((n['body'] as String?) ?? ''),
          title: Value(n['title'] as String?),
          photoAspect: Value((n['photoAspect'] as num?)?.toDouble()),
          noteDate: Value(DateTime.parse(n['date']! as String).toLocal()),
          weatherKind: Value(n['weatherKind'] as String?),
          temperatureC: Value((n['temperatureC'] as num?)?.toDouble()),
          placeName: Value(n['placeName'] as String?),
          placeNameAlt: Value(n['placeNameAlt'] as String?),
          countryCode: Value(n['countryCode'] as String?),
          geoChecked: Value((n['geoChecked'] as bool?) ?? false),
          thumbnailFile: Value(plan.thumbnailFile),
          songUri: Value(n['songUri'] as String?),
          songTitle: Value(n['songTitle'] as String?),
          songArtist: Value(n['songArtist'] as String?),
          songCoverFile: Value(plan.songCoverFile),
          createdAt: Value(DateTime.parse(n['createdAt']! as String).toLocal()),
          updatedAt: Value(DateTime.parse(n['updatedAt']! as String).toLocal()),
        );
        final int id;
        if (plan.localId == null) {
          id = await db.into(db.notes).insert(companion);
        } else {
          id = plan.localId!;
          await (db.update(db.notes)..where((r) => r.id.equals(id))).write(
            companion.copyWith(uid: const Value.absent()),
          );
          await (db.delete(
            db.noteTags,
          )..where((t) => t.noteId.equals(id))).go();
        }
        for (final tagId in (n['tagIds'] as List? ?? const [])) {
          final local = tagIdMap[tagId as int];
          if (local == null) continue;
          await db
              .into(db.noteTags)
              .insert(
                NoteTagsCompanion.insert(noteId: id, tagId: local),
                mode: InsertMode.insertOrIgnore,
              );
        }
        await db.searchIndex.reindexNote(id);
      }

      // Collections by uid; new ones go after the existing ones.
      final localCollections = await db.select(db.collections).get();
      final collectionByUid = {for (final c in localCollections) c.uid: c.id};
      var nextPosition = localCollections.isEmpty
          ? 0
          : localCollections
                    .map((c) => c.position)
                    .reduce((a, b) => a > b ? a : b) +
                1;
      final noteIdByUid = {
        for (final r in await db.select(db.notes).get()) r.uid: r.id,
      };
      for (final c in snapshot.collections) {
        final uid = c['uid'] as String?;
        var id = uid == null ? null : collectionByUid[uid];
        id ??= await db
            .into(db.collections)
            .insert(
              CollectionsCompanion.insert(
                uid: uid == null ? const Value.absent() : Value(uid),
                name: c['name']! as String,
                createdAt: DateTime.parse(c['createdAt']! as String).toLocal(),
                position: Value(nextPosition++),
              ),
            );
        for (final m in (c['notes'] as List? ?? const [])) {
          final member = m as Map<String, Object?>;
          final noteId = noteIdByUid[member['uid']];
          if (noteId == null) continue;
          await db
              .into(db.collectionNotes)
              .insert(
                CollectionNotesCompanion.insert(
                  collectionId: id,
                  noteId: noteId,
                  addedAt: DateTime.parse(member['addedAt']! as String)
                      .toLocal(),
                ),
                mode: InsertMode.insertOrIgnore,
              );
        }
      }
    });

    onProgress?.call(snapshot.notes.length, snapshot.notes.length);
    return RestoreReport(
      added: plans.where((p) => p.localId == null).length,
      updated: plans.where((p) => p.localId != null).length,
      unchanged: unchanged,
      photos: photos,
      snapshotAt: snapshot.createdAt,
    );
  }

  Future<String> _targetAssetId(
    String backupAssetId,
    BackupPhotoInfo? info,
    Set<String> used,
  ) async {
    if (!used.contains(backupAssetId)) {
      if (ImportedPhotoStore.isImportedId(backupAssetId)) return backupAssetId;
      final here = await galleryPhoto(backupAssetId);
      if (here != null &&
          info != null &&
          here.createdAt.millisecondsSinceEpoch ~/ 1000 ==
              info.takenAt.millisecondsSinceEpoch ~/ 1000 &&
          _sameSize(here, info)) {
        return backupAssetId;
      }
    }
    String id;
    do {
      id = ImportedPhotoStore.newId(_clock());
    } while (used.contains(id));
    return id;
  }

  static bool _sameSize(PhotoItem p, BackupPhotoInfo info) =>
      (p.width == info.width && p.height == info.height) ||
      (p.width == info.height && p.height == info.width);

  static BackupPhotoInfo? _photoInfo(Object? json) {
    if (json is! Map<String, Object?>) return null;
    try {
      return (
        takenAt: DateTime.parse(json['takenAt']! as String),
        width: json['width']! as int,
        height: json['height']! as int,
      );
    } on Object {
      return null;
    }
  }
}

class _NotePlan {
  _NotePlan({
    required this.json,
    required this.localId,
    required this.assetId,
    required this.thumbnailFile,
    required this.songCoverFile,
  });

  final Map<String, Object?> json;
  final int? localId;
  final String assetId;
  final String? thumbnailFile;
  final String? songCoverFile;
}
