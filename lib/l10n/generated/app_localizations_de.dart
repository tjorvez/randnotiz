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
  String get claim =>
      'Schreib deine eigene Geschichte – statt nur durch fremde zu swipen.';

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
      'Text, Tags und Wetter dieser Notiz und die Kopie des Fotos in Randnotiz werden entfernt. Das Foto in deiner Galerie bzw. in Google Fotos bleibt unberührt.';

  @override
  String get editorPhotoMissing =>
      'Das Foto in voller Größe fehlt. Die gespeicherte Vorschau bleibt im Tagebuch.';

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
      'Tippe unten auf das Foto mit dem Plus, wähle ein Bild aus deiner Galerie oder aus Google Fotos und schreib deine erste Randnotiz.';

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
  String get settingsLanguage => 'Sprache';

  @override
  String get languageSystem => 'Gerätesprache';

  @override
  String languageSystemShowing(String language) {
    return 'Gerätesprache ($language)';
  }

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
  String get settingsSectionMemories => 'Erinnerungen';

  @override
  String get settingsBirthday => 'Geburtstag';

  @override
  String get settingsBirthdayNotSet =>
      'Optional – zeigt bei Erinnerungen, wie viel deines bisherigen Lebens damals schon hinter dir lag. Bleibt auf dem Gerät.';

  @override
  String get settingsBirthdayRemove => 'Geburtstag entfernen';

  @override
  String lifeShare(String percent) {
    return '$percent deines Lebens';
  }

  @override
  String get lostNotesTitle => 'Deine Notizen ließen sich nicht öffnen';

  @override
  String get lostNotesBody =>
      'Der Schlüssel zu deinen Notizen ist auf diesem Gerät verloren gegangen – das passiert selten, etwa wenn Android seinen geschützten Speicher zurücksetzt. Randnotiz hat deshalb ein neues, leeres Tagebuch angelegt. Deine Fotos sind noch da. Wenn du eine Sicherung in Google Drive hast, holst du deine Einträge damit zurück.';

  @override
  String get lostNotesRestore => 'Sicherung wiederherstellen';

  @override
  String get lostNotesLater => 'Nicht jetzt';

  @override
  String get lostNotesMeanwhile =>
      'Bis du dich entscheidest, behält Randnotiz alle deine Fotos und pausiert die automatische Sicherung, damit deine bisherige Sicherung nicht ersetzt wird.';

  @override
  String get lostNotesStartOver => 'Ohne weitermachen';

  @override
  String get backupLostNotesTitle => 'Bisherige Sicherung ersetzen?';

  @override
  String get backupLostNotesBody =>
      'Deine Notizen ließen sich zuletzt nicht öffnen. Sicherst du jetzt, ersetzt das neue, fast leere Tagebuch nach und nach deine bisherige Sicherung. Stell sie besser zuerst wieder her.';

  @override
  String get backupLostNotesConfirm => 'Trotzdem sichern';

  @override
  String get databaseUnavailableTitle =>
      'Deine Notizen lassen sich gerade nicht öffnen';

  @override
  String get databaseUnavailableBody =>
      'Android gibt den Schlüssel zu deinen Notizen im Moment nicht heraus. Es ist nichts verloren. Versuch es gleich noch einmal oder starte dein Handy neu.';

  @override
  String get databaseUnavailableRetry => 'Erneut versuchen';

  @override
  String get widgetTitle => 'Erinnerung des Tages';

  @override
  String get widgetEmpty => 'Heute noch keine Erinnerung – öffne Randnotiz.';

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
      'Verschlüsselt in deinem Google Drive – Google sieht nur unlesbare Daten.';

  @override
  String get backupConnect => 'Mit Google verbinden';

  @override
  String get backupConnectFailed =>
      'Die Verbindung mit Google hat nicht geklappt.';

  @override
  String get backupAccount => 'Google-Konto';

  @override
  String get backupSetupIntro =>
      'Mit dem Backup-Passwort öffnest du die Sicherung auf einem neuen Gerät. Es ist nicht dein Google-Passwort.';

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
  String get settingsSectionAbout => 'Über';

  @override
  String get settingsAbout => 'Über Randnotiz';

  @override
  String get settingsPrivacyPolicy => 'Datenschutzerklärung';

  @override
  String settingsPrivacyPolicyOpenFailed(String url) {
    return 'Der Link konnte nicht geöffnet werden: $url';
  }

  @override
  String settingsAboutLegalese(String url, String copyright, String source) {
    return 'Ein privates Foto-Tagebuch. Deine Notizen bleiben auf deinem Gerät.\n\nDatenschutz: $url\n\n$copyright. Freie Software unter der GNU General Public License v3 oder später, ohne jede Gewährleistung. Quellcode: $source\n\nKartendaten: Natural Earth (gemeinfrei). Orte: GeoNames (CC BY 4.0). Liedsuche, Cover und Hörproben: Apple (iTunes Search API). Details unter „Lizenzen“.';
  }

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
  String get newEntryTooltip => 'Neuer Eintrag – Foto auswählen';

  @override
  String get newEntryImporting => 'Foto wird übernommen …';

  @override
  String get newEntryImportFailed => 'Das Foto konnte nicht übernommen werden.';

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
      'Gespeichert werden nur Land und Ortsname. Für das Wetter wird der ungefähre Ort an den Wetterdienst gesendet.';

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
      'Länder mit Einträgen werden hier eingefärbt. Das Land bekommt ein Eintrag über „Ort“.';

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
  String get countryPickerSearch => 'Land suchen';

  @override
  String get introSkip => 'Überspringen';

  @override
  String get introNext => 'Weiter';

  @override
  String introPageLabel(int page, int count) {
    return 'Seite $page von $count';
  }

  @override
  String get introWelcome => 'Willkommen bei Randnotiz';

  @override
  String get introWelcomeBody =>
      'Ein stilles Fototagebuch für die Geschichten hinter deinen Bildern.';

  @override
  String get introLanguageTitle => 'Deine Sprache';

  @override
  String get introCloudCaption => 'nur für dich';

  @override
  String get introCloudTitle => 'Dein Tagebuch bleibt deins.';

  @override
  String get introCloudBody =>
      'Was du schreibst, bleibt auf diesem Gerät – ohne Konto, ohne Server von uns, ohne Werbung und ohne Tracking. Wenn du möchtest, sichert Randnotiz deine Einträge im versteckten App-Ordner deines eigenen Google Drive – vorher auf diesem Gerät Ende-zu-Ende-verschlüsselt.';

  @override
  String get introCloudKeys =>
      'Den Schlüssel hast nur du: dein Backup-Passwort und den Notfallschlüssel. Ohne sie kann niemand die Sicherung öffnen – auch nicht Google oder wir, die Entwickler. Bewahre beides gut auf.';

  @override
  String get introCloudQuestion => 'In deinem Google Drive sichern?';

  @override
  String get introCloudAfterTour =>
      'Eingerichtet wird direkt nach einer kurzen Tour.';

  @override
  String get introNoCloud => 'Ohne Sicherung weiter';

  @override
  String get introOnlineTitle => 'Wann Randnotiz ins Internet geht';

  @override
  String get introOnlineBody =>
      'Wetter und Ortssuche fragen Open-Meteo – mit einer auf etwa 1 km gerundeten Position bzw. deinem Suchbegriff. Suchst du ein Lied für einen Eintrag, geht der Suchbegriff an Apple. Beim Diktieren hört je nach Gerät die Spracherkennung von Google zu; wer das nicht möchte, tippt einfach. Was du tippst, und deine Fotos verlassen das Gerät nur verschlüsselt – in deiner Sicherung.';

  @override
  String get introSetUpBackup => 'Sicherung einrichten';

  @override
  String get introHaveBackup => 'Ich habe schon eine Sicherung';

  @override
  String get introBackupUnavailable =>
      'In dieser Version ist die Sicherung nicht verfügbar.';

  @override
  String get introPhotoCaption => 'ein Foto';

  @override
  String get introPhotoTitle => 'Ein Foto, eine Geschichte.';

  @override
  String get introPhotoBody =>
      'Tippe unten auf das Foto mit dem Plus und wähle ein Bild – vom Handy oder aus Google Fotos. Randnotiz braucht dafür keinen Zugriff auf deine Galerie.';

  @override
  String get introWriteCaption => 'am Rand';

  @override
  String get introWriteTitle => 'Schreib auf, wie es war.';

  @override
  String get introWriteBody =>
      'Wer war dabei? Worüber habt ihr gelacht? Schreib oder diktiere ein paar Zeilen an den Rand – alles speichert sich von selbst. Ort, Wetter, Stimmung oder das Lied des Tages legst du dazu, wenn du magst.';

  @override
  String get introJournalCaption => 'dein Tagebuch';

  @override
  String get introJournalTitle => 'Seite für Seite dein Tagebuch.';

  @override
  String get introJournalBody =>
      'Deine Einträge sammeln sich wie Seiten in einem Heft. Such nach Worten, Orten oder Stimmungen, bündle Reisen in Sammlungen und sieh zu, wie sich deine Weltkarte färbt.';

  @override
  String get introMemoriesCaption => 'vor einem Jahr';

  @override
  String get introMemoriesTitle => 'Deine Momente kommen zurück.';

  @override
  String get introMemoriesBody =>
      'Am Jahrestag spielt dir Randnotiz deinen Moment wieder zu – in der App und, wenn du magst, als Widget auf dem Startbildschirm.';

  @override
  String get introLock =>
      'Hat dein Gerät eine Displaysperre, öffnet sich Randnotiz nur mit Fingerabdruck, Gesicht oder PIN – das ist von Anfang an so eingestellt. Solange die Sperre an ist, gibt es keine Screenshots und keine Vorschau in der App-Übersicht. Das Widget zeigt trotzdem ein Foto aus deinem Tagebuch.';

  @override
  String get introLockDebug =>
      'In dieser Entwicklungsversion sind Screenshots trotzdem möglich.';

  @override
  String get introStart => 'Los geht’s';

  @override
  String get introStartBackup => 'Weiter zur Sicherung';

  @override
  String get introStartRestore => 'Weiter zur Wiederherstellung';

  @override
  String get introDemoTitle => 'Picknick am See';

  @override
  String get introDemoText =>
      'Mia hatte viel zu viele Erdbeeren dabei. Wir sind geblieben, bis die Sonne unterging.';

  @override
  String get introDemoPlace => 'Bodensee';

  @override
  String get introDemoTitle2 => 'Der erste Schnee';

  @override
  String get introDemoTitle3 => 'Omas Geburtstag';

  @override
  String get introDemoSearch => 'See';

  @override
  String get settingsIntro => 'Einführung ansehen';

  @override
  String get settingsIntroSubtitle => 'Sprache, Sicherung und eine kurze Tour';

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

  @override
  String get songAdd => 'Lied hinzufügen';

  @override
  String get songSheetTitle => 'Lied zum Eintrag';

  @override
  String get songSearchHint => 'Titel oder Künstler suchen';

  @override
  String get songNoResults => 'Nichts gefunden.';

  @override
  String get songSearchSource =>
      'Suche, Cover und Hörproben bereitgestellt von Apple';

  @override
  String get songRemove => 'Lied entfernen';

  @override
  String get songChange => 'Lied ändern';

  @override
  String get songPlay => 'Hörprobe abspielen';

  @override
  String get songPause => 'Hörprobe pausieren';

  @override
  String get songChangeHint => 'Lange drücken zum Ändern';

  @override
  String get songOpenAppleMusic => 'Anhören auf Apple Music';

  @override
  String get songOtherServices => 'Andere Dienste';

  @override
  String songRecordLabel(String title, String artist) {
    return 'Lied: $title von $artist';
  }

  @override
  String songOf(String title, String artist) {
    return '$title · $artist';
  }

  @override
  String get journalHasSong => 'Mit Lied';

  @override
  String get songErrorNetwork => 'Keine Verbindung zu Apple Music.';

  @override
  String get songErrorSearch => 'Die Suche hat nicht geklappt.';

  @override
  String get songErrorRateLimit =>
      'Gerade zu viele Anfragen. Bitte gleich noch einmal versuchen.';

  @override
  String get songErrorPlayback =>
      'Die Hörprobe ließ sich gerade nicht abspielen.';

  @override
  String get songErrorNoPreview => 'Für dieses Lied gibt es keine Hörprobe.';

  @override
  String get songErrorNotFound =>
      'Dieses Lied ist in Apple Music hier nicht (mehr) verfügbar.';

  @override
  String get songErrorOpen => 'Der Link ließ sich nicht öffnen.';

  @override
  String get calendarOpen => 'Kalender öffnen';

  @override
  String get calendarTitle => 'Kalender';

  @override
  String get calendarToday => 'Zu heute springen';

  @override
  String get calendarPreviousMonth => 'Voriger Monat';

  @override
  String get calendarNextMonth => 'Nächster Monat';

  @override
  String get calendarYearView => 'Zur Jahresansicht';

  @override
  String get calendarPreviousYear => 'Voriges Jahr';

  @override
  String get calendarNextYear => 'Nächstes Jahr';

  @override
  String calendarYearEntries(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Einträge in diesem Jahr',
      one: '1 Eintrag in diesem Jahr',
      zero: 'Keine Einträge in diesem Jahr',
    );
    return '$_temp0';
  }

  @override
  String calendarMonthEntries(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Einträge in diesem Monat',
      one: '1 Eintrag in diesem Monat',
      zero: 'Keine Einträge in diesem Monat',
    );
    return '$_temp0';
  }

  @override
  String get calendarDayEmpty => 'Keine Einträge an diesem Tag';

  @override
  String calendarDaysAhead(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'In $count Tagen',
      one: 'Morgen',
    );
    return '$_temp0';
  }

  @override
  String get settingsWhatsNew => 'Neuigkeiten';

  @override
  String get settingsWhatsNewSubtitle =>
      'Was sich mit den letzten Updates geändert hat';

  @override
  String whatsNewTitle(String version) {
    return 'Neu in Randnotiz $version';
  }

  @override
  String whatsNewVersion(String version) {
    return 'Version $version';
  }

  @override
  String get whatsNewDone => 'Alles klar';

  @override
  String get whatsNew130EncryptionTitle => 'Verschlüsselt gespeichert';

  @override
  String get whatsNew130EncryptionBody =>
      'Deine Notizen liegen jetzt verschlüsselt auf dem Gerät. Den Schlüssel kennt nur Randnotiz – er steckt im geschützten Speicher von Android und verlässt dein Handy nie.';

  @override
  String get whatsNew130LifeShareTitle => 'Wie viel deines Lebens?';

  @override
  String get whatsNew130LifeShareBody =>
      'Trag in den Einstellungen deinen Geburtstag ein: Bei Erinnerungen und im Kalender siehst du dann, wie viel Prozent deines bisherigen Lebens damals schon hinter dir lag.';

  @override
  String get whatsNew120CalendarTitle => 'Kalender';

  @override
  String get whatsNew120CalendarBody =>
      'Über das Kalender-Symbol im Tagebuch siehst du, an welchen Tagen du geschrieben hast – Monat für Monat oder das ganze Jahr auf einen Blick.';

  @override
  String get whatsNew120CollectionsTitle => 'Sammlungen';

  @override
  String get whatsNew120CollectionsBody =>
      'Die neuesten Einträge stehen jetzt oben – wie im Tagebuch.';

  @override
  String get whatsNew120TitlesTitle => 'Von Hand geschrieben';

  @override
  String get whatsNew120TitlesBody =>
      'Wechselst du den Bereich, wird der alte Titel durchgestrichen und der neue hingeschrieben.';

  @override
  String get whatsNew120PolishTitle => 'Feinschliff';

  @override
  String get whatsNew120PolishBody =>
      'Lange Notizen bleiben genau auf den Linien, und das Menü schiebt sich beim Schreiben nicht mehr über die Tastatur.';
}
