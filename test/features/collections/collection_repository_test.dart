import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:randnotiz/core/database/app_database.dart';
import 'package:randnotiz/features/collections/data/drift_collection_repository.dart';
import 'package:randnotiz/features/collections/domain/collection.dart';
import 'package:randnotiz/features/notes/data/drift_note_repository.dart';
import 'package:randnotiz/features/notes/domain/note.dart';

void main() {
  driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;

  late AppDatabase db;
  late DriftNoteRepository notes;
  late DriftCollectionRepository collections;

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
    notes = DriftNoteRepository(db);
    collections = DriftCollectionRepository(db);
  });
  tearDown(() => db.close());

  Future<Note> write(String assetId, DateTime date) => notes.save(
    NoteDraft(assetId: assetId, body: 'Notiz $assetId', date: date),
  );

  Future<List<NoteSummary>> entries(int collectionId) => notes
      .watchJournal(JournalQuery(collectionId: collectionId, oldestFirst: true))
      .first;

  test('entries of a collection are chronological', () async {
    final c = await collections.create('  Italien   2024 ');
    expect(c.name, 'Italien 2024');
    final late = await write('a', DateTime(2024, 8, 20));
    final early = await write('b', DateTime(2024, 8, 12));
    final middle = await write('c', DateTime(2024, 8, 15));
    await write('other', DateTime(2024, 8, 16)); // not in the collection
    await collections.addNotes(c.id, [late.id, early.id, middle.id]);

    final list = await entries(c.id);
    expect(list.map((e) => e.assetId), ['b', 'c', 'a']);
  });

  test('neighbours: previous and next around an entry', () async {
    final c = await collections.create('Sommer');
    final ids = <int>[];
    for (var day = 1; day <= 3; day++) {
      ids.add((await write('$day', DateTime(2024, 7, day))).id);
    }
    await collections.addNotes(c.id, ids);
    final list = await entries(c.id);

    final first = CollectionNeighbours.of(list, ids[0])!;
    expect(first.previous, isNull);
    expect(first.next!.id, ids[1]);
    expect((first.position, first.total), (1, 3));

    final middle = CollectionNeighbours.of(list, ids[1])!;
    expect(middle.previous!.id, ids[0]);
    expect(middle.next!.id, ids[2]);

    final last = CollectionNeighbours.of(list, ids[2])!;
    expect(last.next, isNull);
    expect(CollectionNeighbours.of(list, 999), isNull);
  });

  test('counts and covers update; deleting a note removes it', () async {
    final c = await collections.create('Oma');
    final a = await write('a', DateTime(2023, 1, 1));
    final b = await write('b', DateTime(2023, 2, 1));
    await collections.addNotes(c.id, [a.id, b.id]);
    await collections.addNotes(c.id, [a.id]); // twice is fine

    var overview = (await collections.watchCollections().first).single;
    expect(overview.noteCount, 2);
    expect(overview.covers.first.assetId, 'b'); // newest first

    await notes.deleteByAsset('b');
    overview = (await collections.watchCollections().first).single;
    expect(overview.noteCount, 1);
    expect(await collections.watchCollectionIdsOf(a.id).first, {c.id});

    await collections.removeNote(c.id, a.id);
    expect(await collections.watchCollectionIdsOf(a.id).first, isEmpty);
  });

  test('deleting a collection keeps its notes', () async {
    final c = await collections.create('Weg damit');
    final a = await write('a', DateTime(2023, 1, 1));
    await collections.addNotes(c.id, [a.id]);
    await collections.delete(c.id);
    expect(await collections.watchCollections().first, isEmpty);
    expect(await notes.findByAsset('a'), isNotNull);
  });

  test('a note can be in several collections', () async {
    final trip = await collections.create('Reise');
    final food = await collections.create('Essen');
    final a = await write('a', DateTime(2023, 1, 1));
    await collections.addNotes(trip.id, [a.id]);
    await collections.addNotes(food.id, [a.id]);
    expect(await collections.watchCollectionIdsOf(a.id).first, {
      trip.id,
      food.id,
    });
  });

  test('new collections come first; the order can be changed', () async {
    Future<List<String>> names() async =>
        (await collections.watchCollections().first)
            .map((c) => c.name)
            .toList();

    final a = await collections.create('A');
    final b = await collections.create('B');
    final c = await collections.create('C');
    expect(await names(), ['C', 'B', 'A']);

    await collections.reorder([a.id, c.id, b.id]);
    expect(await names(), ['A', 'C', 'B']);

    // A collection created after reordering still appears first.
    await collections.create('D');
    expect(await names(), ['D', 'A', 'C', 'B']);
  });

  test('empty names are rejected', () async {
    expect(() => collections.create('   '), throwsArgumentError);
  });
}
