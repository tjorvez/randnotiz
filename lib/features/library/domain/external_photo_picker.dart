/// Size and capture time of a picked photo.
typedef PickedImage = ({int width, int height, DateTime? takenAt});

/// Picks a single photo from outside the device gallery – today the Android
/// system photo picker, which also shows Google Photos when Google Photos is
/// set as the picker's cloud media app. A later implementation could use the
/// Google Photos Picker API (needs an OAuth client).
abstract interface class ExternalPhotoPicker {
  /// Lets the user choose a photo and stores a downscaled JPEG copy at
  /// [destPath]. Returns null if the user cancelled.
  Future<PickedImage?> pickInto(String destPath, {int maxSide = 1600});
}
