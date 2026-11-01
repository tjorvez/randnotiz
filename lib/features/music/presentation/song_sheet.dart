import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/providers.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../../notes/presentation/note_editor_controller.dart';
import '../domain/music_service.dart';
import '../domain/song.dart';
import 'music_providers.dart';

/// Bottom sheet to link a song to a note: search Spotify, pick a track;
/// shows the current song with "remove" at the top.
class SongSheet extends ConsumerStatefulWidget {
  const SongSheet({super.key, required this.assetId});

  final String assetId;

  /// Pause after typing before searching.
  static const debounce = Duration(milliseconds: 350);

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

  @override
  void dispose() {
    _debounce?.cancel();
    _query.dispose();
    super.dispose();
  }

  void _onChanged(String text) {
    _debounce?.cancel();
    if (text.trim().isEmpty) {
      _generation++;
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
    final generation = ++_generation;
    setState(() {
      _searching = true;
      _error = null;
    });
    try {
      final results = await ref.read(musicServiceProvider).search(text);
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
    final usable =
        (ref.watch(musicStatusProvider).value ?? MusicStatus.off).usable;
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
              ListTile(
                leading: const Icon(Icons.album_outlined),
                title: Text(current.title),
                subtitle: Text(current.artist),
                trailing: TextButton.icon(
                  icon: const Icon(Icons.close),
                  label: Text(l10n.songRemove),
                  onPressed: () {
                    _controller.removeSong();
                    Navigator.of(context).pop();
                  },
                ),
              ),
            if (usable) ...[
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
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        musicErrorText(l10n, _error!, search: true),
                        style: TextStyle(color: scheme.error),
                      ),
                      const SizedBox(height: 6),
                      SelectableText(
                        musicErrorDetail(_error!),
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: scheme.onSurfaceVariant,
                        ),
                      ),
                    ],
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
            ] else
              const SizedBox(height: 16),
          ],
        ),
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
