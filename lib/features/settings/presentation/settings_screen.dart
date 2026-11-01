import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/format/formatters.dart';
import '../../../core/platform/app_info.dart';
import '../../../core/widgets/app_logo.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../../backup/domain/backup_service.dart';
import '../../backup/presentation/backup_controller.dart';
import '../../backup/presentation/backup_screen.dart' show problemText;
import '../../geo/presentation/geo_backfill_controller.dart';
import '../../lock/presentation/lock_controller.dart';
import '../domain/app_settings.dart';
import 'settings_controller.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final settings = ref.watch(settingsProvider);
    final controller = ref.read(settingsProvider.notifier);
    final lockAvailable = ref.watch(lockProvider.select((s) => s.available));

    String timeoutLabel(Duration d) => d == Duration.zero
        ? l10n.lockTimeoutImmediately
        : l10n.lockTimeoutMinutes(d.inMinutes);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.settingsTitle)),
      body: ListView(
        padding: const EdgeInsets.only(bottom: 32),
        children: [
          _Section(l10n.settingsSectionAppearance),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.settingsTheme,
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
                const SizedBox(height: 8),
                SegmentedButton<ThemeMode>(
                  segments: [
                    ButtonSegment(
                      value: ThemeMode.system,
                      label: Text(l10n.themeSystem),
                      icon: const Icon(Icons.brightness_auto_outlined),
                    ),
                    ButtonSegment(
                      value: ThemeMode.light,
                      label: Text(l10n.themeLight),
                      icon: const Icon(Icons.light_mode_outlined),
                    ),
                    ButtonSegment(
                      value: ThemeMode.dark,
                      label: Text(l10n.themeDark),
                      icon: const Icon(Icons.dark_mode_outlined),
                    ),
                  ],
                  selected: {settings.themeMode},
                  onSelectionChanged: (s) => controller.setThemeMode(s.first),
                ),
              ],
            ),
          ),
          _Section(l10n.settingsSectionPrivacy),
          SwitchListTile(
            secondary: const Icon(Icons.fingerprint),
            title: Text(l10n.settingsLock),
            subtitle: Text(
              lockAvailable
                  ? l10n.settingsLockSubtitle
                  : l10n.settingsLockUnavailable,
            ),
            value: settings.lockEnabled && lockAvailable,
            onChanged: lockAvailable ? controller.setLockEnabled : null,
          ),
          ListTile(
            enabled: settings.lockEnabled && lockAvailable,
            leading: const Icon(Icons.timer_outlined),
            title: Text(l10n.settingsLockTimeout),
            subtitle: Text(timeoutLabel(settings.lockTimeout)),
            onTap: () async {
              final picked = await showDialog<Duration>(
                context: context,
                builder: (context) => SimpleDialog(
                  title: Text(l10n.settingsLockTimeout),
                  children: [
                    RadioGroup<Duration>(
                      groupValue: settings.lockTimeout,
                      onChanged: (d) => Navigator.pop(context, d),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          for (final d in lockTimeoutOptions)
                            RadioListTile<Duration>(
                              value: d,
                              title: Text(timeoutLabel(d)),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
              if (picked != null) await controller.setLockTimeout(picked);
            },
          ),
          _Section(l10n.settingsSectionTags),
          ListTile(
            leading: const Icon(Icons.sell_outlined),
            title: Text(l10n.settingsManageTags),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => context.push('/settings/tags'),
          ),
          _Section(l10n.settingsSectionPlaces),
          const _GeoBackfillTile(),
          _Section(l10n.settingsSectionWidget),
          SwitchListTile(
            secondary: const Icon(Icons.widgets_outlined),
            title: Text(l10n.settingsWidgetText),
            subtitle: Text(l10n.settingsWidgetTextSubtitle),
            value: settings.widgetShowsText,
            onChanged: controller.setWidgetShowsText,
          ),
          _Section(l10n.settingsSectionBackup),
          const _BackupTile(),
          _Section(l10n.settingsSectionAbout),
          ListTile(
            leading: const Icon(Icons.auto_stories_outlined),
            title: Text(l10n.settingsIntro),
            subtitle: Text(l10n.settingsIntroSubtitle),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => context.push('/settings/intro'),
          ),
          AboutListTile(
            icon: const Icon(Icons.info_outline),
            applicationName: l10n.appTitle,
            applicationVersion: ref.watch(appVersionProvider).value,
            applicationIcon: const AppLogo(size: 56),
            applicationLegalese: l10n.settingsAboutLegalese,
            child: Text(l10n.settingsAbout),
          ),
        ],
      ),
    );
  }
}

class _Section extends StatelessWidget {
  const _Section(this.title);

  final String title;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.fromLTRB(16, 24, 16, 6),
    child: Text(
      title,
      style: Theme.of(context).textTheme.titleMedium
          ?.copyWith(color: Theme.of(context).colorScheme.secondary),
    ),
  );
}

/// Start, follow or cancel the back-fill of countries and places.
class _GeoBackfillTile extends ConsumerWidget {
  const _GeoBackfillTile();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final state = ref.watch(geoBackfillProvider);
    final controller = ref.read(geoBackfillProvider.notifier);
    return ListTile(
      leading: const Icon(Icons.travel_explore),
      title: Text(l10n.settingsGeoBackfill),
      subtitle: Text(switch (state.status) {
        GeoBackfillStatus.idle => l10n.settingsGeoBackfillIdle,
        GeoBackfillStatus.running => l10n.settingsGeoBackfillRunning(
          state.done,
          state.total,
        ),
        GeoBackfillStatus.done => l10n.settingsGeoBackfillDone,
        GeoBackfillStatus.cancelled => l10n.settingsGeoBackfillCancelled,
      }),
      trailing: state.running
          ? SizedBox.square(
              dimension: 24,
              child: CircularProgressIndicator(
                strokeWidth: 2.5,
                value: state.total == 0 ? null : state.progress,
              ),
            )
          : null,
      onTap: state.running ? controller.cancel : controller.start,
    );
  }
}

/// Status of the Drive backup; opens its screen.
class _BackupTile extends ConsumerWidget {
  const _BackupTile();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final status = ref.watch(backupStatusProvider);
    final available = status.phase != BackupPhase.notConfigured;
    final problem = status.problem;
    final subtitle = switch (status.phase) {
      _ when status.running => l10n.settingsBackupRunning,
      _ when problem != null && available => problemText(l10n, problem),
      BackupPhase.notConfigured => l10n.settingsBackupUnavailable,
      BackupPhase.signedOut => l10n.settingsBackupOff,
      BackupPhase.needsSetup => l10n.settingsBackupNeedsSetup,
      BackupPhase.needsUnlock => l10n.settingsBackupNeedsUnlock,
      BackupPhase.ready when status.restorePending =>
        l10n.settingsBackupRestorePending,
      BackupPhase.ready =>
        status.lastBackupAt == null
            ? l10n.settingsBackupNever
            : l10n.settingsBackupLast(Fmt.fullDateTime(status.lastBackupAt!)),
    };
    return ListTile(
      enabled: available,
      leading: Icon(
        status.phase == BackupPhase.ready && problem == null
            ? Icons.cloud_done_outlined
            : Icons.cloud_outlined,
      ),
      title: Text(l10n.settingsBackupDrive),
      subtitle: Text(subtitle),
      trailing: status.running
          ? SizedBox.square(
              dimension: 24,
              child: CircularProgressIndicator(
                strokeWidth: 2.5,
                value: status.progress,
              ),
            )
          : available
          ? const Icon(Icons.chevron_right)
          : null,
      onTap: () => context.push('/settings/backup'),
    );
  }
}
