import 'dart:io';

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:randnotiz/features/library/data/imported_photo_repository.dart';
import 'package:randnotiz/features/library/data/imported_photo_store.dart';

import 'imported_photo_store_test.dart' show FakePicker;

void main() {
  late Directory dir;
  late ImportedPhotoStore store;
  late ImportedPhotoRepository photos;

  setUp(() async {
    dir = await Directory.systemTemp.createTemp('randnotiz_photos');
    store = ImportedPhotoStore(dir);
    photos = ImportedPhotoRepository(store);
  });
  tearDown(() => dir.delete(recursive: true));

  test('finds picked photos and shows their private copy', () async {
    final item = await store.pickAndImport(
      FakePicker((width: 1600, height: 900, takenAt: DateTime(2024, 5, 1))),
    );
    final found = await photos.findById(item!.id);
    expect(found, item);
    expect(found!.aspectRatio, closeTo(16 / 9, 1e-9));

    final full = photos.imageFor(found);
    expect(full, isA<FileImage>());
    expect((full as FileImage).file.path, store.imageFile(item.id).path);
    expect(photos.imageFor(found, size: 200), isA<ResizeImage>());
  });

  test('picked photos carry no location (the picker removes GPS)', () async {
    final item = await store.pickAndImport(
      FakePicker((width: 1, height: 1, takenAt: null)),
    );
    expect(await photos.locationOf(item!.id), isNull);
  });

  test('gallery ids from the APK version are not resolved', () async {
    // No media permission: such notes fall back to their stored thumbnail.
    expect(await photos.findById('1000012345'), isNull);
    expect(await photos.scaledJpeg('1000012345'), isNull);
    expect(await photos.locationOf('1000012345'), isNull);
  });
}
