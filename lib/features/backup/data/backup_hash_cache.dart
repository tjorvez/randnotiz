import 'dart:convert';
import 'dart:io';

import 'backup_snapshot.dart';

/// Remembers SHA-256 hashes of local files (by size and modification time)
/// and the photo info of notes, so a backup does not read every photo again.
/// Losing the file only costs time.
class BackupHashCache {
  BackupHashCache(this.file);

  final File file;

  final _hashes = <String, ({int size, int mtime, String sha256})>{};
  final _photos = <String, BackupPhotoInfo>{};
  var _loaded = false;
  var _dirty = false;

  Future<void> load() async {
    if (_loaded) return;
    _loaded = true;
    try {
      if (!await file.exists()) return;
      final json =
          jsonDecode(await file.readAsString()) as Map<String, Object?>;
      for (final MapEntry(:key, :value)
          in (json['hashes'] as Map<String, Object?>? ?? const {}).entries) {
        final v = value! as Map<String, Object?>;
        _hashes[key] = (
          size: v['size']! as int,
          mtime: v['mtime']! as int,
          sha256: v['sha256']! as String,
        );
      }
      for (final MapEntry(:key, :value)
          in (json['photos'] as Map<String, Object?>? ?? const {}).entries) {
        final v = value! as Map<String, Object?>;
        _photos[key] = (
          takenAt: DateTime.fromMillisecondsSinceEpoch(v['takenAt']! as int),
          width: v['width']! as int,
          height: v['height']! as int,
        );
      }
    } on Object {
      _hashes.clear();
      _photos.clear();
    }
  }

  String? hashOf(String key, {required int size, required int mtime}) {
    final e = _hashes[key];
    return e != null && e.size == size && e.mtime == mtime ? e.sha256 : null;
  }

  void putHash(
    String key, {
    required int size,
    required int mtime,
    required String sha256,
  }) {
    _hashes[key] = (size: size, mtime: mtime, sha256: sha256);
    _dirty = true;
  }

  BackupPhotoInfo? photoOf(String assetId) => _photos[assetId];

  void putPhoto(String assetId, BackupPhotoInfo info) {
    _photos[assetId] = info;
    _dirty = true;
  }

  /// Keeps only entries that are still in use.
  void retain({required Set<String> hashKeys, required Set<String> assetIds}) {
    final before = _hashes.length + _photos.length;
    _hashes.removeWhere((k, _) => !hashKeys.contains(k));
    _photos.removeWhere((k, _) => !assetIds.contains(k));
    if (_hashes.length + _photos.length != before) _dirty = true;
  }

  Future<void> save() async {
    if (!_dirty) return;
    await file.parent.create(recursive: true);
    final tmp = File('${file.path}.tmp');
    await tmp.writeAsString(
      jsonEncode({
        'hashes': {
          for (final MapEntry(:key, :value) in _hashes.entries)
            key: {
              'size': value.size,
              'mtime': value.mtime,
              'sha256': value.sha256,
            },
        },
        'photos': {
          for (final MapEntry(:key, :value) in _photos.entries)
            key: {
              'takenAt': value.takenAt.millisecondsSinceEpoch,
              'width': value.width,
              'height': value.height,
            },
        },
      }),
      flush: true,
    );
    await tmp.rename(file.path);
    _dirty = false;
  }
}
