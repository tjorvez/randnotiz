import 'dart:typed_data';

import 'package:flutter/widgets.dart';

import '../../weather/domain/weather.dart';
import '../domain/photo_repository.dart';
import 'imported_photo_store.dart';

/// The gallery plus photos imported from outside (Google Photos & co.).
/// Gallery browsing (permission, paging, changes) goes to [gallery]; lookups
/// by id are routed by the `picked:` prefix.
class CombinedPhotoRepository implements PhotoRepository {
  CombinedPhotoRepository(this.gallery, this.imported);

  final PhotoRepository gallery;
  final ImportedPhotoStore imported;

  bool _isImported(String id) => ImportedPhotoStore.isImportedId(id);

  @override
  Future<PhotoAccess> currentAccess() => gallery.currentAccess();

  @override
  Future<PhotoAccess> requestAccess() => gallery.requestAccess();

  @override
  Future<void> manageAccess() => gallery.manageAccess();

  @override
  Future<List<PhotoItem>> loadPage(int page, {int pageSize = 120}) =>
      gallery.loadPage(page, pageSize: pageSize);

  @override
  Stream<void> get changes => gallery.changes;

  @override
  Future<PhotoItem?> findById(String id) =>
      _isImported(id) ? imported.find(id) : gallery.findById(id);

  /// The system photo picker removes GPS data, so imported photos have no
  /// location; the user can search a place for the weather instead.
  @override
  Future<GeoPoint?> locationOf(String id) async =>
      _isImported(id) ? null : gallery.locationOf(id);

  @override
  Future<Uint8List?> scaledJpeg(
    String id, {
    int maxSide = 800,
    int quality = 85,
  }) => _isImported(id)
      ? imported.scaledJpeg(id, maxSide: maxSide, quality: quality)
      : gallery.scaledJpeg(id, maxSide: maxSide, quality: quality);

  @override
  ImageProvider imageFor(PhotoItem item, {int? size}) {
    if (!_isImported(item.id)) return gallery.imageFor(item, size: size);
    final file = FileImage(imported.imageFile(item.id));
    return size == null
        ? file
        : ResizeImage(file, width: size, policy: ResizeImagePolicy.fit);
  }
}
