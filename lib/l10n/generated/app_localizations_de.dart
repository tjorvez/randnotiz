// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for German (`de`).
class AppLocalizationsDe extends AppLocalizations {
  AppLocalizationsDe([String locale = 'de']) : super(locale);

  @override
  String get appTitle => 'Randnotiz';

  @override
  String get navLibrary => 'Bibliothek';

  @override
  String get navJournal => 'Tagebuch';

  @override
  String get navMemories => 'Erinnerungen';

  @override
  String get settingsTooltip => 'Einstellungen';

  @override
  String get cancel => 'Abbrechen';

  @override
  String get delete => 'Löschen';

  @override
  String get save => 'Speichern';

  @override
  String get create => 'Anlegen';

  @override
  String get done => 'Fertig';

  @override
  String get ok => 'OK';

  @override
  String get openSystemSettings => 'Einstellungen öffnen';

  @override
  String get errorGeneric =>
      'Etwas ist schiefgelaufen. Bitte versuch es noch einmal.';

  @override
  String get libraryPermissionTitle => 'Deine Fotos, dein Tagebuch';

  @override
  String get libraryPermissionBody =>
      'Randnotiz zeigt die Fotos deiner Galerie, damit du zu jedem eine Notiz schreiben kannst. Die Fotos bleiben auf deinem Gerät und werden nirgendwohin hochgeladen.';

  @override
  String get libraryPermissionButton => 'Zugriff erlauben';

  @override
  String get libraryPermissionDeniedBody =>
      'Ohne Zugriff auf deine Fotos kann Randnotiz nichts anzeigen. Du kannst ihn jederzeit in den Einstellungen deines Handys erlauben.';

  @override
  String get libraryLimitedBanner =>
      'Randnotiz sieht nur die Fotos, die du ausgewählt hast.';

  @override
  String get libraryLimitedPickMore => 'Auswahl ändern';

  @override
  String get libraryLimitedAllowAll => 'Alle erlauben';

  @override
  String get libraryEmpty => 'In deiner Galerie sind noch keine Fotos.';

  @override
  String get libraryHasNote => 'Hat eine Notiz';

  @override
  String libraryPhotoOf(String date) {
    return 'Foto vom $date';
  }

  @override
  String get editorTitleNew => 'Neue Notiz';

  @override
  String get editorTitleEdit => 'Notiz';

  @override
  String get editorHint => 'Was war da los? Schreib es auf …';

  @override
  String get editorSaveFailed => 'Nicht gespeichert – neuer Versuch …';

  @override
  String get editorCleared =>
      'Notiz geleert – sie wird beim Schließen gelöscht.';

  @override
  String get editorUndoClear => 'Rückgängig';

  @override
  String get editorSaved => 'Gespeichert';

  @override
  String get editorSaving => 'Speichert …';

  @override
  String get editorDelete => 'Notiz löschen';

  @override
  String get editorDeleteConfirmTitle => 'Notiz löschen?';

  @override
  String get editorDeleteConfirmBody =>
      'Text, Tags und Wetter dieser Notiz werden entfernt. Das Foto in deiner Galerie bleibt unberührt.';

  @override
  String get editorPhotoMissing =>
      'Das Originalfoto ist nicht mehr in der Galerie. Die gespeicherte Kopie bleibt im Tagebuch.';

  @override
  String get editorDateTooltip => 'Datum ändern';

  @override
  String get editorEmptyDiscarded => 'Leere Notizen werden nicht gespeichert.';

  @override
  String weatherKind(String kind) {
    String _temp0 = intl.Intl.selectLogic(kind, {
      'clear': 'Sonnig',
      'partlyCloudy': 'Heiter bis wolkig',
      'cloudy': 'Bewölkt',
      'fog': 'Nebel',
      'drizzle': 'Nieselregen',
      'rain': 'Regen',
      'snow': 'Schnee',
      'thunderstorm': 'Gewitter',
      'other': 'Wetter',
    });
    return '$_temp0';
  }

  @override
  String weatherTemperature(String temperature) {
    return '$temperature °C';
  }

  @override
  String get weatherLoading => 'Wetter wird gesucht …';

  @override
  String get weatherAdd => 'Wetter';

  @override
  String get weatherFetchAgain => 'Erneut abrufen';

  @override
  String get weatherOffline =>
      'Das Wetter konnte nicht abgerufen werden. Vielleicht fehlt gerade die Internetverbindung.';

  @override
  String get weatherTemperatureLabel => 'Temperatur in °C (optional)';

  @override
  String get weatherRemove => 'Wetter entfernen';

  @override
  String get tagsAdd => 'Stimmung';

  @override
  String get tagsSheetTitle => 'Stimmungen';

  @override
  String get tagsCreateNew => 'Stimmung neu anlegen';

  @override
  String get tagNameLabel => 'Name der Stimmung';

  @override
  String get tagNameHint => 'z. B. Glücklich';

  @override
  String get tagDuplicate => 'Diese Stimmung gibt es schon.';

  @override
  String get tagNameEmpty => 'Bitte gib einen Namen ein.';

  @override
  String get tagsNone => 'Noch keine Stimmungen. Leg deine erste an.';

  @override
  String tagRemove(String name) {
    return 'Stimmung $name entfernen';
  }

  @override
  String get micStart => 'Diktieren';

  @override
  String get micStop => 'Diktat beenden';

  @override
  String get micListening => 'Ich höre zu …';

  @override
  String get micUnavailableTooltip => 'Diktat nicht verfügbar';

  @override
  String get micRationaleTitle => 'Notizen per Sprache';

  @override
  String get micRationaleBody =>
      'Damit du deine Notiz diktieren kannst, braucht Randnotiz Zugriff auf das Mikrofon. Es wird nichts aufgenommen oder gespeichert – nur der erkannte Text landet in deiner Notiz. Je nach Gerät erkennt dein Handy die Sprache selbst oder nutzt den Spracherkennungsdienst von Google.';

  @override
  String get micRationaleContinue => 'Weiter';

  @override
  String get micDenied =>
      'Ohne Mikrofon-Zugriff ist kein Diktat möglich. Du kannst natürlich weiter tippen.';

  @override
  String get micPermanentlyDeniedTitle => 'Mikrofon ist gesperrt';

  @override
  String get micPermanentlyDeniedBody =>
      'Du hast den Mikrofon-Zugriff abgelehnt. Wenn du diktieren möchtest, erlaube ihn in den App-Einstellungen.';

  @override
  String get micUnavailable =>
      'Auf diesem Gerät ist keine Spracherkennung verfügbar. Aktiviere z. B. „Speech Services by Google“ in den Systemeinstellungen.';

  @override
  String get dictationNoSpeech =>
      'Ich habe nichts verstanden. Tippe noch einmal aufs Mikrofon.';

  @override
  String get dictationNetwork =>
      'Die Spracherkennung braucht gerade eine Internetverbindung.';

  @override
  String get dictationBusy =>
      'Die Spracherkennung ist gerade beschäftigt. Versuch es gleich noch einmal.';

  @override
  String get dictationLanguage =>
      'Deutsch wird von der Spracherkennung dieses Geräts nicht unterstützt.';

  @override
  String get dictationAudio =>
      'Das Mikrofon ist gerade belegt, zum Beispiel durch einen Anruf. Dein Text ist erhalten.';

  @override
  String get dictationUnknown =>
      'Das Diktat wurde unterbrochen. Dein Text ist erhalten.';

  @override
  String get journalSearchHint => 'Notizen durchsuchen';

  @override
  String get journalEmptyTitle => 'Dein Tagebuch ist noch leer';

  @override
  String get journalEmptyBody =>
      'Tippe in der Bibliothek auf ein Foto und schreib deine erste Randnotiz.';

  @override
  String get journalNoResults => 'Dazu habe ich nichts gefunden.';

  @override
  String journalResultCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Notizen',
      one: '1 Notiz',
    );
    return '$_temp0';
  }

  @override
  String get journalClearFilter => 'Filter zurücksetzen';

  @override
  String get journalClearSearch => 'Suche leeren';

  @override
  String yearsAgo(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Vor $count Jahren',
      one: 'Vor 1 Jahr',
    );
    return '$_temp0';
  }

  @override
  String monthsAgo(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Vor $count Monaten',
      one: 'Vor 1 Monat',
    );
    return '$_temp0';
  }

  @override
  String weeksAgo(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Vor $count Wochen',
      one: 'Vor 1 Woche',
    );
    return '$_temp0';
  }

  @override
  String daysAgo(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Vor $count Tagen',
      one: 'Gestern',
      zero: 'Heute',
    );
    return '$_temp0';
  }

  @override
  String get memoriesEmptyTitle => 'Noch keine Erinnerungen';

  @override
  String get memoriesEmptyBody =>
      'Sobald du Notizen schreibst, tauchen sie hier an ihren Jahrestagen wieder auf.';

  @override
  String get lockTitle => 'Randnotiz ist gesperrt';

  @override
  String get lockBody =>
      'Entsperre mit Fingerabdruck, Gesicht oder deiner Displaysperre.';

  @override
  String get lockButton => 'Entsperren';

  @override
  String get lockReason => 'Randnotiz entsperren';

  @override
  String get lockLockedOut =>
      'Zu viele Versuche. Bitte warte einen Moment und versuch es dann erneut.';

  @override
  String get lockFailed => 'Entsperren hat nicht geklappt.';

  @override
  String get settingsTitle => 'Einstellungen';

  @override
  String get settingsSectionAppearance => 'Darstellung';

  @override
  String get settingsTheme => 'Design';

  @override
  String get themeSystem => 'System';

  @override
  String get themeLight => 'Hell';

  @override
  String get themeDark => 'Dunkel';

  @override
  String get settingsSectionPrivacy => 'Privatsphäre';

  @override
  String get settingsLock => 'Sperre mit Biometrie';

  @override
  String get settingsLockSubtitle =>
      'Fingerabdruck, Gesicht oder Displaysperre beim Öffnen. Solange die Sperre an ist, sind Screenshots und Bildschirmübertragung blockiert.';

  @override
  String get settingsLockUnavailable =>
      'Richte zuerst eine Displaysperre auf deinem Gerät ein.';

  @override
  String get settingsLockTimeout => 'Sperren nach';

  @override
  String get lockTimeoutImmediately => 'Sofort';

  @override
  String lockTimeoutMinutes(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Minuten im Hintergrund',
      one: '1 Minute im Hintergrund',
    );
    return '$_temp0';
  }

  @override
  String get settingsSectionTags => 'Stimmungen';

  @override
  String get settingsManageTags => 'Stimmungen verwalten';

  @override
  String get settingsSectionWidget => 'Widget';

  @override
  String get settingsWidgetText => 'Textvorschau im Widget';

  @override
  String get settingsWidgetTextSubtitle =>
      'Zeigt den Anfang der Notiz auf dem Startbildschirm – sichtbar für alle, die dein Handy sehen.';

  @override
  String get settingsSectionBackup => 'Sicherung';

  @override
  String get settingsBackupDrive => 'Sicherung in Google Drive';

  @override
  String get settingsBackupOff =>
      'Aus – deine Notizen sind nur auf diesem Gerät';

  @override
  String get settingsBackupUnavailable => 'In dieser Version nicht verfügbar';

  @override
  String get settingsBackupNeedsSetup =>
      'Verbunden – Backup-Passwort festlegen';

  @override
  String get settingsBackupNeedsUnlock =>
      'Sicherung gefunden – zum Entsperren tippen';

  @override
  String get settingsBackupRestorePending =>
      'Pausiert – Sicherung noch nicht übernommen';

  @override
  String get settingsBackupNever =>
      'Verschlüsselt eingeschaltet – noch keine Sicherung';

  @override
  String settingsBackupLast(String when) {
    return 'Zuletzt gesichert: $when';
  }

  @override
  String get settingsBackupRunning => 'Wird gesichert …';

  @override
  String get backupTitle => 'Sicherung in Google Drive';

  @override
  String get backupIntro =>
      'Randnotiz sichert deine Notizen, Stimmungen, Sammlungen und verkleinerte Fotos in einem versteckten App-Ordner deines Google-Drive-Kontos. Alles wird vorher auf diesem Gerät verschlüsselt: Google sieht nur unlesbare Daten, nicht deine Einträge.';

  @override
  String get backupConnect => 'Mit Google verbinden';

  @override
  String get backupConnectFailed =>
      'Die Verbindung mit Google hat nicht geklappt.';

  @override
  String get backupAccount => 'Google-Konto';

  @override
  String get backupSetupIntro =>
      'Lege ein Backup-Passwort fest. Damit kannst du die Sicherung auf einem neuen Gerät öffnen. Es verlässt dieses Gerät nie und ist nicht dein Google-Passwort.';

  @override
  String get backupSetupButton => 'Backup-Passwort festlegen';

  @override
  String get backupPasswordTitle => 'Backup-Passwort';

  @override
  String get backupPasswordNewTitle => 'Neues Backup-Passwort';

  @override
  String get backupPasswordLabel => 'Passwort';

  @override
  String get backupPasswordRepeat => 'Passwort wiederholen';

  @override
  String backupPasswordTooShort(int count) {
    return 'Mindestens $count Zeichen';
  }

  @override
  String get backupPasswordMismatch => 'Die Passwörter stimmen nicht überein';

  @override
  String get backupPasswordHint =>
      'Gut merkbar, aber nicht zu erraten – z. B. ein kurzer Satz. Ohne Passwort und ohne Notfallschlüssel lässt sich die Sicherung von niemandem öffnen, auch nicht von uns.';

  @override
  String get backupWorking => 'Einen Moment …';

  @override
  String get backupEmergencyTitle => 'Dein Notfallschlüssel';

  @override
  String get backupEmergencyIntro =>
      'Falls du das Backup-Passwort vergisst, öffnet dieser Schlüssel deine Sicherung. Schreib ihn auf und bewahre ihn sicher auf – er wird nur jetzt angezeigt.';

  @override
  String get backupEmergencyCopy => 'Kopieren';

  @override
  String get backupEmergencyCopied => 'Notfallschlüssel kopiert';

  @override
  String get backupEmergencyConfirm =>
      'Ich habe den Notfallschlüssel sicher notiert';

  @override
  String get backupEmergencyDone => 'Fertig';

  @override
  String get backupUnlockIntro =>
      'Auf deinem Google-Konto liegt eine verschlüsselte Sicherung. Gib das Backup-Passwort oder den Notfallschlüssel ein, um sie auf diesem Gerät zu öffnen.';

  @override
  String backupUnlockFoundAt(String when) {
    return 'Letzte Sicherung: $when';
  }

  @override
  String get backupUnlockLabel => 'Passwort oder Notfallschlüssel';

  @override
  String get backupUnlockButton => 'Entsperren';

  @override
  String get backupUnlockWrong =>
      'Das passt nicht. Prüfe Passwort bzw. Notfallschlüssel.';

  @override
  String get backupRestoreAskTitle => 'Notizen wiederherstellen?';

  @override
  String get backupRestoreAskBody =>
      'Die Einträge aus der Sicherung werden zu diesem Gerät hinzugefügt. Was hier neuer ist, bleibt unverändert.';

  @override
  String get backupRestoreLater => 'Später';

  @override
  String get backupRestore => 'Wiederherstellen';

  @override
  String backupRestoreDone(int added) {
    String _temp0 = intl.Intl.pluralLogic(
      added,
      locale: localeName,
      other: '$added Einträge wiederhergestellt',
      one: '1 Eintrag wiederhergestellt',
      zero: 'Keine neuen Einträge',
    );
    return '$_temp0';
  }

  @override
  String backupRestoreUpdated(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Einträge aktualisiert',
      one: '1 Eintrag aktualisiert',
    );
    return '$_temp0';
  }

  @override
  String get backupNow => 'Jetzt sichern';

  @override
  String get backupDone => 'Gesichert';

  @override
  String get backupUnchanged => 'Schon aktuell – nichts zu sichern';

  @override
  String get backupStatusNever => 'Noch keine Sicherung.';

  @override
  String backupStatusLast(String when) {
    return 'Zuletzt gesichert: $when';
  }

  @override
  String backupStatusCounts(int notes, int photos) {
    String _temp0 = intl.Intl.pluralLogic(
      notes,
      locale: localeName,
      other: '$notes Einträge',
      one: '1 Eintrag',
    );
    String _temp1 = intl.Intl.pluralLogic(
      photos,
      locale: localeName,
      other: '$photos Bilder',
      one: '1 Bild',
    );
    return '$_temp0 · $_temp1';
  }

  @override
  String get backupStatusAuto =>
      'Gesichert wird automatisch einmal am Tag, wenn du die App öffnest.';

  @override
  String get backupStatusPending => 'Sicherung noch nicht übernommen';

  @override
  String get backupStatusPendingHint =>
      'Die automatische Sicherung pausiert, bis die Einträge aus deiner Sicherung auch auf diesem Gerät sind – damit nichts überschrieben wird. „Wiederherstellen“ oder „Jetzt sichern“ holt sie hierher.';

  @override
  String get backupProblemOffline =>
      'Keine Verbindung zu Google Drive – es wird später erneut versucht.';

  @override
  String get backupProblemAuth =>
      'Google hat den Zugriff verweigert. Bitte verbinde dich erneut.';

  @override
  String get backupProblemQuota => 'Dein Google-Drive-Speicher ist voll.';

  @override
  String get backupProblemDamaged =>
      'Die Sicherung in Google Drive ist beschädigt oder gehört zu einem anderen Schlüssel.';

  @override
  String get backupProblemUnknown => 'Die Sicherung hat nicht geklappt.';

  @override
  String get backupReconnect => 'Erneut verbinden';

  @override
  String get backupChangePassword => 'Backup-Passwort ändern';

  @override
  String get backupPasswordChanged => 'Backup-Passwort geändert';

  @override
  String get backupRenewEmergency => 'Neuen Notfallschlüssel erstellen';

  @override
  String get backupRenewEmergencyAsk =>
      'Der bisherige Notfallschlüssel funktioniert danach nicht mehr.';

  @override
  String get backupRenewEmergencyButton => 'Neu erstellen';

  @override
  String get backupDisconnect => 'Abmelden';

  @override
  String get backupDisconnectTitle => 'Von Google Drive abmelden?';

  @override
  String get backupDisconnectBody =>
      'Auf diesem Gerät wird nicht mehr gesichert. Deine Notizen hier bleiben erhalten.';

  @override
  String get backupDisconnectDelete =>
      'Auch die Sicherung in Google Drive löschen';

  @override
  String get backupPrivacyNote =>
      'Ende-zu-Ende-verschlüsselt (AES-256). Schlüssel: dein Backup-Passwort bzw. der Notfallschlüssel – beide kennt nur du.';

  @override
  String get settingsSectionAbout => 'Über';

  @override
  String get settingsAbout => 'Über Randnotiz';

  @override
  String get settingsAboutLegalese =>
      'Ein privates Foto-Tagebuch. Deine Notizen bleiben auf deinem Gerät.\n\nKartendaten: Natural Earth (gemeinfrei). Orte: GeoNames (CC BY 4.0). Details unter „Lizenzen“.';

  @override
  String get tagManageTitle => 'Stimmungen verwalten';

  @override
  String tagDeleteConfirmTitle(String name) {
    return 'Stimmung „$name“ löschen?';
  }

  @override
  String tagDeleteConfirmBody(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other:
          'Sie wird von $count Notizen entfernt. Die Notizen selbst bleiben erhalten.',
      one: 'Sie wird von 1 Notiz entfernt. Die Notiz selbst bleibt erhalten.',
      zero: 'Sie wird noch nirgends verwendet.',
    );
    return '$_temp0';
  }

  @override
  String tagUsage(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Notizen',
      one: '1 Notiz',
      zero: 'Nicht verwendet',
    );
    return '$_temp0';
  }

  @override
  String get tagEdit => 'Stimmung bearbeiten';

  @override
  String get libraryPickExternal => 'Google Fotos';

  @override
  String get libraryPickExternalTooltip =>
      'Foto aus Google Fotos oder einer anderen Quelle wählen';

  @override
  String get libraryImporting => 'Foto wird übernommen …';

  @override
  String get libraryImportFailed => 'Das Foto konnte nicht übernommen werden.';

  @override
  String get placeAdd => 'Ort';

  @override
  String get placeSheetTitle => 'Land und Ort';

  @override
  String get placeSearchHint => 'Ort suchen, z. B. Hamburg';

  @override
  String get placeNoResults => 'Kein Ort gefunden.';

  @override
  String get placePrivacy =>
      'Gespeichert werden nur Land und Ortsname – nie der GPS-Standort deines Fotos. Fotos mit Standort bekommen beides automatisch, ganz ohne Internet. Für das Wetter wird der ungefähre Ort an den Wetterdienst gesendet.';

  @override
  String get placeRemove => 'Entfernen';

  @override
  String get placeWeatherHint =>
      'Mit einem Ort zeigt Randnotiz auch das Wetter an diesem Tag.';

  @override
  String get weatherAdjust => 'Wetter selbst anpassen';

  @override
  String get editorMetaMood => 'Stimmung';

  @override
  String get navCollections => 'Sammlungen';

  @override
  String get collectionAddShort => 'Sammlung';

  @override
  String get collectionPickerTitle => 'Sammlungen';

  @override
  String get collectionPickerHint =>
      'Sammle Einträge, die zusammengehören – eine Reise, einen Sommer, einen Menschen.';

  @override
  String get collectionNew => 'Neue Sammlung';

  @override
  String get collectionNameLabel => 'Name';

  @override
  String get collectionNameHint => 'z. B. Italien 2024';

  @override
  String get collectionRename => 'Umbenennen';

  @override
  String get collectionDelete => 'Sammlung löschen';

  @override
  String get collectionDeleteConfirmTitle => 'Sammlung löschen?';

  @override
  String collectionDeleteConfirmBody(String name) {
    return '„$name“ wird gelöscht. Die Einträge selbst bleiben im Tagebuch erhalten.';
  }

  @override
  String collectionEntryCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Einträge',
      one: '1 Eintrag',
      zero: 'Noch leer',
    );
    return '$_temp0';
  }

  @override
  String get collectionsReorderHint =>
      'Gedrückt halten und ziehen zum Sortieren';

  @override
  String get collectionMoveEarlier => 'Nach vorne verschieben';

  @override
  String get collectionMoveLater => 'Nach hinten verschieben';

  @override
  String get collectionsEmptyTitle => 'Noch keine Sammlungen';

  @override
  String get collectionsEmptyBody =>
      'Fasse Einträge zusammen, die zusammengehören – eine Reise, einen Sommer, einen Menschen.';

  @override
  String get collectionEmptyBody =>
      'Füge Einträge hinzu – hier oder direkt in einer Notiz über „Sammlung“.';

  @override
  String get collectionAddEntries => 'Einträge hinzufügen';

  @override
  String get collectionAddEntriesNone =>
      'Alle Einträge sind schon in dieser Sammlung.';

  @override
  String collectionAddSelected(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Einträge hinzufügen',
      one: '1 Eintrag hinzufügen',
      zero: 'Hinzufügen',
    );
    return '$_temp0';
  }

  @override
  String get collectionRemoveEntry => 'Aus der Sammlung entfernen';

  @override
  String collectionNeighboursTitle(String name, int position, int total) {
    return '$name · $position von $total';
  }

  @override
  String get collectionPrevious => 'Vorheriger';

  @override
  String get collectionNext => 'Nächster';

  @override
  String get collectionStart => 'Hier beginnt die Sammlung';

  @override
  String get collectionEnd => 'Hier endet die Sammlung';

  @override
  String mapEntriesCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Einträge',
      one: '1 Eintrag',
    );
    return '$_temp0';
  }

  @override
  String get mapShowAll => 'Alle Einträge zeigen';

  @override
  String get mapEmptyTitle => 'Noch nichts auf der Karte';

  @override
  String get mapEmptyBody =>
      'Länder mit Einträgen werden hier eingefärbt. Fotos mit Standort bekommen ihr Land automatisch, sonst über „Ort“ im Eintrag.';

  @override
  String get mapEmptyNoNotes =>
      'Sobald du Notizen schreibst, färben sich hier die Länder, in denen du warst.';

  @override
  String get editorTitleHint => 'Titel';

  @override
  String get editorTitleLabel => 'Titel des Eintrags';

  @override
  String get emojiPickerTitle => 'Emoji wählen';

  @override
  String get emojiSearchHint => 'Emoji suchen';

  @override
  String get emojiNoRecents =>
      'Hier erscheinen die Emojis, die du zuletzt gewählt hast.';

  @override
  String get emojiCurrent => 'Aktuelles Emoji';

  @override
  String get emojiChange => 'Emoji ändern';

  @override
  String get memoriesSectionOnThisDay => 'An diesem Tag';

  @override
  String get memoriesSectionAround => 'Rund um diesen Tag';

  @override
  String get memoriesSectionMore => 'Weitere Erinnerungen';

  @override
  String memoriesAnniversaryIn(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Jahrestag in $count Tagen',
      one: 'Jahrestag morgen',
    );
    return '$_temp0';
  }

  @override
  String memoriesAnniversaryAgo(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Jahrestag vor $count Tagen',
      one: 'Jahrestag war gestern',
    );
    return '$_temp0';
  }

  @override
  String get memoriesOpen => 'Eintrag öffnen';

  @override
  String get memoriesSwipeHint => 'Nach oben wischen für mehr';

  @override
  String get journalRemoveFilter => 'Filter entfernen';

  @override
  String get suggestionsTags => 'Stimmungen';

  @override
  String get suggestionsPlaces => 'Orte';

  @override
  String get suggestionsCountries => 'Länder';

  @override
  String get suggestionsRecent => 'Frühere Suchen';

  @override
  String get suggestionsClearRecent => 'Alle löschen';

  @override
  String get suggestionsRemoveRecent => 'Aus den früheren Suchen löschen';

  @override
  String geoBackfillProgress(int done, int total) {
    return 'Orte und Länder werden ergänzt … $done von $total';
  }

  @override
  String get mapTitle => 'Weltkarte';

  @override
  String get mapOpen => 'Weltkarte öffnen';

  @override
  String get mapShowBorders => 'Ländergrenzen zeigen';

  @override
  String get mapHideBorders => 'Ländergrenzen ausblenden';

  @override
  String mapCountriesCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Länder',
      one: '1 Land',
    );
    return '$_temp0';
  }

  @override
  String mapNoEntriesIn(String country) {
    return 'Noch keine Einträge in $country';
  }

  @override
  String get countryLabel => 'Land';

  @override
  String get countryNone => 'Kein Land';

  @override
  String get countryAdd => 'Wählen';

  @override
  String get countryChange => 'Ändern';

  @override
  String get countryRemove => 'Land entfernen';

  @override
  String get countryPickerTitle => 'Land wählen';

  @override
  String get countryPickerSearch => 'Land suchen (deutsch oder englisch)';

  @override
  String get settingsSectionPlaces => 'Orte und Länder';

  @override
  String get settingsGeoBackfill => 'Orte und Länder aus Fotos ergänzen';

  @override
  String get settingsGeoBackfillIdle =>
      'Für ältere Einträge: Land und nächster Ort aus dem Fotostandort, offline.';

  @override
  String get settingsGeoBackfillDone =>
      'Erledigt – du kannst den Abgleich jederzeit erneut starten.';

  @override
  String get settingsGeoBackfillCancelled =>
      'Abgebrochen – tippe, um weiterzumachen.';

  @override
  String settingsGeoBackfillRunning(int done, int total) {
    return '$done von $total – tippe zum Abbrechen';
  }

  @override
  String get songAdd => 'Lied hinzufügen';

  @override
  String get songSheetTitle => 'Lied zum Eintrag';

  @override
  String get songSearchHint => 'Titel oder Künstler suchen';

  @override
  String get songNoResults => 'Nichts gefunden.';

  @override
  String get songSearchSource => 'Musik von Spotify';

  @override
  String get songRemove => 'Lied entfernen';

  @override
  String get songChange => 'Lied ändern';

  @override
  String get songPlay => 'Abspielen';

  @override
  String get songPause => 'Pausieren';

  @override
  String get songOpenInSpotify => 'In Spotify öffnen';

  @override
  String songRecordLabel(String title, String artist) {
    return 'Lied: $title von $artist';
  }

  @override
  String songOf(String title, String artist) {
    return '$title · $artist';
  }

  @override
  String get songErrorNotInstalled =>
      'Dafür braucht es die Spotify-App auf diesem Gerät.';

  @override
  String get songErrorNotLoggedIn =>
      'Bitte melde dich zuerst in der Spotify-App an.';

  @override
  String get songErrorNotAuthorized => 'Spotify hat den Zugriff nicht erlaubt.';

  @override
  String get songErrorCancelled => 'Anmeldung bei Spotify abgebrochen.';

  @override
  String get songErrorNetwork => 'Keine Verbindung zu Spotify.';

  @override
  String get songErrorPlayback =>
      'Spotify konnte das Lied gerade nicht abspielen.';

  @override
  String get journalHasSong => 'Mit Lied';

  @override
  String get songErrorSearch => 'Die Suche bei Spotify hat nicht geklappt.';

  @override
  String get songErrorForbidden =>
      'Spotify lässt die Suche nicht zu. Ist dein Spotify-Konto im Developer Dashboard unter „User Management“ eingetragen?';

  @override
  String get songErrorRateLimit =>
      'Spotify bremst gerade. Bitte gleich noch einmal versuchen.';

  @override
  String get introSkip => 'Überspringen';

  @override
  String get introNext => 'Weiter';

  @override
  String introPageLabel(int page, int count) {
    return 'Seite $page von $count';
  }

  @override
  String get introPrivateCaption => 'nur für dich';

  @override
  String get introPrivateTitle => 'Deine Gedanken gehören nur dir.';

  @override
  String get introPrivateBody =>
      'Randnotiz ist ein stilles Erinnerungsbuch zu deinen Fotos. Was du schreibst, liegt auf diesem Gerät – ohne Konto, ohne Server von uns, ohne Werbung und ohne Tracking.';

  @override
  String get introLockCaption => 'gut verschlossen';

  @override
  String get introLockTitle => 'Dein Tagebuch ist verschlossen.';

  @override
  String get introLockBody =>
      'Hat dein Gerät eine Displaysperre, öffnet sich Randnotiz nur mit Fingerabdruck, Gesicht oder PIN – das ist von Anfang an so eingestellt. Solange die Sperre an ist, gibt es keine Screenshots und keine Vorschau in der App-Übersicht.';

  @override
  String get introLockDebug =>
      'In dieser Entwicklungsversion sind Screenshots trotzdem möglich.';

  @override
  String get introLockWidget =>
      'Legst du das Widget auf den Startbildschirm, zeigt es dort ein Foto aus deinem Tagebuch – auch wenn die App gesperrt ist.';

  @override
  String get introBackupCaption => 'sicher verwahrt';

  @override
  String get introBackupTitle => 'Eine Sicherung nur für dich.';

  @override
  String get introBackupBody =>
      'Wenn du möchtest, sichert Randnotiz deine Einträge im versteckten App-Ordner deines eigenen Google Drive – vorher auf diesem Gerät Ende-zu-Ende-verschlüsselt. Den Schlüssel hast nur du: dein Backup-Passwort und den Notfallschlüssel. Ohne Passwort und ohne Notfallschlüssel kann niemand die Sicherung öffnen – auch nicht Google oder wir, die Entwickler. Bewahre beides gut auf.';

  @override
  String get introOnlineTitle => 'Wann Randnotiz ins Internet geht';

  @override
  String get introOnlineBody =>
      'Wetter und Ortssuche fragen Open-Meteo – mit einer auf etwa 1 km gerundeten Position bzw. deinem Suchbegriff. Beim Diktieren hört je nach Gerät die Spracherkennung von Google zu; wer das nicht möchte, tippt einfach. Wenn du ein Lied verknüpfst, wird bei Spotify gesucht. Was du tippst, und deine Fotos verlassen das Gerät nur verschlüsselt – in deiner Sicherung.';

  @override
  String get introSetUpBackup => 'Sicherung einrichten';

  @override
  String get introHaveBackup => 'Ich habe schon eine Sicherung';

  @override
  String get introLater => 'Später';

  @override
  String get introStart => 'Los geht’s';

  @override
  String get introBackupUnavailable =>
      'In dieser Version ist die Sicherung nicht verfügbar.';

  @override
  String get settingsIntro => 'Einführung ansehen';

  @override
  String get settingsIntroSubtitle => 'Was Randnotiz mit deinen Daten macht';

  @override
  String get backupRestoreGuide =>
      'Du hast schon eine Sicherung? Verbinde dasselbe Google-Konto wie auf deinem bisherigen Gerät. Danach gibst du dein Backup-Passwort oder den Notfallschlüssel ein und holst deine Einträge zurück.';

  @override
  String get backupRestoreNoBackup =>
      'In diesem Google-Konto liegt keine Sicherung von Randnotiz. Liegt sie in einem anderen Konto, melde dich ab und verbinde das richtige.';

  @override
  String get backupDevBanner =>
      'Test-App – teilt die Sicherung mit der echten App. Was du hier einrichtest, sicherst oder löschst, betrifft dieselbe Sicherung in Google Drive.';

  @override
  String get backupDevConfirmTitle => 'Wirklich in der Test-App?';

  @override
  String get backupDevConfirmAuto =>
      'Danach sichert die Test-App automatisch in denselben Drive-Ordner wie die echte App – Testeinträge landen dann auch in deren Sicherung.';

  @override
  String get backupDevConfirmDelete =>
      'Das löscht auch die Sicherung der echten App, denn beide nutzen denselben Drive-Ordner. Das lässt sich nicht rückgängig machen.';

  @override
  String get backupDevConfirmContinue => 'Trotzdem fortfahren';

  @override
  String get backupDevConfirmDeleteButton => 'Trotzdem löschen';
}
