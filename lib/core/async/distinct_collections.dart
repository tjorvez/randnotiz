import 'package:flutter/foundation.dart';

// Drift re-runs a watched query after every write to one of its tables,
// even when the result is the same (e.g. an autosave of the note text
// re-emits the list of countries). A fresh but equal list would still
// notify every listener – and rebuild every tab, including the hidden ones.
// These helpers drop such repeats. The elements need value equality.

extension DistinctLists<T> on Stream<List<T>> {
  /// Skips results equal (element by element) to the previous one.
  Stream<List<T>> distinctLists() => distinct(listEquals);
}

extension DistinctSets<T> on Stream<Set<T>> {
  Stream<Set<T>> distinctSets() => distinct(setEquals);
}

extension DistinctMaps<K, V> on Stream<Map<K, V>> {
  Stream<Map<K, V>> distinctMaps() => distinct(mapEquals);
}
