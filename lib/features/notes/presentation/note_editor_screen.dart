import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/providers.dart';
import '../../../core/format/formatters.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/paper.dart';
import '../../../core/widgets/polaroid.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../../collections/presentation/collection_neighbours.dart';
import '../../collections/presentation/collection_picker_sheet.dart';
import '../../collections/presentation/collection_providers.dart';
import '../../dictation/presentation/dictation_controller.dart';
import '../../dictation/presentation/mic_button.dart';
import '../../music/domain/music_service.dart';
import '../../music/presentation/music_providers.dart';
import '../../music/presentation/record_on_polaroid.dart';
import '../../music/presentation/song_sheet.dart';
import '../../tags/presentation/tag_picker_sheet.dart';
import '../../weather/presentation/weather_ui.dart';
import 'note_editor_controller.dart';
import 'note_photo.dart';
import 'place_sheet.dart';
import 'rim_title_field.dart';

class NoteEditorScreen extends ConsumerStatefulWidget {
  const NoteEditorScreen({
    super.key,
    required this.assetId,
    this.collectionId,
    this.heroTag,
  });

  final String assetId;

  /// Tag of the polaroid the note was opened from (it flies in).
  final Object? heroTag;

  /// The collection the note was opened from (its neighbours come first).
  final int? collectionId;

  @override
  ConsumerState<NoteEditorScreen> createState() => _NoteEditorScreenState();
}

class _NoteEditorScreenState extends ConsumerState<NoteEditorScreen>
    with WidgetsBindingObserver {
  final _text = TextEditingController();
  final _focus = FocusNode();
  final _title = TextEditingController();
  final _titleFocus = FocusNode();
  late final DictationController _dictation;
  bool _textLoaded = false;

  NoteEditorController get _controller =>
      ref.read(noteEditorProvider(widget.assetId).notifier);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _dictation = DictationController(
      service: ref.read(dictationServiceProvider),
      textController: _text,
      onTextChanged: () => _controller.setBody(_text.text),
    );
    _text.addListener(() {
      if (!_textLoaded) return;
      _controller.setBody(_text.text);
      _offerUndoClear();
    });
    _title.addListener(() {
      if (!_textLoaded) return;
      _controller.setTitle(_title.text);
      _offerUndoClear();
    });
  }

  /// The SnackBar offering to bring back an emptied note, while shown.
  ScaffoldFeatureController<SnackBar, SnackBarClosedReason>? _clearNotice;

  /// Text and title were emptied completely (e.g. by accident): offers to
  /// bring them back. The note is only deleted when the editor closes.
  void _offerUndoClear() {
    final cleared = _controller.clearedContent != null;
    if (!cleared) {
      _clearNotice?.close();
      _clearNotice = null;
      return;
    }
    if (_clearNotice != null) return;
    final l10n = AppLocalizations.of(context);
    final messenger = ScaffoldMessenger.of(context)..hideCurrentSnackBar();
    _clearNotice = messenger.showSnackBar(
      SnackBar(
        content: Text(l10n.editorCleared),
        duration: const Duration(seconds: 8),
        action: SnackBarAction(
          label: l10n.editorUndoClear,
          onPressed: () {
            final before = _controller.undoClear();
            if (before == null) return;
            _textLoaded = false;
            _text.text = before.body;
            _text.selection = TextSelection.collapsed(
              offset: before.body.length,
            );
            _title.text = before.title;
            _textLoaded = true;
          },
        ),
      ),
    );
    final notice = _clearNotice!;
    unawaited(
      notice.closed.then((_) {
        if (identical(_clearNotice, notice)) _clearNotice = null;
      }),
    );
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.hidden) {
      // Call coming in / app in background: end dictation, keep the text,
      // and save immediately.
      unawaited(_dictation.interrupt());
      unawaited(_controller.flush());
    }
  }

  @override
  void dispose() {
    // Undoing is no longer possible once the editor is closed.
    _clearNotice?.close();
    WidgetsBinding.instance.removeObserver(this);
    _dictation.dispose();
    _text.dispose();
    _focus.dispose();
    _title.dispose();
    _titleFocus.dispose();
    super.dispose();
  }

  Future<void> _pickDate(NoteEditorState state) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: state.date,
      firstDate: DateTime(1900),
      lastDate: DateTime.now().add(const Duration(days: 1)),
    );
    if (picked == null) return;
    final d = state.date;
    _controller.setDate(
      DateTime(picked.year, picked.month, picked.day, d.hour, d.minute),
    );
  }

  Future<void> _confirmDelete() async {
    final l10n = AppLocalizations.of(context);
    final ok = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.editorDeleteConfirmTitle),
        content: Text(l10n.editorDeleteConfirmBody),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(l10n.cancel),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
              foregroundColor: Theme.of(context).colorScheme.onError,
            ),
            onPressed: () => Navigator.pop(context, true),
            child: Text(l10n.delete),
          ),
        ],
      ),
    );
    if (ok != true) return;
    _textLoaded = false;
    _clearNotice?.close();
    await _controller.delete();
    _text.clear();
    _title.clear();
    _textLoaded = true;
    if (mounted) Navigator.of(context).maybePop();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    // Not the save status – see NoteEditorContent and _SaveIndicator.
    final state = ref
        .watch(noteEditorProvider(widget.assetId).select(NoteEditorContent.new))
        .state;

    if (!state.loading && !_textLoaded) {
      _text.text = state.initialBody;
      _text.selection = TextSelection.collapsed(offset: _text.text.length);
      _title.text = state.initialTitle;
      _textLoaded = true;
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(state.exists ? l10n.editorTitleEdit : l10n.editorTitleNew),
        actions: [
          _SaveIndicator(assetId: widget.assetId),
          _NoteMenu(
            assetId: widget.assetId,
            exists: state.exists,
            hasSong: state.song != null,
            onDelete: _confirmDelete,
          ),
        ],
      ),
      floatingActionButton: state.loading
          ? null
          : MicButton(
              controller: _dictation,
              service: ref.read(dictationServiceProvider),
            ),
      body: PaperBackground(
        // Notes are loaded before the page opens (see openNote), so this is
        // only a fallback for slow loads – then the content fades in.
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 180),
          child: state.loading
              ? const SizedBox.expand()
              // Not a LayoutBuilder: while the keyboard slides in, the
              // body's height changes every frame, and a LayoutBuilder
              // would rebuild both panels each time. The width is enough.
              : Builder(
                  builder: (context) {
                    final wide = MediaQuery.sizeOf(context).width >= 720;
                    final photo = _PhotoPanel(
                      assetId: widget.assetId,
                      heroTag: widget.heroTag,
                      state: state,
                      wide: wide,
                      title: _title,
                      titleFocus: _titleFocus,
                    );
                    final note = _NotePanel(
                      assetId: widget.assetId,
                      collectionId: widget.collectionId,
                      state: state,
                      text: _text,
                      focus: _focus,
                      onPickDate: () => _pickDate(state),
                    );
                    if (wide) {
                      return Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            flex: 5,
                            child: SingleChildScrollView(child: photo),
                          ),
                          Expanded(
                            flex: 6,
                            child: SingleChildScrollView(child: note),
                          ),
                        ],
                      );
                    }
                    return GestureDetector(
                      behavior: HitTestBehavior.translucent,
                      onTap: () => _focus.requestFocus(),
                      child: ListView(
                        padding: const EdgeInsets.only(bottom: 120),
                        keyboardDismissBehavior:
                            ScrollViewKeyboardDismissBehavior.manual,
                        children: [photo, note],
                      ),
                    );
                  },
                ),
        ),
      ),
    );
  }
}

class _SaveIndicator extends ConsumerWidget {
  const _SaveIndicator({required this.assetId});

  final String assetId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final status = ref.watch(
      noteEditorProvider(assetId).select((s) => s.saveStatus),
    );
    final l10n = AppLocalizations.of(context);
    final scheme = Theme.of(context).colorScheme;
    final (icon, text) = switch (status) {
      SaveStatus.clean => (null, null),
      SaveStatus.pending ||
      SaveStatus.saving => (Icons.more_horiz, l10n.editorSaving),
      SaveStatus.saved => (Icons.check, l10n.editorSaved),
      SaveStatus.failed => (Icons.error_outline, l10n.editorSaveFailed),
    };
    if (icon == null) return const SizedBox.shrink();
    final color = status == SaveStatus.failed
        ? scheme.error
        : scheme.onSurfaceVariant;
    return Semantics(
      liveRegion: true,
      label: text,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8),
        child: Row(
          children: [
            Icon(icon, size: 18, color: color),
            const SizedBox(width: 4),
            Text(text!, style: TextStyle(fontSize: 13, color: color)),
          ],
        ),
      ),
    );
  }
}

class _PhotoPanel extends StatelessWidget {
  const _PhotoPanel({
    required this.assetId,
    required this.heroTag,
    required this.state,
    required this.wide,
    required this.title,
    required this.titleFocus,
  });

  final String assetId;
  final Object? heroTag;
  final NoteEditorState state;
  final bool wide;
  final TextEditingController title;
  final FocusNode titleFocus;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final size = MediaQuery.sizeOf(context);
    final aspect = PolaroidGeometry.photoAspectOrSquare(state.photoAspect);
    final cardAspect = PolaroidGeometry.cardAspect(aspect);
    final maxHeight = wide ? size.height * 0.72 : size.height * 0.42;
    // With a song, the record lies on the polaroid's corner and sticks out
    // on the right: the polaroid leaves room for that part.
    final hasSong = state.song != null;
    final maxWidth = wide
        ? size.width * 0.4
        : hasSong
        ? (size.width - 48) /
              (1 + RecordOnPolaroid.sizeFactor * RecordOnPolaroid.outside)
        : size.width - 84;
    final width = maxWidth / cardAspect > maxHeight
        ? maxHeight * cardAspect
        : maxWidth;
    final tilt = Polaroid.tiltFor(assetId);

    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 22, 24, 8),
      child: Column(
        children: [
          Center(
            child: RecordOnPolaroid(
              assetId: assetId,
              polaroidWidth: width,
              child: SizedBox(
                width: width,
                child: Polaroid(
                  tilt: tilt,
                  photoAspect: aspect,
                  title: title.text,
                  rim: RimTitleField(controller: title, focusNode: titleFocus),
                  hero: heroTag == null ? null : PolaroidHero(tag: heroTag!),
                  image: NotePhoto(
                    assetId: assetId,
                    photo: state.photo,
                    thumbnailFile: state.thumbnailFile,
                  ),
                ),
              ),
            ),
          ),
          if (state.photoMissing)
            Padding(
              padding: const EdgeInsets.only(top: 16),
              child: Text(
                l10n.editorPhotoMissing,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

/// The ⋮ menu of a note: add/change/remove its song, delete the note.
class _NoteMenu extends ConsumerWidget {
  const _NoteMenu({
    required this.assetId,
    required this.exists,
    required this.hasSong,
    required this.onDelete,
  });

  final String assetId;
  final bool exists;
  final bool hasSong;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final music = ref.watch(musicStatusProvider).value ?? MusicStatus.off;
    final canPickSong = music.usable;
    if (!exists && !canPickSong) return const SizedBox.shrink();

    PopupMenuItem<String> item(String value, IconData icon, String text) =>
        PopupMenuItem(
          value: value,
          child: ListTile(
            leading: Icon(icon),
            title: Text(text),
            contentPadding: EdgeInsets.zero,
          ),
        );

    return PopupMenuButton<String>(
      onSelected: (value) {
        switch (value) {
          case 'song':
            unawaited(SongSheet.show(context, assetId: assetId));
          case 'removeSong':
            ref.read(noteEditorProvider(assetId).notifier).removeSong();
          case 'delete':
            onDelete();
        }
      },
      itemBuilder: (_) => [
        if (canPickSong)
          item(
            'song',
            Icons.album_outlined,
            hasSong ? l10n.songChange : l10n.songAdd,
          ),
        if (hasSong)
          item('removeSong', Icons.music_off_outlined, l10n.songRemove),
        if (exists) item('delete', Icons.delete_outline, l10n.editorDelete),
      ],
    );
  }
}

class _NotePanel extends ConsumerWidget {
  const _NotePanel({
    required this.assetId,
    required this.collectionId,
    required this.state,
    required this.text,
    required this.focus,
    required this.onPickDate,
  });

  final String assetId;
  final int? collectionId;
  final NoteEditorState state;
  final TextEditingController text;
  final FocusNode focus;
  final VoidCallback onPickDate;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final tags = ref.watch(tagsProvider).value ?? const [];
    final selectedTags = tags
        .where((t) => state.tagIds.contains(t.id))
        .toList();
    final noteStyle = AppTheme.noteText(context);
    // A forced strut gives every text line exactly the same height, so the
    // ruled lines below stay aligned with the handwriting.
    final strut = StrutStyle(
      fontFamily: noteStyle.fontFamily,
      fontSize: noteStyle.fontSize,
      height: noteStyle.height,
      forceStrutHeight: true,
    );
    final lineHeight =
        MediaQuery.textScalerOf(context).scale(noteStyle.fontSize!) *
        noteStyle.height!;

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // --- one quiet line: date · place · weather · moods ---
          Wrap(
            spacing: 2,
            runSpacing: 0,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              _MetaButton(
                icon: Icons.event_outlined,
                label: Fmt.mediumDateWithWeekday(state.date),
                tooltip: l10n.editorDateTooltip,
                onTap: onPickDate,
              ),
              _PlaceButton(assetId: assetId, state: state),
              if (state.weatherLookup == WeatherLookup.loading)
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 8),
                  child: SizedBox.square(
                    dimension: 14,
                    child: CircularProgressIndicator(strokeWidth: 1.6),
                  ),
                )
              else if (state.weather != null)
                _MetaButton(
                  icon: weatherIcon(state.weather!.kind),
                  label: state.weather!.temperatureC != null
                      ? l10n.weatherTemperature(
                          Fmt.temperature(state.weather!.temperatureC!),
                        )
                      : l10n.weatherKind(state.weather!.kind.name),
                  tooltip: weatherLabel(l10n, state.weather!),
                  onTap: () => PlaceSheet.show(context, assetId),
                ),
              _MetaButton(
                icon: selectedTags.isEmpty ? Icons.mood_outlined : null,
                label: selectedTags.isEmpty
                    ? l10n.editorMetaMood
                    : selectedTags.map((t) => t.emoji).join(' '),
                tooltip: selectedTags.isEmpty
                    ? l10n.tagsAdd
                    : selectedTags.map((t) => t.label).join(', '),
                muted: selectedTags.isEmpty,
                large: selectedTags.isNotEmpty,
                onTap: () => TagPickerSheet.show(context, assetId),
              ),
              if (state.noteId != null)
                _CollectionsButton(noteId: state.noteId!),
            ],
          ),
          const SizedBox(height: 6),
          Divider(color: theme.colorScheme.outlineVariant, height: 1),
          // --- the note itself, on ruled paper ---
          RuledLines(
            lineHeight: lineHeight,
            topOffset: 12,
            child: TextField(
              controller: text,
              focusNode: focus,
              maxLines: null,
              minLines: 10,
              keyboardType: TextInputType.multiline,
              textCapitalization: TextCapitalization.sentences,
              style: noteStyle,
              strutStyle: strut,
              cursorColor: theme.colorScheme.secondary,
              decoration: InputDecoration(
                border: InputBorder.none,
                hintText: l10n.editorHint,
                hintStyle: noteStyle.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
                contentPadding: const EdgeInsets.only(top: 12, bottom: 12),
              ),
            ),
          ),
          if (state.noteId != null)
            CollectionNeighboursSection(
              noteId: state.noteId!,
              preferredCollectionId: collectionId,
            ),
        ],
      ),
    );
  }
}

/// Meta-line item: flag and place (or country), or an invitation.
class _PlaceButton extends ConsumerWidget {
  const _PlaceButton({required this.assetId, required this.state});

  final String assetId;
  final NoteEditorState state;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final country = ref
        .watch(geoDatabaseProvider)
        .value
        ?.country(state.countryCode);
    final name = state.placeName ?? country?.nameDe;
    return _MetaButton(
      icon: name != null ? null : Icons.place_outlined,
      label: name == null ? l10n.placeAdd : [?country?.flag, name].join(' '),
      tooltip: name == null
          ? null
          : [?state.placeName, ?country?.nameDe].join(', '),
      muted: name == null,
      onTap: () => PlaceSheet.show(context, assetId),
    );
  }
}

/// Meta-line item: the collections of this note (or an invitation).
class _CollectionsButton extends ConsumerWidget {
  const _CollectionsButton({required this.noteId});

  final int noteId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final ids = ref.watch(noteCollectionIdsProvider(noteId)).value ?? const {};
    final names = [
      for (final c in ref.watch(collectionsProvider).value ?? const [])
        if (ids.contains(c.id)) c.name,
    ];
    return _MetaButton(
      icon: names.isEmpty
          ? Icons.collections_bookmark_outlined
          : Icons.collections_bookmark,
      label: names.isEmpty ? l10n.collectionAddShort : names.join(', '),
      tooltip: l10n.collectionPickerTitle,
      muted: names.isEmpty,
      onTap: () => CollectionPickerSheet.show(context, noteId),
    );
  }
}

/// A small, borderless, tappable item of the note's meta line.
class _MetaButton extends StatelessWidget {
  const _MetaButton({
    required this.label,
    required this.onTap,
    this.icon,
    this.tooltip,
    this.muted = false,
    this.large = false,
  });

  final IconData? icon;
  final String label;
  final String? tooltip;
  final VoidCallback onTap;
  final bool muted;

  /// Emoji labels are shown a bit larger.
  final bool large;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final color = muted ? scheme.outline : scheme.onSurfaceVariant;
    final child = InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 6),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(icon, size: 16, color: color),
              const SizedBox(width: 4),
            ],
            Text(
              label,
              style: TextStyle(fontSize: large ? 17 : 13.5, color: color),
            ),
          ],
        ),
      ),
    );
    return tooltip == null ? child : Tooltip(message: tooltip!, child: child);
  }
}
