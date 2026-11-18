import 'package:drift/drift.dart';

import '../../../core/async/distinct_collections.dart';
import '../../../core/database/app_database.dart';
import '../domain/collection.dart';

class DriftCollectionRepository implements CollectionRepository {
  DriftCollectionRepository(this._db, {DateTime Function()? clock})
    : _clock = clock ?? DateTime.now;

  final AppDatabase _db;
  final DateTime Function() _clock;

  static String normalizeName(String name) =>
      name.trim().replaceAll(RegExp(r'\s+'), ' ');

  static const _coverCount = 3;

  @override
  Stream<List<Collection>> watchCollections() => _watch(null);

  @override
  Stream<Collection?> watchCollection(int id) =>
      _watch(id).map((list) => list.isEmpty ? null : list.first);

  Stream<List<Collection>> _watch(int? id) {
    // Re-run whenever collections, memberships or notes change.
    final changes = _db
        .customSelect(
          'SELECT 1',
          readsFrom: {_db.collections, _db.collectionNotes, _db.notes},
        )
        .watch();
    return changes.asyncMap((_) => _load(id)).distinctLists();
  }

  Future<List<Collection>> _load(int? id) async {
    final query = _db.select(_db.collections)
      ..orderBy([
        (c) => OrderingTerm.asc(c.position),
        (c) => OrderingTerm.desc(c.createdAt),
        (c) => OrderingTerm.desc(c.id),
      ]);
    if (id != null) query.where((c) => c.id.equals(id));
    final rows = await query.get();
    if (rows.isEmpty) return const [];
    final ids = rows.map((r) => r.id).toList();
    final members =
        await (_db.select(_db.collectionNotes).join([
                innerJoin(
                  _db.notes,
                  _db.notes.id.equalsExp(_db.collectionNotes.noteId),
                ),
              ])
              ..where(_db.collectionNotes.collectionId.isIn(ids))
              ..orderBy([
                OrderingTerm.desc(_db.notes.noteDate),
                OrderingTerm.desc(_db.notes.id),
              ]))
            .get();
    final counts = <int, int>{};
    final covers = <int, List<CollectionCover>>{};
    for (final m in members) {
      final cid = m.readTable(_db.collectionNotes).collectionId;
      final note = m.readTable(_db.notes);
      counts[cid] = (counts[cid] ?? 0) + 1;
      final list = covers.putIfAbsent(cid, () => []);
      if (list.length < _coverCount) {
        list.add(
          CollectionCover(
            noteId: note.id,
            assetId: note.assetId,
            thumbnailFile: note.thumbnailFile,
          ),
        );
      }
    }
    return [
      for (final r in rows)
        Collection(
          id: r.id,
          name: r.name,
          createdAt: r.createdAt,
          noteCount: counts[r.id] ?? 0,
          covers: covers[r.id] ?? const [],
        ),
    ];
  }

  @override
  Stream<Set<int>> watchCollectionIdsOf(int noteId) {
    final query = _db.select(_db.collectionNotes)
      ..where((c) => c.noteId.equals(noteId));
    return query
        .watch()
        .map((rows) => rows.map((r) => r.collectionId).toSet())
        .distinctSets();
  }

  @override
  Future<Collection> create(String name) {
    final clean = _validName(name);
    final now = _clock();
    return _db.transaction(() async {
      // Before all others: a new collection appears first.
      final first = _db.collections.position.min();
      final min = await (_db.selectOnly(
        _db.collections,
      )..addColumns([first])).map((r) => r.read(first)).getSingle();
      final id = await _db
          .into(_db.collections)
          .insert(
            CollectionsCompanion.insert(
              name: clean,
              createdAt: now,
              position: Value(min == null ? 0 : min - 1),
            ),
          );
      return Collection(id: id, name: clean, createdAt: now);
    });
  }

  @override
  Future<void> reorder(List<int> orderedIds) => _db.batch((b) {
    for (final (position, id) in orderedIds.indexed) {
      b.update(
        _db.collections,
        CollectionsCompanion(position: Value(position)),
        where: (c) => c.id.equals(id),
      );
    }
  });

  @override
  Future<void> rename(int id, String name) =>
      (_db.update(_db.collections)..where((c) => c.id.equals(id))).write(
        CollectionsCompanion(name: Value(_validName(name))),
      );

  @override
  Future<void> delete(int id) =>
      (_db.delete(_db.collections)..where((c) => c.id.equals(id))).go();

  @override
  Future<void> addNotes(int collectionId, Iterable<int> noteIds) {
    final now = _clock();
    return _db.batch(
      (b) => b.insertAll(_db.collectionNotes, [
        for (final noteId in noteIds)
          CollectionNotesCompanion.insert(
            collectionId: collectionId,
            noteId: noteId,
            addedAt: now,
          ),
      ], mode: InsertMode.insertOrIgnore),
    );
  }

  @override
  Future<void> removeNote(int collectionId, int noteId) =>
      (_db.delete(_db.collectionNotes)..where(
            (c) =>
                c.collectionId.equals(collectionId) & c.noteId.equals(noteId),
          ))
          .go();

  static String _validName(String name) {
    final clean = normalizeName(name);
    if (clean.isEmpty) throw ArgumentError.value(name, 'name', 'empty');
    return clean.length > 60 ? clean.substring(0, 60) : clean;
  }
}
