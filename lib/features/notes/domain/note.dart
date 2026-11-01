import 'package:flutter/foundation.dart';

import '../../music/domain/song.dart';
import '../../tags/domain/tag.dart';
import '../../weather/domain/weather.dart';

/// A stored diary note.
class Note {
  const Note({
    required this.id,
    required this.assetId,
    required this.body,
    required this.date,
    required this.tags,
    required this.createdAt,
    required this.updatedAt,
    this.weather,
    this.thumbnailFile,
    this.placeName,
    this.placeNameAlt,
    this.countryCode,
    this.geoChecked = false,
    this.title,
    this.photoAspect,
    this.song,
  });

  final int id;
  final String assetId;
  final String body;

  /// Optional linked song.
  final Song? song;

  /// Optional title, handwritten on the polaroid's rim.
  final String? title;

  /// Width / height of the photo; null if unknown.
  final double? photoAspect;
  final DateTime date;
  final WeatherSnapshot? weather;

  /// Optional place: typed in or the nearest town of the photo's position.
  final String? placeName;

  /// English/international name of [placeName] if different.
  final String? placeNameAlt;

  /// ISO 3166-1 alpha-2 code of the country.
  final String? countryCode;

  /// Country/place were looked up or set by hand.
  final bool geoChecked;
  final String? thumbnailFile;
  final List<Tag> tags;
  final DateTime createdAt;
  final DateTime updatedAt;
}

/// The editable content of a note, used to create or update it.
class NoteDraft {
  const NoteDraft({
    required this.assetId,
    required this.body,
    required this.date,
    this.weather,
    this.tagIds = const {},
    this.placeName,
    this.placeNameAlt,
    this.countryCode,
    this.geoChecked = false,
    this.keepStoredGeo = false,
    this.title,
    this.photoAspect,
    this.song,
  });

  final String assetId;
  final String body;
  final String? title;

  /// The linked song; null removes it.
  final Song? song;

  /// Width / height of the photo if known (kept if null).
  final double? photoAspect;
  final DateTime date;
  final WeatherSnapshot? weather;
  final String? placeName;
  final String? placeNameAlt;
  final String? countryCode;

  /// Set once country/place were looked up or chosen (no back-fill then).
  final bool geoChecked;

  /// Leaves the stored place, its second name and the country as they are
  /// (for an existing note whose place was not touched).
  final bool keepStoredGeo;
  final Set<int> tagIds;

  /// A note without text, title, tags and song is not worth keeping.
  bool get isBlank =>
      body.trim().isEmpty &&
      (title?.trim() ?? '').isEmpty &&
      tagIds.isEmpty &&
      song == null;
}

/// A lightweight row for lists (journal, memories, widget).
@immutable
class NoteSummary {
  const NoteSummary({
    required this.id,
    required this.assetId,
    required this.date,
    required this.preview,
    required this.tags,
    this.weather,
    this.thumbnailFile,
    this.highlightedSnippet,
    this.placeName,
    this.countryCode,
    this.title,
    this.highlightedTitle,
    this.photoAspect,
    this.song,
  });

  /// Optional linked song.
  final Song? song;

  final String? placeName;
  final String? countryCode;

  /// Optional title of the note.
  final String? title;

  /// [title] with search hits marked (search results only).
  final String? highlightedTitle;

  /// Width / height of the photo; null if unknown.
  final double? photoAspect;

  final int id;
  final String assetId;
  final DateTime date;

  /// The first few hundred characters of the note.
  final String preview;
  final List<Tag> tags;
  final WeatherSnapshot? weather;
  final String? thumbnailFile;

  /// Snippet with search hits marked (see `core/search/highlight.dart`),
  /// only set for search results.
  final String? highlightedSnippet;

  // Value equality lets repeated, unchanged query results be dropped
  // before they rebuild the lists (see `core/async/distinct_collections`).
  @override
  bool operator ==(Object other) =>
      other is NoteSummary &&
      other.id == id &&
      other.assetId == assetId &&
      other.date == date &&
      other.preview == preview &&
      listEquals(other.tags, tags) &&
      other.weather == weather &&
      other.thumbnailFile == thumbnailFile &&
      other.highlightedSnippet == highlightedSnippet &&
      other.placeName == placeName &&
      other.countryCode == countryCode &&
      other.title == title &&
      other.highlightedTitle == highlightedTitle &&
      other.photoAspect == photoAspect &&
      other.song == song;

  @override
  int get hashCode => Object.hash(
    song,
    id,
    assetId,
    date,
    preview,
    Object.hashAll(tags),
    weather,
    thumbnailFile,
    highlightedSnippet,
    placeName,
    countryCode,
    title,
    highlightedTitle,
    photoAspect,
  );
}

/// Filter for the journal.
class JournalQuery {
  const JournalQuery({
    this.text = '',
    this.tagIds = const {},
    this.collectionId,
    this.oldestFirst = false,
    this.placeName,
    this.countryCode,
  });

  final String text;

  /// Only notes that carry *all* of these tags.
  final Set<int> tagIds;

  /// Only notes at this place (exact name, case-insensitive).
  final String? placeName;

  /// Only notes in this country.
  final String? countryCode;

  /// Only notes of this collection.
  final int? collectionId;

  /// Chronological order (collections) instead of newest first.
  final bool oldestFirst;

  bool get isEmpty =>
      text.trim().isEmpty &&
      tagIds.isEmpty &&
      collectionId == null &&
      placeName == null &&
      countryCode == null;

  JournalQuery copyWith({
    String? text,
    Set<int>? tagIds,
    String? Function()? placeName,
    String? Function()? countryCode,
  }) => JournalQuery(
    text: text ?? this.text,
    tagIds: tagIds ?? this.tagIds,
    collectionId: collectionId,
    oldestFirst: oldestFirst,
    placeName: placeName != null ? placeName() : this.placeName,
    countryCode: countryCode != null ? countryCode() : this.countryCode,
  );

  @override
  bool operator ==(Object other) =>
      other is JournalQuery &&
      other.text == text &&
      other.collectionId == collectionId &&
      other.oldestFirst == oldestFirst &&
      other.placeName == placeName &&
      other.countryCode == countryCode &&
      other.tagIds.length == tagIds.length &&
      other.tagIds.containsAll(tagIds);

  @override
  int get hashCode => Object.hash(
    text,
    collectionId,
    oldestFirst,
    placeName,
    countryCode,
    Object.hashAllUnordered(tagIds),
  );
}

/// A place name as used by notes.
@immutable
class PlaceUse {
  const PlaceUse({required this.name, required this.count, this.countryCode});

  final String name;
  final String? countryCode;
  final int count;

  @override
  bool operator ==(Object other) =>
      other is PlaceUse &&
      other.name == name &&
      other.countryCode == countryCode &&
      other.count == count;

  @override
  int get hashCode => Object.hash(name, countryCode, count);
}

abstract interface class NoteRepository {
  Future<Note?> findByAsset(String assetId);

  Stream<Note?> watchByAsset(String assetId);

  /// Cover files of linked songs still used by a note.
  Future<Set<String>> songCoverFilesInUse();

  /// Creates the note for [NoteDraft.assetId] or updates the existing one,
  /// including its tags and the search index.
  Future<Note> save(NoteDraft draft);

  Future<void> setThumbnailFile(int noteId, String? fileName);

  /// Stores the photo's width / height ratio (see [Note.photoAspect]).
  Future<void> setPhotoAspect(int noteId, double aspect);

  /// Notes whose photo aspect ratio is not known yet (one-time back-fill).
  Future<List<({int id, String assetId, String? thumbnailFile})>>
  notesWithoutPhotoAspect();

  /// Notes whose country/place were not looked up yet (one-time back-fill).
  Future<List<({int id, String assetId, String? placeName})>> notesNeedingGeo();

  /// Stores the looked-up country and place of a note and marks it as
  /// checked. A place the note already has is kept.
  Future<void> setGeo(
    int noteId, {
    String? countryCode,
    String? placeName,
    String? placeNameAlt,
  });

  /// Number of notes per country code.
  Stream<Map<String, int>> watchCountryCounts();

  /// Places used by notes (with their country and how often), most used
  /// first – for search suggestions.
  Stream<List<PlaceUse>> watchPlaces();

  /// Deletes the note. Returns the thumbnail file name that should be removed.
  Future<String?> deleteByAsset(String assetId);

  /// Asset ids of all photos that have a note (for the library badges).
  Stream<Set<String>> watchNotedAssetIds();

  /// Notes matching [query], newest first.
  Stream<List<NoteSummary>> watchJournal(JournalQuery query);

  Future<int> count();
}
