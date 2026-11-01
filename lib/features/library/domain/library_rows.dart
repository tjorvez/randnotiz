import 'photo_repository.dart';

sealed class LibraryRow {
  const LibraryRow();
}

class MonthHeaderRow extends LibraryRow {
  const MonthHeaderRow(this.month);

  /// First day of the month.
  final DateTime month;
}

class PhotoGridRow extends LibraryRow {
  const PhotoGridRow(this.photos);
  final List<PhotoItem> photos;
}

/// Turns a newest-first photo list into month headers and grid rows of
/// [columns] photos (a month never shares a row with another month).
List<LibraryRow> buildLibraryRows(
  List<PhotoItem> photos, {
  required int columns,
}) {
  assert(columns > 0);
  final rows = <LibraryRow>[];
  DateTime? currentMonth;
  var buffer = <PhotoItem>[];

  void flush() {
    if (buffer.isNotEmpty) rows.add(PhotoGridRow(buffer));
    buffer = <PhotoItem>[];
  }

  for (final photo in photos) {
    final month = DateTime(photo.createdAt.year, photo.createdAt.month);
    if (month != currentMonth) {
      flush();
      rows.add(MonthHeaderRow(month));
      currentMonth = month;
    }
    buffer.add(photo);
    if (buffer.length == columns) flush();
  }
  flush();
  return rows;
}
