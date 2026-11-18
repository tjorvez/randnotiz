import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_de.dart';
import 'app_localizations_en.dart';
import 'app_localizations_es.dart';
import 'app_localizations_fr.dart';

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
  static const List<Locale> supportedLocales = <Locale>[
    Locale('de'),
    Locale('en'),
    Locale('es'),
    Locale('fr'),
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'Randnotiz'**
  String get appTitle;

  /// The app's claim, shown on the start screen and in the introduction
  ///
  /// In en, this message translates to:
  /// **'Write your own story – instead of just swiping through other people’s.'**
  String get claim;

  /// No description provided for @navJournal.
  ///
  /// In en, this message translates to:
  /// **'Journal'**
  String get navJournal;

  /// No description provided for @navMemories.
  ///
  /// In en, this message translates to:
  /// **'Memories'**
  String get navMemories;

  /// No description provided for @settingsTooltip.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settingsTooltip;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @delete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// No description provided for @create.
  ///
  /// In en, this message translates to:
  /// **'Create'**
  String get create;

  /// No description provided for @done.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get done;

  /// No description provided for @ok.
  ///
  /// In en, this message translates to:
  /// **'OK'**
  String get ok;

  /// No description provided for @openSystemSettings.
  ///
  /// In en, this message translates to:
  /// **'Open settings'**
  String get openSystemSettings;

  /// No description provided for @errorGeneric.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong. Please try again.'**
  String get errorGeneric;

  /// No description provided for @editorTitleNew.
  ///
  /// In en, this message translates to:
  /// **'New note'**
  String get editorTitleNew;

  /// No description provided for @editorTitleEdit.
  ///
  /// In en, this message translates to:
  /// **'Note'**
  String get editorTitleEdit;

  /// No description provided for @editorHint.
  ///
  /// In en, this message translates to:
  /// **'What was going on? Write it down …'**
  String get editorHint;

  /// No description provided for @editorSaveFailed.
  ///
  /// In en, this message translates to:
  /// **'Not saved – trying again …'**
  String get editorSaveFailed;

  /// No description provided for @editorCleared.
  ///
  /// In en, this message translates to:
  /// **'Note emptied – it will be deleted when you close it.'**
  String get editorCleared;

  /// No description provided for @editorUndoClear.
  ///
  /// In en, this message translates to:
  /// **'Undo'**
  String get editorUndoClear;

  /// No description provided for @editorSaved.
  ///
  /// In en, this message translates to:
  /// **'Saved'**
  String get editorSaved;

  /// No description provided for @editorSaving.
  ///
  /// In en, this message translates to:
  /// **'Saving …'**
  String get editorSaving;

  /// No description provided for @editorDelete.
  ///
  /// In en, this message translates to:
  /// **'Delete note'**
  String get editorDelete;

  /// No description provided for @editorDeleteConfirmTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete note?'**
  String get editorDeleteConfirmTitle;

  /// No description provided for @editorDeleteConfirmBody.
  ///
  /// In en, this message translates to:
  /// **'This note’s text, moods and weather and Randnotiz’s copy of the photo will be removed. The photo in your gallery or in Google Photos stays untouched.'**
  String get editorDeleteConfirmBody;

  /// No description provided for @editorPhotoMissing.
  ///
  /// In en, this message translates to:
  /// **'The full-size photo is missing. The saved preview stays in the journal.'**
  String get editorPhotoMissing;

  /// No description provided for @editorDateTooltip.
  ///
  /// In en, this message translates to:
  /// **'Change date'**
  String get editorDateTooltip;

  /// No description provided for @editorEmptyDiscarded.
  ///
  /// In en, this message translates to:
  /// **'Empty notes aren’t saved.'**
  String get editorEmptyDiscarded;

  /// Short weather description
  ///
  /// In en, this message translates to:
  /// **'{kind, select, clear{Sunny} partlyCloudy{Partly cloudy} cloudy{Cloudy} fog{Fog} drizzle{Drizzle} rain{Rain} snow{Snow} thunderstorm{Thunderstorm} other{Weather}}'**
  String weatherKind(String kind);

  /// No description provided for @weatherTemperature.
  ///
  /// In en, this message translates to:
  /// **'{temperature} °C'**
  String weatherTemperature(String temperature);

  /// No description provided for @weatherLoading.
  ///
  /// In en, this message translates to:
  /// **'Looking up the weather …'**
  String get weatherLoading;

  /// No description provided for @weatherAdd.
  ///
  /// In en, this message translates to:
  /// **'Weather'**
  String get weatherAdd;

  /// No description provided for @weatherFetchAgain.
  ///
  /// In en, this message translates to:
  /// **'Try again'**
  String get weatherFetchAgain;

  /// No description provided for @weatherOffline.
  ///
  /// In en, this message translates to:
  /// **'The weather couldn’t be fetched. Maybe there’s no internet connection right now.'**
  String get weatherOffline;

  /// No description provided for @weatherTemperatureLabel.
  ///
  /// In en, this message translates to:
  /// **'Temperature in °C (optional)'**
  String get weatherTemperatureLabel;

  /// No description provided for @weatherRemove.
  ///
  /// In en, this message translates to:
  /// **'Remove weather'**
  String get weatherRemove;

  /// No description provided for @tagsAdd.
  ///
  /// In en, this message translates to:
  /// **'Mood'**
  String get tagsAdd;

  /// No description provided for @tagsSheetTitle.
  ///
  /// In en, this message translates to:
  /// **'Moods'**
  String get tagsSheetTitle;

  /// No description provided for @tagsCreateNew.
  ///
  /// In en, this message translates to:
  /// **'Create a new mood'**
  String get tagsCreateNew;

  /// No description provided for @tagNameLabel.
  ///
  /// In en, this message translates to:
  /// **'Name of the mood'**
  String get tagNameLabel;

  /// No description provided for @tagNameHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. Happy'**
  String get tagNameHint;

  /// No description provided for @tagDuplicate.
  ///
  /// In en, this message translates to:
  /// **'This mood already exists.'**
  String get tagDuplicate;

  /// No description provided for @tagNameEmpty.
  ///
  /// In en, this message translates to:
  /// **'Please enter a name.'**
  String get tagNameEmpty;

  /// No description provided for @tagsNone.
  ///
  /// In en, this message translates to:
  /// **'No moods yet. Create your first one.'**
  String get tagsNone;

  /// No description provided for @tagRemove.
  ///
  /// In en, this message translates to:
  /// **'Remove mood {name}'**
  String tagRemove(String name);

  /// No description provided for @micStart.
  ///
  /// In en, this message translates to:
  /// **'Dictate'**
  String get micStart;

  /// No description provided for @micStop.
  ///
  /// In en, this message translates to:
  /// **'Stop dictation'**
  String get micStop;

  /// No description provided for @micListening.
  ///
  /// In en, this message translates to:
  /// **'Listening …'**
  String get micListening;

  /// No description provided for @micUnavailableTooltip.
  ///
  /// In en, this message translates to:
  /// **'Dictation not available'**
  String get micUnavailableTooltip;

  /// No description provided for @micRationaleTitle.
  ///
  /// In en, this message translates to:
  /// **'Notes by voice'**
  String get micRationaleTitle;

  /// No description provided for @micRationaleBody.
  ///
  /// In en, this message translates to:
  /// **'To dictate your note, Randnotiz needs access to the microphone. Nothing is recorded or stored – only the recognised text ends up in your note. Depending on the device, your phone recognises speech itself or uses Google’s speech recognition service.'**
  String get micRationaleBody;

  /// No description provided for @micRationaleContinue.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get micRationaleContinue;

  /// No description provided for @micDenied.
  ///
  /// In en, this message translates to:
  /// **'Without microphone access, dictation isn’t possible. You can of course keep typing.'**
  String get micDenied;

  /// No description provided for @micPermanentlyDeniedTitle.
  ///
  /// In en, this message translates to:
  /// **'Microphone is blocked'**
  String get micPermanentlyDeniedTitle;

  /// No description provided for @micPermanentlyDeniedBody.
  ///
  /// In en, this message translates to:
  /// **'You declined microphone access. If you’d like to dictate, allow it in the app settings.'**
  String get micPermanentlyDeniedBody;

  /// No description provided for @micUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Speech recognition isn’t available on this device. Turn on e.g. “Speech Services by Google” in the system settings.'**
  String get micUnavailable;

  /// No description provided for @dictationNoSpeech.
  ///
  /// In en, this message translates to:
  /// **'I didn’t catch anything. Tap the microphone again.'**
  String get dictationNoSpeech;

  /// No description provided for @dictationNetwork.
  ///
  /// In en, this message translates to:
  /// **'Speech recognition needs an internet connection right now.'**
  String get dictationNetwork;

  /// No description provided for @dictationBusy.
  ///
  /// In en, this message translates to:
  /// **'Speech recognition is busy right now. Try again in a moment.'**
  String get dictationBusy;

  /// No description provided for @dictationLanguage.
  ///
  /// In en, this message translates to:
  /// **'This device’s speech recognition doesn’t support English.'**
  String get dictationLanguage;

  /// No description provided for @dictationAudio.
  ///
  /// In en, this message translates to:
  /// **'The microphone is in use right now, for example by a call. Your text is safe.'**
  String get dictationAudio;

  /// No description provided for @dictationUnknown.
  ///
  /// In en, this message translates to:
  /// **'Dictation was interrupted. Your text is safe.'**
  String get dictationUnknown;

  /// No description provided for @journalSearchHint.
  ///
  /// In en, this message translates to:
  /// **'Search notes'**
  String get journalSearchHint;

  /// No description provided for @journalEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'Your journal is still empty'**
  String get journalEmptyTitle;

  /// No description provided for @journalEmptyBody.
  ///
  /// In en, this message translates to:
  /// **'Tap the photo with the plus below, pick a picture from your gallery or from Google Photos and write your first note in the margin.'**
  String get journalEmptyBody;

  /// No description provided for @journalNoResults.
  ///
  /// In en, this message translates to:
  /// **'I couldn’t find anything for that.'**
  String get journalNoResults;

  /// No description provided for @journalResultCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, one{1 note} other{{count} notes}}'**
  String journalResultCount(int count);

  /// No description provided for @journalClearFilter.
  ///
  /// In en, this message translates to:
  /// **'Reset filters'**
  String get journalClearFilter;

  /// No description provided for @journalClearSearch.
  ///
  /// In en, this message translates to:
  /// **'Clear search'**
  String get journalClearSearch;

  /// No description provided for @yearsAgo.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, one{1 year ago} other{{count} years ago}}'**
  String yearsAgo(int count);

  /// No description provided for @monthsAgo.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, one{1 month ago} other{{count} months ago}}'**
  String monthsAgo(int count);

  /// No description provided for @weeksAgo.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, one{1 week ago} other{{count} weeks ago}}'**
  String weeksAgo(int count);

  /// No description provided for @daysAgo.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =0{Today} =1{Yesterday} other{{count} days ago}}'**
  String daysAgo(int count);

  /// No description provided for @memoriesEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'No memories yet'**
  String get memoriesEmptyTitle;

  /// No description provided for @memoriesEmptyBody.
  ///
  /// In en, this message translates to:
  /// **'Once you write notes, they’ll come back here on their anniversaries.'**
  String get memoriesEmptyBody;

  /// No description provided for @lockTitle.
  ///
  /// In en, this message translates to:
  /// **'Randnotiz is locked'**
  String get lockTitle;

  /// No description provided for @lockBody.
  ///
  /// In en, this message translates to:
  /// **'Unlock with your fingerprint, face or screen lock.'**
  String get lockBody;

  /// No description provided for @lockButton.
  ///
  /// In en, this message translates to:
  /// **'Unlock'**
  String get lockButton;

  /// No description provided for @lockReason.
  ///
  /// In en, this message translates to:
  /// **'Unlock Randnotiz'**
  String get lockReason;

  /// No description provided for @lockLockedOut.
  ///
  /// In en, this message translates to:
  /// **'Too many attempts. Please wait a moment and try again.'**
  String get lockLockedOut;

  /// No description provided for @lockFailed.
  ///
  /// In en, this message translates to:
  /// **'Unlocking didn’t work.'**
  String get lockFailed;

  /// No description provided for @settingsTitle.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settingsTitle;

  /// No description provided for @settingsSectionAppearance.
  ///
  /// In en, this message translates to:
  /// **'Appearance'**
  String get settingsSectionAppearance;

  /// No description provided for @settingsTheme.
  ///
  /// In en, this message translates to:
  /// **'Theme'**
  String get settingsTheme;

  /// No description provided for @themeSystem.
  ///
  /// In en, this message translates to:
  /// **'System'**
  String get themeSystem;

  /// No description provided for @themeLight.
  ///
  /// In en, this message translates to:
  /// **'Light'**
  String get themeLight;

  /// No description provided for @themeDark.
  ///
  /// In en, this message translates to:
  /// **'Dark'**
  String get themeDark;

  /// No description provided for @settingsLanguage.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get settingsLanguage;

  /// No description provided for @languageSystem.
  ///
  /// In en, this message translates to:
  /// **'Device language'**
  String get languageSystem;

  /// Setting 'follow the device'; the placeholder is the language currently shown, in its own name
  ///
  /// In en, this message translates to:
  /// **'Device language ({language})'**
  String languageSystemShowing(String language);

  /// No description provided for @settingsSectionPrivacy.
  ///
  /// In en, this message translates to:
  /// **'Privacy'**
  String get settingsSectionPrivacy;

  /// No description provided for @settingsLock.
  ///
  /// In en, this message translates to:
  /// **'Biometric lock'**
  String get settingsLock;

  /// No description provided for @settingsLockSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Fingerprint, face or screen lock when opening. While the lock is on, screenshots and screen casting are blocked.'**
  String get settingsLockSubtitle;

  /// No description provided for @settingsLockUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Set up a screen lock on your device first.'**
  String get settingsLockUnavailable;

  /// No description provided for @settingsLockTimeout.
  ///
  /// In en, this message translates to:
  /// **'Lock after'**
  String get settingsLockTimeout;

  /// No description provided for @lockTimeoutImmediately.
  ///
  /// In en, this message translates to:
  /// **'Immediately'**
  String get lockTimeoutImmediately;

  /// No description provided for @lockTimeoutMinutes.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, one{1 minute in the background} other{{count} minutes in the background}}'**
  String lockTimeoutMinutes(int count);

  /// No description provided for @settingsSectionTags.
  ///
  /// In en, this message translates to:
  /// **'Moods'**
  String get settingsSectionTags;

  /// No description provided for @settingsManageTags.
  ///
  /// In en, this message translates to:
  /// **'Manage moods'**
  String get settingsManageTags;

  /// No description provided for @settingsSectionWidget.
  ///
  /// In en, this message translates to:
  /// **'Widget'**
  String get settingsSectionWidget;

  /// No description provided for @settingsWidgetText.
  ///
  /// In en, this message translates to:
  /// **'Text preview in the widget'**
  String get settingsWidgetText;

  /// No description provided for @settingsWidgetTextSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Shows the beginning of the note on the home screen – visible to anyone who sees your phone.'**
  String get settingsWidgetTextSubtitle;

  /// No description provided for @settingsSectionMemories.
  ///
  /// In en, this message translates to:
  /// **'Memories'**
  String get settingsSectionMemories;

  /// Settings: the person's date of birth, only used for lifeShare
  ///
  /// In en, this message translates to:
  /// **'Birthday'**
  String get settingsBirthday;

  /// No description provided for @settingsBirthdayNotSet.
  ///
  /// In en, this message translates to:
  /// **'Optional – shows next to memories how much of your life so far you had lived back then. Stays on this device.'**
  String get settingsBirthdayNotSet;

  /// No description provided for @settingsBirthdayRemove.
  ///
  /// In en, this message translates to:
  /// **'Remove birthday'**
  String get settingsBirthdayRemove;

  /// Next to "5 years ago": the share of the life so far that the person had lived on that day (age then / age today). percent is already formatted, e.g. "50%" or "50 %"
  ///
  /// In en, this message translates to:
  /// **'{percent} of your life'**
  String lifeShare(String percent);

  /// No description provided for @lostNotesTitle.
  ///
  /// In en, this message translates to:
  /// **'Your notes could not be opened'**
  String get lostNotesTitle;

  /// No description provided for @lostNotesBody.
  ///
  /// In en, this message translates to:
  /// **'The key to your notes is gone from this device – this rarely happens, for example when Android resets its protected storage. Randnotiz has therefore started a new, empty diary. Your photos are still here. If you have a backup in Google Drive, you can bring your entries back with it.'**
  String get lostNotesBody;

  /// No description provided for @lostNotesRestore.
  ///
  /// In en, this message translates to:
  /// **'Restore backup'**
  String get lostNotesRestore;

  /// No description provided for @lostNotesLater.
  ///
  /// In en, this message translates to:
  /// **'Not now'**
  String get lostNotesLater;

  /// No description provided for @lostNotesMeanwhile.
  ///
  /// In en, this message translates to:
  /// **'Until you decide, Randnotiz keeps all your photos and pauses automatic backups, so your existing backup is not replaced.'**
  String get lostNotesMeanwhile;

  /// No description provided for @lostNotesStartOver.
  ///
  /// In en, this message translates to:
  /// **'Continue without'**
  String get lostNotesStartOver;

  /// No description provided for @backupLostNotesTitle.
  ///
  /// In en, this message translates to:
  /// **'Replace your earlier backup?'**
  String get backupLostNotesTitle;

  /// No description provided for @backupLostNotesBody.
  ///
  /// In en, this message translates to:
  /// **'Your notes could not be opened recently. If you back up now, the new, almost empty diary will gradually replace your earlier backup. Better restore it first.'**
  String get backupLostNotesBody;

  /// No description provided for @backupLostNotesConfirm.
  ///
  /// In en, this message translates to:
  /// **'Back up anyway'**
  String get backupLostNotesConfirm;

  /// No description provided for @databaseUnavailableTitle.
  ///
  /// In en, this message translates to:
  /// **'Your notes can\'t be opened right now'**
  String get databaseUnavailableTitle;

  /// No description provided for @databaseUnavailableBody.
  ///
  /// In en, this message translates to:
  /// **'Android is not handing out the key to your notes at the moment. Nothing is lost. Try again in a moment, or restart your phone.'**
  String get databaseUnavailableBody;

  /// No description provided for @databaseUnavailableRetry.
  ///
  /// In en, this message translates to:
  /// **'Try again'**
  String get databaseUnavailableRetry;

  /// Home screen widget: title while there is no memory for today
  ///
  /// In en, this message translates to:
  /// **'Memory of the day'**
  String get widgetTitle;

  /// No description provided for @widgetEmpty.
  ///
  /// In en, this message translates to:
  /// **'No memory yet today – open Randnotiz.'**
  String get widgetEmpty;

  /// No description provided for @settingsSectionBackup.
  ///
  /// In en, this message translates to:
  /// **'Backup'**
  String get settingsSectionBackup;

  /// No description provided for @settingsBackupDrive.
  ///
  /// In en, this message translates to:
  /// **'Backup in Google Drive'**
  String get settingsBackupDrive;

  /// No description provided for @settingsBackupOff.
  ///
  /// In en, this message translates to:
  /// **'Off – your notes are only on this device'**
  String get settingsBackupOff;

  /// No description provided for @settingsBackupUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Not available in this version'**
  String get settingsBackupUnavailable;

  /// No description provided for @settingsBackupNeedsSetup.
  ///
  /// In en, this message translates to:
  /// **'Connected – set a backup password'**
  String get settingsBackupNeedsSetup;

  /// No description provided for @settingsBackupNeedsUnlock.
  ///
  /// In en, this message translates to:
  /// **'Backup found – tap to unlock'**
  String get settingsBackupNeedsUnlock;

  /// No description provided for @settingsBackupRestorePending.
  ///
  /// In en, this message translates to:
  /// **'Paused – backup not brought over yet'**
  String get settingsBackupRestorePending;

  /// No description provided for @settingsBackupNever.
  ///
  /// In en, this message translates to:
  /// **'Encrypted and on – no backup yet'**
  String get settingsBackupNever;

  /// No description provided for @settingsBackupLast.
  ///
  /// In en, this message translates to:
  /// **'Last backup: {when}'**
  String settingsBackupLast(String when);

  /// No description provided for @settingsBackupRunning.
  ///
  /// In en, this message translates to:
  /// **'Backing up …'**
  String get settingsBackupRunning;

  /// No description provided for @backupTitle.
  ///
  /// In en, this message translates to:
  /// **'Backup in Google Drive'**
  String get backupTitle;

  /// No description provided for @backupIntro.
  ///
  /// In en, this message translates to:
  /// **'Encrypted in your Google Drive – Google only sees unreadable data.'**
  String get backupIntro;

  /// No description provided for @backupConnect.
  ///
  /// In en, this message translates to:
  /// **'Connect with Google'**
  String get backupConnect;

  /// No description provided for @backupConnectFailed.
  ///
  /// In en, this message translates to:
  /// **'Connecting with Google didn’t work.'**
  String get backupConnectFailed;

  /// No description provided for @backupAccount.
  ///
  /// In en, this message translates to:
  /// **'Google account'**
  String get backupAccount;

  /// No description provided for @backupSetupIntro.
  ///
  /// In en, this message translates to:
  /// **'The backup password opens the backup on a new device. It isn’t your Google password.'**
  String get backupSetupIntro;

  /// No description provided for @backupSetupButton.
  ///
  /// In en, this message translates to:
  /// **'Set backup password'**
  String get backupSetupButton;

  /// No description provided for @backupPasswordTitle.
  ///
  /// In en, this message translates to:
  /// **'Backup password'**
  String get backupPasswordTitle;

  /// No description provided for @backupPasswordNewTitle.
  ///
  /// In en, this message translates to:
  /// **'New backup password'**
  String get backupPasswordNewTitle;

  /// No description provided for @backupPasswordLabel.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get backupPasswordLabel;

  /// No description provided for @backupPasswordRepeat.
  ///
  /// In en, this message translates to:
  /// **'Repeat password'**
  String get backupPasswordRepeat;

  /// No description provided for @backupPasswordTooShort.
  ///
  /// In en, this message translates to:
  /// **'At least {count} characters'**
  String backupPasswordTooShort(int count);

  /// No description provided for @backupPasswordMismatch.
  ///
  /// In en, this message translates to:
  /// **'The passwords don’t match'**
  String get backupPasswordMismatch;

  /// No description provided for @backupPasswordHint.
  ///
  /// In en, this message translates to:
  /// **'Easy to remember but hard to guess – e.g. a short sentence. Without the password and the emergency key, nobody can open the backup, not even us.'**
  String get backupPasswordHint;

  /// No description provided for @backupWorking.
  ///
  /// In en, this message translates to:
  /// **'One moment …'**
  String get backupWorking;

  /// No description provided for @backupEmergencyTitle.
  ///
  /// In en, this message translates to:
  /// **'Your emergency key'**
  String get backupEmergencyTitle;

  /// No description provided for @backupEmergencyIntro.
  ///
  /// In en, this message translates to:
  /// **'If you forget the backup password, this key opens your backup. Write it down and keep it safe – it’s only shown now.'**
  String get backupEmergencyIntro;

  /// No description provided for @backupEmergencyCopy.
  ///
  /// In en, this message translates to:
  /// **'Copy'**
  String get backupEmergencyCopy;

  /// No description provided for @backupEmergencyCopied.
  ///
  /// In en, this message translates to:
  /// **'Emergency key copied'**
  String get backupEmergencyCopied;

  /// No description provided for @backupEmergencyConfirm.
  ///
  /// In en, this message translates to:
  /// **'I’ve written down the emergency key safely'**
  String get backupEmergencyConfirm;

  /// No description provided for @backupEmergencyDone.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get backupEmergencyDone;

  /// No description provided for @backupUnlockIntro.
  ///
  /// In en, this message translates to:
  /// **'There’s an encrypted backup in your Google account. Enter the backup password or the emergency key to open it on this device.'**
  String get backupUnlockIntro;

  /// No description provided for @backupUnlockFoundAt.
  ///
  /// In en, this message translates to:
  /// **'Last backup: {when}'**
  String backupUnlockFoundAt(String when);

  /// No description provided for @backupUnlockLabel.
  ///
  /// In en, this message translates to:
  /// **'Password or emergency key'**
  String get backupUnlockLabel;

  /// No description provided for @backupUnlockButton.
  ///
  /// In en, this message translates to:
  /// **'Unlock'**
  String get backupUnlockButton;

  /// No description provided for @backupUnlockWrong.
  ///
  /// In en, this message translates to:
  /// **'That doesn’t match. Check the password or emergency key.'**
  String get backupUnlockWrong;

  /// No description provided for @backupRestoreAskTitle.
  ///
  /// In en, this message translates to:
  /// **'Restore notes?'**
  String get backupRestoreAskTitle;

  /// No description provided for @backupRestoreAskBody.
  ///
  /// In en, this message translates to:
  /// **'The entries from the backup are added to this device. Whatever is newer here stays as it is.'**
  String get backupRestoreAskBody;

  /// No description provided for @backupRestoreLater.
  ///
  /// In en, this message translates to:
  /// **'Later'**
  String get backupRestoreLater;

  /// No description provided for @backupRestore.
  ///
  /// In en, this message translates to:
  /// **'Restore'**
  String get backupRestore;

  /// No description provided for @backupRestoreDone.
  ///
  /// In en, this message translates to:
  /// **'{added, plural, =0{No new entries} =1{1 entry restored} other{{added} entries restored}}'**
  String backupRestoreDone(int added);

  /// No description provided for @backupRestoreUpdated.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, one{1 entry updated} other{{count} entries updated}}'**
  String backupRestoreUpdated(int count);

  /// No description provided for @backupNow.
  ///
  /// In en, this message translates to:
  /// **'Back up now'**
  String get backupNow;

  /// No description provided for @backupDone.
  ///
  /// In en, this message translates to:
  /// **'Backed up'**
  String get backupDone;

  /// No description provided for @backupUnchanged.
  ///
  /// In en, this message translates to:
  /// **'Already up to date – nothing to back up'**
  String get backupUnchanged;

  /// No description provided for @backupStatusNever.
  ///
  /// In en, this message translates to:
  /// **'No backup yet.'**
  String get backupStatusNever;

  /// No description provided for @backupStatusLast.
  ///
  /// In en, this message translates to:
  /// **'Last backup: {when}'**
  String backupStatusLast(String when);

  /// No description provided for @backupStatusCounts.
  ///
  /// In en, this message translates to:
  /// **'{notes, plural, one{1 entry} other{{notes} entries}} · {photos, plural, one{1 picture} other{{photos} pictures}}'**
  String backupStatusCounts(int notes, int photos);

  /// No description provided for @backupStatusAuto.
  ///
  /// In en, this message translates to:
  /// **'Backups happen automatically once a day when you open the app.'**
  String get backupStatusAuto;

  /// No description provided for @backupStatusPending.
  ///
  /// In en, this message translates to:
  /// **'Backup not brought over yet'**
  String get backupStatusPending;

  /// No description provided for @backupStatusPendingHint.
  ///
  /// In en, this message translates to:
  /// **'Automatic backups are paused until the entries from your backup are on this device too – so nothing gets overwritten. “Restore” or “Back up now” brings them here.'**
  String get backupStatusPendingHint;

  /// No description provided for @backupProblemOffline.
  ///
  /// In en, this message translates to:
  /// **'No connection to Google Drive – it will try again later.'**
  String get backupProblemOffline;

  /// No description provided for @backupProblemAuth.
  ///
  /// In en, this message translates to:
  /// **'Google denied access. Please connect again.'**
  String get backupProblemAuth;

  /// No description provided for @backupProblemQuota.
  ///
  /// In en, this message translates to:
  /// **'Your Google Drive storage is full.'**
  String get backupProblemQuota;

  /// No description provided for @backupProblemDamaged.
  ///
  /// In en, this message translates to:
  /// **'The backup in Google Drive is damaged or belongs to a different key.'**
  String get backupProblemDamaged;

  /// No description provided for @backupProblemUnknown.
  ///
  /// In en, this message translates to:
  /// **'The backup didn’t work.'**
  String get backupProblemUnknown;

  /// No description provided for @backupReconnect.
  ///
  /// In en, this message translates to:
  /// **'Connect again'**
  String get backupReconnect;

  /// No description provided for @backupChangePassword.
  ///
  /// In en, this message translates to:
  /// **'Change backup password'**
  String get backupChangePassword;

  /// No description provided for @backupPasswordChanged.
  ///
  /// In en, this message translates to:
  /// **'Backup password changed'**
  String get backupPasswordChanged;

  /// No description provided for @backupRenewEmergency.
  ///
  /// In en, this message translates to:
  /// **'Create a new emergency key'**
  String get backupRenewEmergency;

  /// No description provided for @backupRenewEmergencyAsk.
  ///
  /// In en, this message translates to:
  /// **'The current emergency key will stop working.'**
  String get backupRenewEmergencyAsk;

  /// No description provided for @backupRenewEmergencyButton.
  ///
  /// In en, this message translates to:
  /// **'Create new key'**
  String get backupRenewEmergencyButton;

  /// No description provided for @backupDisconnect.
  ///
  /// In en, this message translates to:
  /// **'Sign out'**
  String get backupDisconnect;

  /// No description provided for @backupDisconnectTitle.
  ///
  /// In en, this message translates to:
  /// **'Sign out of Google Drive?'**
  String get backupDisconnectTitle;

  /// No description provided for @backupDisconnectBody.
  ///
  /// In en, this message translates to:
  /// **'This device will stop backing up. Your notes here stay as they are.'**
  String get backupDisconnectBody;

  /// No description provided for @backupDisconnectDelete.
  ///
  /// In en, this message translates to:
  /// **'Also delete the backup in Google Drive'**
  String get backupDisconnectDelete;

  /// No description provided for @settingsSectionAbout.
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get settingsSectionAbout;

  /// No description provided for @settingsAbout.
  ///
  /// In en, this message translates to:
  /// **'About Randnotiz'**
  String get settingsAbout;

  /// No description provided for @settingsPrivacyPolicy.
  ///
  /// In en, this message translates to:
  /// **'Privacy policy'**
  String get settingsPrivacyPolicy;

  /// No description provided for @settingsPrivacyPolicyOpenFailed.
  ///
  /// In en, this message translates to:
  /// **'The link couldn’t be opened: {url}'**
  String settingsPrivacyPolicyOpenFailed(String url);

  /// No description provided for @settingsAboutLegalese.
  ///
  /// In en, this message translates to:
  /// **'A private photo diary. Your notes stay on your device.\n\nPrivacy: {url}\n\n{copyright}. Free software under the GNU General Public License v3 or later, without any warranty. Source code: {source}\n\nMap data: Natural Earth (public domain). Places: GeoNames (CC BY 4.0). Song search, covers and previews: Apple (iTunes Search API). Details under “Licenses”.'**
  String settingsAboutLegalese(String url, String copyright, String source);

  /// No description provided for @tagManageTitle.
  ///
  /// In en, this message translates to:
  /// **'Manage moods'**
  String get tagManageTitle;

  /// No description provided for @tagDeleteConfirmTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete mood “{name}”?'**
  String tagDeleteConfirmTitle(String name);

  /// No description provided for @tagDeleteConfirmBody.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =0{It isn’t used anywhere yet.} =1{It will be removed from 1 note. The note itself stays.} other{It will be removed from {count} notes. The notes themselves stay.}}'**
  String tagDeleteConfirmBody(int count);

  /// No description provided for @tagUsage.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =0{Not used} =1{1 note} other{{count} notes}}'**
  String tagUsage(int count);

  /// No description provided for @tagEdit.
  ///
  /// In en, this message translates to:
  /// **'Edit mood'**
  String get tagEdit;

  /// No description provided for @newEntryTooltip.
  ///
  /// In en, this message translates to:
  /// **'New entry – pick a photo'**
  String get newEntryTooltip;

  /// No description provided for @newEntryImporting.
  ///
  /// In en, this message translates to:
  /// **'Bringing in the photo …'**
  String get newEntryImporting;

  /// No description provided for @newEntryImportFailed.
  ///
  /// In en, this message translates to:
  /// **'The photo couldn’t be brought in.'**
  String get newEntryImportFailed;

  /// No description provided for @placeAdd.
  ///
  /// In en, this message translates to:
  /// **'Place'**
  String get placeAdd;

  /// No description provided for @placeSheetTitle.
  ///
  /// In en, this message translates to:
  /// **'Country and place'**
  String get placeSheetTitle;

  /// No description provided for @placeSearchHint.
  ///
  /// In en, this message translates to:
  /// **'Search for a place, e.g. London'**
  String get placeSearchHint;

  /// No description provided for @placeNoResults.
  ///
  /// In en, this message translates to:
  /// **'No place found.'**
  String get placeNoResults;

  /// No description provided for @placePrivacy.
  ///
  /// In en, this message translates to:
  /// **'Only the country and the name of the place are stored. For the weather, the approximate location is sent to the weather service.'**
  String get placePrivacy;

  /// No description provided for @placeRemove.
  ///
  /// In en, this message translates to:
  /// **'Remove'**
  String get placeRemove;

  /// No description provided for @placeWeatherHint.
  ///
  /// In en, this message translates to:
  /// **'With a place, Randnotiz also shows the weather on that day.'**
  String get placeWeatherHint;

  /// No description provided for @weatherAdjust.
  ///
  /// In en, this message translates to:
  /// **'Adjust the weather yourself'**
  String get weatherAdjust;

  /// No description provided for @editorMetaMood.
  ///
  /// In en, this message translates to:
  /// **'Mood'**
  String get editorMetaMood;

  /// No description provided for @navCollections.
  ///
  /// In en, this message translates to:
  /// **'Collections'**
  String get navCollections;

  /// No description provided for @collectionAddShort.
  ///
  /// In en, this message translates to:
  /// **'Collection'**
  String get collectionAddShort;

  /// No description provided for @collectionPickerTitle.
  ///
  /// In en, this message translates to:
  /// **'Collections'**
  String get collectionPickerTitle;

  /// No description provided for @collectionPickerHint.
  ///
  /// In en, this message translates to:
  /// **'Gather entries that belong together – a trip, a summer, a person.'**
  String get collectionPickerHint;

  /// No description provided for @collectionNew.
  ///
  /// In en, this message translates to:
  /// **'New collection'**
  String get collectionNew;

  /// No description provided for @collectionNameLabel.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get collectionNameLabel;

  /// No description provided for @collectionNameHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. Italy 2024'**
  String get collectionNameHint;

  /// No description provided for @collectionRename.
  ///
  /// In en, this message translates to:
  /// **'Rename'**
  String get collectionRename;

  /// No description provided for @collectionDelete.
  ///
  /// In en, this message translates to:
  /// **'Delete collection'**
  String get collectionDelete;

  /// No description provided for @collectionDeleteConfirmTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete collection?'**
  String get collectionDeleteConfirmTitle;

  /// No description provided for @collectionDeleteConfirmBody.
  ///
  /// In en, this message translates to:
  /// **'“{name}” will be deleted. The entries themselves stay in the journal.'**
  String collectionDeleteConfirmBody(String name);

  /// No description provided for @collectionEntryCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =0{Still empty} =1{1 entry} other{{count} entries}}'**
  String collectionEntryCount(int count);

  /// No description provided for @collectionsReorderHint.
  ///
  /// In en, this message translates to:
  /// **'Press and hold, then drag to sort'**
  String get collectionsReorderHint;

  /// No description provided for @collectionMoveEarlier.
  ///
  /// In en, this message translates to:
  /// **'Move forward'**
  String get collectionMoveEarlier;

  /// No description provided for @collectionMoveLater.
  ///
  /// In en, this message translates to:
  /// **'Move back'**
  String get collectionMoveLater;

  /// No description provided for @collectionsEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'No collections yet'**
  String get collectionsEmptyTitle;

  /// No description provided for @collectionsEmptyBody.
  ///
  /// In en, this message translates to:
  /// **'Bundle entries that belong together – a trip, a summer, a person.'**
  String get collectionsEmptyBody;

  /// No description provided for @collectionEmptyBody.
  ///
  /// In en, this message translates to:
  /// **'Add entries – here or right in a note via “Collection”.'**
  String get collectionEmptyBody;

  /// No description provided for @collectionAddEntries.
  ///
  /// In en, this message translates to:
  /// **'Add entries'**
  String get collectionAddEntries;

  /// No description provided for @collectionAddEntriesNone.
  ///
  /// In en, this message translates to:
  /// **'All entries are already in this collection.'**
  String get collectionAddEntriesNone;

  /// No description provided for @collectionAddSelected.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =0{Add} =1{Add 1 entry} other{Add {count} entries}}'**
  String collectionAddSelected(int count);

  /// No description provided for @collectionRemoveEntry.
  ///
  /// In en, this message translates to:
  /// **'Remove from the collection'**
  String get collectionRemoveEntry;

  /// No description provided for @collectionNeighboursTitle.
  ///
  /// In en, this message translates to:
  /// **'{name} · {position} of {total}'**
  String collectionNeighboursTitle(String name, int position, int total);

  /// No description provided for @collectionPrevious.
  ///
  /// In en, this message translates to:
  /// **'Previous'**
  String get collectionPrevious;

  /// No description provided for @collectionNext.
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get collectionNext;

  /// No description provided for @collectionStart.
  ///
  /// In en, this message translates to:
  /// **'The collection starts here'**
  String get collectionStart;

  /// No description provided for @collectionEnd.
  ///
  /// In en, this message translates to:
  /// **'The collection ends here'**
  String get collectionEnd;

  /// No description provided for @mapEntriesCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, one{1 entry} other{{count} entries}}'**
  String mapEntriesCount(int count);

  /// No description provided for @mapShowAll.
  ///
  /// In en, this message translates to:
  /// **'Show all entries'**
  String get mapShowAll;

  /// No description provided for @mapEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'Nothing on the map yet'**
  String get mapEmptyTitle;

  /// No description provided for @mapEmptyBody.
  ///
  /// In en, this message translates to:
  /// **'Countries with entries are coloured in here. An entry gets its country via “Place”.'**
  String get mapEmptyBody;

  /// No description provided for @mapEmptyNoNotes.
  ///
  /// In en, this message translates to:
  /// **'Once you write notes, the countries you’ve been to light up here.'**
  String get mapEmptyNoNotes;

  /// No description provided for @editorTitleHint.
  ///
  /// In en, this message translates to:
  /// **'Title'**
  String get editorTitleHint;

  /// No description provided for @editorTitleLabel.
  ///
  /// In en, this message translates to:
  /// **'Title of the entry'**
  String get editorTitleLabel;

  /// No description provided for @emojiPickerTitle.
  ///
  /// In en, this message translates to:
  /// **'Choose an emoji'**
  String get emojiPickerTitle;

  /// No description provided for @emojiSearchHint.
  ///
  /// In en, this message translates to:
  /// **'Search emoji'**
  String get emojiSearchHint;

  /// No description provided for @emojiNoRecents.
  ///
  /// In en, this message translates to:
  /// **'The emojis you picked last will show up here.'**
  String get emojiNoRecents;

  /// No description provided for @emojiCurrent.
  ///
  /// In en, this message translates to:
  /// **'Current emoji'**
  String get emojiCurrent;

  /// No description provided for @emojiChange.
  ///
  /// In en, this message translates to:
  /// **'Change emoji'**
  String get emojiChange;

  /// No description provided for @memoriesSectionOnThisDay.
  ///
  /// In en, this message translates to:
  /// **'On this day'**
  String get memoriesSectionOnThisDay;

  /// No description provided for @memoriesSectionAround.
  ///
  /// In en, this message translates to:
  /// **'Around this day'**
  String get memoriesSectionAround;

  /// No description provided for @memoriesSectionMore.
  ///
  /// In en, this message translates to:
  /// **'More memories'**
  String get memoriesSectionMore;

  /// No description provided for @memoriesAnniversaryIn.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, one{Anniversary tomorrow} other{Anniversary in {count} days}}'**
  String memoriesAnniversaryIn(int count);

  /// No description provided for @memoriesAnniversaryAgo.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, one{Anniversary was yesterday} other{Anniversary {count} days ago}}'**
  String memoriesAnniversaryAgo(int count);

  /// No description provided for @memoriesOpen.
  ///
  /// In en, this message translates to:
  /// **'Open entry'**
  String get memoriesOpen;

  /// No description provided for @memoriesSwipeHint.
  ///
  /// In en, this message translates to:
  /// **'Swipe up for more'**
  String get memoriesSwipeHint;

  /// No description provided for @journalRemoveFilter.
  ///
  /// In en, this message translates to:
  /// **'Remove filter'**
  String get journalRemoveFilter;

  /// No description provided for @suggestionsTags.
  ///
  /// In en, this message translates to:
  /// **'Moods'**
  String get suggestionsTags;

  /// No description provided for @suggestionsPlaces.
  ///
  /// In en, this message translates to:
  /// **'Places'**
  String get suggestionsPlaces;

  /// No description provided for @suggestionsCountries.
  ///
  /// In en, this message translates to:
  /// **'Countries'**
  String get suggestionsCountries;

  /// No description provided for @suggestionsRecent.
  ///
  /// In en, this message translates to:
  /// **'Recent searches'**
  String get suggestionsRecent;

  /// No description provided for @suggestionsClearRecent.
  ///
  /// In en, this message translates to:
  /// **'Clear all'**
  String get suggestionsClearRecent;

  /// No description provided for @suggestionsRemoveRecent.
  ///
  /// In en, this message translates to:
  /// **'Remove from recent searches'**
  String get suggestionsRemoveRecent;

  /// No description provided for @geoBackfillProgress.
  ///
  /// In en, this message translates to:
  /// **'Adding places and countries … {done} of {total}'**
  String geoBackfillProgress(int done, int total);

  /// No description provided for @mapTitle.
  ///
  /// In en, this message translates to:
  /// **'World map'**
  String get mapTitle;

  /// No description provided for @mapOpen.
  ///
  /// In en, this message translates to:
  /// **'Open world map'**
  String get mapOpen;

  /// No description provided for @mapShowBorders.
  ///
  /// In en, this message translates to:
  /// **'Show borders'**
  String get mapShowBorders;

  /// No description provided for @mapHideBorders.
  ///
  /// In en, this message translates to:
  /// **'Hide borders'**
  String get mapHideBorders;

  /// No description provided for @mapCountriesCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, one{1 country} other{{count} countries}}'**
  String mapCountriesCount(int count);

  /// No description provided for @mapNoEntriesIn.
  ///
  /// In en, this message translates to:
  /// **'No entries in {country} yet'**
  String mapNoEntriesIn(String country);

  /// No description provided for @countryLabel.
  ///
  /// In en, this message translates to:
  /// **'Country'**
  String get countryLabel;

  /// No description provided for @countryNone.
  ///
  /// In en, this message translates to:
  /// **'No country'**
  String get countryNone;

  /// No description provided for @countryAdd.
  ///
  /// In en, this message translates to:
  /// **'Choose'**
  String get countryAdd;

  /// No description provided for @countryChange.
  ///
  /// In en, this message translates to:
  /// **'Change'**
  String get countryChange;

  /// No description provided for @countryRemove.
  ///
  /// In en, this message translates to:
  /// **'Remove country'**
  String get countryRemove;

  /// No description provided for @countryPickerTitle.
  ///
  /// In en, this message translates to:
  /// **'Choose a country'**
  String get countryPickerTitle;

  /// No description provided for @countryPickerSearch.
  ///
  /// In en, this message translates to:
  /// **'Search for a country'**
  String get countryPickerSearch;

  /// No description provided for @introSkip.
  ///
  /// In en, this message translates to:
  /// **'Skip'**
  String get introSkip;

  /// No description provided for @introNext.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get introNext;

  /// No description provided for @introPageLabel.
  ///
  /// In en, this message translates to:
  /// **'Page {page} of {count}'**
  String introPageLabel(int page, int count);

  /// No description provided for @introWelcome.
  ///
  /// In en, this message translates to:
  /// **'Welcome to Randnotiz'**
  String get introWelcome;

  /// No description provided for @introWelcomeBody.
  ///
  /// In en, this message translates to:
  /// **'A quiet photo diary for the stories behind your pictures.'**
  String get introWelcomeBody;

  /// No description provided for @introLanguageTitle.
  ///
  /// In en, this message translates to:
  /// **'Your language'**
  String get introLanguageTitle;

  /// No description provided for @introCloudCaption.
  ///
  /// In en, this message translates to:
  /// **'only for you'**
  String get introCloudCaption;

  /// No description provided for @introCloudTitle.
  ///
  /// In en, this message translates to:
  /// **'Your diary stays yours.'**
  String get introCloudTitle;

  /// No description provided for @introCloudBody.
  ///
  /// In en, this message translates to:
  /// **'What you write stays on this device – no account, no server of ours, no ads and no tracking. If you like, Randnotiz backs up your entries to a hidden app folder in your own Google Drive, end-to-end encrypted on this device first.'**
  String get introCloudBody;

  /// No description provided for @introCloudKeys.
  ///
  /// In en, this message translates to:
  /// **'Only you hold the key: your backup password and the emergency key. Without them nobody can open the backup – not Google and not us, the developers. Keep both somewhere safe.'**
  String get introCloudKeys;

  /// No description provided for @introCloudQuestion.
  ///
  /// In en, this message translates to:
  /// **'Back up to your Google Drive?'**
  String get introCloudQuestion;

  /// No description provided for @introCloudAfterTour.
  ///
  /// In en, this message translates to:
  /// **'You’ll set it up right after a short tour.'**
  String get introCloudAfterTour;

  /// No description provided for @introNoCloud.
  ///
  /// In en, this message translates to:
  /// **'Continue without backup'**
  String get introNoCloud;

  /// No description provided for @introOnlineTitle.
  ///
  /// In en, this message translates to:
  /// **'When Randnotiz goes online'**
  String get introOnlineTitle;

  /// No description provided for @introOnlineBody.
  ///
  /// In en, this message translates to:
  /// **'Weather and place search ask Open-Meteo – with a position rounded to about 1 km or with your search term. If you search for a song for an entry, the search term goes to Apple. When you dictate, Google’s speech recognition may listen, depending on the device; if you don’t want that, just type. What you type and your photos only leave the device encrypted – in your backup.'**
  String get introOnlineBody;

  /// No description provided for @introSetUpBackup.
  ///
  /// In en, this message translates to:
  /// **'Set up backup'**
  String get introSetUpBackup;

  /// No description provided for @introHaveBackup.
  ///
  /// In en, this message translates to:
  /// **'I already have a backup'**
  String get introHaveBackup;

  /// No description provided for @introBackupUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Backup isn’t available in this version.'**
  String get introBackupUnavailable;

  /// No description provided for @introPhotoCaption.
  ///
  /// In en, this message translates to:
  /// **'one photo'**
  String get introPhotoCaption;

  /// No description provided for @introPhotoTitle.
  ///
  /// In en, this message translates to:
  /// **'One photo, one story.'**
  String get introPhotoTitle;

  /// No description provided for @introPhotoBody.
  ///
  /// In en, this message translates to:
  /// **'Tap the photo with the plus at the bottom and pick a picture – from your phone or from Google Photos. Randnotiz doesn’t need access to your gallery for that.'**
  String get introPhotoBody;

  /// No description provided for @introWriteCaption.
  ///
  /// In en, this message translates to:
  /// **'in the margin'**
  String get introWriteCaption;

  /// No description provided for @introWriteTitle.
  ///
  /// In en, this message translates to:
  /// **'Write down how it felt.'**
  String get introWriteTitle;

  /// No description provided for @introWriteBody.
  ///
  /// In en, this message translates to:
  /// **'Who was there? What made you laugh? Write or dictate a few lines in the margin – everything saves by itself. Add a place, the weather, your mood or the song of the day if you like.'**
  String get introWriteBody;

  /// No description provided for @introJournalCaption.
  ///
  /// In en, this message translates to:
  /// **'your journal'**
  String get introJournalCaption;

  /// No description provided for @introJournalTitle.
  ///
  /// In en, this message translates to:
  /// **'Page by page, your journal.'**
  String get introJournalTitle;

  /// No description provided for @introJournalBody.
  ///
  /// In en, this message translates to:
  /// **'Your entries collect like the pages of a notebook. Search for words, places or moods, gather trips into collections and watch your world map fill with colour.'**
  String get introJournalBody;

  /// No description provided for @introMemoriesCaption.
  ///
  /// In en, this message translates to:
  /// **'a year ago'**
  String get introMemoriesCaption;

  /// No description provided for @introMemoriesTitle.
  ///
  /// In en, this message translates to:
  /// **'Your moments come back.'**
  String get introMemoriesTitle;

  /// No description provided for @introMemoriesBody.
  ///
  /// In en, this message translates to:
  /// **'On the anniversary, Randnotiz brings your moment back – in the app and, if you like, as a widget on your home screen.'**
  String get introMemoriesBody;

  /// No description provided for @introLock.
  ///
  /// In en, this message translates to:
  /// **'If your device has a screen lock, Randnotiz opens only with your fingerprint, face or PIN – that’s on from the start. While it’s locked there are no screenshots and no preview in the app overview. The widget still shows a photo from your journal.'**
  String get introLock;

  /// No description provided for @introLockDebug.
  ///
  /// In en, this message translates to:
  /// **'In this development version, screenshots are still possible.'**
  String get introLockDebug;

  /// No description provided for @introStart.
  ///
  /// In en, this message translates to:
  /// **'Let’s go'**
  String get introStart;

  /// No description provided for @introStartBackup.
  ///
  /// In en, this message translates to:
  /// **'Continue to backup'**
  String get introStartBackup;

  /// No description provided for @introStartRestore.
  ///
  /// In en, this message translates to:
  /// **'Continue to restore'**
  String get introStartRestore;

  /// Sample entry in the introduction's animations
  ///
  /// In en, this message translates to:
  /// **'Picnic by the lake'**
  String get introDemoTitle;

  /// No description provided for @introDemoText.
  ///
  /// In en, this message translates to:
  /// **'Mia brought far too many strawberries. We stayed until the sun went down.'**
  String get introDemoText;

  /// No description provided for @introDemoPlace.
  ///
  /// In en, this message translates to:
  /// **'Lake Constance'**
  String get introDemoPlace;

  /// No description provided for @introDemoTitle2.
  ///
  /// In en, this message translates to:
  /// **'First snow'**
  String get introDemoTitle2;

  /// No description provided for @introDemoTitle3.
  ///
  /// In en, this message translates to:
  /// **'Grandma’s birthday'**
  String get introDemoTitle3;

  /// No description provided for @introDemoSearch.
  ///
  /// In en, this message translates to:
  /// **'lake'**
  String get introDemoSearch;

  /// No description provided for @settingsIntro.
  ///
  /// In en, this message translates to:
  /// **'View introduction'**
  String get settingsIntro;

  /// No description provided for @settingsIntroSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Language, backup and a short tour'**
  String get settingsIntroSubtitle;

  /// No description provided for @backupRestoreGuide.
  ///
  /// In en, this message translates to:
  /// **'Already have a backup? Connect the same Google account as on your previous device. Then enter your backup password or emergency key and bring your entries back.'**
  String get backupRestoreGuide;

  /// No description provided for @backupRestoreNoBackup.
  ///
  /// In en, this message translates to:
  /// **'There’s no Randnotiz backup in this Google account. If it’s in a different account, sign out and connect the right one.'**
  String get backupRestoreNoBackup;

  /// No description provided for @backupDevBanner.
  ///
  /// In en, this message translates to:
  /// **'Test app – shares the backup with the real app. Whatever you set up, back up or delete here affects the same backup in Google Drive.'**
  String get backupDevBanner;

  /// No description provided for @backupDevConfirmTitle.
  ///
  /// In en, this message translates to:
  /// **'Really in the test app?'**
  String get backupDevConfirmTitle;

  /// No description provided for @backupDevConfirmAuto.
  ///
  /// In en, this message translates to:
  /// **'After this, the test app backs up automatically to the same Drive folder as the real app – test entries then end up in its backup too.'**
  String get backupDevConfirmAuto;

  /// No description provided for @backupDevConfirmDelete.
  ///
  /// In en, this message translates to:
  /// **'This also deletes the real app’s backup, because both use the same Drive folder. It can’t be undone.'**
  String get backupDevConfirmDelete;

  /// No description provided for @backupDevConfirmContinue.
  ///
  /// In en, this message translates to:
  /// **'Continue anyway'**
  String get backupDevConfirmContinue;

  /// No description provided for @backupDevConfirmDeleteButton.
  ///
  /// In en, this message translates to:
  /// **'Delete anyway'**
  String get backupDevConfirmDeleteButton;

  /// No description provided for @songAdd.
  ///
  /// In en, this message translates to:
  /// **'Add song'**
  String get songAdd;

  /// No description provided for @songSheetTitle.
  ///
  /// In en, this message translates to:
  /// **'Song for the entry'**
  String get songSheetTitle;

  /// No description provided for @songSearchHint.
  ///
  /// In en, this message translates to:
  /// **'Search for a title or artist'**
  String get songSearchHint;

  /// No description provided for @songNoResults.
  ///
  /// In en, this message translates to:
  /// **'Nothing found.'**
  String get songNoResults;

  /// No description provided for @songSearchSource.
  ///
  /// In en, this message translates to:
  /// **'Search, covers and previews provided by Apple'**
  String get songSearchSource;

  /// No description provided for @songRemove.
  ///
  /// In en, this message translates to:
  /// **'Remove song'**
  String get songRemove;

  /// No description provided for @songChange.
  ///
  /// In en, this message translates to:
  /// **'Change song'**
  String get songChange;

  /// No description provided for @songPlay.
  ///
  /// In en, this message translates to:
  /// **'Play preview'**
  String get songPlay;

  /// No description provided for @songPause.
  ///
  /// In en, this message translates to:
  /// **'Pause preview'**
  String get songPause;

  /// No description provided for @songChangeHint.
  ///
  /// In en, this message translates to:
  /// **'Press and hold to change'**
  String get songChangeHint;

  /// No description provided for @songOpenAppleMusic.
  ///
  /// In en, this message translates to:
  /// **'Listen on Apple Music'**
  String get songOpenAppleMusic;

  /// No description provided for @songOtherServices.
  ///
  /// In en, this message translates to:
  /// **'Other services'**
  String get songOtherServices;

  /// No description provided for @songRecordLabel.
  ///
  /// In en, this message translates to:
  /// **'Song: {title} by {artist}'**
  String songRecordLabel(String title, String artist);

  /// No description provided for @songOf.
  ///
  /// In en, this message translates to:
  /// **'{title} · {artist}'**
  String songOf(String title, String artist);

  /// No description provided for @journalHasSong.
  ///
  /// In en, this message translates to:
  /// **'With song'**
  String get journalHasSong;

  /// No description provided for @songErrorNetwork.
  ///
  /// In en, this message translates to:
  /// **'No connection to Apple Music.'**
  String get songErrorNetwork;

  /// No description provided for @songErrorSearch.
  ///
  /// In en, this message translates to:
  /// **'The search didn’t work.'**
  String get songErrorSearch;

  /// No description provided for @songErrorRateLimit.
  ///
  /// In en, this message translates to:
  /// **'Too many requests right now. Please try again in a moment.'**
  String get songErrorRateLimit;

  /// No description provided for @songErrorPlayback.
  ///
  /// In en, this message translates to:
  /// **'The preview couldn’t be played right now.'**
  String get songErrorPlayback;

  /// No description provided for @songErrorNoPreview.
  ///
  /// In en, this message translates to:
  /// **'There’s no preview for this song.'**
  String get songErrorNoPreview;

  /// No description provided for @songErrorNotFound.
  ///
  /// In en, this message translates to:
  /// **'This song isn’t (or is no longer) available on Apple Music here.'**
  String get songErrorNotFound;

  /// No description provided for @songErrorOpen.
  ///
  /// In en, this message translates to:
  /// **'The link couldn’t be opened.'**
  String get songErrorOpen;

  /// No description provided for @calendarOpen.
  ///
  /// In en, this message translates to:
  /// **'Open calendar'**
  String get calendarOpen;

  /// No description provided for @calendarTitle.
  ///
  /// In en, this message translates to:
  /// **'Calendar'**
  String get calendarTitle;

  /// No description provided for @calendarToday.
  ///
  /// In en, this message translates to:
  /// **'Go to today'**
  String get calendarToday;

  /// No description provided for @calendarPreviousMonth.
  ///
  /// In en, this message translates to:
  /// **'Previous month'**
  String get calendarPreviousMonth;

  /// No description provided for @calendarNextMonth.
  ///
  /// In en, this message translates to:
  /// **'Next month'**
  String get calendarNextMonth;

  /// No description provided for @calendarYearView.
  ///
  /// In en, this message translates to:
  /// **'Show years'**
  String get calendarYearView;

  /// No description provided for @calendarPreviousYear.
  ///
  /// In en, this message translates to:
  /// **'Previous year'**
  String get calendarPreviousYear;

  /// No description provided for @calendarNextYear.
  ///
  /// In en, this message translates to:
  /// **'Next year'**
  String get calendarNextYear;

  /// No description provided for @calendarYearEntries.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =0{No entries this year} =1{1 entry this year} other{{count} entries this year}}'**
  String calendarYearEntries(int count);

  /// No description provided for @calendarMonthEntries.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =0{No entries this month} one{1 entry this month} other{{count} entries this month}}'**
  String calendarMonthEntries(int count);

  /// No description provided for @calendarDayEmpty.
  ///
  /// In en, this message translates to:
  /// **'No entries on this day'**
  String get calendarDayEmpty;

  /// No description provided for @calendarDaysAhead.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{Tomorrow} other{In {count} days}}'**
  String calendarDaysAhead(int count);

  /// No description provided for @settingsWhatsNew.
  ///
  /// In en, this message translates to:
  /// **'What’s new'**
  String get settingsWhatsNew;

  /// No description provided for @settingsWhatsNewSubtitle.
  ///
  /// In en, this message translates to:
  /// **'What changed in recent updates'**
  String get settingsWhatsNewSubtitle;

  /// Title of the dialog after an update. {version} is e.g. 1.2
  ///
  /// In en, this message translates to:
  /// **'New in Randnotiz {version}'**
  String whatsNewTitle(String version);

  /// Heading per release when the dialog lists several
  ///
  /// In en, this message translates to:
  /// **'Version {version}'**
  String whatsNewVersion(String version);

  /// No description provided for @whatsNewDone.
  ///
  /// In en, this message translates to:
  /// **'Got it'**
  String get whatsNewDone;

  /// No description provided for @whatsNew130EncryptionTitle.
  ///
  /// In en, this message translates to:
  /// **'Stored encrypted'**
  String get whatsNew130EncryptionTitle;

  /// No description provided for @whatsNew130EncryptionBody.
  ///
  /// In en, this message translates to:
  /// **'Your notes are now stored encrypted on your device. Only Randnotiz knows the key – it sits in Android\'s protected storage and never leaves your phone.'**
  String get whatsNew130EncryptionBody;

  /// No description provided for @whatsNew130LifeShareTitle.
  ///
  /// In en, this message translates to:
  /// **'How much of your life?'**
  String get whatsNew130LifeShareTitle;

  /// No description provided for @whatsNew130LifeShareBody.
  ///
  /// In en, this message translates to:
  /// **'Add your birthday in the settings: memories and the calendar then show how much of your life so far you had already lived back then.'**
  String get whatsNew130LifeShareBody;

  /// No description provided for @whatsNew120CalendarTitle.
  ///
  /// In en, this message translates to:
  /// **'Calendar'**
  String get whatsNew120CalendarTitle;

  /// No description provided for @whatsNew120CalendarBody.
  ///
  /// In en, this message translates to:
  /// **'Tap the calendar icon in the journal to see which days you wrote on – month by month, or a whole year at a glance.'**
  String get whatsNew120CalendarBody;

  /// No description provided for @whatsNew120CollectionsTitle.
  ///
  /// In en, this message translates to:
  /// **'Collections'**
  String get whatsNew120CollectionsTitle;

  /// No description provided for @whatsNew120CollectionsBody.
  ///
  /// In en, this message translates to:
  /// **'The newest entries now come first – just like in the journal.'**
  String get whatsNew120CollectionsBody;

  /// No description provided for @whatsNew120TitlesTitle.
  ///
  /// In en, this message translates to:
  /// **'Written by hand'**
  String get whatsNew120TitlesTitle;

  /// No description provided for @whatsNew120TitlesBody.
  ///
  /// In en, this message translates to:
  /// **'When you switch tabs, the old title is crossed out and the new one written in.'**
  String get whatsNew120TitlesBody;

  /// No description provided for @whatsNew120PolishTitle.
  ///
  /// In en, this message translates to:
  /// **'Polish'**
  String get whatsNew120PolishTitle;

  /// No description provided for @whatsNew120PolishBody.
  ///
  /// In en, this message translates to:
  /// **'Long notes stay right on the lines, and the menu no longer rides up over the keyboard while you write.'**
  String get whatsNew120PolishBody;
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
      <String>['de', 'en', 'es', 'fr'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'de':
      return AppLocalizationsDe();
    case 'en':
      return AppLocalizationsEn();
    case 'es':
      return AppLocalizationsEs();
    case 'fr':
      return AppLocalizationsFr();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
