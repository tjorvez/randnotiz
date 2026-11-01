import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/providers.dart';
import '../domain/photo_repository.dart';

@immutable
class LibraryState {
  const LibraryState({
    this.access,
    this.photos = const [],
    this.loading = false,
    this.hasMore = true,
    this.askedOnce = false,
  });

  /// Null while the permission state is being checked.
  final PhotoAccess? access;
  final List<PhotoItem> photos;
  final bool loading;
  final bool hasMore;

  /// Whether the user has answered the system dialog in this session. Until
  /// then the "access denied" hint is not shown.
  final bool askedOnce;

  LibraryState copyWith({
    PhotoAccess? access,
    List<PhotoItem>? photos,
    bool? loading,
    bool? hasMore,
    bool? askedOnce,
  }) => LibraryState(
    access: access ?? this.access,
    photos: photos ?? this.photos,
    loading: loading ?? this.loading,
    hasMore: hasMore ?? this.hasMore,
    askedOnce: askedOnce ?? this.askedOnce,
  );
}

final libraryProvider = NotifierProvider<LibraryController, LibraryState>(
  LibraryController.new,
);

/// Pages through the gallery (newest first). Never asks for permission on its
/// own – the user triggers that from the friendly explanation screen.
class LibraryController extends Notifier<LibraryState> {
  static const pageSize = 120;
  int _nextPage = 0;
  int _generation = 0;
  StreamSubscription<void>? _changes;

  PhotoRepository get _repo => ref.read(photoRepositoryProvider);

  @override
  LibraryState build() {
    ref.onDispose(() {
      unawaited(_changes?.cancel());
      _debounce?.cancel();
    });
    unawaited(_init());
    return const LibraryState();
  }

  Future<void> _init() async {
    final access = await _repo.currentAccess();
    state = state.copyWith(access: access);
    if (access != PhotoAccess.denied) {
      _listenForChanges();
      await reload();
    }
  }

  Timer? _debounce;

  void _listenForChanges() {
    _changes ??= _repo.changes.listen((_) {
      _debounce?.cancel();
      _debounce = Timer(const Duration(seconds: 2), () => unawaited(reload()));
    });
  }

  Future<void> requestAccess() async {
    final access = await _repo.requestAccess();
    state = state.copyWith(access: access, askedOnce: true);
    if (access != PhotoAccess.denied) {
      _listenForChanges();
      await reload();
    }
  }

  Future<void> manageAccess() async {
    await _repo.manageAccess();
    await refreshAccess();
  }

  /// Re-checks the permission (e.g. after returning from system settings).
  Future<void> refreshAccess() async {
    final access = await _repo.currentAccess();
    final changed = access != state.access;
    state = state.copyWith(access: access);
    if (changed && access != PhotoAccess.denied) {
      _listenForChanges();
      await reload();
    }
  }

  /// Reloads as many pages as were loaded before and swaps them in at once,
  /// so the grid does not flicker or jump.
  Future<void> reload() async {
    final generation = ++_generation;
    final pages = _nextPage < 1 ? 1 : _nextPage;
    try {
      final photos = <PhotoItem>[];
      var hasMore = true;
      for (var page = 0; page < pages && hasMore; page++) {
        final result = await _repo.loadPage(page, pageSize: pageSize);
        photos.addAll(result);
        hasMore = result.length == pageSize;
      }
      if (generation != _generation) return;
      _nextPage = pages;
      state = state.copyWith(photos: photos, hasMore: hasMore, loading: false);
    } on Exception catch (e) {
      debugPrint('Reloading photos failed: $e');
    }
  }

  Future<void> loadMore() async {
    if (state.loading || !state.hasMore) return;
    final generation = _generation;
    state = state.copyWith(loading: true);
    try {
      final page = await _repo.loadPage(_nextPage, pageSize: pageSize);
      if (generation != _generation) return;
      _nextPage++;
      state = state.copyWith(
        photos: [...state.photos, ...page],
        hasMore: page.length == pageSize,
        loading: false,
      );
    } on Exception catch (e) {
      debugPrint('Loading photos failed: $e');
      if (generation == _generation) {
        state = state.copyWith(loading: false, hasMore: false);
      }
    }
  }
}
