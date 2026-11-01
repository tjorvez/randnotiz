import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/home_shell.dart';
import '../../../app/providers.dart';
import '../../../core/format/formatters.dart';
import '../../../core/search/fts_query.dart';
import '../../../core/search/text_normalize.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/common.dart';
import '../../../core/widgets/polaroid.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../../geo/presentation/geo_backfill_banner.dart';
import '../../notes/domain/note.dart';
import '../../notes/presentation/note_photo.dart';
import '../../notes/presentation/open_note.dart';
import '../../weather/presentation/weather_ui.dart';
import '../data/recent_searches.dart';
import '../domain/search_suggestions.dart';
import 'search_suggestion_list.dart';

/// Current search text and filters (Stimmungen, place, country) of the
/// journal.
final journalQueryProvider =
    NotifierProvider<JournalQueryController, JournalQuery>(
      JournalQueryController.new,
    );

class JournalQueryController extends Notifier<JournalQuery> {
  @override
  JournalQuery build() => const JournalQuery();

  void setText(String text) => state = state.copyWith(text: text);

  void toggleTag(int id) {
    final tags = {...state.tagIds};
    if (!tags.remove(id)) tags.add(id);
    state = state.copyWith(tagIds: tags);
  }

  void setPlace(String? name) => state = state.copyWith(placeName: () => name);

  void setCountry(String? code) =>
      state = state.copyWith(countryCode: () => code);

  void clear() => state = const JournalQuery();
}

final journalEntriesProvider = StreamProvider.autoDispose<List<NoteSummary>>((
  ref,
) {
  final query = ref.watch(journalQueryProvider);
  return ref.watch(noteRepositoryProvider).watchJournal(query);
});

final recentSearchesStoreProvider = Provider<RecentSearches>(
  (ref) => RecentSearches(ref.watch(preferencesProvider)),
);

/// Earlier searches, newest first (stored on the device only).
final recentSearchesProvider =
    NotifierProvider<RecentSearchesController, List<String>>(
      RecentSearchesController.new,
    );

class RecentSearchesController extends Notifier<List<String>> {
  RecentSearches get _store => ref.read(recentSearchesStoreProvider);

  @override
  List<String> build() => ref.watch(recentSearchesStoreProvider).load();

  Future<void> add(String text) async => state = await _store.add(text);
  Future<void> remove(String text) async => state = await _store.remove(text);

  Future<void> clear() async {
    await _store.clear();
    state = const [];
  }
}

final _placeUsesProvider = StreamProvider.autoDispose<List<PlaceUse>>(
  (ref) => ref.watch(noteRepositoryProvider).watchPlaces(),
);

final countryCountsProvider = StreamProvider<Map<String, int>>(
  (ref) => ref.watch(noteRepositoryProvider).watchCountryCounts(),
);

/// Suggestions for the text being typed (see [buildSuggestions]).
final searchSuggestionsProvider = Provider.autoDispose
    .family<SearchSuggestions, String>((ref, text) {
      final geo = ref.watch(geoDatabaseProvider).value;
      return buildSuggestions(
        query: text,
        tags: ref.watch(tagsProvider).value ?? const [],
        places: ref.watch(_placeUsesProvider).value ?? const [],
        countries: geo?.countries ?? const [],
        countryCounts: ref.watch(countryCountsProvider).value ?? const {},
        recent: ref.watch(recentSearchesProvider),
        active: ref.watch(journalQueryProvider),
      );
    });

class JournalScreen extends ConsumerStatefulWidget {
  const JournalScreen({super.key});

  @override
  ConsumerState<JournalScreen> createState() => _JournalScreenState();
}

class _JournalScreenState extends ConsumerState<JournalScreen> {
  late final _search = TextEditingController(
    text: ref.read(journalQueryProvider).text,
  );
  final _searchFocus = FocusNode();
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    _searchFocus.addListener(_onFocusChanged);
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _searchFocus
      ..removeListener(_onFocusChanged)
      ..dispose();
    _search.dispose();
    super.dispose();
  }

  void _onFocusChanged() {
    // Leaving the field with a search in it keeps it as an earlier search.
    if (!_searchFocus.hasFocus) _remember();
    setState(() {});
  }

  void _remember() {
    final text = _search.text.trim();
    if (text.isNotEmpty) {
      unawaited(ref.read(recentSearchesProvider.notifier).add(text));
    }
  }

  void _onSearchChanged(String text) {
    setState(() {}); // clear button + suggestions
    _debounce?.cancel();
    _debounce = Timer(
      const Duration(milliseconds: 250),
      () => ref.read(journalQueryProvider.notifier).setText(text),
    );
  }

  void _setSearchText(String text) {
    _search.value = TextEditingValue(
      text: text,
      selection: TextSelection.collapsed(offset: text.length),
    );
    _debounce?.cancel();
    ref.read(journalQueryProvider.notifier).setText(text);
    setState(() {});
  }

  /// A suggestion becomes a filter chip; the typed text has done its job.
  void _applyFilter(void Function(JournalQueryController c) apply) {
    _remember();
    apply(ref.read(journalQueryProvider.notifier));
    _setSearchText('');
    _searchFocus.unfocus();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final query = ref.watch(journalQueryProvider);
    final entries = ref.watch(journalEntriesProvider);
    final tags = ref.watch(tagsProvider).value ?? const [];
    final tokens = queryTokens(query.text);
    final suggestions = _searchFocus.hasFocus
        ? ref.watch(searchSuggestionsProvider(_search.text))
        : const SearchSuggestions();
    final geo = ref.watch(geoDatabaseProvider).value;
    final country = geo?.country(query.countryCode);

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 4, 16, 6),
          child: SearchBar(
            controller: _search,
            focusNode: _searchFocus,
            hintText: l10n.journalSearchHint,
            leading: const Icon(Icons.search),
            elevation: const WidgetStatePropertyAll(0),
            onChanged: _onSearchChanged,
            onSubmitted: (_) => _searchFocus.unfocus(),
            textInputAction: TextInputAction.search,
            trailing: [
              if (_search.text.isNotEmpty)
                IconButton(
                  tooltip: l10n.journalClearSearch,
                  icon: const Icon(Icons.close),
                  onPressed: () => _setSearchText(''),
                ),
            ],
          ),
        ),
        if (tags.isNotEmpty || query.placeName != null || country != null)
          SizedBox(
            height: 48,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              children: [
                if (query.placeName != null)
                  _ActiveFilterChip(
                    avatar: const Icon(Icons.place_outlined, size: 18),
                    label: query.placeName!,
                    tooltip: l10n.journalRemoveFilter,
                    onDeleted: () =>
                        ref.read(journalQueryProvider.notifier).setPlace(null),
                  ),
                if (country != null)
                  _ActiveFilterChip(
                    avatar: Text(country.flag),
                    label: country.nameDe,
                    tooltip: l10n.journalRemoveFilter,
                    onDeleted: () => ref
                        .read(journalQueryProvider.notifier)
                        .setCountry(null),
                  ),
                for (final tag in tags)
                  Padding(
                    padding: const EdgeInsets.only(right: 6),
                    child: FilterChip(
                      avatar: Text(tag.emoji),
                      label: Text(tag.name),
                      selected: query.tagIds.contains(tag.id),
                      onSelected: (_) => ref
                          .read(journalQueryProvider.notifier)
                          .toggleTag(tag.id),
                      visualDensity: VisualDensity.compact,
                    ),
                  ),
              ],
            ),
          ),
        const GeoBackfillBanner(),
        Expanded(
          child: !suggestions.isEmpty
              ? SearchSuggestionList(
                  suggestions: suggestions,
                  onTag: (t) => _applyFilter((c) => c.toggleTag(t.id)),
                  onPlace: (p) => _applyFilter((c) => c.setPlace(p.name)),
                  onCountry: (code) => _applyFilter((c) => c.setCountry(code)),
                  onRecent: (text) {
                    _setSearchText(text);
                    _searchFocus.unfocus();
                  },
                  onRemoveRecent: (text) => unawaited(
                    ref.read(recentSearchesProvider.notifier).remove(text),
                  ),
                  onClearRecent: () => unawaited(
                    ref.read(recentSearchesProvider.notifier).clear(),
                  ),
                )
              : entries.when(
                  loading: () =>
                      const Center(child: CircularProgressIndicator()),
                  error: (e, _) => Center(child: Text(l10n.errorGeneric)),
                  data: (list) {
                    if (list.isEmpty && query.isEmpty) {
                      return EmptyState(
                        icon: Icons.menu_book_outlined,
                        title: l10n.journalEmptyTitle,
                        body: l10n.journalEmptyBody,
                      );
                    }
                    if (list.isEmpty) {
                      return EmptyState(
                        icon: Icons.search_off,
                        title: l10n.journalNoResults,
                        body: '',
                        action: TextButton(
                          onPressed: () {
                            _setSearchText('');
                            ref.read(journalQueryProvider.notifier).clear();
                          },
                          child: Text(l10n.journalClearFilter),
                        ),
                      );
                    }
                    return _JournalList(
                      entries: list,
                      tokens: tokens,
                      showCount: !query.isEmpty,
                    );
                  },
                ),
        ),
      ],
    );
  }
}

/// An active place/country filter; the cross removes it.
class _ActiveFilterChip extends StatelessWidget {
  const _ActiveFilterChip({
    required this.avatar,
    required this.label,
    required this.tooltip,
    required this.onDeleted,
  });

  final Widget avatar;
  final String label;
  final String tooltip;
  final VoidCallback onDeleted;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(right: 6),
    child: InputChip(
      avatar: avatar,
      label: Text(label),
      selected: true,
      showCheckmark: false,
      onDeleted: onDeleted,
      deleteButtonTooltipMessage: tooltip,
      onPressed: onDeleted,
      visualDensity: VisualDensity.compact,
    ),
  );
}

class _JournalList extends StatelessWidget {
  const _JournalList({
    required this.entries,
    required this.tokens,
    required this.showCount,
  });

  final List<NoteSummary> entries;
  final List<String> tokens;
  final bool showCount;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final items = <Object>[]; // DateTime (month header) or NoteSummary
    DateTime? month;
    for (final e in entries) {
      final m = DateTime(e.date.year, e.date.month);
      if (m != month) {
        items.add(m);
        month = m;
      }
      items.add(e);
    }
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(12, 0, 12, floatingNavClearance),
      itemCount: items.length + (showCount ? 1 : 0),
      itemBuilder: (context, index) {
        if (showCount) {
          if (index == 0) {
            return _ListLabel(
              l10n.journalResultCount(entries.length),
              padding: const EdgeInsets.fromLTRB(8, 4, 8, 0),
              muted: true,
            );
          }
          index--;
        }
        final item = items[index];
        if (item is DateTime) {
          return _ListLabel(
            Fmt.month(item),
            padding: const EdgeInsets.fromLTRB(8, 20, 8, 8),
          );
        }
        return JournalEntryCard(entry: item as NoteSummary, tokens: tokens);
      },
    );
  }
}

/// One journal page: polaroid on the left, handwritten note on the right,
/// with a notebook margin line.
class JournalEntryCard extends StatelessWidget {
  const JournalEntryCard({
    super.key,
    required this.entry,
    this.tokens = const [],
    this.maxLines = 5,
    this.collectionId,
    this.onLongPress,
    this.heroScope = 'journal',
  });

  final NoteSummary entry;
  final List<String> tokens;
  final int maxLines;

  /// Where the card is shown (part of the polaroid's hero tag).
  final String heroScope;

  /// Opens the note within this collection (previous/next entries).
  final int? collectionId;
  final VoidCallback? onLongPress;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final noteStyle = AppTheme.noteText(context, size: 17);
    final weather = entry.weather;
    final cacheWidth = (110 * MediaQuery.devicePixelRatioOf(context)).round();
    final heroTag = NoteHeroTag(heroScope, entry.assetId);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      // No clip on the card (anti-aliased clips are expensive while
      // scrolling): the ink is shaped by the card's border instead, and
      // nothing else reaches into the rounded corners.
      child: Card(
        child: InkWell(
          customBorder: theme.cardTheme.shape,
          onTap: () => openNote(
            context,
            entry.assetId,
            collectionId: collectionId,
            heroTag: heroTag,
          ),
          onLongPress: onLongPress,
          child: CustomPaint(
            painter: _MarginLinePainter(
              theme.colorScheme.secondary.withValues(alpha: 0.35),
            ),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(14, 16, 14, 14),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    width: 92,
                    child: Polaroid(
                      tilt: Polaroid.tiltFor(entry.assetId),
                      tape: false,
                      photoAspect: PolaroidGeometry.photoAspectOrSquare(
                        entry.photoAspect,
                      ),
                      hero: PolaroidHero(
                        tag: heroTag,
                        // The full stored copy (decoded by openNote) stays
                        // sharp while the polaroid grows.
                        flightImage: NotePhoto(
                          assetId: entry.assetId,
                          thumbnailFile: entry.thumbnailFile,
                          preferStoredCopy: true,
                        ),
                      ),
                      image: NotePhoto(
                        assetId: entry.assetId,
                        thumbnailFile: entry.thumbnailFile,
                        preferStoredCopy: true,
                        cacheWidth: cacheWidth,
                      ),
                    ),
                  ),
                  const SizedBox(width: 22),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (entry.title != null) ...[
                          _EntryTitle(entry: entry),
                          const SizedBox(height: 2),
                        ],
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                [
                                  Fmt.mediumDateWithWeekday(entry.date),
                                  ?entry.placeName,
                                ].join(' · '),
                                style: theme.textTheme.titleSmall?.copyWith(
                                  fontFamily: AppFonts.serif,
                                  fontSize: 16,
                                  color: theme.colorScheme.onSurfaceVariant,
                                ),
                              ),
                            ),
                            if (entry.song case final song?)
                              Padding(
                                padding: const EdgeInsets.only(right: 6),
                                child: Tooltip(
                                  message: l10n.songOf(song.title, song.artist),
                                  child: Semantics(
                                    label: l10n.journalHasSong,
                                    child: Icon(
                                      Icons.album_outlined,
                                      size: 18,
                                      color: theme.colorScheme.onSurfaceVariant,
                                    ),
                                  ),
                                ),
                              ),
                            if (weather != null)
                              Tooltip(
                                message: weatherLabel(l10n, weather),
                                child: Icon(
                                  weatherIcon(weather.kind),
                                  size: 18,
                                  color: theme.colorScheme.onSurfaceVariant,
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        if (entry.highlightedSnippet != null)
                          HighlightedText(
                            entry.highlightedSnippet!,
                            style: noteStyle,
                            maxLines: maxLines,
                          )
                        else
                          Text(
                            entry.preview,
                            style: noteStyle,
                            maxLines: maxLines,
                            overflow: TextOverflow.ellipsis,
                          ),
                        if (entry.tags.isNotEmpty) ...[
                          const SizedBox(height: 8),
                          Wrap(
                            spacing: 5,
                            runSpacing: 5,
                            children: [
                              for (final t in entry.tags)
                                TagLabel(
                                  tag: t,
                                  highlighted:
                                      tokens.isNotEmpty &&
                                      matchesAnyPrefix(t.name, tokens),
                                ),
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// A month header or the result count. A widget of its own (instead of
/// building inline in the item builder) so it reads the theme from its own
/// context and follows a theme switch at once.
class _ListLabel extends StatelessWidget {
  const _ListLabel(this.text, {required this.padding, this.muted = false});

  final String text;
  final EdgeInsets padding;
  final bool muted;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: padding,
      child: Text(
        text,
        style: muted
            ? TextStyle(color: theme.colorScheme.onSurfaceVariant)
            : theme.textTheme.titleMedium,
      ),
    );
  }
}

/// The title of a journal entry in the handwriting, search hits marked.
class _EntryTitle extends StatelessWidget {
  const _EntryTitle({required this.entry});

  final NoteSummary entry;

  @override
  Widget build(BuildContext context) {
    final style = AppTheme.noteText(context, size: 19).copyWith(
      fontWeight: FontWeight.w700,
      height: 1.25,
      color: Theme.of(context).colorScheme.onSurface,
    );
    final marked = entry.highlightedTitle;
    if (marked != null) {
      return HighlightedText(marked, style: style, maxLines: 2);
    }
    return Text(
      entry.title!,
      style: style,
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
    );
  }
}

class _MarginLinePainter extends CustomPainter {
  _MarginLinePainter(this.color);

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    const x = 116.0;
    canvas.drawLine(
      const Offset(x, 0),
      Offset(x, size.height),
      Paint()
        ..color = color
        ..strokeWidth = 1,
    );
  }

  @override
  bool shouldRepaint(_MarginLinePainter old) => old.color != color;
}
