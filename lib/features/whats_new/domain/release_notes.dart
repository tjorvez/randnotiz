import 'package:flutter/material.dart';

import '../../../l10n/generated/app_localizations.dart';

/// A version name as built ("1.2.0" from pubspec.yaml), compared part by
/// part. Anything after the numbers ("-dev", "+3") is ignored.
@immutable
class AppVersion implements Comparable<AppVersion> {
  const AppVersion(this.major, this.minor, [this.patch = 0]);

  /// Null if [name] does not start with a number.
  static AppVersion? tryParse(String? name) {
    final match = RegExp(r'^\s*(\d+)(?:\.(\d+))?(?:\.(\d+))?')
        .firstMatch(name ?? '');
    if (match == null) return null;
    int part(int i) => int.parse(match.group(i) ?? '0');
    return AppVersion(part(1), part(2), part(3));
  }

  final int major;
  final int minor;
  final int patch;

  /// As shown to people: "1.2" for 1.2.0, "1.2.1" otherwise.
  String get label => patch == 0 ? '$major.$minor' : '$major.$minor.$patch';

  @override
  int compareTo(AppVersion other) {
    if (major != other.major) return major.compareTo(other.major);
    if (minor != other.minor) return minor.compareTo(other.minor);
    return patch.compareTo(other.patch);
  }

  bool operator >(AppVersion other) => compareTo(other) > 0;
  bool operator <=(AppVersion other) => compareTo(other) <= 0;

  @override
  bool operator ==(Object other) =>
      other is AppVersion && compareTo(other) == 0;

  @override
  int get hashCode => Object.hash(major, minor, patch);

  @override
  String toString() => '$major.$minor.$patch';
}

/// One new thing, in the app's language.
@immutable
class WhatsNewItem {
  const WhatsNewItem({
    required this.icon,
    required this.title,
    required this.body,
  });

  final IconData icon;
  final String Function(AppLocalizations l10n) title;
  final String Function(AppLocalizations l10n) body;
}

/// What a release brought, as told in the "Neu in Randnotiz" dialog.
@immutable
class ReleaseNotes {
  const ReleaseNotes({required this.version, required this.items});

  final AppVersion version;
  final List<WhatsNewItem> items;
}

/// Every release with something worth telling, newest first. Add an entry
/// (with texts in all four ARB files) when a release brings something people
/// should know about; releases without an entry show no dialog.
final List<ReleaseNotes> releaseNotes = [
  ReleaseNotes(
    version: const AppVersion(1, 3),
    items: [
      WhatsNewItem(
        icon: Icons.lock_outline,
        title: (l) => l.whatsNew130EncryptionTitle,
        body: (l) => l.whatsNew130EncryptionBody,
      ),
      WhatsNewItem(
        icon: Icons.cake_outlined,
        title: (l) => l.whatsNew130LifeShareTitle,
        body: (l) => l.whatsNew130LifeShareBody,
      ),
    ],
  ),
  ReleaseNotes(
    version: const AppVersion(1, 2),
    items: [
      WhatsNewItem(
        icon: Icons.calendar_month_outlined,
        title: (l) => l.whatsNew120CalendarTitle,
        body: (l) => l.whatsNew120CalendarBody,
      ),
      WhatsNewItem(
        icon: Icons.collections_bookmark_outlined,
        title: (l) => l.whatsNew120CollectionsTitle,
        body: (l) => l.whatsNew120CollectionsBody,
      ),
      WhatsNewItem(
        icon: Icons.draw_outlined,
        title: (l) => l.whatsNew120TitlesTitle,
        body: (l) => l.whatsNew120TitlesBody,
      ),
      WhatsNewItem(
        icon: Icons.auto_fix_high_outlined,
        title: (l) => l.whatsNew120PolishTitle,
        body: (l) => l.whatsNew120PolishBody,
      ),
    ],
  ),
];

/// The last version before the dialog existed. An installation that was
/// set up before then has never recorded a version – it updated from here.
const versionBeforeWhatsNew = AppVersion(1, 1);

/// The notes to show after updating from [seen] (null: from
/// [versionBeforeWhatsNew]) to [current]: every release after [seen] up to
/// and including [current], newest first.
List<ReleaseNotes> notesSince(
  AppVersion? seen,
  AppVersion current, {
  List<ReleaseNotes>? from,
}) {
  final since = seen ?? versionBeforeWhatsNew;
  return [
    for (final notes in from ?? releaseNotes)
      if (notes.version > since && notes.version <= current) notes,
  ]..sort((a, b) => b.version.compareTo(a.version));
}
