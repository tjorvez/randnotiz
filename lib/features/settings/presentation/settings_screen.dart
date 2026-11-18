import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../app/app_locale.dart';
import '../../../app/providers.dart';
import '../../../core/format/formatters.dart';
import '../../../core/l10n/app_language.dart';
import '../../../core/platform/app_info.dart';
import '../../../core/widgets/app_logo.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../../backup/domain/backup_service.dart';
import '../../backup/presentation/backup_controller.dart';
import '../../backup/presentation/backup_screen.dart' show problemText;
import '../../lock/presentation/lock_controller.dart';
import '../../whats_new/domain/release_notes.dart';
import '../../whats_new/presentation/whats_new_dialog.dart';
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
          const _LanguageTile(),
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
          _Section(l10n.settingsSectionMemories),
          const _BirthdayTile(),
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
          ListTile(
            leading: const Icon(Icons.new_releases_outlined),
            title: Text(l10n.settingsWhatsNew),
            subtitle: Text(l10n.settingsWhatsNewSubtitle),
            onTap: () => showWhatsNew(context, releaseNotes),
          ),
          const _PrivacyPolicyTile(),
          AboutListTile(
            icon: const Icon(Icons.info_outline),
            applicationName: l10n.appTitle,
            applicationVersion: ref.watch(appVersionProvider).value,
            applicationIcon: const AppLogo(size: 56),
            applicationLegalese: l10n.settingsAboutLegalese(
              privacyPolicyLabel(ref.watch(appLanguageProvider)),
              appCopyright,
              sourceCodeLabel,
            ),
            child: Text(l10n.settingsAbout),
          ),
        ],
      ),
    );
  }
}

/// The optional birthday for "x % of your life" next to memories.
class _BirthdayTile extends ConsumerWidget {
  const _BirthdayTile();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final birthday = ref.watch(settingsProvider.select((s) => s.birthday));
    final controller = ref.read(settingsProvider.notifier);
    return ListTile(
      leading: const Icon(Icons.cake_outlined),
      title: Text(l10n.settingsBirthday),
      subtitle: Text(
        birthday != null ? Fmt.longDate(birthday) : l10n.settingsBirthdayNotSet,
      ),
      trailing: birthday == null
          ? null
          : IconButton(
              icon: const Icon(Icons.close),
              tooltip: l10n.settingsBirthdayRemove,
              onPressed: () => controller.setBirthday(null),
            ),
      onTap: () async {
        final now = ref.read(clockProvider)();
        final today = DateTime(now.year, now.month, now.day);
        final picked = await showDatePicker(
          context: context,
          helpText: l10n.settingsBirthday,
          initialDate: birthday ?? DateTime(today.year - 30, 1, 1),
          firstDate: DateTime(1900),
          lastDate: today,
          initialDatePickerMode: birthday == null
              ? DatePickerMode.year
              : DatePickerMode.day,
        );
        if (picked != null) await controller.setBirthday(picked);
      },
    );
  }
}

/// The app's language: "System" or one of the translations, each named in
/// its own language.
class _LanguageTile extends ConsumerWidget {
  const _LanguageTile();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final setting = ref.watch(settingsProvider.select((s) => s.language));
    final showing = ref.watch(appLanguageProvider);

    String label(AppLanguage language) => language == AppLanguage.system
        ? l10n.languageSystem
        : language.nativeName!;

    return ListTile(
      leading: const Icon(Icons.translate),
      title: Text(l10n.settingsLanguage),
      subtitle: Text(
        setting == AppLanguage.system
            ? l10n.languageSystemShowing(showing.nativeName!)
            : label(setting),
      ),
      onTap: () async {
        final picked = await showDialog<AppLanguage>(
          context: context,
          builder: (context) => SimpleDialog(
            title: Text(l10n.settingsLanguage),
            children: [
              RadioGroup<AppLanguage>(
                groupValue: setting,
                onChanged: (l) => Navigator.pop(context, l),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    for (final l in [
                      AppLanguage.system,
                      ...AppLanguage.translated,
                    ])
                      RadioListTile<AppLanguage>(
                        value: l,
                        title: Text(label(l)),
                      ),
                  ],
                ),
              ),
            ],
          ),
        );
        if (picked != null) {
          await ref.read(settingsProvider.notifier).setLanguage(picked);
        }
      },
    );
  }
}

/// Opens the privacy policy in the browser, in the app's language.
class _PrivacyPolicyTile extends ConsumerWidget {
  const _PrivacyPolicyTile();

  Future<void> _open(BuildContext context, AppLanguage language) async {
    final l10n = AppLocalizations.of(context);
    final messenger = ScaffoldMessenger.of(context);
    var opened = false;
    try {
      opened = await launchUrl(
        privacyPolicyUrl(language),
        mode: LaunchMode.externalApplication,
      );
    } on Exception catch (e) {
      debugPrint('Opening the privacy policy failed: $e');
    }
    if (!opened) {
      messenger.showSnackBar(
        SnackBar(
          content: Text(
            l10n.settingsPrivacyPolicyOpenFailed(privacyPolicyLabel(language)),
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final language = ref.watch(appLanguageProvider);
    return ListTile(
      leading: const Icon(Icons.privacy_tip_outlined),
      title: Text(l10n.settingsPrivacyPolicy),
      subtitle: Text(privacyPolicyLabel(language)),
      trailing: const Icon(Icons.open_in_new),
      onTap: () => _open(context, language),
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
