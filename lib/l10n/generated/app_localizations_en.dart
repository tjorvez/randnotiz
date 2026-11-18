// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Randnotiz';

  @override
  String get claim =>
      'Write your own story – instead of just swiping through other people’s.';

  @override
  String get navJournal => 'Journal';

  @override
  String get navMemories => 'Memories';

  @override
  String get settingsTooltip => 'Settings';

  @override
  String get cancel => 'Cancel';

  @override
  String get delete => 'Delete';

  @override
  String get save => 'Save';

  @override
  String get create => 'Create';

  @override
  String get done => 'Done';

  @override
  String get ok => 'OK';

  @override
  String get openSystemSettings => 'Open settings';

  @override
  String get errorGeneric => 'Something went wrong. Please try again.';

  @override
  String get editorTitleNew => 'New note';

  @override
  String get editorTitleEdit => 'Note';

  @override
  String get editorHint => 'What was going on? Write it down …';

  @override
  String get editorSaveFailed => 'Not saved – trying again …';

  @override
  String get editorCleared =>
      'Note emptied – it will be deleted when you close it.';

  @override
  String get editorUndoClear => 'Undo';

  @override
  String get editorSaved => 'Saved';

  @override
  String get editorSaving => 'Saving …';

  @override
  String get editorDelete => 'Delete note';

  @override
  String get editorDeleteConfirmTitle => 'Delete note?';

  @override
  String get editorDeleteConfirmBody =>
      'This note’s text, moods and weather and Randnotiz’s copy of the photo will be removed. The photo in your gallery or in Google Photos stays untouched.';

  @override
  String get editorPhotoMissing =>
      'The full-size photo is missing. The saved preview stays in the journal.';

  @override
  String get editorDateTooltip => 'Change date';

  @override
  String get editorEmptyDiscarded => 'Empty notes aren’t saved.';

  @override
  String weatherKind(String kind) {
    String _temp0 = intl.Intl.selectLogic(kind, {
      'clear': 'Sunny',
      'partlyCloudy': 'Partly cloudy',
      'cloudy': 'Cloudy',
      'fog': 'Fog',
      'drizzle': 'Drizzle',
      'rain': 'Rain',
      'snow': 'Snow',
      'thunderstorm': 'Thunderstorm',
      'other': 'Weather',
    });
    return '$_temp0';
  }

  @override
  String weatherTemperature(String temperature) {
    return '$temperature °C';
  }

  @override
  String get weatherLoading => 'Looking up the weather …';

  @override
  String get weatherAdd => 'Weather';

  @override
  String get weatherFetchAgain => 'Try again';

  @override
  String get weatherOffline =>
      'The weather couldn’t be fetched. Maybe there’s no internet connection right now.';

  @override
  String get weatherTemperatureLabel => 'Temperature in °C (optional)';

  @override
  String get weatherRemove => 'Remove weather';

  @override
  String get tagsAdd => 'Mood';

  @override
  String get tagsSheetTitle => 'Moods';

  @override
  String get tagsCreateNew => 'Create a new mood';

  @override
  String get tagNameLabel => 'Name of the mood';

  @override
  String get tagNameHint => 'e.g. Happy';

  @override
  String get tagDuplicate => 'This mood already exists.';

  @override
  String get tagNameEmpty => 'Please enter a name.';

  @override
  String get tagsNone => 'No moods yet. Create your first one.';

  @override
  String tagRemove(String name) {
    return 'Remove mood $name';
  }

  @override
  String get micStart => 'Dictate';

  @override
  String get micStop => 'Stop dictation';

  @override
  String get micListening => 'Listening …';

  @override
  String get micUnavailableTooltip => 'Dictation not available';

  @override
  String get micRationaleTitle => 'Notes by voice';

  @override
  String get micRationaleBody =>
      'To dictate your note, Randnotiz needs access to the microphone. Nothing is recorded or stored – only the recognised text ends up in your note. Depending on the device, your phone recognises speech itself or uses Google’s speech recognition service.';

  @override
  String get micRationaleContinue => 'Continue';

  @override
  String get micDenied =>
      'Without microphone access, dictation isn’t possible. You can of course keep typing.';

  @override
  String get micPermanentlyDeniedTitle => 'Microphone is blocked';

  @override
  String get micPermanentlyDeniedBody =>
      'You declined microphone access. If you’d like to dictate, allow it in the app settings.';

  @override
  String get micUnavailable =>
      'Speech recognition isn’t available on this device. Turn on e.g. “Speech Services by Google” in the system settings.';

  @override
  String get dictationNoSpeech =>
      'I didn’t catch anything. Tap the microphone again.';

  @override
  String get dictationNetwork =>
      'Speech recognition needs an internet connection right now.';

  @override
  String get dictationBusy =>
      'Speech recognition is busy right now. Try again in a moment.';

  @override
  String get dictationLanguage =>
      'This device’s speech recognition doesn’t support English.';

  @override
  String get dictationAudio =>
      'The microphone is in use right now, for example by a call. Your text is safe.';

  @override
  String get dictationUnknown =>
      'Dictation was interrupted. Your text is safe.';

  @override
  String get journalSearchHint => 'Search notes';

  @override
  String get journalEmptyTitle => 'Your journal is still empty';

  @override
  String get journalEmptyBody =>
      'Tap the photo with the plus below, pick a picture from your gallery or from Google Photos and write your first note in the margin.';

  @override
  String get journalNoResults => 'I couldn’t find anything for that.';

  @override
  String journalResultCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count notes',
      one: '1 note',
    );
    return '$_temp0';
  }

  @override
  String get journalClearFilter => 'Reset filters';

  @override
  String get journalClearSearch => 'Clear search';

  @override
  String yearsAgo(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count years ago',
      one: '1 year ago',
    );
    return '$_temp0';
  }

  @override
  String monthsAgo(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count months ago',
      one: '1 month ago',
    );
    return '$_temp0';
  }

  @override
  String weeksAgo(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count weeks ago',
      one: '1 week ago',
    );
    return '$_temp0';
  }

  @override
  String daysAgo(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count days ago',
      one: 'Yesterday',
      zero: 'Today',
    );
    return '$_temp0';
  }

  @override
  String get memoriesEmptyTitle => 'No memories yet';

  @override
  String get memoriesEmptyBody =>
      'Once you write notes, they’ll come back here on their anniversaries.';

  @override
  String get lockTitle => 'Randnotiz is locked';

  @override
  String get lockBody => 'Unlock with your fingerprint, face or screen lock.';

  @override
  String get lockButton => 'Unlock';

  @override
  String get lockReason => 'Unlock Randnotiz';

  @override
  String get lockLockedOut =>
      'Too many attempts. Please wait a moment and try again.';

  @override
  String get lockFailed => 'Unlocking didn’t work.';

  @override
  String get settingsTitle => 'Settings';

  @override
  String get settingsSectionAppearance => 'Appearance';

  @override
  String get settingsTheme => 'Theme';

  @override
  String get themeSystem => 'System';

  @override
  String get themeLight => 'Light';

  @override
  String get themeDark => 'Dark';

  @override
  String get settingsLanguage => 'Language';

  @override
  String get languageSystem => 'Device language';

  @override
  String languageSystemShowing(String language) {
    return 'Device language ($language)';
  }

  @override
  String get settingsSectionPrivacy => 'Privacy';

  @override
  String get settingsLock => 'Biometric lock';

  @override
  String get settingsLockSubtitle =>
      'Fingerprint, face or screen lock when opening. While the lock is on, screenshots and screen casting are blocked.';

  @override
  String get settingsLockUnavailable =>
      'Set up a screen lock on your device first.';

  @override
  String get settingsLockTimeout => 'Lock after';

  @override
  String get lockTimeoutImmediately => 'Immediately';

  @override
  String lockTimeoutMinutes(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count minutes in the background',
      one: '1 minute in the background',
    );
    return '$_temp0';
  }

  @override
  String get settingsSectionTags => 'Moods';

  @override
  String get settingsManageTags => 'Manage moods';

  @override
  String get settingsSectionWidget => 'Widget';

  @override
  String get settingsWidgetText => 'Text preview in the widget';

  @override
  String get settingsWidgetTextSubtitle =>
      'Shows the beginning of the note on the home screen – visible to anyone who sees your phone.';

  @override
  String get settingsSectionMemories => 'Memories';

  @override
  String get settingsBirthday => 'Birthday';

  @override
  String get settingsBirthdayNotSet =>
      'Optional – shows next to memories how much of your life so far you had lived back then. Stays on this device.';

  @override
  String get settingsBirthdayRemove => 'Remove birthday';

  @override
  String lifeShare(String percent) {
    return '$percent of your life';
  }

  @override
  String get lostNotesTitle => 'Your notes could not be opened';

  @override
  String get lostNotesBody =>
      'The key to your notes is gone from this device – this rarely happens, for example when Android resets its protected storage. Randnotiz has therefore started a new, empty diary. Your photos are still here. If you have a backup in Google Drive, you can bring your entries back with it.';

  @override
  String get lostNotesRestore => 'Restore backup';

  @override
  String get lostNotesLater => 'Not now';

  @override
  String get lostNotesMeanwhile =>
      'Until you decide, Randnotiz keeps all your photos and pauses automatic backups, so your existing backup is not replaced.';

  @override
  String get lostNotesStartOver => 'Continue without';

  @override
  String get backupLostNotesTitle => 'Replace your earlier backup?';

  @override
  String get backupLostNotesBody =>
      'Your notes could not be opened recently. If you back up now, the new, almost empty diary will gradually replace your earlier backup. Better restore it first.';

  @override
  String get backupLostNotesConfirm => 'Back up anyway';

  @override
  String get databaseUnavailableTitle =>
      'Your notes can\'t be opened right now';

  @override
  String get databaseUnavailableBody =>
      'Android is not handing out the key to your notes at the moment. Nothing is lost. Try again in a moment, or restart your phone.';

  @override
  String get databaseUnavailableRetry => 'Try again';

  @override
  String get widgetTitle => 'Memory of the day';

  @override
  String get widgetEmpty => 'No memory yet today – open Randnotiz.';

  @override
  String get settingsSectionBackup => 'Backup';

  @override
  String get settingsBackupDrive => 'Backup in Google Drive';

  @override
  String get settingsBackupOff => 'Off – your notes are only on this device';

  @override
  String get settingsBackupUnavailable => 'Not available in this version';

  @override
  String get settingsBackupNeedsSetup => 'Connected – set a backup password';

  @override
  String get settingsBackupNeedsUnlock => 'Backup found – tap to unlock';

  @override
  String get settingsBackupRestorePending =>
      'Paused – backup not brought over yet';

  @override
  String get settingsBackupNever => 'Encrypted and on – no backup yet';

  @override
  String settingsBackupLast(String when) {
    return 'Last backup: $when';
  }

  @override
  String get settingsBackupRunning => 'Backing up …';

  @override
  String get backupTitle => 'Backup in Google Drive';

  @override
  String get backupIntro =>
      'Encrypted in your Google Drive – Google only sees unreadable data.';

  @override
  String get backupConnect => 'Connect with Google';

  @override
  String get backupConnectFailed => 'Connecting with Google didn’t work.';

  @override
  String get backupAccount => 'Google account';

  @override
  String get backupSetupIntro =>
      'The backup password opens the backup on a new device. It isn’t your Google password.';

  @override
  String get backupSetupButton => 'Set backup password';

  @override
  String get backupPasswordTitle => 'Backup password';

  @override
  String get backupPasswordNewTitle => 'New backup password';

  @override
  String get backupPasswordLabel => 'Password';

  @override
  String get backupPasswordRepeat => 'Repeat password';

  @override
  String backupPasswordTooShort(int count) {
    return 'At least $count characters';
  }

  @override
  String get backupPasswordMismatch => 'The passwords don’t match';

  @override
  String get backupPasswordHint =>
      'Easy to remember but hard to guess – e.g. a short sentence. Without the password and the emergency key, nobody can open the backup, not even us.';

  @override
  String get backupWorking => 'One moment …';

  @override
  String get backupEmergencyTitle => 'Your emergency key';

  @override
  String get backupEmergencyIntro =>
      'If you forget the backup password, this key opens your backup. Write it down and keep it safe – it’s only shown now.';

  @override
  String get backupEmergencyCopy => 'Copy';

  @override
  String get backupEmergencyCopied => 'Emergency key copied';

  @override
  String get backupEmergencyConfirm =>
      'I’ve written down the emergency key safely';

  @override
  String get backupEmergencyDone => 'Done';

  @override
  String get backupUnlockIntro =>
      'There’s an encrypted backup in your Google account. Enter the backup password or the emergency key to open it on this device.';

  @override
  String backupUnlockFoundAt(String when) {
    return 'Last backup: $when';
  }

  @override
  String get backupUnlockLabel => 'Password or emergency key';

  @override
  String get backupUnlockButton => 'Unlock';

  @override
  String get backupUnlockWrong =>
      'That doesn’t match. Check the password or emergency key.';

  @override
  String get backupRestoreAskTitle => 'Restore notes?';

  @override
  String get backupRestoreAskBody =>
      'The entries from the backup are added to this device. Whatever is newer here stays as it is.';

  @override
  String get backupRestoreLater => 'Later';

  @override
  String get backupRestore => 'Restore';

  @override
  String backupRestoreDone(int added) {
    String _temp0 = intl.Intl.pluralLogic(
      added,
      locale: localeName,
      other: '$added entries restored',
      one: '1 entry restored',
      zero: 'No new entries',
    );
    return '$_temp0';
  }

  @override
  String backupRestoreUpdated(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count entries updated',
      one: '1 entry updated',
    );
    return '$_temp0';
  }

  @override
  String get backupNow => 'Back up now';

  @override
  String get backupDone => 'Backed up';

  @override
  String get backupUnchanged => 'Already up to date – nothing to back up';

  @override
  String get backupStatusNever => 'No backup yet.';

  @override
  String backupStatusLast(String when) {
    return 'Last backup: $when';
  }

  @override
  String backupStatusCounts(int notes, int photos) {
    String _temp0 = intl.Intl.pluralLogic(
      notes,
      locale: localeName,
      other: '$notes entries',
      one: '1 entry',
    );
    String _temp1 = intl.Intl.pluralLogic(
      photos,
      locale: localeName,
      other: '$photos pictures',
      one: '1 picture',
    );
    return '$_temp0 · $_temp1';
  }

  @override
  String get backupStatusAuto =>
      'Backups happen automatically once a day when you open the app.';

  @override
  String get backupStatusPending => 'Backup not brought over yet';

  @override
  String get backupStatusPendingHint =>
      'Automatic backups are paused until the entries from your backup are on this device too – so nothing gets overwritten. “Restore” or “Back up now” brings them here.';

  @override
  String get backupProblemOffline =>
      'No connection to Google Drive – it will try again later.';

  @override
  String get backupProblemAuth => 'Google denied access. Please connect again.';

  @override
  String get backupProblemQuota => 'Your Google Drive storage is full.';

  @override
  String get backupProblemDamaged =>
      'The backup in Google Drive is damaged or belongs to a different key.';

  @override
  String get backupProblemUnknown => 'The backup didn’t work.';

  @override
  String get backupReconnect => 'Connect again';

  @override
  String get backupChangePassword => 'Change backup password';

  @override
  String get backupPasswordChanged => 'Backup password changed';

  @override
  String get backupRenewEmergency => 'Create a new emergency key';

  @override
  String get backupRenewEmergencyAsk =>
      'The current emergency key will stop working.';

  @override
  String get backupRenewEmergencyButton => 'Create new key';

  @override
  String get backupDisconnect => 'Sign out';

  @override
  String get backupDisconnectTitle => 'Sign out of Google Drive?';

  @override
  String get backupDisconnectBody =>
      'This device will stop backing up. Your notes here stay as they are.';

  @override
  String get backupDisconnectDelete => 'Also delete the backup in Google Drive';

  @override
  String get settingsSectionAbout => 'About';

  @override
  String get settingsAbout => 'About Randnotiz';

  @override
  String get settingsPrivacyPolicy => 'Privacy policy';

  @override
  String settingsPrivacyPolicyOpenFailed(String url) {
    return 'The link couldn’t be opened: $url';
  }

  @override
  String settingsAboutLegalese(String url, String copyright, String source) {
    return 'A private photo diary. Your notes stay on your device.\n\nPrivacy: $url\n\n$copyright. Free software under the GNU General Public License v3 or later, without any warranty. Source code: $source\n\nMap data: Natural Earth (public domain). Places: GeoNames (CC BY 4.0). Song search, covers and previews: Apple (iTunes Search API). Details under “Licenses”.';
  }

  @override
  String get tagManageTitle => 'Manage moods';

  @override
  String tagDeleteConfirmTitle(String name) {
    return 'Delete mood “$name”?';
  }

  @override
  String tagDeleteConfirmBody(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'It will be removed from $count notes. The notes themselves stay.',
      one: 'It will be removed from 1 note. The note itself stays.',
      zero: 'It isn’t used anywhere yet.',
    );
    return '$_temp0';
  }

  @override
  String tagUsage(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count notes',
      one: '1 note',
      zero: 'Not used',
    );
    return '$_temp0';
  }

  @override
  String get tagEdit => 'Edit mood';

  @override
  String get newEntryTooltip => 'New entry – pick a photo';

  @override
  String get newEntryImporting => 'Bringing in the photo …';

  @override
  String get newEntryImportFailed => 'The photo couldn’t be brought in.';

  @override
  String get placeAdd => 'Place';

  @override
  String get placeSheetTitle => 'Country and place';

  @override
  String get placeSearchHint => 'Search for a place, e.g. London';

  @override
  String get placeNoResults => 'No place found.';

  @override
  String get placePrivacy =>
      'Only the country and the name of the place are stored. For the weather, the approximate location is sent to the weather service.';

  @override
  String get placeRemove => 'Remove';

  @override
  String get placeWeatherHint =>
      'With a place, Randnotiz also shows the weather on that day.';

  @override
  String get weatherAdjust => 'Adjust the weather yourself';

  @override
  String get editorMetaMood => 'Mood';

  @override
  String get navCollections => 'Collections';

  @override
  String get collectionAddShort => 'Collection';

  @override
  String get collectionPickerTitle => 'Collections';

  @override
  String get collectionPickerHint =>
      'Gather entries that belong together – a trip, a summer, a person.';

  @override
  String get collectionNew => 'New collection';

  @override
  String get collectionNameLabel => 'Name';

  @override
  String get collectionNameHint => 'e.g. Italy 2024';

  @override
  String get collectionRename => 'Rename';

  @override
  String get collectionDelete => 'Delete collection';

  @override
  String get collectionDeleteConfirmTitle => 'Delete collection?';

  @override
  String collectionDeleteConfirmBody(String name) {
    return '“$name” will be deleted. The entries themselves stay in the journal.';
  }

  @override
  String collectionEntryCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count entries',
      one: '1 entry',
      zero: 'Still empty',
    );
    return '$_temp0';
  }

  @override
  String get collectionsReorderHint => 'Press and hold, then drag to sort';

  @override
  String get collectionMoveEarlier => 'Move forward';

  @override
  String get collectionMoveLater => 'Move back';

  @override
  String get collectionsEmptyTitle => 'No collections yet';

  @override
  String get collectionsEmptyBody =>
      'Bundle entries that belong together – a trip, a summer, a person.';

  @override
  String get collectionEmptyBody =>
      'Add entries – here or right in a note via “Collection”.';

  @override
  String get collectionAddEntries => 'Add entries';

  @override
  String get collectionAddEntriesNone =>
      'All entries are already in this collection.';

  @override
  String collectionAddSelected(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Add $count entries',
      one: 'Add 1 entry',
      zero: 'Add',
    );
    return '$_temp0';
  }

  @override
  String get collectionRemoveEntry => 'Remove from the collection';

  @override
  String collectionNeighboursTitle(String name, int position, int total) {
    return '$name · $position of $total';
  }

  @override
  String get collectionPrevious => 'Previous';

  @override
  String get collectionNext => 'Next';

  @override
  String get collectionStart => 'The collection starts here';

  @override
  String get collectionEnd => 'The collection ends here';

  @override
  String mapEntriesCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count entries',
      one: '1 entry',
    );
    return '$_temp0';
  }

  @override
  String get mapShowAll => 'Show all entries';

  @override
  String get mapEmptyTitle => 'Nothing on the map yet';

  @override
  String get mapEmptyBody =>
      'Countries with entries are coloured in here. An entry gets its country via “Place”.';

  @override
  String get mapEmptyNoNotes =>
      'Once you write notes, the countries you’ve been to light up here.';

  @override
  String get editorTitleHint => 'Title';

  @override
  String get editorTitleLabel => 'Title of the entry';

  @override
  String get emojiPickerTitle => 'Choose an emoji';

  @override
  String get emojiSearchHint => 'Search emoji';

  @override
  String get emojiNoRecents => 'The emojis you picked last will show up here.';

  @override
  String get emojiCurrent => 'Current emoji';

  @override
  String get emojiChange => 'Change emoji';

  @override
  String get memoriesSectionOnThisDay => 'On this day';

  @override
  String get memoriesSectionAround => 'Around this day';

  @override
  String get memoriesSectionMore => 'More memories';

  @override
  String memoriesAnniversaryIn(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Anniversary in $count days',
      one: 'Anniversary tomorrow',
    );
    return '$_temp0';
  }

  @override
  String memoriesAnniversaryAgo(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Anniversary $count days ago',
      one: 'Anniversary was yesterday',
    );
    return '$_temp0';
  }

  @override
  String get memoriesOpen => 'Open entry';

  @override
  String get memoriesSwipeHint => 'Swipe up for more';

  @override
  String get journalRemoveFilter => 'Remove filter';

  @override
  String get suggestionsTags => 'Moods';

  @override
  String get suggestionsPlaces => 'Places';

  @override
  String get suggestionsCountries => 'Countries';

  @override
  String get suggestionsRecent => 'Recent searches';

  @override
  String get suggestionsClearRecent => 'Clear all';

  @override
  String get suggestionsRemoveRecent => 'Remove from recent searches';

  @override
  String geoBackfillProgress(int done, int total) {
    return 'Adding places and countries … $done of $total';
  }

  @override
  String get mapTitle => 'World map';

  @override
  String get mapOpen => 'Open world map';

  @override
  String get mapShowBorders => 'Show borders';

  @override
  String get mapHideBorders => 'Hide borders';

  @override
  String mapCountriesCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count countries',
      one: '1 country',
    );
    return '$_temp0';
  }

  @override
  String mapNoEntriesIn(String country) {
    return 'No entries in $country yet';
  }

  @override
  String get countryLabel => 'Country';

  @override
  String get countryNone => 'No country';

  @override
  String get countryAdd => 'Choose';

  @override
  String get countryChange => 'Change';

  @override
  String get countryRemove => 'Remove country';

  @override
  String get countryPickerTitle => 'Choose a country';

  @override
  String get countryPickerSearch => 'Search for a country';

  @override
  String get introSkip => 'Skip';

  @override
  String get introNext => 'Continue';

  @override
  String introPageLabel(int page, int count) {
    return 'Page $page of $count';
  }

  @override
  String get introWelcome => 'Welcome to Randnotiz';

  @override
  String get introWelcomeBody =>
      'A quiet photo diary for the stories behind your pictures.';

  @override
  String get introLanguageTitle => 'Your language';

  @override
  String get introCloudCaption => 'only for you';

  @override
  String get introCloudTitle => 'Your diary stays yours.';

  @override
  String get introCloudBody =>
      'What you write stays on this device – no account, no server of ours, no ads and no tracking. If you like, Randnotiz backs up your entries to a hidden app folder in your own Google Drive, end-to-end encrypted on this device first.';

  @override
  String get introCloudKeys =>
      'Only you hold the key: your backup password and the emergency key. Without them nobody can open the backup – not Google and not us, the developers. Keep both somewhere safe.';

  @override
  String get introCloudQuestion => 'Back up to your Google Drive?';

  @override
  String get introCloudAfterTour =>
      'You’ll set it up right after a short tour.';

  @override
  String get introNoCloud => 'Continue without backup';

  @override
  String get introOnlineTitle => 'When Randnotiz goes online';

  @override
  String get introOnlineBody =>
      'Weather and place search ask Open-Meteo – with a position rounded to about 1 km or with your search term. If you search for a song for an entry, the search term goes to Apple. When you dictate, Google’s speech recognition may listen, depending on the device; if you don’t want that, just type. What you type and your photos only leave the device encrypted – in your backup.';

  @override
  String get introSetUpBackup => 'Set up backup';

  @override
  String get introHaveBackup => 'I already have a backup';

  @override
  String get introBackupUnavailable =>
      'Backup isn’t available in this version.';

  @override
  String get introPhotoCaption => 'one photo';

  @override
  String get introPhotoTitle => 'One photo, one story.';

  @override
  String get introPhotoBody =>
      'Tap the photo with the plus at the bottom and pick a picture – from your phone or from Google Photos. Randnotiz doesn’t need access to your gallery for that.';

  @override
  String get introWriteCaption => 'in the margin';

  @override
  String get introWriteTitle => 'Write down how it felt.';

  @override
  String get introWriteBody =>
      'Who was there? What made you laugh? Write or dictate a few lines in the margin – everything saves by itself. Add a place, the weather, your mood or the song of the day if you like.';

  @override
  String get introJournalCaption => 'your journal';

  @override
  String get introJournalTitle => 'Page by page, your journal.';

  @override
  String get introJournalBody =>
      'Your entries collect like the pages of a notebook. Search for words, places or moods, gather trips into collections and watch your world map fill with colour.';

  @override
  String get introMemoriesCaption => 'a year ago';

  @override
  String get introMemoriesTitle => 'Your moments come back.';

  @override
  String get introMemoriesBody =>
      'On the anniversary, Randnotiz brings your moment back – in the app and, if you like, as a widget on your home screen.';

  @override
  String get introLock =>
      'If your device has a screen lock, Randnotiz opens only with your fingerprint, face or PIN – that’s on from the start. While it’s locked there are no screenshots and no preview in the app overview. The widget still shows a photo from your journal.';

  @override
  String get introLockDebug =>
      'In this development version, screenshots are still possible.';

  @override
  String get introStart => 'Let’s go';

  @override
  String get introStartBackup => 'Continue to backup';

  @override
  String get introStartRestore => 'Continue to restore';

  @override
  String get introDemoTitle => 'Picnic by the lake';

  @override
  String get introDemoText =>
      'Mia brought far too many strawberries. We stayed until the sun went down.';

  @override
  String get introDemoPlace => 'Lake Constance';

  @override
  String get introDemoTitle2 => 'First snow';

  @override
  String get introDemoTitle3 => 'Grandma’s birthday';

  @override
  String get introDemoSearch => 'lake';

  @override
  String get settingsIntro => 'View introduction';

  @override
  String get settingsIntroSubtitle => 'Language, backup and a short tour';

  @override
  String get backupRestoreGuide =>
      'Already have a backup? Connect the same Google account as on your previous device. Then enter your backup password or emergency key and bring your entries back.';

  @override
  String get backupRestoreNoBackup =>
      'There’s no Randnotiz backup in this Google account. If it’s in a different account, sign out and connect the right one.';

  @override
  String get backupDevBanner =>
      'Test app – shares the backup with the real app. Whatever you set up, back up or delete here affects the same backup in Google Drive.';

  @override
  String get backupDevConfirmTitle => 'Really in the test app?';

  @override
  String get backupDevConfirmAuto =>
      'After this, the test app backs up automatically to the same Drive folder as the real app – test entries then end up in its backup too.';

  @override
  String get backupDevConfirmDelete =>
      'This also deletes the real app’s backup, because both use the same Drive folder. It can’t be undone.';

  @override
  String get backupDevConfirmContinue => 'Continue anyway';

  @override
  String get backupDevConfirmDeleteButton => 'Delete anyway';

  @override
  String get songAdd => 'Add song';

  @override
  String get songSheetTitle => 'Song for the entry';

  @override
  String get songSearchHint => 'Search for a title or artist';

  @override
  String get songNoResults => 'Nothing found.';

  @override
  String get songSearchSource =>
      'Search, covers and previews provided by Apple';

  @override
  String get songRemove => 'Remove song';

  @override
  String get songChange => 'Change song';

  @override
  String get songPlay => 'Play preview';

  @override
  String get songPause => 'Pause preview';

  @override
  String get songChangeHint => 'Press and hold to change';

  @override
  String get songOpenAppleMusic => 'Listen on Apple Music';

  @override
  String get songOtherServices => 'Other services';

  @override
  String songRecordLabel(String title, String artist) {
    return 'Song: $title by $artist';
  }

  @override
  String songOf(String title, String artist) {
    return '$title · $artist';
  }

  @override
  String get journalHasSong => 'With song';

  @override
  String get songErrorNetwork => 'No connection to Apple Music.';

  @override
  String get songErrorSearch => 'The search didn’t work.';

  @override
  String get songErrorRateLimit =>
      'Too many requests right now. Please try again in a moment.';

  @override
  String get songErrorPlayback => 'The preview couldn’t be played right now.';

  @override
  String get songErrorNoPreview => 'There’s no preview for this song.';

  @override
  String get songErrorNotFound =>
      'This song isn’t (or is no longer) available on Apple Music here.';

  @override
  String get songErrorOpen => 'The link couldn’t be opened.';

  @override
  String get calendarOpen => 'Open calendar';

  @override
  String get calendarTitle => 'Calendar';

  @override
  String get calendarToday => 'Go to today';

  @override
  String get calendarPreviousMonth => 'Previous month';

  @override
  String get calendarNextMonth => 'Next month';

  @override
  String get calendarYearView => 'Show years';

  @override
  String get calendarPreviousYear => 'Previous year';

  @override
  String get calendarNextYear => 'Next year';

  @override
  String calendarYearEntries(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count entries this year',
      one: '1 entry this year',
      zero: 'No entries this year',
    );
    return '$_temp0';
  }

  @override
  String calendarMonthEntries(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count entries this month',
      one: '1 entry this month',
      zero: 'No entries this month',
    );
    return '$_temp0';
  }

  @override
  String get calendarDayEmpty => 'No entries on this day';

  @override
  String calendarDaysAhead(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'In $count days',
      one: 'Tomorrow',
    );
    return '$_temp0';
  }

  @override
  String get settingsWhatsNew => 'What’s new';

  @override
  String get settingsWhatsNewSubtitle => 'What changed in recent updates';

  @override
  String whatsNewTitle(String version) {
    return 'New in Randnotiz $version';
  }

  @override
  String whatsNewVersion(String version) {
    return 'Version $version';
  }

  @override
  String get whatsNewDone => 'Got it';

  @override
  String get whatsNew130EncryptionTitle => 'Stored encrypted';

  @override
  String get whatsNew130EncryptionBody =>
      'Your notes are now stored encrypted on your device. Only Randnotiz knows the key – it sits in Android\'s protected storage and never leaves your phone.';

  @override
  String get whatsNew130LifeShareTitle => 'How much of your life?';

  @override
  String get whatsNew130LifeShareBody =>
      'Add your birthday in the settings: memories and the calendar then show how much of your life so far you had already lived back then.';

  @override
  String get whatsNew120CalendarTitle => 'Calendar';

  @override
  String get whatsNew120CalendarBody =>
      'Tap the calendar icon in the journal to see which days you wrote on – month by month, or a whole year at a glance.';

  @override
  String get whatsNew120CollectionsTitle => 'Collections';

  @override
  String get whatsNew120CollectionsBody =>
      'The newest entries now come first – just like in the journal.';

  @override
  String get whatsNew120TitlesTitle => 'Written by hand';

  @override
  String get whatsNew120TitlesBody =>
      'When you switch tabs, the old title is crossed out and the new one written in.';

  @override
  String get whatsNew120PolishTitle => 'Polish';

  @override
  String get whatsNew120PolishBody =>
      'Long notes stay right on the lines, and the menu no longer rides up over the keyboard while you write.';
}
