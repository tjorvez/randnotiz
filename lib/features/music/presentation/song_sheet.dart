import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/providers.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../../notes/domain/song.dart';
import '../../notes/presentation/note_editor_controller.dart';
import '../domain/music_service.dart';
import '../domain/song_candidate.dart';
import 'apple_music_badge.dart';
import 'music_providers.dart';

/// Bottom sheet to link a song to a note: search Apple Music, pick a song;
/// shows the current song (with Apple Music, other services and "remove")
/// at the top.
class SongSheet extends ConsumerStatefulWidget {
  const SongSheet({super.key, required this.assetId});

  final String assetId;

  /// Pause after typing before searching: Apple allows about 20 requests
  /// a minute.
  static const debounce = Duration(milliseconds: 600);

  /// Shorter queries are not sent while typing (only on "search").
  static const minLength = 2;

  static Future<void> show(BuildContext context, {required String assetId}) =>
      showModalBottomSheet<void>(
        context: context,
        isScrollControlled: true,
        showDragHandle: true,
        useSafeArea: true,
        builder: (_) => SongSheet(assetId: assetId),
      );

  @override
  ConsumerState<SongSheet> createState() => _SongSheetState();
}

class _SongSheetState extends ConsumerState<SongSheet> {
  final _query = TextEditingController();
  Timer? _debounce;

  /// Increases with every search; late answers of older ones are dropped.
  int _generation = 0;
  bool _searching = false;
  bool _linking = false;
  List<SongCandidate>? _results;
  Object? _error;

  /// The last query sent (the same one is not sent twice in a row).
  String? _sent;

  @override
  void dispose() {
    _debounce?.cancel();
    _query.dispose();
    super.dispose();
  }

  void _onChanged(String text) {
    _debounce?.cancel();
    if (text.trim().length < SongSheet.minLength) {
      _generation++;
      _sent = null;
      setState(() {
        _results = null;
        _error = null;
        _searching = false;
      });
      return;
    }
    _debounce = Timer(SongSheet.debounce, () => unawaited(_search(text)));
  }

  Future<void> _search(String text) async {
    final query = text.trim();
    if (query.isEmpty || (query == _sent && _error == null)) return;
    _sent = query;
    final generation = ++_generation;
    setState(() {
      _searching = true;
      _error = null;
    });
    try {
      final results = await ref.read(musicServiceProvider).search(query);
      if (!mounted || generation != _generation) return;
      setState(() {
        _results = results;
        _searching = false;
      });
    } on Object catch (e, st) {
      // Every failure ends the search with a message – never an endless
      // spinner without results.
      if (e is! MusicException) debugPrint('Song search failed: $e\n$st');
      if (!mounted || generation != _generation) return;
      setState(() {
        _error = e;
        _searching = false;
      });
    }
  }

  NoteEditorController get _controller =>
      ref.read(noteEditorProvider(widget.assetId).notifier);

  Future<void> _pick(SongCandidate candidate) async {
    setState(() => _linking = true);
    await _controller.setSong(candidate);
    if (mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final current = ref.watch(
      noteEditorProvider(widget.assetId).select((s) => s.song),
    );
    final results = _results;
    final bottom = MediaQuery.viewInsetsOf(context).bottom;

    return Padding(
      padding: EdgeInsets.only(bottom: bottom),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.sizeOf(context).height * 0.75,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
              child: Text(
                l10n.songSheetTitle,
                style: theme.textTheme.titleLarge,
              ),
            ),
            if (current != null)
              _CurrentSong(
                song: current,
                onRemove: () {
                  _controller.removeSong();
                  Navigator.of(context).pop();
                },
              ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
              child: TextField(
                controller: _query,
                autofocus: current == null,
                textInputAction: TextInputAction.search,
                decoration: InputDecoration(
                  hintText: l10n.songSearchHint,
                  prefixIcon: const Icon(Icons.search),
                  suffixIcon: _searching || _linking
                      ? const Padding(
                          padding: EdgeInsets.all(14),
                          child: SizedBox.square(
                            dimension: 18,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ),
                        )
                      : null,
                ),
                onChanged: _onChanged,
                onSubmitted: (text) {
                  _debounce?.cancel();
                  if (text.trim().isNotEmpty) unawaited(_search(text));
                },
              ),
            ),
            if (_error != null)
              Padding(
                padding: const EdgeInsets.all(20),
                child: Text(
                  musicErrorText(l10n, _error!, search: true),
                  style: TextStyle(color: scheme.error),
                ),
              )
            else if (results != null && results.isEmpty && !_searching)
              Padding(
                padding: const EdgeInsets.all(20),
                child: Text(
                  l10n.songNoResults,
                  style: TextStyle(color: scheme.onSurfaceVariant),
                ),
              )
            else if (results != null)
              Flexible(
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: results.length,
                  itemBuilder: (context, i) => _ResultTile(
                    candidate: results[i],
                    enabled: !_linking,
                    onTap: () => unawaited(_pick(results[i])),
                  ),
                ),
              ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 4, 20, 16),
              child: Text(
                l10n.songSearchSource,
                textAlign: TextAlign.end,
                style: theme.textTheme.labelSmall?.copyWith(
                  color: scheme.onSurfaceVariant,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// The linked song: cover, title, artist; Apple Music, other services,
/// remove.
class _CurrentSong extends ConsumerWidget {
  const _CurrentSong({required this.song, required this.onRemove});

  final Song song;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final scheme = Theme.of(context).colorScheme;
    final coverFile = song.coverFile;
    final px = (48 * MediaQuery.devicePixelRatioOf(context)).round();
    return Padding(
      padding: const EdgeInsets.fromLTRB(4, 0, 4, 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ListTile(
            leading: ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: SizedBox.square(
                dimension: 48,
                child: coverFile == null
                    ? ColoredBox(
                        color: scheme.surfaceContainerHighest,
                        child: Icon(
                          Icons.album_outlined,
                          color: scheme.onSurfaceVariant,
                        ),
                      )
                    : Image(
                        image: ResizeImage(
                          FileImage(
                            ref.read(thumbnailStoreProvider).fileFor(coverFile),
                          ),
                          width: px,
                        ),
                        fit: BoxFit.cover,
                        errorBuilder: (_, _, _) =>
                            ColoredBox(color: scheme.surfaceContainerHighest),
                      ),
              ),
            ),
            title: Text(
              song.title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            subtitle: Text(
              song.artist,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Wrap(
              spacing: 8,
              runSpacing: 4,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                AppleMusicBadge(songUri: song.uri, height: 36),
                TextButton.icon(
                  icon: const Icon(Icons.open_in_new),
                  label: Text(l10n.songOtherServices),
                  onPressed: () => openInOtherServices(context, ref, song.uri),
                ),
                TextButton.icon(
                  icon: const Icon(Icons.close),
                  label: Text(l10n.songRemove),
                  onPressed: onRemove,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ResultTile extends StatelessWidget {
  const _ResultTile({
    required this.candidate,
    required this.enabled,
    required this.onTap,
  });

  final SongCandidate candidate;
  final bool enabled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final thumb = candidate.thumbnailUrl;
    final px = (48 * MediaQuery.devicePixelRatioOf(context)).round();
    return ListTile(
      enabled: enabled,
      onTap: onTap,
      leading: ClipRRect(
        borderRadius: BorderRadius.circular(4),
        child: SizedBox.square(
          dimension: 48,
          child: thumb == null
              ? ColoredBox(
                  color: scheme.surfaceContainerHighest,
                  child: Icon(Icons.music_note, color: scheme.onSurfaceVariant),
                )
              : Image.network(
                  thumb,
                  fit: BoxFit.cover,
                  cacheWidth: px,
                  errorBuilder: (_, _, _) =>
                      ColoredBox(color: scheme.surfaceContainerHighest),
                ),
        ),
      ),
      title: Text(
        candidate.title,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      subtitle: Text(
        [candidate.artist, ?candidate.album].join(' · '),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }
}
