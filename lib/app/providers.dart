import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:path/path.dart' as p;
import 'package:shared_preferences/shared_preferences.dart';

import '../core/database/app_database.dart';
import '../core/platform/secure_window.dart';
import '../features/backup/data/backup_hash_cache.dart';
import '../features/backup/data/backup_key_store.dart';
import '../features/backup/data/backup_restorer.dart';
import '../features/backup/data/backup_writer.dart';
import '../features/backup/data/drive_backup_service.dart';
import '../features/backup/data/google_account.dart';
import '../features/backup/data/remote/google_drive_store.dart';
import '../features/backup/domain/backup_service.dart';
import '../features/collections/data/drift_collection_repository.dart';
import '../features/collections/domain/collection.dart';
import '../features/dictation/data/speech_to_text_dictation_service.dart';
import '../features/dictation/domain/dictation_service.dart';
import '../features/geo/data/geo_database.dart';
import '../features/library/data/combined_photo_repository.dart';
import '../features/library/data/imported_photo_store.dart';
import '../features/library/data/photo_manager_repository.dart';
import '../features/library/domain/external_photo_picker.dart';
import '../features/library/domain/photo_repository.dart';
import '../features/lock/data/local_auth_authenticator.dart';
import '../features/lock/domain/authenticator.dart';
import '../features/music/data/spotify_music_service.dart';
import '../features/music/domain/music_service.dart';
import '../features/notes/data/drift_note_repository.dart';
import '../features/notes/data/thumbnail_store.dart';
import '../features/notes/domain/note.dart';
import '../features/tags/data/drift_tag_repository.dart';
import '../features/tags/domain/tag.dart';
import '../features/weather/data/open_meteo_place_search.dart';
import '../features/weather/data/open_meteo_weather_provider.dart';
import '../features/weather/domain/place_search.dart';
import '../features/weather/domain/weather.dart';

// Dependencies that need async setup are created in main() and injected via
// overrides. Every service is accessed through an interface so tests (and a
// later store release) can swap implementations.

final databaseProvider = Provider<AppDatabase>(
  (ref) => throw UnimplementedError('overridden in main()'),
);

final preferencesProvider = Provider<SharedPreferencesWithCache>(
  (ref) => throw UnimplementedError('overridden in main()'),
);

final thumbnailStoreProvider = Provider<ThumbnailStore>(
  (ref) => throw UnimplementedError('overridden in main()'),
);

final noteRepositoryProvider = Provider<NoteRepository>(
  (ref) => DriftNoteRepository(ref.watch(databaseProvider)),
);

final tagRepositoryProvider = Provider<TagRepository>(
  (ref) => DriftTagRepository(ref.watch(databaseProvider)),
);

final collectionRepositoryProvider = Provider<CollectionRepository>(
  (ref) => DriftCollectionRepository(ref.watch(databaseProvider)),
);

/// Copies of photos picked from outside the gallery (Google Photos & co.).
final importedPhotoStoreProvider = Provider<ImportedPhotoStore>(
  (ref) => throw UnimplementedError('overridden in main()'),
);

final photoRepositoryProvider = Provider<PhotoRepository>(
  (ref) => CombinedPhotoRepository(
    PhotoManagerRepository(),
    ref.watch(importedPhotoStoreProvider),
  ),
);

final externalPhotoPickerProvider = Provider<ExternalPhotoPicker>(
  (ref) => const SystemPhotoPicker(),
);

final httpClientProvider = Provider<http.Client>((ref) {
  final client = http.Client();
  ref.onDispose(client.close);
  return client;
});

final weatherProviderProvider = Provider<WeatherProvider>(
  (ref) => OpenMeteoWeatherProvider(ref.watch(httpClientProvider)),
);

final placeSearchProvider = Provider<PlaceSearch>(
  (ref) => OpenMeteoPlaceSearch(ref.watch(httpClientProvider)),
);

/// Offline countries and towns (Natural Earth + GeoNames), loaded once in
/// the background.
final geoDatabaseProvider = FutureProvider<GeoDatabase>(
  (ref) => GeoDatabase.load(),
);

/// Songs from Spotify (optional; inert without spotify.local.json).
final musicServiceProvider = Provider<MusicService>(
  (ref) => SpotifyMusicService(ref.watch(httpClientProvider)),
);

final dictationServiceProvider = Provider<DictationService>(
  (ref) => SpeechToTextDictationService(),
);

final authenticatorProvider = Provider<Authenticator>(
  (ref) => LocalAuthAuthenticator(),
);

final secureWindowProvider = Provider<SecureWindow>(
  (ref) => const SecureWindow(),
);

/// End-to-end encrypted backup in the user's Google Drive (optional; off
/// without google.local.json, see README.md).
final backupServiceProvider = Provider<BackupService>((ref) {
  final db = ref.watch(databaseProvider);
  final thumbnails = ref.watch(thumbnailStoreProvider);
  final imported = ref.watch(importedPhotoStoreProvider);
  final photos = ref.watch(photoRepositoryProvider);
  final account = GoogleSignInAccountSource();
  final remote = GoogleDriveStore(ref.watch(httpClientProvider), account);
  return DriveBackupService(
    account: account,
    remote: remote,
    keys: SecureBackupKeyStore(),
    prefs: ref.watch(preferencesProvider),
    writer: BackupWriter(
      db: db,
      remote: remote,
      thumbnails: thumbnails,
      imported: imported,
      cache: BackupHashCache(
        File(p.join(thumbnails.directory.parent.path, 'backup_cache.json')),
      ),
      photoInfo: (id) async {
        final item = await photos.findById(id);
        return item == null
            ? null
            : (takenAt: item.createdAt, width: item.width, height: item.height);
      },
    ),
    restorer: BackupRestorer(
      db: db,
      remote: remote,
      thumbnails: thumbnails,
      imported: imported,
      galleryPhoto: (id) async =>
          ImportedPhotoStore.isImportedId(id) ? null : photos.findById(id),
    ),
  );
});

/// "Now", overridable in tests.
final clockProvider = Provider<DateTime Function()>((ref) => DateTime.now);

// --- shared streams ----------------------------------------------------------

final tagsProvider = StreamProvider<List<Tag>>(
  (ref) => ref.watch(tagRepositoryProvider).watchTags(),
);

final notedAssetIdsProvider = StreamProvider<Set<String>>(
  (ref) => ref.watch(noteRepositoryProvider).watchNotedAssetIds(),
);

/// All notes as lightweight summaries (memories, widget).
final allNotesProvider = StreamProvider<List<NoteSummary>>(
  (ref) => ref.watch(noteRepositoryProvider).watchJournal(const JournalQuery()),
);

final collectionsProvider = StreamProvider<List<Collection>>(
  (ref) => ref.watch(collectionRepositoryProvider).watchCollections(),
);
