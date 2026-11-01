import 'dart:typed_data';

import 'package:flutter/widgets.dart';

import '../../weather/domain/weather.dart';

enum PhotoAccess {
  /// All photos.
  full,

  /// Android 14+ "selected photos only".
  limited,
  denied,
}

/// A photo of the device gallery.
@immutable
class PhotoItem {
  const PhotoItem({
    required this.id,
    required this.createdAt,
    required this.width,
    required this.height,
  });

  final String id;

  /// Capture date if known, otherwise the date it was added.
  final DateTime createdAt;
  final int width;
  final int height;

  double get aspectRatio => width > 0 && height > 0 ? width / height : 1;

  @override
  bool operator ==(Object other) => other is PhotoItem && other.id == id;

  @override
  int get hashCode => id.hashCode;
}

/// Read-only access to the device gallery.
abstract interface class PhotoRepository {
  Future<PhotoAccess> currentAccess();

  /// Shows the system permission dialog (incl. media location).
  Future<PhotoAccess> requestAccess();

  /// Lets the user pick more photos (Android 14+ partial access) or opens the
  /// app settings on older versions.
  Future<void> manageAccess();

  /// Photos sorted newest first; [page] starts at 0.
  Future<List<PhotoItem>> loadPage(int page, {int pageSize = 120});

  /// Null if the photo no longer exists or is not accessible.
  Future<PhotoItem?> findById(String id);

  /// GPS position from the photo's metadata, if any.
  Future<GeoPoint?> locationOf(String id);

  /// JPEG of the photo scaled so the longer side is at most [maxSide].
  Future<Uint8List?> scaledJpeg(
    String id, {
    int maxSide = 800,
    int quality = 85,
  });

  /// Image for display. [size] is the requested thumbnail edge in pixels;
  /// null loads a large version for the editor.
  ImageProvider imageFor(PhotoItem item, {int? size});

  /// Emits when the gallery content changed (photo added/removed).
  Stream<void> get changes;
}
