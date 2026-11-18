import 'dart:typed_data';

import 'package:flutter/widgets.dart';

import '../../weather/domain/weather.dart';
import '../domain/photo_repository.dart';
import 'imported_photo_store.dart';

/// [PhotoRepository] over the private copies of picked photos. Gallery ids
/// (MediaStore, from the earlier APK version) are not resolved – the app has
/// no gallery permission – so such notes show their stored thumbnail.
class ImportedPhotoRepository implements PhotoRepository {
  ImportedPhotoRepository(this.imported);

  final ImportedPhotoStore imported;

  bool _isImported(String id) => ImportedPhotoStore.isImportedId(id);

  @override
  Future<PhotoItem?> findById(String id) async =>
      _isImported(id) ? imported.find(id) : null;

  /// The system photo picker removes GPS data, so picked photos have no
  /// location; the user can search a place for the weather instead.
  @override
  Future<GeoPoint?> locationOf(String id) async => null;

  @override
  Future<Uint8List?> scaledJpeg(
    String id, {
    int maxSide = 800,
    int quality = 85,
  }) async => _isImported(id)
      ? imported.scaledJpeg(id, maxSide: maxSide, quality: quality)
      : null;

  @override
  ImageProvider imageFor(PhotoItem item, {int? size}) {
    final file = FileImage(imported.imageFile(item.id));
    return size == null
        ? file
        : ResizeImage(file, width: size, policy: ResizeImagePolicy.fit);
  }
}
