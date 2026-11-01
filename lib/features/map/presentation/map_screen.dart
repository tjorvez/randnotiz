import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/providers.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/paper.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../../geo/data/geo_database.dart';
import '../../geo/presentation/geo_backfill_controller.dart';
import '../../journal/presentation/journal_screen.dart';
import '../../notes/domain/note.dart';
import '../data/world_shapes.dart';
import '../domain/country_shapes.dart';
import '../domain/projection.dart';
import 'map_preferences.dart';

final worldShapesProvider = FutureProvider<WorldShapes>(
  (ref) => WorldShapes.load(),
);

/// The world map, opened from the journal: a calm drawing of the continents
/// (no tiles, no network) in which every country with entries is filled
/// with the accent colour. Borders can be switched on and off; small
/// countries get a marker. Tapping a country lists its entries.
///
/// All outlines are projected once per map size ([CountryShapes]); panning
/// and zooming only transform the canvas.
class MapScreen extends ConsumerStatefulWidget {
  const MapScreen({super.key});

  @override
  ConsumerState<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends ConsumerState<MapScreen>
    with SingleTickerProviderStateMixin {
  static const _maxScale = 40.0;

  /// Tap radius around small-country markers, in screen pixels.
  static const _markerHitRadius = 18.0;

  final _transform = TransformationController();
  late final AnimationController _zoom = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 520),
  );
  Animation<Matrix4>? _zoomAnimation;

  /// The zoom level the map is painted for. Panning alone never repaints
  /// (the InteractiveViewer just moves the cached layer); while zooming,
  /// the map is repainted only in steps of [_paintScaleStep], and exactly
  /// once the gesture or zoom animation ends – so lines and markers keep
  /// (almost) their size on screen without redrawing every outline in
  /// every frame.
  final _paintScale = ValueNotifier<double>(1);
  static const _paintScaleStep = 1.15;
  bool _framed = false;
  bool _userMoved = false;

  // Projected outlines, rebuilt only when the map size changes.
  Path? _land;
  CountryShapes? _shapes;
  double? _builtFor;

  // The highlighted countries as one path, rebuilt when they change.
  Path? _highlighted;
  Set<String>? _highlightedFor;

  @override
  void initState() {
    super.initState();
    _zoom.addListener(() {
      final a = _zoomAnimation;
      if (a != null) _transform.value = a.value;
    });
    _zoom.addStatusListener((status) {
      if (status == AnimationStatus.completed) _syncPaintScale(exact: true);
    });
    _transform.addListener(_syncPaintScale);
  }

  void _syncPaintScale({bool exact = false}) {
    final scale = _transform.value.getMaxScaleOnAxis();
    final painted = _paintScale.value;
    final ratio = scale > painted ? scale / painted : painted / scale;
    if (exact ? scale != painted : ratio >= _paintScaleStep) {
      _paintScale.value = scale;
    }
  }

  @override
  void dispose() {
    _zoom.dispose();
    _transform.dispose();
    _paintScale.dispose();
    super.dispose();
  }

  void _ensureShapes(WorldShapes land, GeoDatabase geo, EqualEarth p) {
    if (_builtFor == p.height && _land != null && _shapes != null) return;
    _land = land.toPath(p);
    _shapes = CountryShapes.build(geo, p);
    _builtFor = p.height;
    _highlighted = null;
  }

  Path _highlightPath(Set<String> codes) {
    if (_highlighted == null || _highlightedFor != codes) {
      _highlighted = _shapes!.combined(codes);
      _highlightedFor = codes;
    }
    return _highlighted!;
  }

  /// A transformation that shows [area] (map coordinates) centred in
  /// [viewport], never zooming out beyond "map fills the view".
  Matrix4 _matrixFor(
    Rect area,
    Size viewport,
    Size map, {
    double padding = 48,
    double maxScale = _maxScale,
  }) {
    final w = max(area.width, 1.0);
    final h = max(area.height, 1.0);
    final scale = min(
      (viewport.width - 2 * padding) / w,
      (viewport.height - 2 * padding) / h,
    ).clamp(1.0, maxScale);
    var tx = viewport.width / 2 - area.center.dx * scale;
    var ty = viewport.height / 2 - area.center.dy * scale;
    tx = tx.clamp(viewport.width - map.width * scale, 0.0);
    ty = ty.clamp(viewport.height - map.height * scale, 0.0);
    return Matrix4.diagonal3Values(scale, scale, 1)
      ..setTranslationRaw(tx, ty, 0);
  }

  void _show(Rect? area, Size viewport, EqualEarth p, {bool animate = true}) {
    final map = Size(p.width, p.height);
    final target = area == null
        // Nothing yet: Europe.
        ? _matrixFor(
            Rect.fromCenter(center: p.project(10, 50), width: 1, height: 1),
            viewport,
            map,
            maxScale: 1,
          )
        : _matrixFor(area, viewport, map, maxScale: 6);
    if (!animate || MediaQuery.disableAnimationsOf(context)) {
      _transform.value = target;
      return;
    }
    _zoomAnimation = Matrix4Tween(
      begin: _transform.value,
      end: target,
    ).animate(CurvedAnimation(parent: _zoom, curve: Curves.easeInOutCubic));
    _zoom
      ..reset()
      ..forward();
  }

  void _onTap(Offset mapPoint, Set<String> withEntries) {
    final shapes = _shapes;
    if (shapes == null) return;
    final scale = _transform.value.getMaxScaleOnAxis();
    final code = shapes.hit(
      mapPoint,
      markerRadius: _markerHitRadius / scale,
      preferred: withEntries,
    );
    if (code == null) return;
    final geo = ref.read(geoDatabaseProvider).value;
    if (withEntries.contains(code)) {
      CountryEntriesSheet.show(context, code);
    } else {
      final l10n = AppLocalizations.of(context);
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(
            content: Text(l10n.mapNoEntriesIn(countryName(geo, code))),
            duration: const Duration(seconds: 2),
          ),
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final scheme = Theme.of(context).colorScheme;
    final land = ref.watch(worldShapesProvider).value;
    final geo = ref.watch(geoDatabaseProvider).value;
    final counts = ref.watch(countryCountsProvider).value ?? const {};
    final showBorders = ref.watch(mapShowBordersProvider);
    final backfill = ref.watch(geoBackfillProvider);
    final withEntries = countriesWithEntries(counts);
    final entryCount = counts.values.fold(0, (a, b) => a + b);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.mapTitle),
        actions: [
          IconButton(
            tooltip: showBorders ? l10n.mapHideBorders : l10n.mapShowBorders,
            isSelected: showBorders,
            icon: const Icon(Icons.border_clear),
            selectedIcon: const Icon(Icons.border_all),
            onPressed: () => ref.read(mapShowBordersProvider.notifier).toggle(),
          ),
        ],
      ),
      body: PaperBackground(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final viewport = constraints.biggest;
            final projection = EqualEarth.ofHeight(
              max(viewport.height, viewport.width / EqualEarth.aspectRatio),
            );
            final ready = land != null && geo != null;
            if (ready) _ensureShapes(land, geo, projection);
            if (ready && (!_framed || (!_userMoved && counts.isNotEmpty))) {
              final area = _shapes!.boundsOf(withEntries);
              final first = !_framed;
              _framed = true;
              if (first || area != null) {
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  if (mounted && !_userMoved) {
                    _show(area, viewport, projection, animate: !first);
                  }
                });
              }
            }

            return Stack(
              children: [
                Positioned.fill(
                  child: InteractiveViewer(
                    transformationController: _transform,
                    constrained: false,
                    minScale: 1,
                    maxScale: _maxScale,
                    boundaryMargin: EdgeInsets.zero,
                    onInteractionStart: (_) {
                      _zoom.stop();
                      _userMoved = true;
                    },
                    onInteractionEnd: (_) => _syncPaintScale(exact: true),
                    child: GestureDetector(
                      onTapUp: (d) => _onTap(d.localPosition, withEntries),
                      child: SizedBox(
                        width: projection.width,
                        height: projection.height,
                        child: !ready
                            ? null
                            : RepaintBoundary(
                                child: CustomPaint(
                                  painter: WorldPainter(
                                    land: _land!,
                                    shapes: _shapes!,
                                    highlighted: _highlightPath(withEntries),
                                    withEntries: withEntries,
                                    showBorders: showBorders,
                                    scale: _paintScale,
                                    colors: WorldColors.of(context),
                                  ),
                                ),
                              ),
                      ),
                    ),
                  ),
                ),
                Positioned(
                  top: 10,
                  left: 16,
                  right: 16,
                  child: Center(
                    child: _StatusPill(
                      text: backfill.running
                          ? l10n.geoBackfillProgress(
                              backfill.done,
                              backfill.total,
                            )
                          : withEntries.isEmpty
                          ? null
                          : [
                              l10n.mapCountriesCount(withEntries.length),
                              l10n.mapEntriesCount(entryCount),
                            ].join(' · '),
                      busy: backfill.running,
                    ),
                  ),
                ),
                if (ready && withEntries.isNotEmpty)
                  Positioned(
                    right: 16,
                    bottom: 16 + MediaQuery.paddingOf(context).bottom,
                    child: _RoundButton(
                      icon: Icons.center_focus_strong_outlined,
                      tooltip: l10n.mapShowAll,
                      onTap: () => _show(
                        _shapes!.boundsOf(withEntries),
                        viewport,
                        projection,
                      ),
                    ),
                  ),
                if (ready && withEntries.isEmpty && !backfill.running)
                  Positioned(
                    left: 24,
                    right: 24,
                    bottom: 24 + MediaQuery.paddingOf(context).bottom,
                    child: const _EmptyHint(),
                  ),
                if (!ready)
                  Center(
                    child: CircularProgressIndicator(color: scheme.secondary),
                  ),
              ],
            );
          },
        ),
      ),
    );
  }
}

/// Colours of the world map, from the theme (light and dark).
@immutable
class WorldColors {
  const WorldColors({
    required this.land,
    required this.coast,
    required this.borders,
    required this.grid,
    required this.highlight,
    required this.highlightEdge,
    required this.marker,
    required this.markerRim,
  });

  factory WorldColors.of(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final diary = context.diary;
    return WorldColors(
      land: Color.alphaBlend(
        scheme.onSurface.withValues(alpha: 0.07),
        scheme.surface,
      ),
      coast: scheme.onSurfaceVariant.withValues(alpha: 0.35),
      borders: scheme.onSurfaceVariant.withValues(alpha: 0.32),
      grid: scheme.outlineVariant.withValues(alpha: 0.4),
      highlight: Color.alphaBlend(
        scheme.primary.withValues(alpha: 0.55),
        scheme.surface,
      ),
      highlightEdge: scheme.primary,
      marker: scheme.primary,
      markerRim: diary.polaroidFrame,
    );
  }

  final Color land;
  final Color coast;
  final Color borders;
  final Color grid;
  final Color highlight;
  final Color highlightEdge;
  final Color marker;
  final Color markerRim;

  @override
  bool operator ==(Object other) =>
      other is WorldColors &&
      other.land == land &&
      other.coast == coast &&
      other.borders == borders &&
      other.grid == grid &&
      other.highlight == highlight &&
      other.highlightEdge == highlightEdge &&
      other.marker == marker &&
      other.markerRim == markerRim;

  @override
  int get hashCode => Object.hash(
    land,
    coast,
    borders,
    grid,
    highlight,
    highlightEdge,
    marker,
    markerRim,
  );
}

/// Draws graticule, land, highlighted countries, borders and small-country
/// markers from cached paths. Line widths and markers keep their size on
/// screen at every zoom level.
class WorldPainter extends CustomPainter {
  WorldPainter({
    required this.land,
    required this.shapes,
    required this.highlighted,
    required this.withEntries,
    required this.showBorders,
    required this.scale,
    required this.colors,
  }) : super(repaint: scale);

  final Path land;
  final CountryShapes shapes;
  final Path highlighted;
  final Set<String> withEntries;
  final bool showBorders;

  /// Zoom level to size lines and markers for (see `_paintScale`).
  final ValueListenable<double> scale;
  final WorldColors colors;

  Path? _graticule;

  Path _grid(EqualEarth projection) {
    if (_graticule != null) return _graticule!;
    final g = Path();
    for (var lat = -30; lat <= 60; lat += 30) {
      final a = projection.project(-180, lat.toDouble());
      g.moveTo(a.dx, a.dy);
      for (var lon = -175; lon <= 180; lon += 5) {
        final p = projection.project(lon.toDouble(), lat.toDouble());
        g.lineTo(p.dx, p.dy);
      }
    }
    for (var lon = -180; lon <= 180; lon += 30) {
      final a = projection.project(lon.toDouble(), EqualEarth.southLimit);
      g.moveTo(a.dx, a.dy);
      for (var lat = -55.0; lat <= EqualEarth.northLimit; lat += 5) {
        final p = projection.project(lon.toDouble(), lat);
        g.lineTo(p.dx, p.dy);
      }
    }
    return _graticule = g;
  }

  @override
  void paint(Canvas canvas, Size size) {
    final scale = this.scale.value;
    Paint stroke(Color color, double width) => Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeJoin = StrokeJoin.round
      ..strokeWidth = width / scale;

    canvas.drawPath(_grid(shapes.projection), stroke(colors.grid, 0.7));
    canvas.drawPath(land, Paint()..color = colors.land);
    canvas.drawPath(highlighted, Paint()..color = colors.highlight);
    if (showBorders) {
      canvas.drawPath(shapes.borders, stroke(colors.borders, 0.6));
    }
    canvas.drawPath(land, stroke(colors.coast, 0.8));
    canvas.drawPath(highlighted, stroke(colors.highlightEdge, 0.9));

    // Small countries: a marker that keeps its size on screen. Those with
    // entries are filled; the others only appear while borders are shown.
    for (final MapEntry(key: code, value: pos) in shapes.markers.entries) {
      final has = withEntries.contains(code);
      if (!has && !showBorders) continue;
      final r = (has ? 6.0 : 3.5) / scale;
      if (has) {
        canvas
          ..drawCircle(pos, r + 1.6 / scale, Paint()..color = colors.markerRim)
          ..drawCircle(pos, r, Paint()..color = colors.marker);
      } else {
        canvas.drawCircle(pos, r, stroke(colors.borders, 1));
      }
    }
  }

  @override
  bool shouldRepaint(WorldPainter old) =>
      old.land != land ||
      old.shapes != shapes ||
      old.highlighted != highlighted ||
      old.showBorders != showBorders ||
      old.colors != colors;
}

class _StatusPill extends StatelessWidget {
  const _StatusPill({required this.text, this.busy = false});

  final String? text;
  final bool busy;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    if (text == null) return const SizedBox.shrink();
    return Material(
      color: scheme.surfaceContainerHigh.withValues(alpha: 0.94),
      shape: StadiumBorder(
        side: BorderSide(color: scheme.outlineVariant.withValues(alpha: 0.6)),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (busy) ...[
              const SizedBox.square(
                dimension: 12,
                child: CircularProgressIndicator(strokeWidth: 1.6),
              ),
              const SizedBox(width: 8),
            ],
            Flexible(
              child: Text(
                text!,
                style: TextStyle(fontSize: 13, color: scheme.onSurfaceVariant),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RoundButton extends StatelessWidget {
  const _RoundButton({
    required this.icon,
    required this.tooltip,
    required this.onTap,
  });

  final IconData icon;
  final String tooltip;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Tooltip(
      message: tooltip,
      child: Material(
        color: scheme.surfaceContainerHigh,
        elevation: 4,
        shadowColor: scheme.shadow.withValues(alpha: 0.3),
        shape: CircleBorder(
          side: BorderSide(color: scheme.outlineVariant.withValues(alpha: 0.6)),
        ),
        child: InkWell(
          customBorder: const CircleBorder(),
          onTap: onTap,
          child: SizedBox.square(
            dimension: 46,
            child: Icon(icon, size: 22, color: scheme.onSurfaceVariant),
          ),
        ),
      ),
    );
  }
}

class _EmptyHint extends ConsumerWidget {
  const _EmptyHint();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final hasNotes = (ref.watch(allNotesProvider).value ?? const []).isNotEmpty;
    return Material(
      color: theme.colorScheme.surfaceContainerHigh.withValues(alpha: 0.95),
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(18, 14, 18, 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(l10n.mapEmptyTitle, style: theme.textTheme.titleMedium),
            const SizedBox(height: 6),
            Text(
              hasNotes ? l10n.mapEmptyBody : l10n.mapEmptyNoNotes,
              textAlign: TextAlign.center,
              style: AppTheme.noteText(
                context,
                size: 16,
              ).copyWith(color: theme.colorScheme.onSurfaceVariant),
            ),
          ],
        ),
      ),
    );
  }
}

/// The entries of one country.
class CountryEntriesSheet extends ConsumerWidget {
  const CountryEntriesSheet({super.key, required this.countryCode});

  final String countryCode;

  static Future<void> show(BuildContext context, String code) =>
      showModalBottomSheet<void>(
        context: context,
        showDragHandle: true,
        isScrollControlled: true,
        useSafeArea: true,
        builder: (_) => CountryEntriesSheet(countryCode: code),
      );

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final country = ref.watch(geoDatabaseProvider).value?.country(countryCode);
    final notes =
        ref
            .watch(
              _countryEntriesProvider(JournalQuery(countryCode: countryCode)),
            )
            .value ??
        const <NoteSummary>[];
    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: notes.length > 2 ? 0.62 : 0.45,
      minChildSize: 0.3,
      maxChildSize: 0.92,
      builder: (context, scroll) => ListView(
        controller: scroll,
        padding: const EdgeInsets.fromLTRB(12, 0, 12, 24),
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(8, 0, 8, 4),
            child: Row(
              children: [
                if (country != null)
                  Text(country.flag, style: const TextStyle(fontSize: 24)),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    country?.nameDe ?? countryCode,
                    style: theme.textTheme.titleLarge,
                  ),
                ),
                Text(
                  l10n.mapEntriesCount(notes.length),
                  style: TextStyle(color: theme.colorScheme.onSurfaceVariant),
                ),
              ],
            ),
          ),
          for (final n in notes)
            JournalEntryCard(
              entry: n,
              maxLines: 3,
              heroScope: 'map:$countryCode',
            ),
        ],
      ),
    );
  }
}

final _countryEntriesProvider = StreamProvider.autoDispose
    .family<List<NoteSummary>, JournalQuery>(
      (ref, query) => ref.watch(noteRepositoryProvider).watchJournal(query),
    );
