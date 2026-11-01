import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:randnotiz/features/library/data/imported_photo_store.dart';
import 'package:randnotiz/features/library/domain/external_photo_picker.dart';

class FakePicker implements ExternalPhotoPicker {
  FakePicker(this.result);

  final PickedImage? result;

  @override
  Future<PickedImage?> pickInto(String destPath, {int maxSide = 1600}) async {
    if (result == null) return null;
    await File(destPath).writeAsBytes([0xFF, 0xD8, 0xFF]); // fake JPEG
    return result;
  }
}

void main() {
  late Directory dir;
  late ImportedPhotoStore store;

  setUp(() async {
    dir = await Directory.systemTemp.createTemp('randnotiz_import');
    store = ImportedPhotoStore(dir);
  });
  tearDown(() => dir.delete(recursive: true));

  test('keeps the capture date reported by the picker', () async {
    final taken = DateTime(2019, 7, 4, 18, 30);
    final item = await store.pickAndImport(
      FakePicker((width: 1600, height: 1200, takenAt: taken)),
      now: DateTime(2026, 10, 31),
    );
    expect(item, isNotNull);
    expect(ImportedPhotoStore.isImportedId(item!.id), isTrue);
    expect(item.createdAt, taken);

    final found = await store.find(item.id);
    expect(found!.createdAt, taken);
    expect(found.width, 1600);
    expect(await store.imageFile(item.id).exists(), isTrue);
  });

  test('without a date the import time is used', () async {
    final now = DateTime(2026, 10, 31, 12);
    final item = await store.pickAndImport(
      FakePicker((width: 10, height: 10, takenAt: null)),
      now: now,
    );
    expect(item!.createdAt, now);
  });

  test('cancelled picker imports nothing', () async {
    expect(await store.pickAndImport(FakePicker(null)), isNull);
    expect(await dir.list().isEmpty, isTrue);
  });

  test('orphans without a note are removed, noted ones kept', () async {
    const r = (width: 1, height: 1, takenAt: null);
    final kept = await store.pickAndImport(FakePicker(r));
    final orphan = await store.pickAndImport(FakePicker(r));

    expect(await store.deleteOrphans({kept!.id}), 1);
    expect(await store.find(kept.id), isNotNull);
    expect(await store.find(orphan!.id), isNull);
    expect(await store.imageFile(orphan.id).exists(), isFalse);
  });

  test('gallery ids are not treated as imported', () {
    expect(ImportedPhotoStore.isImportedId('1000012345'), isFalse);
  });
}
