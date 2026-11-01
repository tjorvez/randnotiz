import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/providers.dart';
import '../../geo/data/geo_database.dart';
import '../../library/data/imported_photo_store.dart';
import '../../library/domain/photo_repository.dart';
import '../../music/domain/music_service.dart';
import '../../music/domain/song.dart';
import '../../weather/domain/place_search.dart';
import '../../weather/domain/weather.dart';
import '../data/thumbnail_store.dart';
import '../domain/note.dart';

enum WeatherLookup { idle, loading, done, noLocation, failed, manual }

/// [failed]: the last save did not work; it is retried automatically.
enum SaveStatus { clean, pending, saving, saved, failed }

@immutable
class NoteEditorState {
  const NoteEditorState({
    this.loading = true,
    this.photo,
    this.photoMissing = false,
    this.thumbnailFile,
    this.noteId,
    this.initialBody = '',
    this.initialTitle = '',
    this.photoAspect,
    required this.date,
    this.weather,
    this.weatherLookup = WeatherLookup.idle,
    this.tagIds = const {},
    this.saveStatus = SaveStatus.clean,
    this.photoHasLocation,
    this.placeName,
    this.placeNameAlt,
    this.countryCode,
    this.song,
  });

  final bool loading;

  /// The linked song, if any.
  final Song? song;
  final PhotoItem? photo;

  /// The original photo is gone; only the stored copy can be shown.
  final bool photoMissing;
  final String? thumbnailFile;
  final int? noteId;
  final String initialBody;
  final String initialTitle;

  /// Width / height of the photo (stored with the note, else from the
  /// gallery). Null if unknown.
  final double? photoAspect;
  final DateTime date;
  final WeatherSnapshot? weather;
  final WeatherLookup weatherLookup;
  final Set<int> tagIds;
  final SaveStatus saveStatus;

  /// Whether the photo carries GPS data; null until it was checked.
  final bool? photoHasLocation;

  /// Optional place: typed in or the nearest town of the photo's position.
  final String? placeName;

  /// English/international name of [placeName] if different (searchable).
  final String? placeNameAlt;

  /// ISO 3166-1 alpha-2 code of the country.
  final String? countryCode;

  bool get exists => noteId != null;

  NoteEditorState copyWith({
    bool? loading,
    PhotoItem? Function()? photo,
    bool? photoMissing,
    String? Function()? thumbnailFile,
    int? Function()? noteId,
    String? initialBody,
    String? initialTitle,
    double? Function()? photoAspect,
    DateTime? date,
    WeatherSnapshot? Function()? weather,
    WeatherLookup? weatherLookup,
    Set<int>? tagIds,
    SaveStatus? saveStatus,
    bool? photoHasLocation,
    String? Function()? placeName,
    String? Function()? placeNameAlt,
    String? Function()? countryCode,
    Song? Function()? song,
  }) => NoteEditorState(
    loading: loading ?? this.loading,
    photo: photo != null ? photo() : this.photo,
    photoMissing: photoMissing ?? this.photoMissing,
    thumbnailFile: thumbnailFile != null ? thumbnailFile() : this.thumbnailFile,
    noteId: noteId != null ? noteId() : this.noteId,
    initialBody: initialBody ?? this.initialBody,
    initialTitle: initialTitle ?? this.initialTitle,
    photoAspect: photoAspect != null ? photoAspect() : this.photoAspect,
    date: date ?? this.date,
    weather: weather != null ? weather() : this.weather,
    weatherLookup: weatherLookup ?? this.weatherLookup,
    tagIds: tagIds ?? this.tagIds,
    saveStatus: saveStatus ?? this.saveStatus,
    photoHasLocation: photoHasLocation ?? this.photoHasLocation,
    placeName: placeName != null ? placeName() : this.placeName,
    placeNameAlt: placeNameAlt != null ? placeNameAlt() : this.placeNameAlt,
    countryCode: countryCode != null ? countryCode() : this.countryCode,
    song: song != null ? song() : this.song,
  );
}

/// Everything of a [NoteEditorState] except the save status.
///
/// The editor page watches only this, so the frequent status changes while
/// typing (pending → saving → saved) rebuild just the save indicator, not
/// the photo, the paper and the panels.
@immutable
class NoteEditorContent {
  const NoteEditorContent(this.state);

  final NoteEditorState state;

  @override
  bool operator ==(Object other) {
    if (other is! NoteEditorContent) return false;
    final a = state, b = other.state;
    return identical(a, b) ||
        a.loading == b.loading &&
            a.photo == b.photo &&
            a.photoMissing == b.photoMissing &&
            a.thumbnailFile == b.thumbnailFile &&
            a.noteId == b.noteId &&
            a.initialBody == b.initialBody &&
            a.initialTitle == b.initialTitle &&
            a.photoAspect == b.photoAspect &&
            a.date == b.date &&
            a.weather == b.weather &&
            a.weatherLookup == b.weatherLookup &&
            setEquals(a.tagIds, b.tagIds) &&
            a.photoHasLocation == b.photoHasLocation &&
            a.placeName == b.placeName &&
            a.placeNameAlt == b.placeNameAlt &&
            a.countryCode == b.countryCode &&
            a.song == b.song;
  }

  @override
  int get hashCode => Object.hash(
    state.loading,
    state.photo,
    state.noteId,
    state.date,
    state.weather,
    state.weatherLookup,
    Object.hashAllUnordered(state.tagIds),
    state.placeName,
    state.countryCode,
    state.thumbnailFile,
    state.song,
  );
}

final noteEditorProvider = NotifierProvider.autoDispose
    .family<NoteEditorController, NoteEditorState, String>(
      NoteEditorController.new,
    );

/// Loads and autosaves the note of one photo.
///
/// Saving rules:
/// * text changes are saved after a short pause ([textDebounce]),
/// * date/weather/tag changes almost immediately,
/// * pending changes are flushed when the editor closes or the app pauses,
/// * a failed save shows [SaveStatus.failed] and is retried ([retryDelay]),
/// * a note without text, title, tags and song is not kept: a new one is
///   never created, an existing one is deleted when the editor closes (not
///   while typing – the text can still be brought back, see [undoClear]).
class NoteEditorController extends Notifier<NoteEditorState> {
  NoteEditorController(this.assetId);

  final String assetId;

  static const textDebounce = Duration(milliseconds: 700);
  static const metaDebounce = Duration(milliseconds: 150);
  static const retryDelay = Duration(seconds: 3);

  late NoteRepository _notes;
  late PhotoRepository _photos;
  late WeatherProvider _weather;
  late ThumbnailStore _thumbnails;
  late ImportedPhotoStore _imported;
  late Future<GeoDatabase> _geo;
  late MusicService _music;

  /// Country/place were looked up or chosen (saved with the note).
  bool _geoChecked = false;

  String _body = '';
  String _title = '';
  Timer? _timer;
  Future<void> _saveChain = Future.value();
  bool _disposed = false;

  /// A save is running (the note may be about to be created).
  bool _saving = false;

  /// A change that waits for the note to exist came in during a save.
  bool _saveAgain = false;

  /// Text and title before the note was emptied (for [undoClear]).
  ({String body, String title})? _beforeClear;

  String get body => _body;
  String get title => _title;

  /// Text and title the note had before it was emptied, while it can still
  /// be brought back; null otherwise.
  ({String body, String title})? get clearedContent => _beforeClear;

  @override
  NoteEditorState build() {
    _notes = ref.watch(noteRepositoryProvider);
    _photos = ref.watch(photoRepositoryProvider);
    _weather = ref.watch(weatherProviderProvider);
    _thumbnails = ref.watch(thumbnailStoreProvider);
    _imported = ref.watch(importedPhotoStoreProvider);
    _geo = ref.watch(geoDatabaseProvider.future);
    _music = ref.watch(musicServiceProvider);
    ref.onDispose(() {
      _disposed = true;
      // Dependencies were captured above, so the final save can still run.
      unawaited(
        flush()
            .then((_) => _deleteIfBlank())
            .then((_) => _discardUnusedImport()),
      );
    });
    _current = NoteEditorState(date: ref.read(clockProvider)());
    unawaited(_load());
    return _current;
  }

  /// Mirror of [state] that stays readable after dispose (final flush).
  late NoteEditorState _current;

  void _emit(NoteEditorState Function(NoteEditorState s) change) {
    _current = change(_current);
    if (!_disposed) state = _current;
  }

  Future<void> _load() async {
    final note = await _notes.findByAsset(assetId);
    final photo = await _photos.findById(assetId);
    if (note != null) {
      _body = note.body;
      _title = note.title ?? '';
      _geoChecked = note.geoChecked;
      _emit(
        (s) => s.copyWith(
          loading: false,
          photo: () => photo,
          photoMissing: photo == null,
          noteId: () => note.id,
          thumbnailFile: () => note.thumbnailFile,
          initialBody: note.body,
          initialTitle: _title,
          photoAspect: () => note.photoAspect ?? photo?.aspectRatio,
          date: note.date,
          weather: () => note.weather,
          weatherLookup: note.weather == null
              ? WeatherLookup.idle
              : WeatherLookup.done,
          tagIds: note.tags.map((t) => t.id).toSet(),
          placeName: () => note.placeName,
          placeNameAlt: () => note.placeNameAlt,
          countryCode: () => note.countryCode,
          song: () => note.song,
        ),
      );
      if (photo != null && !await _thumbnails.exists(note.thumbnailFile)) {
        unawaited(_ensureThumbnail(note.id));
      }
      if (note.photoAspect == null && photo != null) {
        unawaited(_notes.setPhotoAspect(note.id, photo.aspectRatio));
      }
      return;
    }
    _emit(
      (s) => s.copyWith(
        loading: false,
        photo: () => photo,
        photoMissing: photo == null,
        photoAspect: () => photo?.aspectRatio,
        date: photo?.createdAt ?? s.date,
      ),
    );
    if (photo != null) unawaited(lookupWeatherFromPhoto());
  }

  // --- weather ---------------------------------------------------------------

  /// For a photo with GPS data: finds country and nearest town offline and
  /// looks up the weather of the capture time. The position itself is not
  /// stored; only the names are.
  Future<void> lookupWeatherFromPhoto() async {
    final photo = _current.photo;
    if (photo == null) return;
    _emit((s) => s.copyWith(weatherLookup: WeatherLookup.loading));
    final location = await _photos.locationOf(assetId);
    if (location == null) {
      // Not marked as checked: a later back-fill may still find something
      // (e.g. once access to photo locations is allowed).
      _emit(
        (s) => s.copyWith(
          weatherLookup: WeatherLookup.noLocation,
          photoHasLocation: false,
        ),
      );
      return;
    }
    _emit((s) => s.copyWith(photoHasLocation: true));
    await _placeFromPosition(location);
    await _lookup(location, photo.createdAt);
  }

  Future<void> _placeFromPosition(GeoPoint location) async {
    try {
      final match = (await _geo).resolve(location);
      _geoChecked = true;
      _emit(
        (s) => s.copyWith(
          placeName: () => s.placeName ?? match.placeName,
          placeNameAlt: () =>
              s.placeName == null ? match.placeNameAlt : s.placeNameAlt,
          countryCode: () => s.countryCode ?? match.countryCode,
        ),
      );
      _scheduleSave(metaDebounce, onlyIfExists: true);
    } on Exception catch (e) {
      debugPrint('Offline place lookup failed: $e');
    }
  }

  /// Sets the place the user chose by name and looks up the weather there.
  /// Only the name is stored (plus the country it lies in, found offline),
  /// never coordinates.
  Future<void> setPlace(Place place) async {
    _geoChecked = true;
    _emit(
      (s) => s.copyWith(
        placeName: () => place.name,
        placeNameAlt: () => null,
        weatherLookup: WeatherLookup.loading,
      ),
    );
    try {
      final geo = await _geo;
      final country = geo.countryAt(place.location) ?? _current.countryCode;
      final known = geo.lookupPlace(place.name);
      _emit(
        (s) => s.copyWith(
          countryCode: () => country,
          placeNameAlt: () => known != null && known.countryCode == country
              ? known.placeNameAlt
              : null,
        ),
      );
    } on Exception catch (e) {
      debugPrint('Offline country lookup failed: $e');
    }
    _scheduleSave(metaDebounce, onlyIfExists: true);
    final time = _current.photo?.createdAt ?? _current.date;
    await _lookup(place.location, time);
  }

  /// Sets or (with null) removes the country by hand.
  void setCountry(String? code) {
    _geoChecked = true;
    _emit((s) => s.copyWith(countryCode: () => code));
    _scheduleSave(metaDebounce, onlyIfExists: true);
  }

  Future<void> _lookup(GeoPoint location, DateTime time) async {
    final result = await _weather.weatherAt(location, time);
    if (result == null) {
      _emit((s) => s.copyWith(weatherLookup: WeatherLookup.failed));
      return;
    }
    _emit(
      (s) =>
          s.copyWith(weather: () => result, weatherLookup: WeatherLookup.done),
    );
    _scheduleSave(metaDebounce, onlyIfExists: true);
  }

  /// Removes the place and the weather that came with it. The country stays
  /// (it can be removed on its own).
  void clearPlace() {
    _geoChecked = true;
    _emit(
      (s) => s.copyWith(
        placeName: () => null,
        placeNameAlt: () => null,
        weather: () => null,
        weatherLookup: WeatherLookup.idle,
      ),
    );
    _scheduleSave(metaDebounce, onlyIfExists: true);
  }

  void setWeatherManually(WeatherSnapshot? weather) {
    _emit(
      (s) => s.copyWith(
        weather: () => weather,
        weatherLookup: WeatherLookup.manual,
      ),
    );
    _scheduleSave(metaDebounce, onlyIfExists: true);
  }

  // --- content -----------------------------------------------------------------

  void setBody(String text) {
    if (text == _body) return;
    _rememberBeforeClear(body: text, title: _title);
    _body = text;
    _scheduleSave(textDebounce);
  }

  /// The title is a single line; line breaks (e.g. pasted) become spaces.
  void setTitle(String text) {
    final clean = text.replaceAll(RegExp(r'\s*\n\s*'), ' ');
    if (clean == _title) return;
    _rememberBeforeClear(body: _body, title: clean);
    _title = clean;
    _scheduleSave(textDebounce);
  }

  /// Keeps the last text of an existing note when it is about to be
  /// emptied completely, so [undoClear] can bring it back.
  void _rememberBeforeClear({required String body, required String title}) {
    final emptyNow = body.trim().isEmpty && title.trim().isEmpty;
    final hadText = _body.trim().isNotEmpty || _title.trim().isNotEmpty;
    if (emptyNow && hadText && _current.exists) {
      _beforeClear = (body: _body, title: _title);
    } else if (!emptyNow) {
      _beforeClear = null;
    }
  }

  /// Brings back the text and title the note had before it was emptied.
  /// Returns them (for the text fields), or null if there is nothing.
  ({String body, String title})? undoClear() {
    final before = _beforeClear;
    if (before == null) return null;
    _beforeClear = null;
    _body = before.body;
    _title = before.title;
    _scheduleSave(metaDebounce);
    return before;
  }

  void setDate(DateTime date) {
    _emit((s) => s.copyWith(date: date));
    _scheduleSave(metaDebounce, onlyIfExists: true);
  }

  void toggleTag(int tagId) {
    final tags = {..._current.tagIds};
    if (!tags.remove(tagId)) tags.add(tagId);
    _emit((s) => s.copyWith(tagIds: tags));
    _scheduleSave(metaDebounce);
  }

  void addTag(int tagId) {
    if (_current.tagIds.contains(tagId)) return;
    _emit((s) => s.copyWith(tagIds: {...s.tagIds, tagId}));
    _scheduleSave(metaDebounce);
  }

  /// Links [candidate] to the note (replacing an earlier song). The cover is
  /// downloaded once and stored next to the thumbnails, so the note shows it
  /// offline; without a cover the song is linked all the same.
  Future<void> setSong(SongCandidate candidate) async {
    String? coverFile;
    final trackId = Song.trackIdOf(candidate.uri);
    final url = candidate.coverUrl;
    if (trackId != null && url != null) {
      try {
        final jpeg = await _music.downloadCover(url);
        if (jpeg != null) {
          coverFile = await _thumbnails.saveCover(trackId, jpeg);
        }
      } on Exception catch (e) {
        debugPrint('Song cover failed: $e');
      }
    }
    // Also after the editor closed meanwhile: the song is still saved.
    _emit(
      (s) => s.copyWith(song: () => candidate.toSong(coverFile: coverFile)),
    );
    _scheduleSave(metaDebounce);
  }

  /// Unlinks the song (its cover is removed later if no note uses it).
  void removeSong() {
    if (_current.song == null) return;
    _emit((s) => s.copyWith(song: () => null));
    _scheduleSave(metaDebounce);
  }

  /// Deletes the note (text, tags, weather, stored copy).
  Future<void> delete() async {
    _timer?.cancel();
    await _saveChain;
    _body = '';
    _title = '';
    _beforeClear = null;
    final file = await _notes.deleteByAsset(assetId);
    await _thumbnails.delete(file);
    await _discardUnusedImport();
    _emit(
      (s) => s.copyWith(
        noteId: () => null,
        thumbnailFile: () => null,
        tagIds: {},
        saveStatus: SaveStatus.clean,
      ),
    );
  }

  /// The editor closes: an existing note that was emptied is deleted.
  Future<void> _deleteIfBlank() async {
    if (!_current.exists || !_draft().isBlank) return;
    try {
      final file = await _notes.deleteByAsset(assetId);
      await _thumbnails.delete(file);
      _emit((st) => st.copyWith(noteId: () => null, thumbnailFile: () => null));
    } on Exception catch (e) {
      debugPrint('Deleting the empty note failed: $e');
    }
  }

  /// A photo picked from Google Photos & co. is only kept with a note.
  Future<void> _discardUnusedImport() async {
    if (!ImportedPhotoStore.isImportedId(assetId)) return;
    if (await _notes.findByAsset(assetId) == null) {
      await _imported.delete(assetId);
    }
  }

  // --- saving ------------------------------------------------------------------

  void _scheduleSave(Duration delay, {bool onlyIfExists = false}) {
    // Weather/date alone do not create a note; they are saved with the
    // first text or tag. If the note is being created right now, they are
    // saved right after.
    if (onlyIfExists && !_current.exists) {
      if (_saving) _saveAgain = true;
      return;
    }
    // Typing calls this on every keystroke: only a real change of the
    // status is published (each state change rebuilds the save indicator).
    if (_current.saveStatus != SaveStatus.pending) {
      _emit((s) => s.copyWith(saveStatus: SaveStatus.pending));
    }
    _timer?.cancel();
    _timer = Timer(delay, () => unawaited(flush()));
  }

  /// Saves pending changes now.
  Future<void> flush() {
    final hadTimer = _timer?.isActive ?? false;
    _timer?.cancel();
    _timer = null;
    if (!hadTimer && _current.saveStatus != SaveStatus.pending) {
      return _saveChain;
    }
    return _saveChain = _saveChain.then((_) => _save()).catchError((
      Object e,
      StackTrace st,
    ) {
      debugPrint('Saving note failed: $e\n$st');
      _saving = false;
      // Shown in the app bar; tried again shortly (a later change also
      // tries again at once).
      _emit((st) => st.copyWith(saveStatus: SaveStatus.failed));
      _timer?.cancel();
      _timer = Timer(retryDelay, () => unawaited(flush()));
    });
  }

  NoteDraft _draft() {
    final s = _current;
    return NoteDraft(
      assetId: assetId,
      body: _body,
      title: _title,
      photoAspect: s.photo?.aspectRatio,
      date: s.date,
      weather: s.weather,
      tagIds: s.tagIds,
      placeName: s.placeName,
      placeNameAlt: s.placeNameAlt,
      countryCode: s.countryCode,
      geoChecked: _geoChecked,
      // Place and country the editor never touched stay as stored: the
      // geo back-fill may have filled them in while the editor was open.
      keepStoredGeo: !_geoChecked && s.exists,
      song: s.song,
    );
  }

  Future<void> _save() async {
    final s = _current;
    final draft = _draft();
    _emit((st) => st.copyWith(saveStatus: SaveStatus.saving));

    if (draft.isBlank && !s.exists) {
      // Nothing to keep yet: no note is created.
      _emit((st) => st.copyWith(saveStatus: SaveStatus.clean));
      return;
    }

    _saving = true;
    final Note saved;
    try {
      // An emptied note is saved empty and only deleted when the editor
      // closes (see _deleteIfBlank), so its text can still be brought back.
      saved = await _notes.save(draft);
    } finally {
      _saving = false;
    }
    _emit(
      (st) => st.copyWith(noteId: () => saved.id, saveStatus: SaveStatus.saved),
    );
    if (_saveAgain) {
      _saveAgain = false;
      _scheduleSave(metaDebounce);
    }
    if (saved.thumbnailFile == null && s.photo != null) {
      await _ensureThumbnail(saved.id);
    }
  }

  Future<void> _ensureThumbnail(int noteId) async {
    try {
      final jpeg = await _photos.scaledJpeg(assetId);
      if (jpeg == null) return;
      final name = await _thumbnails.save(assetId, jpeg);
      await _notes.setThumbnailFile(noteId, name);
      _emit((st) => st.copyWith(thumbnailFile: () => name));
    } on Exception catch (e) {
      debugPrint('Thumbnail failed: $e');
    }
  }
}
