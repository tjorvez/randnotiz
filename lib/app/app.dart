import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:home_widget/home_widget.dart';

import '../core/theme/app_theme.dart';
import '../core/theme/season.dart';
import '../features/backup/presentation/backup_controller.dart';
import '../features/geo/data/country_names_sync.dart';
import '../features/geo/presentation/geo_backfill_controller.dart';
import '../features/lock/presentation/lock_controller.dart';
import '../features/memory_widget/data/memory_widget_sync.dart';
import '../features/notes/data/photo_aspect_backfill.dart';
import '../features/settings/presentation/settings_controller.dart';
import '../l10n/generated/app_localizations.dart';
import 'providers.dart';
import 'router.dart';
import 'start_gate.dart';

class RandnotizApp extends ConsumerStatefulWidget {
  const RandnotizApp({super.key});

  @override
  ConsumerState<RandnotizApp> createState() => _RandnotizAppState();
}

class _RandnotizAppState extends ConsumerState<RandnotizApp>
    with WidgetsBindingObserver {
  StreamSubscription<Uri?>? _widgetClicks;

  /// Housekeeping that may wait until the first screens are up.
  Timer? _deferredStartup;

  /// How long the start-up housekeeping waits, so it does not compete with
  /// the first frames and the first taps.
  static const _startupDelay = Duration(seconds: 2);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    // Screenshots/screen casting are blocked only while the lock is in effect.
    ref.listenManual(
      secureWindowWantedProvider,
      (_, secure) =>
          unawaited(ref.read(secureWindowProvider).setSecure(secure)),
      fireImmediately: true,
    );
    unawaited(_handleWidgetLaunch());
    _widgetClicks = HomeWidget.widgetClicked.listen(
      _openFromWidget,
      onError: (_) {},
    );
    WidgetsBinding.instance.addPostFrameCallback((_) {
      unawaited(ref.read(memoryWidgetSyncProvider).refresh());
      _deferredStartup = Timer(_startupDelay, () {
        if (!mounted) return;
        unawaited(_cleanupImports());
        unawaited(_backfillPhotoAspects());
        unawaited(_prepareGeodata());
        unawaited(ref.read(backupStatusProvider.notifier).autoBackup());
      });
    });
  }

  /// Removes copies of picked photos that never got a note, and covers of
  /// songs no note links any more.
  Future<void> _cleanupImports() async {
    final notes = ref.read(noteRepositoryProvider);
    final noted = await notes.watchNotedAssetIds().first;
    await ref.read(importedPhotoStoreProvider).deleteOrphans(noted);
    try {
      await ref
          .read(thumbnailStoreProvider)
          .deleteUnusedCovers(await notes.songCoverFilesInUse());
    } on Exception catch (e) {
      debugPrint('Cover clean-up failed: $e');
    }
  }

  /// Notes from before schema v6 learn their photo's proportions (once).
  Future<void> _backfillPhotoAspects() async {
    try {
      await PhotoAspectBackfill(
        notes: ref.read(noteRepositoryProvider),
        photos: ref.read(photoRepositoryProvider),
        thumbnails: ref.read(thumbnailStoreProvider),
      ).run();
    } on Exception catch (e) {
      debugPrint('Photo aspect back-fill failed: $e');
    }
  }

  /// Country names for the search index, then the one-time back-fill of
  /// countries and places for older notes.
  Future<void> _prepareGeodata() async {
    try {
      final geo = await ref.read(geoDatabaseProvider.future);
      await CountryNamesSync(ref.read(databaseProvider)).sync(geo.countries);
      await ref.read(geoBackfillProvider.notifier).startIfNeeded();
    } on Exception catch (e) {
      debugPrint('Geodata start-up failed: $e');
    }
  }

  Future<void> _handleWidgetLaunch() async {
    try {
      final uri = await HomeWidget.initiallyLaunchedFromHomeWidget();
      if (uri != null) _openFromWidget(uri);
    } on Exception {
      // Not available (tests).
    }
  }

  void _openFromWidget(Uri? uri) {
    if (uri == null) return;
    // Opening from the widget always asks for unlocking (if enabled).
    ref.read(lockProvider.notifier).lockNow();
    ref.read(routerProvider).go('/memories');
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    ref.read(lockProvider.notifier).onLifecycleChanged(state);
    if (state == AppLifecycleState.resumed) {
      // The day may have changed: refresh season + widget.
      setState(() {});
      ref.read(memoryWidgetSyncProvider).scheduleRefresh();
      unawaited(ref.read(backupStatusProvider.notifier).autoBackup());
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    unawaited(_widgetClicks?.cancel());
    _deferredStartup?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final settings = ref.watch(settingsProvider);
    ref.listen(
      settingsProvider.select((s) => s.lockEnabled),
      (_, enabled) =>
          ref.read(lockProvider.notifier).onSettingsChanged(enabled: enabled),
    );
    ref.watch(memoryWidgetSyncProvider);
    final season = Season.of(ref.read(clockProvider)());

    return MaterialApp.router(
      onGenerateTitle: (context) => AppLocalizations.of(context).appTitle,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.build(Brightness.light, season),
      darkTheme: AppTheme.build(Brightness.dark, season),
      themeMode: settings.themeMode,
      locale: const Locale('de'),
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      routerConfig: ref.watch(routerProvider),
      builder: (context, child) =>
          StartGate(child: child ?? const SizedBox.shrink()),
    );
  }
}
