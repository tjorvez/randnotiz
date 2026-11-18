import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:crypto/crypto.dart' as hash;

import '../../../core/database/app_database.dart';
import '../../library/data/imported_photo_store.dart';
import '../../notes/data/thumbnail_store.dart';
import 'backup_hash_cache.dart';
import 'backup_snapshot.dart';
import 'crypto/backup_cipher.dart';
import 'remote/remote_store.dart';

/// Names of the objects in the backup folder.
abstract final class BackupLayout {
  static const snapshotPrefix = 'snapshot-';
  static const snapshotSuffix = '.bin';
  static const blobPrefix = 'b-';

  /// Sortable by name: the newest snapshot has the largest name.
  static String snapshotName(DateTime at) =>
      '$snapshotPrefix${at.toUtc().millisecondsSinceEpoch.toString().padLeft(15, '0')}$snapshotSuffix';

  static bool isSnapshot(String name) =>
      name.startsWith(snapshotPrefix) && name.endsWith(snapshotSuffix);

  static bool isBlob(String name) => name.startsWith(blobPrefix);

  /// Snapshots, newest first.
  static List<RemoteFile> snapshots(Iterable<RemoteFile> files) =>
      files.where((f) => isSnapshot(f.name)).toList()
        ..sort((a, b) => b.name.compareTo(a.name));

  static Uint8List encodeSnapshot(BackupSnapshot s) =>
      Uint8List.fromList(gzip.encode(utf8.encode(s.encode())));

  static BackupSnapshot decodeSnapshot(List<int> bytes) =>
      BackupSnapshot.decode(utf8.decode(gzip.decode(bytes)));
}

/// What the last successful backup was (kept on the device).
typedef BackupMark = ({String snapshotName, String contentHash});

class BackupRunResult {
  const BackupRunResult({
    required this.mark,
    required this.notes,
    required this.photos,
    required this.uploadedFiles,
    required this.uploadedBytes,
    required this.unchanged,
    required this.finishedAt,
  });

  final BackupMark mark;
  final int notes;
  final int photos;
  final int uploadedFiles;
  final int uploadedBytes;

  /// Nothing had changed since [BackupWriter.run]'s `previous` – nothing
  /// was uploaded.
  final bool unchanged;
  final DateTime finishedAt;
}

typedef BackupProgress = void Function(int done, int total);

/// Makes one backup: uploads the photos the server does not have yet, then
/// the encrypted snapshot, and only then removes what no kept snapshot
/// needs any more. Interrupted at any point, the previous snapshot stays
/// complete.
class BackupWriter {
  BackupWriter({
    required this.db,
    required this.remote,
    required this.thumbnails,
    required this.imported,
    required this.cache,
    this.photoInfo,
    DateTime Function()? clock,
    this.keepSnapshots = 2,
  }) : _clock = clock ?? DateTime.now;

  final AppDatabase db;
  final RemoteStore remote;
  final ThumbnailStore thumbnails;
  final ImportedPhotoStore imported;
  final BackupHashCache cache;

  /// Capture date and size of a note's photo (gallery or `picked:`), null
  /// if the photo is gone.
  final Future<BackupPhotoInfo?> Function(String assetId)? photoInfo;
  final DateTime Function() _clock;
  final int keepSnapshots;

  Future<BackupRunResult> run(
    BackupCipher cipher, {
    BackupMark? previous,
    BackupProgress? onProgress,
  }) async {
    await cache.load();
    final remoteFiles = await remote.list();
    final remoteNames = {for (final f in remoteFiles) f.name};

    var snapshot = await BackupSnapshot.fromDatabase(
      db,
      now: _clock(),
      photoInfo: _cachedPhotoInfo,
    );
    final local = await _localFiles(snapshot);
    final entries = <BackupFile>[];
    for (final f in local) {
      final sha = await _hash(f);
      if (sha == null) continue;
      entries.add(
        BackupFile(
          kind: f.kind,
          name: f.name,
          sha256: sha.sha256,
          size: sha.size,
          blob: cipher.blobNameFor(sha.sha256),
        ),
      );
    }
    snapshot = snapshot.withFiles(entries);
    cache.retain(
      hashKeys: {for (final f in local) f.key},
      assetIds: {for (final n in snapshot.notes) n['assetId']! as String},
    );
    await cache.save();

    final contentHash = snapshot.contentHash;
    if (previous != null &&
        previous.contentHash == contentHash &&
        remoteNames.contains(previous.snapshotName)) {
      return BackupRunResult(
        mark: previous,
        notes: snapshot.notes.length,
        photos: entries.length,
        uploadedFiles: 0,
        uploadedBytes: 0,
        unchanged: true,
        finishedAt: _clock(),
      );
    }

    // 1. Photos the server does not have yet (content-addressed names).
    final missing = <BackupFile>[];
    final seen = <String>{};
    for (final e in entries) {
      if (!remoteNames.contains(e.blob) && seen.add(e.blob)) missing.add(e);
    }
    var uploadedBytes = 0;
    final byKey = {for (final f in local) '${f.kind.name}/${f.name}': f};
    for (final (i, e) in missing.indexed) {
      onProgress?.call(i, missing.length + 1);
      final source = byKey['${e.kind.name}/${e.name}']!;
      final bytes = await source.file.readAsBytes();
      if (hash.sha256.convert(bytes).toString() != e.sha256) {
        // Changed while backing up: the next backup takes the new version.
        throw const RemoteUnavailableException('file changed during backup');
      }
      final sealed = await cipher.seal(bytes, objectName: e.blob);
      await remote.create(e.blob, sealed);
      uploadedBytes += sealed.length;
    }

    // 2. The snapshot – from now on it is the backup.
    onProgress?.call(missing.length, missing.length + 1);
    final name = BackupLayout.snapshotName(snapshot.createdAt);
    final sealed = await cipher.seal(
      BackupLayout.encodeSnapshot(snapshot),
      objectName: name,
    );
    final created = await remote.create(name, sealed);
    uploadedBytes += sealed.length;
    onProgress?.call(missing.length + 1, missing.length + 1);

    // 3. Older snapshots, then photos no kept snapshot refers to.
    await _prune(cipher, [...remoteFiles, created], newest: snapshot);

    return BackupRunResult(
      mark: (snapshotName: name, contentHash: contentHash),
      notes: snapshot.notes.length,
      photos: entries.length,
      uploadedFiles: missing.length + 1,
      uploadedBytes: uploadedBytes,
      unchanged: false,
      finishedAt: _clock(),
    );
  }

  Future<void> _prune(
    BackupCipher cipher,
    List<RemoteFile> files, {
    required BackupSnapshot newest,
  }) async {
    final snapshots = BackupLayout.snapshots(files);
    final kept = snapshots.take(keepSnapshots).toList();
    for (final old in snapshots.skip(keepSnapshots)) {
      await remote.delete(old.id);
    }
    final referenced = {for (final f in newest.files) f.blob};
    for (final s in kept.skip(1)) {
      try {
        final plain = await cipher.open(
          await remote.read(s.id),
          objectName: s.name,
        );
        referenced.addAll(
          BackupLayout.decodeSnapshot(plain).files.map((f) => f.blob),
        );
      } on Object {
        // Cannot tell what it needs (e.g. made with another key): keep all
        // photos rather than break it.
        return;
      }
    }
    for (final f in files) {
      if (BackupLayout.isBlob(f.name) && !referenced.contains(f.name)) {
        await remote.delete(f.id);
      }
    }
  }

  Future<BackupPhotoInfo?> _cachedPhotoInfo(String assetId) async {
    final cached = cache.photoOf(assetId);
    if (cached != null) return cached;
    final info = await photoInfo?.call(assetId);
    if (info != null) cache.putPhoto(assetId, info);
    return info;
  }

  Future<List<_LocalFile>> _localFiles(BackupSnapshot snapshot) async {
    final files = <_LocalFile>[];
    final seen = <String>{};
    Future<void> add(BackupFileKind kind, String name, File file) async {
      if (!seen.add('${kind.name}/$name')) return;
      if (await file.exists()) files.add(_LocalFile(kind, name, file));
    }

    for (final n in snapshot.notes) {
      for (final key in ['thumbnailFile', 'songCoverFile']) {
        final name = n[key] as String?;
        if (name != null) {
          await add(BackupFileKind.thumbnail, name, thumbnails.fileFor(name));
        }
      }
      final assetId = n['assetId']! as String;
      if (ImportedPhotoStore.isImportedId(assetId)) {
        await add(
          BackupFileKind.imported,
          assetId,
          imported.imageFile(assetId),
        );
      }
    }
    return files;
  }

  Future<({String sha256, int size})?> _hash(_LocalFile f) async {
    try {
      final stat = await f.file.stat();
      final mtime = stat.modified.millisecondsSinceEpoch;
      final cached = cache.hashOf(f.key, size: stat.size, mtime: mtime);
      if (cached != null) return (sha256: cached, size: stat.size);
      final bytes = await f.file.readAsBytes();
      final sha = hash.sha256.convert(bytes).toString();
      cache.putHash(f.key, size: bytes.length, mtime: mtime, sha256: sha);
      return (sha256: sha, size: bytes.length);
    } on FileSystemException {
      return null; // deleted meanwhile
    }
  }
}

class _LocalFile {
  _LocalFile(this.kind, this.name, this.file);

  final BackupFileKind kind;
  final String name;
  final File file;

  String get key => '${kind.name}/$name';
}
