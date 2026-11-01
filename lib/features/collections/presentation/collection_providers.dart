import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/providers.dart';
import '../../notes/domain/note.dart';
import '../domain/collection.dart';

/// Entries of a collection in chronological order.
final collectionEntriesProvider = StreamProvider.autoDispose
    .family<List<NoteSummary>, int>(
      (ref, id) => ref
          .watch(noteRepositoryProvider)
          .watchJournal(JournalQuery(collectionId: id, oldestFirst: true)),
    );

final collectionProvider = StreamProvider.autoDispose.family<Collection?, int>(
  (ref, id) => ref.watch(collectionRepositoryProvider).watchCollection(id),
);

/// Ids of the collections a note belongs to.
final noteCollectionIdsProvider = StreamProvider.autoDispose
    .family<Set<int>, int>(
      (ref, noteId) =>
          ref.watch(collectionRepositoryProvider).watchCollectionIdsOf(noteId),
    );
