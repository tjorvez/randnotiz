import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:flutter/services.dart';
import 'package:path/path.dart' as p;

import '../domain/external_photo_picker.dart';
import '../domain/photo_repository.dart';

/// Native image helper (MainActivity.kt / ImageTools.kt).
class ImageTools {
  const ImageTools();

  static const _channel = MethodChannel('io.github.randnotiz.app/images');

  /// Downscales [src] (longer side ≤ [maxSide]), applies the EXIF
  /// orientation and writes a JPEG to [dest].
  Future<PickedImage> importImage(
    String src,
    String dest, {
    int maxSide = 1600,
    int quality = 88,
  }) async => _parse(
    await _channel.invokeMapMethod<String, Object?>('importImage', {
      'src': src,
      'dest': dest,
      'maxSide': maxSide,
      'quality': quality,
    }),
  );

  static PickedImage _parse(Map<String, Object?>? result) {
    final takenAt = result?['takenAt'];
    return (
      width: (result?['width'] as int?) ?? 0,
      height: (result?['height'] as int?) ?? 0,
      takenAt: takenAt is int
          ? DateTime.fromMillisecondsSinceEpoch(takenAt)
          : null,
    );
  }
}

/// [ExternalPhotoPicker] using Android's system photo picker (native, see
/// MainActivity.kt). Needs no storage permission; the capture date comes from
/// the picker itself, which also works for Google Photos cloud items.
class SystemPhotoPicker implements ExternalPhotoPicker {
  const SystemPhotoPicker();

  static const _channel = MethodChannel('io.github.randnotiz.app/images');

  @override
  Future<PickedImage?> pickInto(String destPath, {int maxSide = 1600}) async {
    final result = await _channel.invokeMapMethod<String, Object?>(
      'pickImage',
      {'dest': destPath, 'maxSide': maxSide, 'quality': 88},
    );
    return result == null ? null : ImageTools._parse(result);
  }
}

/// Photos picked from outside the gallery (e.g. Google Photos). They live as
/// JPEG copies (≤ 1600 px) in the app's private storage, with their id
/// prefixed by `picked:`. A copy only stays if a note is written for it.
class ImportedPhotoStore {
  ImportedPhotoStore(this.directory, {this._tools = const ImageTools()});

  final Directory directory;
  final ImageTools _tools;

  static const idPrefix = 'picked:';

  static bool isImportedId(String id) => id.startsWith(idPrefix);

  static final _unsafe = RegExp(r'[^A-Za-z0-9_-]');

  String _base(String id) =>
      id.substring(idPrefix.length).replaceAll(_unsafe, '_');

  File imageFile(String id) => File(p.join(directory.path, '${_base(id)}.jpg'));
  File _metaFile(String id) =>
      File(p.join(directory.path, '${_base(id)}.json'));

  /// A fresh `picked:` id.
  static String newId(DateTime now) =>
      '$idPrefix${now.millisecondsSinceEpoch}${Random().nextInt(1 << 20).toRadixString(36)}';

  /// Stores [jpeg] as the copy for [id] (restoring a backup).
  Future<void> restore(
    String id,
    Uint8List jpeg, {
    required DateTime createdAt,
    required int width,
    required int height,
  }) async {
    await directory.create(recursive: true);
    final image = imageFile(id);
    final tmp = File('${image.path}.tmp');
    await tmp.writeAsBytes(jpeg, flush: true);
    await tmp.rename(image.path);
    await _metaFile(id).writeAsString(
      jsonEncode({
        'createdAt': createdAt.millisecondsSinceEpoch,
        'width': width,
        'height': height,
      }),
    );
  }

  /// Lets the user pick a photo with [picker] and keeps a private copy.
  /// Returns null if the user cancelled.
  Future<PhotoItem?> pickAndImport(
    ExternalPhotoPicker picker, {
    DateTime? now,
  }) async {
    await directory.create(recursive: true);
    final time = now ?? DateTime.now();
    final id = newId(time);
    final picked = await picker.pickInto(imageFile(id).path);
    if (picked == null) return null;
    final item = PhotoItem(
      id: id,
      createdAt: picked.takenAt ?? time,
      width: picked.width,
      height: picked.height,
    );
    await _metaFile(id).writeAsString(
      jsonEncode({
        'createdAt': item.createdAt.millisecondsSinceEpoch,
        'width': item.width,
        'height': item.height,
      }),
    );
    return item;
  }

  Future<PhotoItem?> find(String id) async {
    final meta = _metaFile(id);
    if (!await meta.exists() || !await imageFile(id).exists()) return null;
    try {
      final json =
          jsonDecode(await meta.readAsString()) as Map<String, Object?>;
      return PhotoItem(
        id: id,
        createdAt: DateTime.fromMillisecondsSinceEpoch(
          json['createdAt']! as int,
        ),
        width: json['width']! as int,
        height: json['height']! as int,
      );
    } on Object {
      return null;
    }
  }

  /// JPEG scaled to [maxSide] (for the ~800 px journal copy).
  Future<Uint8List?> scaledJpeg(
    String id, {
    int maxSide = 800,
    int quality = 85,
  }) async {
    final src = imageFile(id);
    if (!await src.exists()) return null;
    final tmp = File(p.join(directory.path, '${_base(id)}.scaled.jpg'));
    try {
      await _tools.importImage(
        src.path,
        tmp.path,
        maxSide: maxSide,
        quality: quality,
      );
      return await tmp.readAsBytes();
    } finally {
      if (await tmp.exists()) await tmp.delete();
    }
  }

  Future<void> delete(String id) async {
    for (final f in [imageFile(id), _metaFile(id)]) {
      if (await f.exists()) await f.delete();
    }
  }

  /// Removes imported photos without a note (e.g. app closed while the
  /// editor was open and nothing was written).
  Future<int> deleteOrphans(Set<String> notedIds) async {
    if (!await directory.exists()) return 0;
    var removed = 0;
    await for (final entity in directory.list()) {
      if (entity is! File || !entity.path.endsWith('.json')) continue;
      final id = '$idPrefix${p.basenameWithoutExtension(entity.path)}';
      if (!notedIds.contains(id)) {
        await delete(id);
        removed++;
      }
    }
    return removed;
  }
}
