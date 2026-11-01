import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_de.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'generated/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[Locale('de')];

  /// No description provided for @appTitle.
  ///
  /// In de, this message translates to:
  /// **'Randnotiz'**
  String get appTitle;

  /// No description provided for @navJournal.
  ///
  /// In de, this message translates to:
  /// **'Tagebuch'**
  String get navJournal;

  /// No description provided for @navMemories.
  ///
  /// In de, this message translates to:
  /// **'Erinnerungen'**
  String get navMemories;

  /// No description provided for @settingsTooltip.
  ///
  /// In de, this message translates to:
  /// **'Einstellungen'**
  String get settingsTooltip;

  /// No description provided for @cancel.
  ///
  /// In de, this message translates to:
  /// **'Abbrechen'**
  String get cancel;

  /// No description provided for @delete.
  ///
  /// In de, this message translates to:
  /// **'Löschen'**
  String get delete;

  /// No description provided for @save.
  ///
  /// In de, this message translates to:
  /// **'Speichern'**
  String get save;

  /// No description provided for @create.
  ///
  /// In de, this message translates to:
  /// **'Anlegen'**
  String get create;

  /// No description provided for @done.
  ///
  /// In de, this message translates to:
  /// **'Fertig'**
  String get done;

  /// No description provided for @ok.
  ///
  /// In de, this message translates to:
  /// **'OK'**
  String get ok;

  /// No description provided for @openSystemSettings.
  ///
  /// In de, this message translates to:
  /// **'Einstellungen öffnen'**
  String get openSystemSettings;

  /// No description provided for @errorGeneric.
  ///
  /// In de, this message translates to:
  /// **'Etwas ist schiefgelaufen. Bitte versuch es noch einmal.'**
  String get errorGeneric;

  /// No description provided for @editorTitleNew.
  ///
  /// In de, this message translates to:
  /// **'Neue Notiz'**
  String get editorTitleNew;

  /// No description provided for @editorTitleEdit.
  ///
  /// In de, this message translates to:
  /// **'Notiz'**
  String get editorTitleEdit;

  /// No description provided for @editorHint.
  ///
  /// In de, this message translates to:
  /// **'Was war da los? Schreib es auf …'**
  String get editorHint;

  /// No description provided for @editorSaveFailed.
  ///
  /// In de, this message translates to:
  /// **'Nicht gespeichert – neuer Versuch …'**
  String get editorSaveFailed;

  /// No description provided for @editorCleared.
  ///
  /// In de, this message translates to:
  /// **'Notiz geleert – sie wird beim Schließen gelöscht.'**
  String get editorCleared;

  /// No description provided for @editorUndoClear.
  ///
  /// In de, this message translates to:
  /// **'Rückgängig'**
  String get editorUndoClear;

  /// No description provided for @editorSaved.
  ///
  /// In de, this message translates to:
  /// **'Gespeichert'**
  String get editorSaved;

  /// No description provided for @editorSaving.
  ///
  /// In de, this message translates to:
  /// **'Speichert …'**
  String get editorSaving;

  /// No description provided for @editorDelete.
  ///
  /// In de, this message translates to:
  /// **'Notiz löschen'**
  String get editorDelete;

  /// No description provided for @editorDeleteConfirmTitle.
  ///
  /// In de, this message translates to:
  /// **'Notiz löschen?'**
  String get editorDeleteConfirmTitle;

  /// No description provided for @editorDeleteConfirmBody.
  ///
  /// In de, this message translates to:
  /// **'Text, Tags und Wetter dieser Notiz werden entfernt. Das Foto in deiner Galerie bleibt unberührt.'**
  String get editorDeleteConfirmBody;

  /// No description provided for @editorPhotoMissing.
  ///
  /// In de, this message translates to:
  /// **'Das Originalfoto ist nicht mehr in der Galerie. Die gespeicherte Kopie bleibt im Tagebuch.'**
  String get editorPhotoMissing;

  /// No description provided for @editorDateTooltip.
  ///
  /// In de, this message translates to:
  /// **'Datum ändern'**
  String get editorDateTooltip;

  /// No description provided for @editorEmptyDiscarded.
  ///
  /// In de, this message translates to:
  /// **'Leere Notizen werden nicht gespeichert.'**
  String get editorEmptyDiscarded;

  /// Short weather description
  ///
  /// In de, this message translates to:
  /// **'{kind, select, clear{Sonnig} partlyCloudy{Heiter bis wolkig} cloudy{Bewölkt} fog{Nebel} drizzle{Nieselregen} rain{Regen} snow{Schnee} thunderstorm{Gewitter} other{Wetter}}'**
  String weatherKind(String kind);

  /// No description provided for @weatherTemperature.
  ///
  /// In de, this message translates to:
  /// **'{temperature} °C'**
  String weatherTemperature(String temperature);

  /// No description provided for @weatherLoading.
  ///
  /// In de, this message translates to:
  /// **'Wetter wird gesucht …'**
  String get weatherLoading;

  /// No description provided for @weatherAdd.
  ///
  /// In de, this message translates to:
  /// **'Wetter'**
  String get weatherAdd;

  /// No description provided for @weatherFetchAgain.
  ///
  /// In de, this message translates to:
  /// **'Erneut abrufen'**
  String get weatherFetchAgain;

  /// No description provided for @weatherOffline.
  ///
  /// In de, this message translates to:
  /// **'Das Wetter konnte nicht abgerufen werden. Vielleicht fehlt gerade die Internetverbindung.'**
  String get weatherOffline;

  /// No description provided for @weatherTemperatureLabel.
  ///
  /// In de, this message translates to:
  /// **'Temperatur in °C (optional)'**
  String get weatherTemperatureLabel;

  /// No description provided for @weatherRemove.
  ///
  /// In de, this message translates to:
  /// **'Wetter entfernen'**
  String get weatherRemove;

  /// No description provided for @tagsAdd.
  ///
  /// In de, this message translates to:
  /// **'Stimmung'**
  String get tagsAdd;

  /// No description provided for @tagsSheetTitle.
  ///
  /// In de, this message translates to:
  /// **'Stimmungen'**
  String get tagsSheetTitle;

  /// No description provided for @tagsCreateNew.
  ///
  /// In de, this message translates to:
  /// **'Stimmung neu anlegen'**
  String get tagsCreateNew;

  /// No description provided for @tagNameLabel.
  ///
  /// In de, this message translates to:
  /// **'Name der Stimmung'**
  String get tagNameLabel;

  /// No description provided for @tagNameHint.
  ///
  /// In de, this message translates to:
  /// **'z. B. Glücklich'**
  String get tagNameHint;

  /// No description provided for @tagDuplicate.
  ///
  /// In de, this message translates to:
  /// **'Diese Stimmung gibt es schon.'**
  String get tagDuplicate;

  /// No description provided for @tagNameEmpty.
  ///
  /// In de, this message translates to:
  /// **'Bitte gib einen Namen ein.'**
  String get tagNameEmpty;

  /// No description provided for @tagsNone.
  ///
  /// In de, this message translates to:
  /// **'Noch keine Stimmungen. Leg deine erste an.'**
  String get tagsNone;

  /// No description provided for @tagRemove.
  ///
  /// In de, this message translates to:
  /// **'Stimmung {name} entfernen'**
  String tagRemove(String name);

  /// No description provided for @micStart.
  ///
  /// In de, this message translates to:
  /// **'Diktieren'**
  String get micStart;

  /// No description provided for @micStop.
  ///
  /// In de, this message translates to:
  /// **'Diktat beenden'**
  String get micStop;

  /// No description provided for @micListening.
  ///
  /// In de, this message translates to:
  /// **'Ich höre zu …'**
  String get micListening;

  /// No description provided for @micUnavailableTooltip.
  ///
  /// In de, this message translates to:
  /// **'Diktat nicht verfügbar'**
  String get micUnavailableTooltip;

  /// No description provided for @micRationaleTitle.
  ///
  /// In de, this message translates to:
  /// **'Notizen per Sprache'**
  String get micRationaleTitle;

  /// No description provided for @micRationaleBody.
  ///
  /// In de, this message translates to:
  /// **'Damit du deine Notiz diktieren kannst, braucht Randnotiz Zugriff auf das Mikrofon. Es wird nichts aufgenommen oder gespeichert – nur der erkannte Text landet in deiner Notiz. Je nach Gerät erkennt dein Handy die Sprache selbst oder nutzt den Spracherkennungsdienst von Google.'**
  String get micRationaleBody;

  /// No description provided for @micRationaleContinue.
  ///
  /// In de, this message translates to:
  /// **'Weiter'**
  String get micRationaleContinue;

  /// No description provided for @micDenied.
  ///
  /// In de, this message translates to:
  /// **'Ohne Mikrofon-Zugriff ist kein Diktat möglich. Du kannst natürlich weiter tippen.'**
  String get micDenied;

  /// No description provided for @micPermanentlyDeniedTitle.
  ///
  /// In de, this message translates to:
  /// **'Mikrofon ist gesperrt'**
  String get micPermanentlyDeniedTitle;

  /// No description provided for @micPermanentlyDeniedBody.
  ///
  /// In de, this message translates to:
  /// **'Du hast den Mikrofon-Zugriff abgelehnt. Wenn du diktieren möchtest, erlaube ihn in den App-Einstellungen.'**
  String get micPermanentlyDeniedBody;

  /// No description provided for @micUnavailable.
  ///
  /// In de, this message translates to:
  /// **'Auf diesem Gerät ist keine Spracherkennung verfügbar. Aktiviere z. B. „Speech Services by Google“ in den Systemeinstellungen.'**
  String get micUnavailable;

  /// No description provided for @dictationNoSpeech.
  ///
  /// In de, this message translates to:
  /// **'Ich habe nichts verstanden. Tippe noch einmal aufs Mikrofon.'**
  String get dictationNoSpeech;

  /// No description provided for @dictationNetwork.
  ///
  /// In de, this message translates to:
  /// **'Die Spracherkennung braucht gerade eine Internetverbindung.'**
  String get dictationNetwork;

  /// No description provided for @dictationBusy.
  ///
  /// In de, this message translates to:
  /// **'Die Spracherkennung ist gerade beschäftigt. Versuch es gleich noch einmal.'**
  String get dictationBusy;

  /// No description provided for @dictationLanguage.
  ///
  /// In de, this message translates to:
  /// **'Deutsch wird von der Spracherkennung dieses Geräts nicht unterstützt.'**
  String get dictationLanguage;

  /// No description provided for @dictationAudio.
  ///
  /// In de, this message translates to:
  /// **'Das Mikrofon ist gerade belegt, zum Beispiel durch einen Anruf. Dein Text ist erhalten.'**
  String get dictationAudio;

  /// No description provided for @dictationUnknown.
  ///
  /// In de, this message translates to:
  /// **'Das Diktat wurde unterbrochen. Dein Text ist erhalten.'**
  String get dictationUnknown;

  /// No description provided for @journalSearchHint.
  ///
  /// In de, this message translates to:
  /// **'Notizen durchsuchen'**
  String get journalSearchHint;

  /// No description provided for @journalEmptyTitle.
  ///
  /// In de, this message translates to:
  /// **'Dein Tagebuch ist noch leer'**
  String get journalEmptyTitle;

  /// No description provided for @journalEmptyBody.
  ///
  /// In de, this message translates to:
  /// **'Tippe unten auf das Foto-Plus, wähl ein Bild und schreib deine erste Randnotiz.'**
  String get journalEmptyBody;

  /// No description provided for @journalNoResults.
  ///
  /// In de, this message translates to:
  /// **'Dazu habe ich nichts gefunden.'**
  String get journalNoResults;

  /// No description provided for @journalResultCount.
  ///
  /// In de, this message translates to:
  /// **'{count, plural, =1{1 Notiz} other{{count} Notizen}}'**
  String journalResultCount(int count);

  /// No description provided for @journalClearFilter.
  ///
  /// In de, this message translates to:
  /// **'Filter zurücksetzen'**
  String get journalClearFilter;

  /// No description provided for @journalClearSearch.
  ///
  /// In de, this message translates to:
  /// **'Suche leeren'**
  String get journalClearSearch;

  /// No description provided for @yearsAgo.
  ///
  /// In de, this message translates to:
  /// **'{count, plural, =1{Vor 1 Jahr} other{Vor {count} Jahren}}'**
  String yearsAgo(int count);

  /// No description provided for @monthsAgo.
  ///
  /// In de, this message translates to:
  /// **'{count, plural, =1{Vor 1 Monat} other{Vor {count} Monaten}}'**
  String monthsAgo(int count);

  /// No description provided for @weeksAgo.
  ///
  /// In de, this message translates to:
  /// **'{count, plural, =1{Vor 1 Woche} other{Vor {count} Wochen}}'**
  String weeksAgo(int count);

  /// No description provided for @daysAgo.
  ///
  /// In de, this message translates to:
  /// **'{count, plural, =0{Heute} =1{Gestern} other{Vor {count} Tagen}}'**
  String daysAgo(int count);

  /// No description provided for @memoriesEmptyTitle.
  ///
  /// In de, this message translates to:
  /// **'Noch keine Erinnerungen'**
  String get memoriesEmptyTitle;

  /// No description provided for @memoriesEmptyBody.
  ///
  /// In de, this message translates to:
  /// **'Sobald du Notizen schreibst, tauchen sie hier an ihren Jahrestagen wieder auf.'**
  String get memoriesEmptyBody;

  /// No description provided for @lockTitle.
  ///
  /// In de, this message translates to:
  /// **'Randnotiz ist gesperrt'**
  String get lockTitle;

  /// No description provided for @lockBody.
  ///
  /// In de, this message translates to:
  /// **'Entsperre mit Fingerabdruck, Gesicht oder deiner Displaysperre.'**
  String get lockBody;

  /// No description provided for @lockButton.
  ///
  /// In de, this message translates to:
  /// **'Entsperren'**
  String get lockButton;

  /// No description provided for @lockReason.
  ///
  /// In de, this message translates to:
  /// **'Randnotiz entsperren'**
  String get lockReason;

  /// No description provided for @lockLockedOut.
  ///
  /// In de, this message translates to:
  /// **'Zu viele Versuche. Bitte warte einen Moment und versuch es dann erneut.'**
  String get lockLockedOut;

  /// No description provided for @lockFailed.
  ///
  /// In de, this message translates to:
  /// **'Entsperren hat nicht geklappt.'**
  String get lockFailed;

  /// No description provided for @settingsTitle.
  ///
  /// In de, this message translates to:
  /// **'Einstellungen'**
  String get settingsTitle;

  /// No description provided for @settingsSectionAppearance.
  ///
  /// In de, this message translates to:
  /// **'Darstellung'**
  String get settingsSectionAppearance;

  /// No description provided for @settingsTheme.
  ///
  /// In de, this message translates to:
  /// **'Design'**
  String get settingsTheme;

  /// No description provided for @themeSystem.
  ///
  /// In de, this message translates to:
  /// **'System'**
  String get themeSystem;

  /// No description provided for @themeLight.
  ///
  /// In de, this message translates to:
  /// **'Hell'**
  String get themeLight;

  /// No description provided for @themeDark.
  ///
  /// In de, this message translates to:
  /// **'Dunkel'**
  String get themeDark;

  /// No description provided for @settingsSectionPrivacy.
  ///
  /// In de, this message translates to:
  /// **'Privatsphäre'**
  String get settingsSectionPrivacy;

  /// No description provided for @settingsLock.
  ///
  /// In de, this message translates to:
  /// **'Sperre mit Biometrie'**
  String get settingsLock;

  /// No description provided for @settingsLockSubtitle.
  ///
  /// In de, this message translates to:
  /// **'Fingerabdruck, Gesicht oder Displaysperre beim Öffnen. Solange die Sperre an ist, sind Screenshots und Bildschirmübertragung blockiert.'**
  String get settingsLockSubtitle;

  /// No description provided for @settingsLockUnavailable.
  ///
  /// In de, this message translates to:
  /// **'Richte zuerst eine Displaysperre auf deinem Gerät ein.'**
  String get settingsLockUnavailable;

  /// No description provided for @settingsLockTimeout.
  ///
  /// In de, this message translates to:
  /// **'Sperren nach'**
  String get settingsLockTimeout;

  /// No description provided for @lockTimeoutImmediately.
  ///
  /// In de, this message translates to:
  /// **'Sofort'**
  String get lockTimeoutImmediately;

  /// No description provided for @lockTimeoutMinutes.
  ///
  /// In de, this message translates to:
  /// **'{count, plural, =1{1 Minute im Hintergrund} other{{count} Minuten im Hintergrund}}'**
  String lockTimeoutMinutes(int count);

  /// No description provided for @settingsSectionTags.
  ///
  /// In de, this message translates to:
  /// **'Stimmungen'**
  String get settingsSectionTags;

  /// No description provided for @settingsManageTags.
  ///
  /// In de, this message translates to:
  /// **'Stimmungen verwalten'**
  String get settingsManageTags;

  /// No description provided for @settingsSectionWidget.
  ///
  /// In de, this message translates to:
  /// **'Widget'**
  String get settingsSectionWidget;

  /// No description provided for @settingsWidgetText.
  ///
  /// In de, this message translates to:
  /// **'Textvorschau im Widget'**
  String get settingsWidgetText;

  /// No description provided for @settingsWidgetTextSubtitle.
  ///
  /// In de, this message translates to:
  /// **'Zeigt den Anfang der Notiz auf dem Startbildschirm – sichtbar für alle, die dein Handy sehen.'**
  String get settingsWidgetTextSubtitle;

  /// No description provided for @settingsSectionBackup.
  ///
  /// In de, this message translates to:
  /// **'Sicherung'**
  String get settingsSectionBackup;

  /// No description provided for @settingsBackupDrive.
  ///
  /// In de, this message translates to:
  /// **'Sicherung in Google Drive'**
  String get settingsBackupDrive;

  /// No description provided for @settingsBackupOff.
  ///
  /// In de, this message translates to:
  /// **'Aus – deine Notizen sind nur auf diesem Gerät'**
  String get settingsBackupOff;

  /// No description provided for @settingsBackupUnavailable.
  ///
  /// In de, this message translates to:
  /// **'In dieser Version nicht verfügbar'**
  String get settingsBackupUnavailable;

  /// No description provided for @settingsBackupNeedsSetup.
  ///
  /// In de, this message translates to:
  /// **'Verbunden – Backup-Passwort festlegen'**
  String get settingsBackupNeedsSetup;

  /// No description provided for @settingsBackupNeedsUnlock.
  ///
  /// In de, this message translates to:
  /// **'Sicherung gefunden – zum Entsperren tippen'**
  String get settingsBackupNeedsUnlock;

  /// No description provided for @settingsBackupRestorePending.
  ///
  /// In de, this message translates to:
  /// **'Pausiert – Sicherung noch nicht übernommen'**
  String get settingsBackupRestorePending;

  /// No description provided for @settingsBackupNever.
  ///
  /// In de, this message translates to:
  /// **'Verschlüsselt eingeschaltet – noch keine Sicherung'**
  String get settingsBackupNever;

  /// No description provided for @settingsBackupLast.
  ///
  /// In de, this message translates to:
  /// **'Zuletzt gesichert: {when}'**
  String settingsBackupLast(String when);

  /// No description provided for @settingsBackupRunning.
  ///
  /// In de, this message translates to:
  /// **'Wird gesichert …'**
  String get settingsBackupRunning;

  /// No description provided for @backupTitle.
  ///
  /// In de, this message translates to:
  /// **'Sicherung in Google Drive'**
  String get backupTitle;

  /// No description provided for @backupIntro.
  ///
  /// In de, this message translates to:
  /// **'Randnotiz sichert deine Notizen, Stimmungen, Sammlungen und verkleinerte Fotos in einem versteckten App-Ordner deines Google-Drive-Kontos. Alles wird vorher auf diesem Gerät verschlüsselt: Google sieht nur unlesbare Daten, nicht deine Einträge.'**
  String get backupIntro;

  /// No description provided for @backupConnect.
  ///
  /// In de, this message translates to:
  /// **'Mit Google verbinden'**
  String get backupConnect;

  /// No description provided for @backupConnectFailed.
  ///
  /// In de, this message translates to:
  /// **'Die Verbindung mit Google hat nicht geklappt.'**
  String get backupConnectFailed;

  /// No description provided for @backupAccount.
  ///
  /// In de, this message translates to:
  /// **'Google-Konto'**
  String get backupAccount;

  /// No description provided for @backupSetupIntro.
  ///
  /// In de, this message translates to:
  /// **'Lege ein Backup-Passwort fest. Damit kannst du die Sicherung auf einem neuen Gerät öffnen. Es verlässt dieses Gerät nie und ist nicht dein Google-Passwort.'**
  String get backupSetupIntro;

  /// No description provided for @backupSetupButton.
  ///
  /// In de, this message translates to:
  /// **'Backup-Passwort festlegen'**
  String get backupSetupButton;

  /// No description provided for @backupPasswordTitle.
  ///
  /// In de, this message translates to:
  /// **'Backup-Passwort'**
  String get backupPasswordTitle;

  /// No description provided for @backupPasswordNewTitle.
  ///
  /// In de, this message translates to:
  /// **'Neues Backup-Passwort'**
  String get backupPasswordNewTitle;

  /// No description provided for @backupPasswordLabel.
  ///
  /// In de, this message translates to:
  /// **'Passwort'**
  String get backupPasswordLabel;

  /// No description provided for @backupPasswordRepeat.
  ///
  /// In de, this message translates to:
  /// **'Passwort wiederholen'**
  String get backupPasswordRepeat;

  /// No description provided for @backupPasswordTooShort.
  ///
  /// In de, this message translates to:
  /// **'Mindestens {count} Zeichen'**
  String backupPasswordTooShort(int count);

  /// No description provided for @backupPasswordMismatch.
  ///
  /// In de, this message translates to:
  /// **'Die Passwörter stimmen nicht überein'**
  String get backupPasswordMismatch;

  /// No description provided for @backupPasswordHint.
  ///
  /// In de, this message translates to:
  /// **'Gut merkbar, aber nicht zu erraten – z. B. ein kurzer Satz. Ohne Passwort und ohne Notfallschlüssel lässt sich die Sicherung von niemandem öffnen, auch nicht von uns.'**
  String get backupPasswordHint;

  /// No description provided for @backupWorking.
  ///
  /// In de, this message translates to:
  /// **'Einen Moment …'**
  String get backupWorking;

  /// No description provided for @backupEmergencyTitle.
  ///
  /// In de, this message translates to:
  /// **'Dein Notfallschlüssel'**
  String get backupEmergencyTitle;

  /// No description provided for @backupEmergencyIntro.
  ///
  /// In de, this message translates to:
  /// **'Falls du das Backup-Passwort vergisst, öffnet dieser Schlüssel deine Sicherung. Schreib ihn auf und bewahre ihn sicher auf – er wird nur jetzt angezeigt.'**
  String get backupEmergencyIntro;

  /// No description provided for @backupEmergencyCopy.
  ///
  /// In de, this message translates to:
  /// **'Kopieren'**
  String get backupEmergencyCopy;

  /// No description provided for @backupEmergencyCopied.
  ///
  /// In de, this message translates to:
  /// **'Notfallschlüssel kopiert'**
  String get backupEmergencyCopied;

  /// No description provided for @backupEmergencyConfirm.
  ///
  /// In de, this message translates to:
  /// **'Ich habe den Notfallschlüssel sicher notiert'**
  String get backupEmergencyConfirm;

  /// No description provided for @backupEmergencyDone.
  ///
  /// In de, this message translates to:
  /// **'Fertig'**
  String get backupEmergencyDone;

  /// No description provided for @backupUnlockIntro.
  ///
  /// In de, this message translates to:
  /// **'Auf deinem Google-Konto liegt eine verschlüsselte Sicherung. Gib das Backup-Passwort oder den Notfallschlüssel ein, um sie auf diesem Gerät zu öffnen.'**
  String get backupUnlockIntro;

  /// No description provided for @backupUnlockFoundAt.
  ///
  /// In de, this message translates to:
  /// **'Letzte Sicherung: {when}'**
  String backupUnlockFoundAt(String when);

  /// No description provided for @backupUnlockLabel.
  ///
  /// In de, this message translates to:
  /// **'Passwort oder Notfallschlüssel'**
  String get backupUnlockLabel;

  /// No description provided for @backupUnlockButton.
  ///
  /// In de, this message translates to:
  /// **'Entsperren'**
  String get backupUnlockButton;

  /// No description provided for @backupUnlockWrong.
  ///
  /// In de, this message translates to:
  /// **'Das passt nicht. Prüfe Passwort bzw. Notfallschlüssel.'**
  String get backupUnlockWrong;

  /// No description provided for @backupRestoreAskTitle.
  ///
  /// In de, this message translates to:
  /// **'Notizen wiederherstellen?'**
  String get backupRestoreAskTitle;

  /// No description provided for @backupRestoreAskBody.
  ///
  /// In de, this message translates to:
  /// **'Die Einträge aus der Sicherung werden zu diesem Gerät hinzugefügt. Was hier neuer ist, bleibt unverändert.'**
  String get backupRestoreAskBody;

  /// No description provided for @backupRestoreLater.
  ///
  /// In de, this message translates to:
  /// **'Später'**
  String get backupRestoreLater;

  /// No description provided for @backupRestore.
  ///
  /// In de, this message translates to:
  /// **'Wiederherstellen'**
  String get backupRestore;

  /// No description provided for @backupRestoreDone.
  ///
  /// In de, this message translates to:
  /// **'{added, plural, =0{Keine neuen Einträge} =1{1 Eintrag wiederhergestellt} other{{added} Einträge wiederhergestellt}}'**
  String backupRestoreDone(int added);

  /// No description provided for @backupRestoreUpdated.
  ///
  /// In de, this message translates to:
  /// **'{count, plural, =1{1 Eintrag aktualisiert} other{{count} Einträge aktualisiert}}'**
  String backupRestoreUpdated(int count);

  /// No description provided for @backupNow.
  ///
  /// In de, this message translates to:
  /// **'Jetzt sichern'**
  String get backupNow;

  /// No description provided for @backupDone.
  ///
  /// In de, this message translates to:
  /// **'Gesichert'**
  String get backupDone;

  /// No description provided for @backupUnchanged.
  ///
  /// In de, this message translates to:
  /// **'Schon aktuell – nichts zu sichern'**
  String get backupUnchanged;

  /// No description provided for @backupStatusNever.
  ///
  /// In de, this message translates to:
  /// **'Noch keine Sicherung.'**
  String get backupStatusNever;

  /// No description provided for @backupStatusLast.
  ///
  /// In de, this message translates to:
  /// **'Zuletzt gesichert: {when}'**
  String backupStatusLast(String when);

  /// No description provided for @backupStatusCounts.
  ///
  /// In de, this message translates to:
  /// **'{notes, plural, =1{1 Eintrag} other{{notes} Einträge}} · {photos, plural, =1{1 Bild} other{{photos} Bilder}}'**
  String backupStatusCounts(int notes, int photos);

  /// No description provided for @backupStatusAuto.
  ///
  /// In de, this message translates to:
  /// **'Gesichert wird automatisch einmal am Tag, wenn du die App öffnest.'**
  String get backupStatusAuto;

  /// No description provided for @backupStatusPending.
  ///
  /// In de, this message translates to:
  /// **'Sicherung noch nicht übernommen'**
  String get backupStatusPending;

  /// No description provided for @backupStatusPendingHint.
  ///
  /// In de, this message translates to:
  /// **'Die automatische Sicherung pausiert, bis die Einträge aus deiner Sicherung auch auf diesem Gerät sind – damit nichts überschrieben wird. „Wiederherstellen“ oder „Jetzt sichern“ holt sie hierher.'**
  String get backupStatusPendingHint;

  /// No description provided for @backupProblemOffline.
  ///
  /// In de, this message translates to:
  /// **'Keine Verbindung zu Google Drive – es wird später erneut versucht.'**
  String get backupProblemOffline;

  /// No description provided for @backupProblemAuth.
  ///
  /// In de, this message translates to:
  /// **'Google hat den Zugriff verweigert. Bitte verbinde dich erneut.'**
  String get backupProblemAuth;

  /// No description provided for @backupProblemQuota.
  ///
  /// In de, this message translates to:
  /// **'Dein Google-Drive-Speicher ist voll.'**
  String get backupProblemQuota;

  /// No description provided for @backupProblemDamaged.
  ///
  /// In de, this message translates to:
  /// **'Die Sicherung in Google Drive ist beschädigt oder gehört zu einem anderen Schlüssel.'**
  String get backupProblemDamaged;

  /// No description provided for @backupProblemUnknown.
  ///
  /// In de, this message translates to:
  /// **'Die Sicherung hat nicht geklappt.'**
  String get backupProblemUnknown;

  /// No description provided for @backupReconnect.
  ///
  /// In de, this message translates to:
  /// **'Erneut verbinden'**
  String get backupReconnect;

  /// No description provided for @backupChangePassword.
  ///
  /// In de, this message translates to:
  /// **'Backup-Passwort ändern'**
  String get backupChangePassword;

  /// No description provided for @backupPasswordChanged.
  ///
  /// In de, this message translates to:
  /// **'Backup-Passwort geändert'**
  String get backupPasswordChanged;

  /// No description provided for @backupRenewEmergency.
  ///
  /// In de, this message translates to:
  /// **'Neuen Notfallschlüssel erstellen'**
  String get backupRenewEmergency;

  /// No description provided for @backupRenewEmergencyAsk.
  ///
  /// In de, this message translates to:
  /// **'Der bisherige Notfallschlüssel funktioniert danach nicht mehr.'**
  String get backupRenewEmergencyAsk;

  /// No description provided for @backupRenewEmergencyButton.
  ///
  /// In de, this message translates to:
  /// **'Neu erstellen'**
  String get backupRenewEmergencyButton;

  /// No description provided for @backupDisconnect.
  ///
  /// In de, this message translates to:
  /// **'Abmelden'**
  String get backupDisconnect;

  /// No description provided for @backupDisconnectTitle.
  ///
  /// In de, this message translates to:
  /// **'Von Google Drive abmelden?'**
  String get backupDisconnectTitle;

  /// No description provided for @backupDisconnectBody.
  ///
  /// In de, this message translates to:
  /// **'Auf diesem Gerät wird nicht mehr gesichert. Deine Notizen hier bleiben erhalten.'**
  String get backupDisconnectBody;

  /// No description provided for @backupDisconnectDelete.
  ///
  /// In de, this message translates to:
  /// **'Auch die Sicherung in Google Drive löschen'**
  String get backupDisconnectDelete;

  /// No description provided for @backupPrivacyNote.
  ///
  /// In de, this message translates to:
  /// **'Ende-zu-Ende-verschlüsselt (AES-256). Schlüssel: dein Backup-Passwort bzw. der Notfallschlüssel – beide kennt nur du.'**
  String get backupPrivacyNote;

  /// No description provided for @settingsSectionAbout.
  ///
  /// In de, this message translates to:
  /// **'Über'**
  String get settingsSectionAbout;

  /// No description provided for @settingsAbout.
  ///
  /// In de, this message translates to:
  /// **'Über Randnotiz'**
  String get settingsAbout;

  /// No description provided for @settingsAboutLegalese.
  ///
  /// In de, this message translates to:
  /// **'Ein privates Foto-Tagebuch. Deine Notizen bleiben auf deinem Gerät.\n\nKartendaten: Natural Earth (gemeinfrei). Orte: GeoNames (CC BY 4.0). Details unter „Lizenzen“.'**
  String get settingsAboutLegalese;

  /// No description provided for @tagManageTitle.
  ///
  /// In de, this message translates to:
  /// **'Stimmungen verwalten'**
  String get tagManageTitle;

  /// No description provided for @tagDeleteConfirmTitle.
  ///
  /// In de, this message translates to:
  /// **'Stimmung „{name}“ löschen?'**
  String tagDeleteConfirmTitle(String name);

  /// No description provided for @tagDeleteConfirmBody.
  ///
  /// In de, this message translates to:
  /// **'{count, plural, =0{Sie wird noch nirgends verwendet.} =1{Sie wird von 1 Notiz entfernt. Die Notiz selbst bleibt erhalten.} other{Sie wird von {count} Notizen entfernt. Die Notizen selbst bleiben erhalten.}}'**
  String tagDeleteConfirmBody(int count);

  /// No description provided for @tagUsage.
  ///
  /// In de, this message translates to:
  /// **'{count, plural, =0{Nicht verwendet} =1{1 Notiz} other{{count} Notizen}}'**
  String tagUsage(int count);

  /// No description provided for @tagEdit.
  ///
  /// In de, this message translates to:
  /// **'Stimmung bearbeiten'**
  String get tagEdit;

  /// No description provided for @libraryPickExternalTooltip.
  ///
  /// In de, this message translates to:
  /// **'Neuer Eintrag: Foto auswählen'**
  String get libraryPickExternalTooltip;

  /// No description provided for @libraryImporting.
  ///
  /// In de, this message translates to:
  /// **'Foto wird übernommen …'**
  String get libraryImporting;

  /// No description provided for @libraryImportFailed.
  ///
  /// In de, this message translates to:
  /// **'Das Foto konnte nicht übernommen werden.'**
  String get libraryImportFailed;

  /// No description provided for @placeAdd.
  ///
  /// In de, this message translates to:
  /// **'Ort'**
  String get placeAdd;

  /// No description provided for @placeSheetTitle.
  ///
  /// In de, this message translates to:
  /// **'Land und Ort'**
  String get placeSheetTitle;

  /// No description provided for @placeSearchHint.
  ///
  /// In de, this message translates to:
  /// **'Ort suchen, z. B. Hamburg'**
  String get placeSearchHint;

  /// No description provided for @placeNoResults.
  ///
  /// In de, this message translates to:
  /// **'Kein Ort gefunden.'**
  String get placeNoResults;

  /// No description provided for @placePrivacy.
  ///
  /// In de, this message translates to:
  /// **'Gespeichert werden nur Land und Ortsname – nie der GPS-Standort deines Fotos. Fotos mit Standort bekommen beides automatisch, ganz ohne Internet. Für das Wetter wird der ungefähre Ort an den Wetterdienst gesendet.'**
  String get placePrivacy;

  /// No description provided for @placeRemove.
  ///
  /// In de, this message translates to:
  /// **'Entfernen'**
  String get placeRemove;

  /// No description provided for @placeWeatherHint.
  ///
  /// In de, this message translates to:
  /// **'Mit einem Ort zeigt Randnotiz auch das Wetter an diesem Tag.'**
  String get placeWeatherHint;

  /// No description provided for @weatherAdjust.
  ///
  /// In de, this message translates to:
  /// **'Wetter selbst anpassen'**
  String get weatherAdjust;

  /// No description provided for @editorMetaMood.
  ///
  /// In de, this message translates to:
  /// **'Stimmung'**
  String get editorMetaMood;

  /// No description provided for @navCollections.
  ///
  /// In de, this message translates to:
  /// **'Sammlungen'**
  String get navCollections;

  /// No description provided for @collectionAddShort.
  ///
  /// In de, this message translates to:
  /// **'Sammlung'**
  String get collectionAddShort;

  /// No description provided for @collectionPickerTitle.
  ///
  /// In de, this message translates to:
  /// **'Sammlungen'**
  String get collectionPickerTitle;

  /// No description provided for @collectionPickerHint.
  ///
  /// In de, this message translates to:
  /// **'Sammle Einträge, die zusammengehören – eine Reise, einen Sommer, einen Menschen.'**
  String get collectionPickerHint;

  /// No description provided for @collectionNew.
  ///
  /// In de, this message translates to:
  /// **'Neue Sammlung'**
  String get collectionNew;

  /// No description provided for @collectionNameLabel.
  ///
  /// In de, this message translates to:
  /// **'Name'**
  String get collectionNameLabel;

  /// No description provided for @collectionNameHint.
  ///
  /// In de, this message translates to:
  /// **'z. B. Italien 2024'**
  String get collectionNameHint;

  /// No description provided for @collectionRename.
  ///
  /// In de, this message translates to:
  /// **'Umbenennen'**
  String get collectionRename;

  /// No description provided for @collectionDelete.
  ///
  /// In de, this message translates to:
  /// **'Sammlung löschen'**
  String get collectionDelete;

  /// No description provided for @collectionDeleteConfirmTitle.
  ///
  /// In de, this message translates to:
  /// **'Sammlung löschen?'**
  String get collectionDeleteConfirmTitle;

  /// No description provided for @collectionDeleteConfirmBody.
  ///
  /// In de, this message translates to:
  /// **'„{name}“ wird gelöscht. Die Einträge selbst bleiben im Tagebuch erhalten.'**
  String collectionDeleteConfirmBody(String name);

  /// No description provided for @collectionEntryCount.
  ///
  /// In de, this message translates to:
  /// **'{count, plural, =0{Noch leer} =1{1 Eintrag} other{{count} Einträge}}'**
  String collectionEntryCount(int count);

  /// No description provided for @collectionsReorderHint.
  ///
  /// In de, this message translates to:
  /// **'Gedrückt halten und ziehen zum Sortieren'**
  String get collectionsReorderHint;

  /// No description provided for @collectionMoveEarlier.
  ///
  /// In de, this message translates to:
  /// **'Nach vorne verschieben'**
  String get collectionMoveEarlier;

  /// No description provided for @collectionMoveLater.
  ///
  /// In de, this message translates to:
  /// **'Nach hinten verschieben'**
  String get collectionMoveLater;

  /// No description provided for @collectionsEmptyTitle.
  ///
  /// In de, this message translates to:
  /// **'Noch keine Sammlungen'**
  String get collectionsEmptyTitle;

  /// No description provided for @collectionsEmptyBody.
  ///
  /// In de, this message translates to:
  /// **'Fasse Einträge zusammen, die zusammengehören – eine Reise, einen Sommer, einen Menschen.'**
  String get collectionsEmptyBody;

  /// No description provided for @collectionEmptyBody.
  ///
  /// In de, this message translates to:
  /// **'Füge Einträge hinzu – hier oder direkt in einer Notiz über „Sammlung“.'**
  String get collectionEmptyBody;

  /// No description provided for @collectionAddEntries.
  ///
  /// In de, this message translates to:
  /// **'Einträge hinzufügen'**
  String get collectionAddEntries;

  /// No description provided for @collectionAddEntriesNone.
  ///
  /// In de, this message translates to:
  /// **'Alle Einträge sind schon in dieser Sammlung.'**
  String get collectionAddEntriesNone;

  /// No description provided for @collectionAddSelected.
  ///
  /// In de, this message translates to:
  /// **'{count, plural, =0{Hinzufügen} =1{1 Eintrag hinzufügen} other{{count} Einträge hinzufügen}}'**
  String collectionAddSelected(int count);

  /// No description provided for @collectionRemoveEntry.
  ///
  /// In de, this message translates to:
  /// **'Aus der Sammlung entfernen'**
  String get collectionRemoveEntry;

  /// No description provided for @collectionNeighboursTitle.
  ///
  /// In de, this message translates to:
  /// **'{name} · {position} von {total}'**
  String collectionNeighboursTitle(String name, int position, int total);

  /// No description provided for @collectionPrevious.
  ///
  /// In de, this message translates to:
  /// **'Vorheriger'**
  String get collectionPrevious;

  /// No description provided for @collectionNext.
  ///
  /// In de, this message translates to:
  /// **'Nächster'**
  String get collectionNext;

  /// No description provided for @collectionStart.
  ///
  /// In de, this message translates to:
  /// **'Hier beginnt die Sammlung'**
  String get collectionStart;

  /// No description provided for @collectionEnd.
  ///
  /// In de, this message translates to:
  /// **'Hier endet die Sammlung'**
  String get collectionEnd;

  /// No description provided for @mapEntriesCount.
  ///
  /// In de, this message translates to:
  /// **'{count, plural, =1{1 Eintrag} other{{count} Einträge}}'**
  String mapEntriesCount(int count);

  /// No description provided for @mapShowAll.
  ///
  /// In de, this message translates to:
  /// **'Alle Einträge zeigen'**
  String get mapShowAll;

  /// No description provided for @mapEmptyTitle.
  ///
  /// In de, this message translates to:
  /// **'Noch nichts auf der Karte'**
  String get mapEmptyTitle;

  /// No description provided for @mapEmptyBody.
  ///
  /// In de, this message translates to:
  /// **'Länder mit Einträgen werden hier eingefärbt. Fotos mit Standort bekommen ihr Land automatisch, sonst über „Ort“ im Eintrag.'**
  String get mapEmptyBody;

  /// No description provided for @mapEmptyNoNotes.
  ///
  /// In de, this message translates to:
  /// **'Sobald du Notizen schreibst, färben sich hier die Länder, in denen du warst.'**
  String get mapEmptyNoNotes;

  /// No description provided for @editorTitleHint.
  ///
  /// In de, this message translates to:
  /// **'Titel'**
  String get editorTitleHint;

  /// No description provided for @editorTitleLabel.
  ///
  /// In de, this message translates to:
  /// **'Titel des Eintrags'**
  String get editorTitleLabel;

  /// No description provided for @emojiPickerTitle.
  ///
  /// In de, this message translates to:
  /// **'Emoji wählen'**
  String get emojiPickerTitle;

  /// No description provided for @emojiSearchHint.
  ///
  /// In de, this message translates to:
  /// **'Emoji suchen'**
  String get emojiSearchHint;

  /// No description provided for @emojiNoRecents.
  ///
  /// In de, this message translates to:
  /// **'Hier erscheinen die Emojis, die du zuletzt gewählt hast.'**
  String get emojiNoRecents;

  /// No description provided for @emojiCurrent.
  ///
  /// In de, this message translates to:
  /// **'Aktuelles Emoji'**
  String get emojiCurrent;

  /// No description provided for @emojiChange.
  ///
  /// In de, this message translates to:
  /// **'Emoji ändern'**
  String get emojiChange;

  /// No description provided for @memoriesSectionOnThisDay.
  ///
  /// In de, this message translates to:
  /// **'An diesem Tag'**
  String get memoriesSectionOnThisDay;

  /// No description provided for @memoriesSectionAround.
  ///
  /// In de, this message translates to:
  /// **'Rund um diesen Tag'**
  String get memoriesSectionAround;

  /// No description provided for @memoriesSectionMore.
  ///
  /// In de, this message translates to:
  /// **'Weitere Erinnerungen'**
  String get memoriesSectionMore;

  /// No description provided for @memoriesAnniversaryIn.
  ///
  /// In de, this message translates to:
  /// **'{count, plural, =1{Jahrestag morgen} other{Jahrestag in {count} Tagen}}'**
  String memoriesAnniversaryIn(int count);

  /// No description provided for @memoriesAnniversaryAgo.
  ///
  /// In de, this message translates to:
  /// **'{count, plural, =1{Jahrestag war gestern} other{Jahrestag vor {count} Tagen}}'**
  String memoriesAnniversaryAgo(int count);

  /// No description provided for @memoriesOpen.
  ///
  /// In de, this message translates to:
  /// **'Eintrag öffnen'**
  String get memoriesOpen;

  /// No description provided for @memoriesSwipeHint.
  ///
  /// In de, this message translates to:
  /// **'Nach oben wischen für mehr'**
  String get memoriesSwipeHint;

  /// No description provided for @journalRemoveFilter.
  ///
  /// In de, this message translates to:
  /// **'Filter entfernen'**
  String get journalRemoveFilter;

  /// No description provided for @suggestionsTags.
  ///
  /// In de, this message translates to:
  /// **'Stimmungen'**
  String get suggestionsTags;

  /// No description provided for @suggestionsPlaces.
  ///
  /// In de, this message translates to:
  /// **'Orte'**
  String get suggestionsPlaces;

  /// No description provided for @suggestionsCountries.
  ///
  /// In de, this message translates to:
  /// **'Länder'**
  String get suggestionsCountries;

  /// No description provided for @suggestionsRecent.
  ///
  /// In de, this message translates to:
  /// **'Frühere Suchen'**
  String get suggestionsRecent;

  /// No description provided for @suggestionsClearRecent.
  ///
  /// In de, this message translates to:
  /// **'Alle löschen'**
  String get suggestionsClearRecent;

  /// No description provided for @suggestionsRemoveRecent.
  ///
  /// In de, this message translates to:
  /// **'Aus den früheren Suchen löschen'**
  String get suggestionsRemoveRecent;

  /// No description provided for @geoBackfillProgress.
  ///
  /// In de, this message translates to:
  /// **'Orte und Länder werden ergänzt … {done} von {total}'**
  String geoBackfillProgress(int done, int total);

  /// No description provided for @mapTitle.
  ///
  /// In de, this message translates to:
  /// **'Weltkarte'**
  String get mapTitle;

  /// No description provided for @mapOpen.
  ///
  /// In de, this message translates to:
  /// **'Weltkarte öffnen'**
  String get mapOpen;

  /// No description provided for @mapShowBorders.
  ///
  /// In de, this message translates to:
  /// **'Ländergrenzen zeigen'**
  String get mapShowBorders;

  /// No description provided for @mapHideBorders.
  ///
  /// In de, this message translates to:
  /// **'Ländergrenzen ausblenden'**
  String get mapHideBorders;

  /// No description provided for @mapCountriesCount.
  ///
  /// In de, this message translates to:
  /// **'{count, plural, =1{1 Land} other{{count} Länder}}'**
  String mapCountriesCount(int count);

  /// No description provided for @mapNoEntriesIn.
  ///
  /// In de, this message translates to:
  /// **'Noch keine Einträge in {country}'**
  String mapNoEntriesIn(String country);

  /// No description provided for @countryLabel.
  ///
  /// In de, this message translates to:
  /// **'Land'**
  String get countryLabel;

  /// No description provided for @countryNone.
  ///
  /// In de, this message translates to:
  /// **'Kein Land'**
  String get countryNone;

  /// No description provided for @countryAdd.
  ///
  /// In de, this message translates to:
  /// **'Wählen'**
  String get countryAdd;

  /// No description provided for @countryChange.
  ///
  /// In de, this message translates to:
  /// **'Ändern'**
  String get countryChange;

  /// No description provided for @countryRemove.
  ///
  /// In de, this message translates to:
  /// **'Land entfernen'**
  String get countryRemove;

  /// No description provided for @countryPickerTitle.
  ///
  /// In de, this message translates to:
  /// **'Land wählen'**
  String get countryPickerTitle;

  /// No description provided for @countryPickerSearch.
  ///
  /// In de, this message translates to:
  /// **'Land suchen (deutsch oder englisch)'**
  String get countryPickerSearch;

  /// No description provided for @settingsSectionPlaces.
  ///
  /// In de, this message translates to:
  /// **'Orte und Länder'**
  String get settingsSectionPlaces;

  /// No description provided for @settingsGeoBackfill.
  ///
  /// In de, this message translates to:
  /// **'Orte und Länder aus Fotos ergänzen'**
  String get settingsGeoBackfill;

  /// No description provided for @settingsGeoBackfillIdle.
  ///
  /// In de, this message translates to:
  /// **'Für ältere Einträge: Land und nächster Ort aus dem Fotostandort, offline.'**
  String get settingsGeoBackfillIdle;

  /// No description provided for @settingsGeoBackfillDone.
  ///
  /// In de, this message translates to:
  /// **'Erledigt – du kannst den Abgleich jederzeit erneut starten.'**
  String get settingsGeoBackfillDone;

  /// No description provided for @settingsGeoBackfillCancelled.
  ///
  /// In de, this message translates to:
  /// **'Abgebrochen – tippe, um weiterzumachen.'**
  String get settingsGeoBackfillCancelled;

  /// No description provided for @settingsGeoBackfillRunning.
  ///
  /// In de, this message translates to:
  /// **'{done} von {total} – tippe zum Abbrechen'**
  String settingsGeoBackfillRunning(int done, int total);

  /// No description provided for @songAdd.
  ///
  /// In de, this message translates to:
  /// **'Lied hinzufügen'**
  String get songAdd;

  /// No description provided for @songSheetTitle.
  ///
  /// In de, this message translates to:
  /// **'Lied zum Eintrag'**
  String get songSheetTitle;

  /// No description provided for @songSearchHint.
  ///
  /// In de, this message translates to:
  /// **'Titel oder Künstler suchen'**
  String get songSearchHint;

  /// No description provided for @songNoResults.
  ///
  /// In de, this message translates to:
  /// **'Nichts gefunden.'**
  String get songNoResults;

  /// No description provided for @songSearchSource.
  ///
  /// In de, this message translates to:
  /// **'Musik von Spotify'**
  String get songSearchSource;

  /// No description provided for @songRemove.
  ///
  /// In de, this message translates to:
  /// **'Lied entfernen'**
  String get songRemove;

  /// No description provided for @songChange.
  ///
  /// In de, this message translates to:
  /// **'Lied ändern'**
  String get songChange;

  /// No description provided for @songPlay.
  ///
  /// In de, this message translates to:
  /// **'Abspielen'**
  String get songPlay;

  /// No description provided for @songPause.
  ///
  /// In de, this message translates to:
  /// **'Pausieren'**
  String get songPause;

  /// No description provided for @songOpenInSpotify.
  ///
  /// In de, this message translates to:
  /// **'In Spotify öffnen'**
  String get songOpenInSpotify;

  /// No description provided for @songRecordLabel.
  ///
  /// In de, this message translates to:
  /// **'Lied: {title} von {artist}'**
  String songRecordLabel(String title, String artist);

  /// No description provided for @songOf.
  ///
  /// In de, this message translates to:
  /// **'{title} · {artist}'**
  String songOf(String title, String artist);

  /// No description provided for @songErrorNotInstalled.
  ///
  /// In de, this message translates to:
  /// **'Dafür braucht es die Spotify-App auf diesem Gerät.'**
  String get songErrorNotInstalled;

  /// No description provided for @songErrorNotLoggedIn.
  ///
  /// In de, this message translates to:
  /// **'Bitte melde dich zuerst in der Spotify-App an.'**
  String get songErrorNotLoggedIn;

  /// No description provided for @songErrorNotAuthorized.
  ///
  /// In de, this message translates to:
  /// **'Spotify hat den Zugriff nicht erlaubt.'**
  String get songErrorNotAuthorized;

  /// No description provided for @songErrorCancelled.
  ///
  /// In de, this message translates to:
  /// **'Anmeldung bei Spotify abgebrochen.'**
  String get songErrorCancelled;

  /// No description provided for @songErrorNetwork.
  ///
  /// In de, this message translates to:
  /// **'Keine Verbindung zu Spotify.'**
  String get songErrorNetwork;

  /// No description provided for @songErrorPlayback.
  ///
  /// In de, this message translates to:
  /// **'Spotify konnte das Lied gerade nicht abspielen.'**
  String get songErrorPlayback;

  /// No description provided for @journalHasSong.
  ///
  /// In de, this message translates to:
  /// **'Mit Lied'**
  String get journalHasSong;

  /// No description provided for @songErrorSearch.
  ///
  /// In de, this message translates to:
  /// **'Die Suche bei Spotify hat nicht geklappt.'**
  String get songErrorSearch;

  /// No description provided for @songErrorForbidden.
  ///
  /// In de, this message translates to:
  /// **'Spotify lässt die Suche nicht zu. Ist dein Spotify-Konto im Developer Dashboard unter „User Management“ eingetragen?'**
  String get songErrorForbidden;

  /// No description provided for @songErrorRateLimit.
  ///
  /// In de, this message translates to:
  /// **'Spotify bremst gerade. Bitte gleich noch einmal versuchen.'**
  String get songErrorRateLimit;

  /// No description provided for @introSkip.
  ///
  /// In de, this message translates to:
  /// **'Überspringen'**
  String get introSkip;

  /// No description provided for @introNext.
  ///
  /// In de, this message translates to:
  /// **'Weiter'**
  String get introNext;

  /// No description provided for @introPageLabel.
  ///
  /// In de, this message translates to:
  /// **'Seite {page} von {count}'**
  String introPageLabel(int page, int count);

  /// No description provided for @introPrivateCaption.
  ///
  /// In de, this message translates to:
  /// **'nur für dich'**
  String get introPrivateCaption;

  /// No description provided for @introPrivateTitle.
  ///
  /// In de, this message translates to:
  /// **'Deine Gedanken gehören nur dir.'**
  String get introPrivateTitle;

  /// No description provided for @introPrivateBody.
  ///
  /// In de, this message translates to:
  /// **'Randnotiz ist ein stilles Erinnerungsbuch zu deinen Fotos. Was du schreibst, liegt auf diesem Gerät – ohne Konto, ohne Server von uns, ohne Werbung und ohne Tracking.'**
  String get introPrivateBody;

  /// No description provided for @introLockCaption.
  ///
  /// In de, this message translates to:
  /// **'gut verschlossen'**
  String get introLockCaption;

  /// No description provided for @introLockTitle.
  ///
  /// In de, this message translates to:
  /// **'Dein Tagebuch ist verschlossen.'**
  String get introLockTitle;

  /// No description provided for @introLockBody.
  ///
  /// In de, this message translates to:
  /// **'Hat dein Gerät eine Displaysperre, öffnet sich Randnotiz nur mit Fingerabdruck, Gesicht oder PIN – das ist von Anfang an so eingestellt. Solange die Sperre an ist, gibt es keine Screenshots und keine Vorschau in der App-Übersicht.'**
  String get introLockBody;

  /// No description provided for @introLockDebug.
  ///
  /// In de, this message translates to:
  /// **'In dieser Entwicklungsversion sind Screenshots trotzdem möglich.'**
  String get introLockDebug;

  /// No description provided for @introLockWidget.
  ///
  /// In de, this message translates to:
  /// **'Legst du das Widget auf den Startbildschirm, zeigt es dort ein Foto aus deinem Tagebuch – auch wenn die App gesperrt ist.'**
  String get introLockWidget;

  /// No description provided for @introBackupCaption.
  ///
  /// In de, this message translates to:
  /// **'sicher verwahrt'**
  String get introBackupCaption;

  /// No description provided for @introBackupTitle.
  ///
  /// In de, this message translates to:
  /// **'Eine Sicherung nur für dich.'**
  String get introBackupTitle;

  /// No description provided for @introBackupBody.
  ///
  /// In de, this message translates to:
  /// **'Wenn du möchtest, sichert Randnotiz deine Einträge im versteckten App-Ordner deines eigenen Google Drive – vorher auf diesem Gerät Ende-zu-Ende-verschlüsselt. Den Schlüssel hast nur du: dein Backup-Passwort und den Notfallschlüssel. Ohne Passwort und ohne Notfallschlüssel kann niemand die Sicherung öffnen – auch nicht Google oder wir, die Entwickler. Bewahre beides gut auf.'**
  String get introBackupBody;

  /// No description provided for @introOnlineTitle.
  ///
  /// In de, this message translates to:
  /// **'Wann Randnotiz ins Internet geht'**
  String get introOnlineTitle;

  /// No description provided for @introOnlineBody.
  ///
  /// In de, this message translates to:
  /// **'Wetter und Ortssuche fragen Open-Meteo – mit einer auf etwa 1 km gerundeten Position bzw. deinem Suchbegriff. Beim Diktieren hört je nach Gerät die Spracherkennung von Google zu; wer das nicht möchte, tippt einfach. Wenn du ein Lied verknüpfst, wird bei Spotify gesucht. Was du tippst, und deine Fotos verlassen das Gerät nur verschlüsselt – in deiner Sicherung.'**
  String get introOnlineBody;

  /// No description provided for @introSetUpBackup.
  ///
  /// In de, this message translates to:
  /// **'Sicherung einrichten'**
  String get introSetUpBackup;

  /// No description provided for @introHaveBackup.
  ///
  /// In de, this message translates to:
  /// **'Ich habe schon eine Sicherung'**
  String get introHaveBackup;

  /// No description provided for @introLater.
  ///
  /// In de, this message translates to:
  /// **'Später'**
  String get introLater;

  /// No description provided for @introStart.
  ///
  /// In de, this message translates to:
  /// **'Los geht’s'**
  String get introStart;

  /// No description provided for @introBackupUnavailable.
  ///
  /// In de, this message translates to:
  /// **'In dieser Version ist die Sicherung nicht verfügbar.'**
  String get introBackupUnavailable;

  /// No description provided for @settingsIntro.
  ///
  /// In de, this message translates to:
  /// **'Einführung ansehen'**
  String get settingsIntro;

  /// No description provided for @settingsIntroSubtitle.
  ///
  /// In de, this message translates to:
  /// **'Was Randnotiz mit deinen Daten macht'**
  String get settingsIntroSubtitle;

  /// No description provided for @backupRestoreGuide.
  ///
  /// In de, this message translates to:
  /// **'Du hast schon eine Sicherung? Verbinde dasselbe Google-Konto wie auf deinem bisherigen Gerät. Danach gibst du dein Backup-Passwort oder den Notfallschlüssel ein und holst deine Einträge zurück.'**
  String get backupRestoreGuide;

  /// No description provided for @backupRestoreNoBackup.
  ///
  /// In de, this message translates to:
  /// **'In diesem Google-Konto liegt keine Sicherung von Randnotiz. Liegt sie in einem anderen Konto, melde dich ab und verbinde das richtige.'**
  String get backupRestoreNoBackup;

  /// No description provided for @backupDevBanner.
  ///
  /// In de, this message translates to:
  /// **'Test-App – teilt die Sicherung mit der echten App. Was du hier einrichtest, sicherst oder löschst, betrifft dieselbe Sicherung in Google Drive.'**
  String get backupDevBanner;

  /// No description provided for @backupDevConfirmTitle.
  ///
  /// In de, this message translates to:
  /// **'Wirklich in der Test-App?'**
  String get backupDevConfirmTitle;

  /// No description provided for @backupDevConfirmAuto.
  ///
  /// In de, this message translates to:
  /// **'Danach sichert die Test-App automatisch in denselben Drive-Ordner wie die echte App – Testeinträge landen dann auch in deren Sicherung.'**
  String get backupDevConfirmAuto;

  /// No description provided for @backupDevConfirmDelete.
  ///
  /// In de, this message translates to:
  /// **'Das löscht auch die Sicherung der echten App, denn beide nutzen denselben Drive-Ordner. Das lässt sich nicht rückgängig machen.'**
  String get backupDevConfirmDelete;

  /// No description provided for @backupDevConfirmContinue.
  ///
  /// In de, this message translates to:
  /// **'Trotzdem fortfahren'**
  String get backupDevConfirmContinue;

  /// No description provided for @backupDevConfirmDeleteButton.
  ///
  /// In de, this message translates to:
  /// **'Trotzdem löschen'**
  String get backupDevConfirmDeleteButton;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['de'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'de':
      return AppLocalizationsDe();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
