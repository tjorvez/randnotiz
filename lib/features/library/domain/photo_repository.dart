import 'dart:typed_data';

import 'package:flutter/widgets.dart';

import '../../weather/domain/weather.dart';

/// A photo a note belongs to.
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

/// Read-only access to the photos notes point to. Randnotiz does not read the
/// device gallery (no media permission): every photo is a private copy made
/// when the user picks it with the system photo picker.
abstract interface class PhotoRepository {
  /// Null if the photo no longer exists.
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
}
