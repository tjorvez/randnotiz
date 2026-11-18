import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/providers.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../../notes/domain/song.dart';
import '../../notes/presentation/note_editor_controller.dart';
import '../domain/music_service.dart';
import '../domain/preview_player.dart';
import 'music_providers.dart';
import 'song_sheet.dart';
import 'vinyl_record.dart';

/// The record next to the polaroid of a note with a song (songs are added
/// through the note's ⋮ menu). Tapping plays or pauses Apple's 30-second
/// preview; the record turns while it plays. A long press changes or
/// removes the song. Leaving the note stops the preview.
class SongRecord extends ConsumerStatefulWidget {
  const SongRecord({super.key, required this.assetId, required this.size});

  final String assetId;
  final double size;

  @override
  ConsumerState<SongRecord> createState() => _SongRecordState();
}

class _SongRecordState extends ConsumerState<SongRecord> {
  late final PreviewPlayer _player = ref.read(previewPlayerProvider);

  /// The song this record showed last (its preview stops on dispose).
  String? _uri;

  @override
  void dispose() {
    final uri = _uri;
    if (uri != null && _player.state.uri == uri) unawaited(_player.stop());
    super.dispose();
  }

  Future<void> _toggle(Song song) async {
    final state = _player.state;
    if (state.uri == song.uri) {
      switch (state.status) {
        case PreviewStatus.playing || PreviewStatus.loading:
          return _player.pause();
        case PreviewStatus.paused:
          return _player.resume();
        case PreviewStatus.idle:
          break;
      }
    }
    try {
      final links = await ref.read(musicServiceProvider).links(song.uri);
      final preview = links.previewUrl;
      if (preview == null) {
        throw const MusicException(MusicException.noPreview);
      }
      if (!mounted) return;
      await _player.play(song.uri, preview);
    } on MusicException catch (e) {
      if (mounted) showMusicError(context, e);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final song = ref.watch(
      noteEditorProvider(widget.assetId).select((s) => s.song),
    );
    final preview = ref.watch(previewStateProvider).value ?? _player.state;
    if (song == null) return const SizedBox.shrink();
    if (_uri != null && _uri != song.uri && _player.state.uri == _uri) {
      // The song was changed while its preview played.
      unawaited(_player.stop());
    }
    _uri = song.uri;
    final spinning = preview.isActive(song.uri);

    final coverFile = song.coverFile;
    final cover = coverFile == null
        ? null
        : ResizeImage(
            FileImage(ref.read(thumbnailStoreProvider).fileFor(coverFile)),
            width: (widget.size * MediaQuery.devicePixelRatioOf(context))
                .round(),
          );

    return Semantics(
      button: true,
      label: l10n.songRecordLabel(song.title, song.artist),
      hint: spinning ? l10n.songPause : l10n.songPlay,
      onLongPressHint: l10n.songChange,
      excludeSemantics: true,
      child: Tooltip(
        message: l10n.songOf(song.title, song.artist),
        // Only the round record takes taps: it lies on the polaroid, whose
        // corners around it stay usable.
        child: ClipOval(
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () => unawaited(_toggle(song)),
            onLongPress: () =>
                unawaited(SongSheet.show(context, assetId: widget.assetId)),
            child: VinylRecord(
              size: widget.size,
              cover: cover,
              spinning: spinning,
            ),
          ),
        ),
      ),
    );
  }
}
