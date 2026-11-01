import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/providers.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../../notes/presentation/note_editor_controller.dart';
import '../domain/music_service.dart';
import '../domain/song.dart';
import 'music_providers.dart';
import 'song_sheet.dart';
import 'vinyl_record.dart';

/// The record next to the polaroid of a note with a song (songs are added
/// through the note's ⋮ menu). Tapping plays or pauses the song in Spotify
/// (or opens it there if playback cannot be controlled); the record turns
/// while it plays. A long press changes or removes the song.
class SongRecord extends ConsumerStatefulWidget {
  const SongRecord({super.key, required this.assetId, required this.size});

  final String assetId;
  final double size;

  @override
  ConsumerState<SongRecord> createState() => _SongRecordState();
}

class _SongRecordState extends ConsumerState<SongRecord> {
  /// Started here, not yet confirmed by Spotify: already turns.
  String? _starting;

  Future<void> _toggle(Song song, MusicStatus status) async {
    final music = ref.read(musicServiceProvider);
    final playback = ref.read(playbackProvider).value;
    try {
      if (status.canControl && playback?.isPlaying(song.uri) == true) {
        await music.pause();
      } else if (status.canControl &&
          playback?.uri == song.uri &&
          playback?.paused == true) {
        setState(() => _starting = song.uri);
        await music.resume();
      } else {
        if (status.canControl) setState(() => _starting = song.uri);
        await music.play(song.uri);
      }
    } on MusicException catch (e) {
      if (mounted) showMusicError(context, e);
      if (mounted) setState(() => _starting = null);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final song = ref.watch(
      noteEditorProvider(widget.assetId).select((s) => s.song),
    );
    final status = ref.watch(musicStatusProvider).value ?? MusicStatus.off;
    if (song == null) return const SizedBox.shrink();

    final playback = ref.watch(playbackProvider).value;
    ref.listen(playbackProvider, (_, next) {
      // Spotify reported back: its state counts from now on.
      if (_starting != null && next.value?.uri == _starting) {
        setState(() => _starting = null);
      }
    });
    final spinning =
        status.canControl &&
        (playback?.isPlaying(song.uri) == true || _starting == song.uri);

    final coverFile = song.coverFile;
    final cover = coverFile == null
        ? null
        : ResizeImage(
            FileImage(ref.read(thumbnailStoreProvider).fileFor(coverFile)),
            width: (widget.size * MediaQuery.devicePixelRatioOf(context))
                .round(),
          );

    final label = l10n.songRecordLabel(song.title, song.artist);
    final hint = !status.canControl
        ? l10n.songOpenInSpotify
        : spinning
        ? l10n.songPause
        : l10n.songPlay;

    void openSheet() =>
        unawaited(SongSheet.show(context, assetId: widget.assetId));

    return Semantics(
      button: true,
      label: label,
      hint: hint,
      excludeSemantics: true,
      child: Tooltip(
        message: l10n.songOf(song.title, song.artist),
        // Only the round record takes taps: it lies on the polaroid, whose
        // corners around it stay usable.
        child: ClipOval(
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () => unawaited(_toggle(song, status)),
            onLongPress: status.usable ? openSheet : null,
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
