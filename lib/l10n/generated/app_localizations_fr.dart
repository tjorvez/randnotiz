// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for French (`fr`).
class AppLocalizationsFr extends AppLocalizations {
  AppLocalizationsFr([String locale = 'fr']) : super(locale);

  @override
  String get appTitle => 'Randnotiz';

  @override
  String get claim =>
      'Écris ta propre histoire – au lieu de faire défiler celles des autres.';

  @override
  String get navJournal => 'Journal';

  @override
  String get navMemories => 'Souvenirs';

  @override
  String get settingsTooltip => 'Réglages';

  @override
  String get cancel => 'Annuler';

  @override
  String get delete => 'Supprimer';

  @override
  String get save => 'Enregistrer';

  @override
  String get create => 'Créer';

  @override
  String get done => 'Terminé';

  @override
  String get ok => 'OK';

  @override
  String get openSystemSettings => 'Ouvrir les réglages';

  @override
  String get errorGeneric =>
      'Quelque chose s’est mal passé. Réessaie, s’il te plaît.';

  @override
  String get editorTitleNew => 'Nouvelle note';

  @override
  String get editorTitleEdit => 'Note';

  @override
  String get editorHint => 'Que s’est-il passé ? Écris-le …';

  @override
  String get editorSaveFailed => 'Pas enregistré – nouvel essai …';

  @override
  String get editorCleared =>
      'Note vidée – elle sera supprimée à la fermeture.';

  @override
  String get editorUndoClear => 'Annuler';

  @override
  String get editorSaved => 'Enregistré';

  @override
  String get editorSaving => 'Enregistrement …';

  @override
  String get editorDelete => 'Supprimer la note';

  @override
  String get editorDeleteConfirmTitle => 'Supprimer la note ?';

  @override
  String get editorDeleteConfirmBody =>
      'Le texte, les humeurs et la météo de cette note ainsi que la copie de la photo dans Randnotiz seront supprimés. La photo dans ta galerie ou dans Google Photos n’est pas touchée.';

  @override
  String get editorPhotoMissing =>
      'La photo en taille réelle est introuvable. L’aperçu enregistré reste dans le journal.';

  @override
  String get editorDateTooltip => 'Changer la date';

  @override
  String get editorEmptyDiscarded =>
      'Les notes vides ne sont pas enregistrées.';

  @override
  String weatherKind(String kind) {
    String _temp0 = intl.Intl.selectLogic(kind, {
      'clear': 'Ensoleillé',
      'partlyCloudy': 'Partiellement nuageux',
      'cloudy': 'Nuageux',
      'fog': 'Brouillard',
      'drizzle': 'Bruine',
      'rain': 'Pluie',
      'snow': 'Neige',
      'thunderstorm': 'Orage',
      'other': 'Météo',
    });
    return '$_temp0';
  }

  @override
  String weatherTemperature(String temperature) {
    return '$temperature °C';
  }

  @override
  String get weatherLoading => 'Recherche de la météo …';

  @override
  String get weatherAdd => 'Météo';

  @override
  String get weatherFetchAgain => 'Réessayer';

  @override
  String get weatherOffline =>
      'La météo n’a pas pu être récupérée. Il manque peut-être la connexion Internet.';

  @override
  String get weatherTemperatureLabel => 'Température en °C (facultatif)';

  @override
  String get weatherRemove => 'Retirer la météo';

  @override
  String get tagsAdd => 'Humeur';

  @override
  String get tagsSheetTitle => 'Humeurs';

  @override
  String get tagsCreateNew => 'Créer une humeur';

  @override
  String get tagNameLabel => 'Nom de l’humeur';

  @override
  String get tagNameHint => 'p. ex. Heureux';

  @override
  String get tagDuplicate => 'Cette humeur existe déjà.';

  @override
  String get tagNameEmpty => 'Saisis un nom, s’il te plaît.';

  @override
  String get tagsNone => 'Pas encore d’humeurs. Crée la première.';

  @override
  String tagRemove(String name) {
    return 'Retirer l’humeur $name';
  }

  @override
  String get micStart => 'Dicter';

  @override
  String get micStop => 'Arrêter la dictée';

  @override
  String get micListening => 'Je t’écoute …';

  @override
  String get micUnavailableTooltip => 'Dictée indisponible';

  @override
  String get micRationaleTitle => 'Des notes à la voix';

  @override
  String get micRationaleBody =>
      'Pour que tu puisses dicter ta note, Randnotiz a besoin d’accéder au micro. Rien n’est enregistré ni conservé – seul le texte reconnu arrive dans ta note. Selon l’appareil, ton téléphone reconnaît la parole lui-même ou utilise le service de reconnaissance vocale de Google.';

  @override
  String get micRationaleContinue => 'Continuer';

  @override
  String get micDenied =>
      'Sans accès au micro, pas de dictée. Tu peux bien sûr continuer à taper.';

  @override
  String get micPermanentlyDeniedTitle => 'Le micro est bloqué';

  @override
  String get micPermanentlyDeniedBody =>
      'Tu as refusé l’accès au micro. Si tu veux dicter, autorise-le dans les réglages de l’application.';

  @override
  String get micUnavailable =>
      'Aucune reconnaissance vocale n’est disponible sur cet appareil. Active par exemple « Speech Services by Google » dans les réglages du système.';

  @override
  String get dictationNoSpeech =>
      'Je n’ai rien compris. Touche encore une fois le micro.';

  @override
  String get dictationNetwork =>
      'La reconnaissance vocale a besoin d’une connexion Internet en ce moment.';

  @override
  String get dictationBusy =>
      'La reconnaissance vocale est occupée. Réessaie dans un instant.';

  @override
  String get dictationLanguage =>
      'La reconnaissance vocale de cet appareil ne prend pas en charge le français.';

  @override
  String get dictationAudio =>
      'Le micro est occupé en ce moment, par exemple par un appel. Ton texte est conservé.';

  @override
  String get dictationUnknown =>
      'La dictée a été interrompue. Ton texte est conservé.';

  @override
  String get journalSearchHint => 'Rechercher dans les notes';

  @override
  String get journalEmptyTitle => 'Ton journal est encore vide';

  @override
  String get journalEmptyBody =>
      'Touche la photo avec le plus en bas, choisis une image de ta galerie ou de Google Photos et écris ta première note en marge.';

  @override
  String get journalNoResults => 'Je n’ai rien trouvé.';

  @override
  String journalResultCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count notes',
      one: '$count note',
    );
    return '$_temp0';
  }

  @override
  String get journalClearFilter => 'Réinitialiser les filtres';

  @override
  String get journalClearSearch => 'Effacer la recherche';

  @override
  String yearsAgo(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Il y a $count ans',
      one: 'Il y a $count an',
    );
    return '$_temp0';
  }

  @override
  String monthsAgo(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Il y a $count mois',
      one: 'Il y a $count mois',
    );
    return '$_temp0';
  }

  @override
  String weeksAgo(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Il y a $count semaines',
      one: 'Il y a $count semaine',
    );
    return '$_temp0';
  }

  @override
  String daysAgo(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Il y a $count jours',
      one: 'Hier',
      zero: 'Aujourd’hui',
    );
    return '$_temp0';
  }

  @override
  String get memoriesEmptyTitle => 'Pas encore de souvenirs';

  @override
  String get memoriesEmptyBody =>
      'Dès que tu écris des notes, elles réapparaissent ici le jour de leur anniversaire.';

  @override
  String get lockTitle => 'Randnotiz est verrouillé';

  @override
  String get lockBody =>
      'Déverrouille avec ton empreinte, ton visage ou le verrouillage de l’écran.';

  @override
  String get lockButton => 'Déverrouiller';

  @override
  String get lockReason => 'Déverrouiller Randnotiz';

  @override
  String get lockLockedOut =>
      'Trop de tentatives. Attends un moment, puis réessaie.';

  @override
  String get lockFailed => 'Le déverrouillage n’a pas fonctionné.';

  @override
  String get settingsTitle => 'Réglages';

  @override
  String get settingsSectionAppearance => 'Apparence';

  @override
  String get settingsTheme => 'Thème';

  @override
  String get themeSystem => 'Système';

  @override
  String get themeLight => 'Clair';

  @override
  String get themeDark => 'Sombre';

  @override
  String get settingsLanguage => 'Langue';

  @override
  String get languageSystem => 'Langue de l’appareil';

  @override
  String languageSystemShowing(String language) {
    return 'Langue de l’appareil ($language)';
  }

  @override
  String get settingsSectionPrivacy => 'Confidentialité';

  @override
  String get settingsLock => 'Verrouillage biométrique';

  @override
  String get settingsLockSubtitle =>
      'Empreinte, visage ou verrouillage de l’écran à l’ouverture. Tant que le verrouillage est actif, les captures d’écran et la diffusion d’écran sont bloquées.';

  @override
  String get settingsLockUnavailable =>
      'Configure d’abord un verrouillage de l’écran sur ton appareil.';

  @override
  String get settingsLockTimeout => 'Verrouiller après';

  @override
  String get lockTimeoutImmediately => 'Immédiatement';

  @override
  String lockTimeoutMinutes(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count minutes en arrière-plan',
      one: '$count minute en arrière-plan',
    );
    return '$_temp0';
  }

  @override
  String get settingsSectionTags => 'Humeurs';

  @override
  String get settingsManageTags => 'Gérer les humeurs';

  @override
  String get settingsSectionWidget => 'Widget';

  @override
  String get settingsWidgetText => 'Aperçu du texte dans le widget';

  @override
  String get settingsWidgetTextSubtitle =>
      'Affiche le début de la note sur l’écran d’accueil – visible par toute personne qui voit ton téléphone.';

  @override
  String get settingsSectionMemories => 'Souvenirs';

  @override
  String get settingsBirthday => 'Anniversaire';

  @override
  String get settingsBirthdayNotSet =>
      'Facultatif – indique, à côté des souvenirs, quelle part de ta vie jusqu’ici tu avais déjà vécue à ce moment-là. Reste sur l’appareil.';

  @override
  String get settingsBirthdayRemove => 'Supprimer l’anniversaire';

  @override
  String lifeShare(String percent) {
    return '$percent de ta vie';
  }

  @override
  String get lostNotesTitle => 'Impossible d’ouvrir tes notes';

  @override
  String get lostNotesBody =>
      'La clé de tes notes a disparu de cet appareil – c’est rare, par exemple quand Android réinitialise son stockage protégé. Randnotiz a donc commencé un nouveau journal vide. Tes photos sont toujours là. Si tu as une sauvegarde dans Google Drive, tu peux récupérer tes entrées avec elle.';

  @override
  String get lostNotesRestore => 'Restaurer la sauvegarde';

  @override
  String get lostNotesLater => 'Pas maintenant';

  @override
  String get lostNotesMeanwhile =>
      'Tant que tu n’as pas décidé, Randnotiz garde toutes tes photos et met en pause la sauvegarde automatique, pour que ta sauvegarde existante ne soit pas remplacée.';

  @override
  String get lostNotesStartOver => 'Continuer sans';

  @override
  String get backupLostNotesTitle => 'Remplacer ta sauvegarde précédente ?';

  @override
  String get backupLostNotesBody =>
      'Tes notes n’ont pas pu être ouvertes récemment. Si tu sauvegardes maintenant, le nouveau journal presque vide remplacera peu à peu ta sauvegarde précédente. Mieux vaut d’abord la restaurer.';

  @override
  String get backupLostNotesConfirm => 'Sauvegarder quand même';

  @override
  String get databaseUnavailableTitle =>
      'Impossible d’ouvrir tes notes pour le moment';

  @override
  String get databaseUnavailableBody =>
      'Android ne fournit pas la clé de tes notes en ce moment. Rien n’est perdu. Réessaie dans un instant ou redémarre ton téléphone.';

  @override
  String get databaseUnavailableRetry => 'Réessayer';

  @override
  String get widgetTitle => 'Souvenir du jour';

  @override
  String get widgetEmpty =>
      'Pas encore de souvenir aujourd’hui – ouvre Randnotiz.';

  @override
  String get settingsSectionBackup => 'Sauvegarde';

  @override
  String get settingsBackupDrive => 'Sauvegarde dans Google Drive';

  @override
  String get settingsBackupOff =>
      'Désactivée – tes notes sont uniquement sur cet appareil';

  @override
  String get settingsBackupUnavailable => 'Indisponible dans cette version';

  @override
  String get settingsBackupNeedsSetup =>
      'Connecté – définir un mot de passe de sauvegarde';

  @override
  String get settingsBackupNeedsUnlock =>
      'Sauvegarde trouvée – touche pour déverrouiller';

  @override
  String get settingsBackupRestorePending =>
      'En pause – sauvegarde pas encore récupérée';

  @override
  String get settingsBackupNever =>
      'Activée et chiffrée – pas encore de sauvegarde';

  @override
  String settingsBackupLast(String when) {
    return 'Dernière sauvegarde : $when';
  }

  @override
  String get settingsBackupRunning => 'Sauvegarde en cours …';

  @override
  String get backupTitle => 'Sauvegarde dans Google Drive';

  @override
  String get backupIntro =>
      'Chiffrée dans ton Google Drive : Google ne voit que des données illisibles.';

  @override
  String get backupConnect => 'Se connecter à Google';

  @override
  String get backupConnectFailed => 'La connexion à Google n’a pas fonctionné.';

  @override
  String get backupAccount => 'Compte Google';

  @override
  String get backupSetupIntro =>
      'Le mot de passe de sauvegarde ouvre la sauvegarde sur un nouvel appareil. Ce n’est pas ton mot de passe Google.';

  @override
  String get backupSetupButton => 'Définir le mot de passe de sauvegarde';

  @override
  String get backupPasswordTitle => 'Mot de passe de sauvegarde';

  @override
  String get backupPasswordNewTitle => 'Nouveau mot de passe de sauvegarde';

  @override
  String get backupPasswordLabel => 'Mot de passe';

  @override
  String get backupPasswordRepeat => 'Répéter le mot de passe';

  @override
  String backupPasswordTooShort(int count) {
    return 'Au moins $count caractères';
  }

  @override
  String get backupPasswordMismatch => 'Les mots de passe ne correspondent pas';

  @override
  String get backupPasswordHint =>
      'Facile à retenir mais difficile à deviner – p. ex. une petite phrase. Sans mot de passe ni clé de secours, personne ne peut ouvrir la sauvegarde, pas même nous.';

  @override
  String get backupWorking => 'Un instant …';

  @override
  String get backupEmergencyTitle => 'Ta clé de secours';

  @override
  String get backupEmergencyIntro =>
      'Si tu oublies le mot de passe de sauvegarde, cette clé ouvre ta sauvegarde. Note-la et garde-la en lieu sûr – elle ne s’affiche que maintenant.';

  @override
  String get backupEmergencyCopy => 'Copier';

  @override
  String get backupEmergencyCopied => 'Clé de secours copiée';

  @override
  String get backupEmergencyConfirm =>
      'J’ai noté la clé de secours en lieu sûr';

  @override
  String get backupEmergencyDone => 'Terminé';

  @override
  String get backupUnlockIntro =>
      'Une sauvegarde chiffrée se trouve sur ton compte Google. Saisis le mot de passe de sauvegarde ou la clé de secours pour l’ouvrir sur cet appareil.';

  @override
  String backupUnlockFoundAt(String when) {
    return 'Dernière sauvegarde : $when';
  }

  @override
  String get backupUnlockLabel => 'Mot de passe ou clé de secours';

  @override
  String get backupUnlockButton => 'Déverrouiller';

  @override
  String get backupUnlockWrong =>
      'Ça ne correspond pas. Vérifie le mot de passe ou la clé de secours.';

  @override
  String get backupRestoreAskTitle => 'Restaurer les notes ?';

  @override
  String get backupRestoreAskBody =>
      'Les entrées de la sauvegarde sont ajoutées à cet appareil. Ce qui est plus récent ici reste inchangé.';

  @override
  String get backupRestoreLater => 'Plus tard';

  @override
  String get backupRestore => 'Restaurer';

  @override
  String backupRestoreDone(int added) {
    String _temp0 = intl.Intl.pluralLogic(
      added,
      locale: localeName,
      other: '$added entrées restaurées',
      one: '1 entrée restaurée',
      zero: 'Aucune nouvelle entrée',
    );
    return '$_temp0';
  }

  @override
  String backupRestoreUpdated(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count entrées mises à jour',
      one: '$count entrée mise à jour',
    );
    return '$_temp0';
  }

  @override
  String get backupNow => 'Sauvegarder maintenant';

  @override
  String get backupDone => 'Sauvegardé';

  @override
  String get backupUnchanged => 'Déjà à jour – rien à sauvegarder';

  @override
  String get backupStatusNever => 'Pas encore de sauvegarde.';

  @override
  String backupStatusLast(String when) {
    return 'Dernière sauvegarde : $when';
  }

  @override
  String backupStatusCounts(int notes, int photos) {
    String _temp0 = intl.Intl.pluralLogic(
      notes,
      locale: localeName,
      other: '$notes entrées',
      one: '$notes entrée',
    );
    String _temp1 = intl.Intl.pluralLogic(
      photos,
      locale: localeName,
      other: '$photos images',
      one: '$photos image',
    );
    return '$_temp0 · $_temp1';
  }

  @override
  String get backupStatusAuto =>
      'La sauvegarde se fait automatiquement une fois par jour, quand tu ouvres l’application.';

  @override
  String get backupStatusPending => 'Sauvegarde pas encore récupérée';

  @override
  String get backupStatusPendingHint =>
      'La sauvegarde automatique est en pause jusqu’à ce que les entrées de ta sauvegarde soient aussi sur cet appareil – pour que rien ne soit écrasé. « Restaurer » ou « Sauvegarder maintenant » les ramène ici.';

  @override
  String get backupProblemOffline =>
      'Pas de connexion à Google Drive – nouvel essai plus tard.';

  @override
  String get backupProblemAuth =>
      'Google a refusé l’accès. Reconnecte-toi, s’il te plaît.';

  @override
  String get backupProblemQuota => 'Ton espace Google Drive est plein.';

  @override
  String get backupProblemDamaged =>
      'La sauvegarde dans Google Drive est endommagée ou appartient à une autre clé.';

  @override
  String get backupProblemUnknown => 'La sauvegarde n’a pas fonctionné.';

  @override
  String get backupReconnect => 'Se reconnecter';

  @override
  String get backupChangePassword => 'Changer le mot de passe de sauvegarde';

  @override
  String get backupPasswordChanged => 'Mot de passe de sauvegarde changé';

  @override
  String get backupRenewEmergency => 'Créer une nouvelle clé de secours';

  @override
  String get backupRenewEmergencyAsk =>
      'L’ancienne clé de secours ne fonctionnera plus.';

  @override
  String get backupRenewEmergencyButton => 'Créer une nouvelle clé';

  @override
  String get backupDisconnect => 'Se déconnecter';

  @override
  String get backupDisconnectTitle => 'Se déconnecter de Google Drive ?';

  @override
  String get backupDisconnectBody =>
      'Cet appareil ne sera plus sauvegardé. Tes notes ici restent intactes.';

  @override
  String get backupDisconnectDelete =>
      'Supprimer aussi la sauvegarde dans Google Drive';

  @override
  String get settingsSectionAbout => 'À propos';

  @override
  String get settingsAbout => 'À propos de Randnotiz';

  @override
  String get settingsPrivacyPolicy => 'Politique de confidentialité';

  @override
  String settingsPrivacyPolicyOpenFailed(String url) {
    return 'Le lien n’a pas pu être ouvert : $url';
  }

  @override
  String settingsAboutLegalese(String url, String copyright, String source) {
    return 'Un journal photo privé. Tes notes restent sur ton appareil.\n\nConfidentialité : $url\n\n$copyright. Logiciel libre sous licence GNU General Public License v3 ou ultérieure, sans aucune garantie. Code source : $source\n\nDonnées cartographiques : Natural Earth (domaine public). Lieux : GeoNames (CC BY 4.0). Recherche de chansons, pochettes et extraits : Apple (iTunes Search API). Détails sous « Licences ».';
  }

  @override
  String get tagManageTitle => 'Gérer les humeurs';

  @override
  String tagDeleteConfirmTitle(String name) {
    return 'Supprimer l’humeur « $name » ?';
  }

  @override
  String tagDeleteConfirmBody(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other:
          'Elle sera retirée de $count notes. Les notes elles-mêmes sont conservées.',
      one: 'Elle sera retirée d’une note. La note elle-même est conservée.',
      zero: 'Elle n’est encore utilisée nulle part.',
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
      zero: 'Non utilisée',
    );
    return '$_temp0';
  }

  @override
  String get tagEdit => 'Modifier l’humeur';

  @override
  String get newEntryTooltip => 'Nouvelle entrée – choisir une photo';

  @override
  String get newEntryImporting => 'Importation de la photo …';

  @override
  String get newEntryImportFailed => 'La photo n’a pas pu être importée.';

  @override
  String get placeAdd => 'Lieu';

  @override
  String get placeSheetTitle => 'Pays et lieu';

  @override
  String get placeSearchHint => 'Chercher un lieu, p. ex. Lyon';

  @override
  String get placeNoResults => 'Aucun lieu trouvé.';

  @override
  String get placePrivacy =>
      'Seuls le pays et le nom du lieu sont enregistrés. Pour la météo, la position approximative est envoyée au service météo.';

  @override
  String get placeRemove => 'Retirer';

  @override
  String get placeWeatherHint =>
      'Avec un lieu, Randnotiz affiche aussi la météo de ce jour-là.';

  @override
  String get weatherAdjust => 'Ajuster la météo toi-même';

  @override
  String get editorMetaMood => 'Humeur';

  @override
  String get navCollections => 'Collections';

  @override
  String get collectionAddShort => 'Collection';

  @override
  String get collectionPickerTitle => 'Collections';

  @override
  String get collectionPickerHint =>
      'Rassemble les entrées qui vont ensemble – un voyage, un été, une personne.';

  @override
  String get collectionNew => 'Nouvelle collection';

  @override
  String get collectionNameLabel => 'Nom';

  @override
  String get collectionNameHint => 'p. ex. Italie 2024';

  @override
  String get collectionRename => 'Renommer';

  @override
  String get collectionDelete => 'Supprimer la collection';

  @override
  String get collectionDeleteConfirmTitle => 'Supprimer la collection ?';

  @override
  String collectionDeleteConfirmBody(String name) {
    return '« $name » sera supprimée. Les entrées elles-mêmes restent dans le journal.';
  }

  @override
  String collectionEntryCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count entrées',
      one: '1 entrée',
      zero: 'Encore vide',
    );
    return '$_temp0';
  }

  @override
  String get collectionsReorderHint =>
      'Maintiens appuyé et fais glisser pour trier';

  @override
  String get collectionMoveEarlier => 'Déplacer vers l’avant';

  @override
  String get collectionMoveLater => 'Déplacer vers l’arrière';

  @override
  String get collectionsEmptyTitle => 'Pas encore de collections';

  @override
  String get collectionsEmptyBody =>
      'Regroupe les entrées qui vont ensemble – un voyage, un été, une personne.';

  @override
  String get collectionEmptyBody =>
      'Ajoute des entrées – ici ou directement dans une note via « Collection ».';

  @override
  String get collectionAddEntries => 'Ajouter des entrées';

  @override
  String get collectionAddEntriesNone =>
      'Toutes les entrées sont déjà dans cette collection.';

  @override
  String collectionAddSelected(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Ajouter $count entrées',
      one: 'Ajouter 1 entrée',
      zero: 'Ajouter',
    );
    return '$_temp0';
  }

  @override
  String get collectionRemoveEntry => 'Retirer de la collection';

  @override
  String collectionNeighboursTitle(String name, int position, int total) {
    return '$name · $position sur $total';
  }

  @override
  String get collectionPrevious => 'Précédente';

  @override
  String get collectionNext => 'Suivante';

  @override
  String get collectionStart => 'La collection commence ici';

  @override
  String get collectionEnd => 'La collection s’arrête ici';

  @override
  String mapEntriesCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count entrées',
      one: '$count entrée',
    );
    return '$_temp0';
  }

  @override
  String get mapShowAll => 'Afficher toutes les entrées';

  @override
  String get mapEmptyTitle => 'Rien sur la carte pour l’instant';

  @override
  String get mapEmptyBody =>
      'Les pays avec des entrées se colorent ici. Une entrée reçoit son pays via « Lieu ».';

  @override
  String get mapEmptyNoNotes =>
      'Dès que tu écris des notes, les pays où tu es allé·e se colorent ici.';

  @override
  String get editorTitleHint => 'Titre';

  @override
  String get editorTitleLabel => 'Titre de l’entrée';

  @override
  String get emojiPickerTitle => 'Choisir un emoji';

  @override
  String get emojiSearchHint => 'Chercher un emoji';

  @override
  String get emojiNoRecents =>
      'Les emojis que tu as choisis récemment apparaîtront ici.';

  @override
  String get emojiCurrent => 'Emoji actuel';

  @override
  String get emojiChange => 'Changer d’emoji';

  @override
  String get memoriesSectionOnThisDay => 'Ce jour-là';

  @override
  String get memoriesSectionAround => 'Autour de ce jour';

  @override
  String get memoriesSectionMore => 'Autres souvenirs';

  @override
  String memoriesAnniversaryIn(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Anniversaire dans $count jours',
      one: 'Anniversaire demain',
    );
    return '$_temp0';
  }

  @override
  String memoriesAnniversaryAgo(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Anniversaire il y a $count jours',
      one: 'L’anniversaire était hier',
    );
    return '$_temp0';
  }

  @override
  String get memoriesOpen => 'Ouvrir l’entrée';

  @override
  String get memoriesSwipeHint => 'Balaie vers le haut pour en voir plus';

  @override
  String get journalRemoveFilter => 'Retirer le filtre';

  @override
  String get suggestionsTags => 'Humeurs';

  @override
  String get suggestionsPlaces => 'Lieux';

  @override
  String get suggestionsCountries => 'Pays';

  @override
  String get suggestionsRecent => 'Recherches récentes';

  @override
  String get suggestionsClearRecent => 'Tout effacer';

  @override
  String get suggestionsRemoveRecent => 'Retirer des recherches récentes';

  @override
  String geoBackfillProgress(int done, int total) {
    return 'Ajout des lieux et des pays … $done sur $total';
  }

  @override
  String get mapTitle => 'Carte du monde';

  @override
  String get mapOpen => 'Ouvrir la carte du monde';

  @override
  String get mapShowBorders => 'Afficher les frontières';

  @override
  String get mapHideBorders => 'Masquer les frontières';

  @override
  String mapCountriesCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count pays',
      one: '$count pays',
    );
    return '$_temp0';
  }

  @override
  String mapNoEntriesIn(String country) {
    return 'Pas encore d’entrées : $country';
  }

  @override
  String get countryLabel => 'Pays';

  @override
  String get countryNone => 'Aucun pays';

  @override
  String get countryAdd => 'Choisir';

  @override
  String get countryChange => 'Changer';

  @override
  String get countryRemove => 'Retirer le pays';

  @override
  String get countryPickerTitle => 'Choisir un pays';

  @override
  String get countryPickerSearch => 'Chercher un pays';

  @override
  String get introSkip => 'Passer';

  @override
  String get introNext => 'Continuer';

  @override
  String introPageLabel(int page, int count) {
    return 'Page $page sur $count';
  }

  @override
  String get introWelcome => 'Bienvenue dans Randnotiz';

  @override
  String get introWelcomeBody =>
      'Un journal photo tout calme pour les histoires derrière tes photos.';

  @override
  String get introLanguageTitle => 'Ta langue';

  @override
  String get introCloudCaption => 'rien que pour toi';

  @override
  String get introCloudTitle => 'Ton journal reste à toi.';

  @override
  String get introCloudBody =>
      'Ce que tu écris reste sur cet appareil – sans compte, sans serveur de notre part, sans publicité et sans pistage. Si tu le souhaites, Randnotiz sauvegarde tes entrées dans un dossier d’application caché de ton propre Google Drive – chiffrées de bout en bout sur cet appareil au préalable.';

  @override
  String get introCloudKeys =>
      'Toi seul·e as la clé : ton mot de passe de sauvegarde et la clé de secours. Sans eux, personne ne peut ouvrir la sauvegarde – ni Google ni nous, les développeurs. Garde-les bien.';

  @override
  String get introCloudQuestion => 'Sauvegarder dans ton Google Drive ?';

  @override
  String get introCloudAfterTour =>
      'Tu la configures juste après une petite visite.';

  @override
  String get introNoCloud => 'Continuer sans sauvegarde';

  @override
  String get introOnlineTitle => 'Quand Randnotiz va sur Internet';

  @override
  String get introOnlineBody =>
      'La météo et la recherche de lieux interrogent Open-Meteo – avec une position arrondie à environ 1 km ou avec ton terme de recherche. Si tu cherches une chanson pour une entrée, le terme de recherche est envoyé à Apple. Quand tu dictes, selon l’appareil, la reconnaissance vocale de Google écoute ; si tu ne le souhaites pas, tape simplement. Ce que tu tapes et tes photos ne quittent l’appareil que chiffrés – dans ta sauvegarde.';

  @override
  String get introSetUpBackup => 'Configurer la sauvegarde';

  @override
  String get introHaveBackup => 'J’ai déjà une sauvegarde';

  @override
  String get introBackupUnavailable =>
      'La sauvegarde n’est pas disponible dans cette version.';

  @override
  String get introPhotoCaption => 'une photo';

  @override
  String get introPhotoTitle => 'Une photo, une histoire.';

  @override
  String get introPhotoBody =>
      'Touche la photo avec le plus en bas et choisis une image – sur ton téléphone ou dans Google Photos. Randnotiz n’a pas besoin d’accéder à ta galerie pour ça.';

  @override
  String get introWriteCaption => 'en marge';

  @override
  String get introWriteTitle => 'Écris ce que tu as ressenti.';

  @override
  String get introWriteBody =>
      'Qui était là ? Qu’est-ce qui vous a fait rire ? Écris ou dicte quelques lignes en marge – tout s’enregistre tout seul. Ajoute le lieu, la météo, ton humeur ou la chanson du jour si tu veux.';

  @override
  String get introJournalCaption => 'ton journal';

  @override
  String get introJournalTitle => 'Page après page, ton journal.';

  @override
  String get introJournalBody =>
      'Tes entrées s’assemblent comme les pages d’un cahier. Cherche des mots, des lieux ou des humeurs, rassemble tes voyages en collections et regarde ta carte du monde se colorer.';

  @override
  String get introMemoriesCaption => 'il y a un an';

  @override
  String get introMemoriesTitle => 'Tes moments reviennent.';

  @override
  String get introMemoriesBody =>
      'Le jour de l’anniversaire, Randnotiz te ramène ton moment – dans l’application et, si tu veux, en widget sur ton écran d’accueil.';

  @override
  String get introLock =>
      'Si ton appareil a un verrouillage de l’écran, Randnotiz ne s’ouvre qu’avec ton empreinte, ton visage ou ton code – c’est activé dès le départ. Tant qu’il est verrouillé, pas de captures d’écran ni d’aperçu dans les applications récentes. Le widget affiche quand même une photo de ton journal.';

  @override
  String get introLockDebug =>
      'Dans cette version de développement, les captures d’écran restent possibles.';

  @override
  String get introStart => 'C’est parti';

  @override
  String get introStartBackup => 'Continuer vers la sauvegarde';

  @override
  String get introStartRestore => 'Continuer vers la restauration';

  @override
  String get introDemoTitle => 'Pique-nique au bord du lac';

  @override
  String get introDemoText =>
      'Mia avait apporté bien trop de fraises. Nous sommes restés jusqu’au coucher du soleil.';

  @override
  String get introDemoPlace => 'Lac de Constance';

  @override
  String get introDemoTitle2 => 'La première neige';

  @override
  String get introDemoTitle3 => 'L’anniversaire de mamie';

  @override
  String get introDemoSearch => 'lac';

  @override
  String get settingsIntro => 'Revoir l’introduction';

  @override
  String get settingsIntroSubtitle => 'Langue, sauvegarde et petite visite';

  @override
  String get backupRestoreGuide =>
      'Tu as déjà une sauvegarde ? Connecte le même compte Google que sur ton ancien appareil. Saisis ensuite ton mot de passe de sauvegarde ou ta clé de secours et récupère tes entrées.';

  @override
  String get backupRestoreNoBackup =>
      'Ce compte Google ne contient aucune sauvegarde de Randnotiz. Si elle se trouve dans un autre compte, déconnecte-toi et connecte le bon.';

  @override
  String get backupDevBanner =>
      'Application de test – elle partage la sauvegarde avec la vraie application. Ce que tu configures, sauvegardes ou supprimes ici concerne la même sauvegarde dans Google Drive.';

  @override
  String get backupDevConfirmTitle => 'Vraiment dans l’application de test ?';

  @override
  String get backupDevConfirmAuto =>
      'Ensuite, l’application de test sauvegarde automatiquement dans le même dossier Drive que la vraie application – les entrées de test arrivent alors aussi dans sa sauvegarde.';

  @override
  String get backupDevConfirmDelete =>
      'Cela supprime aussi la sauvegarde de la vraie application, car les deux utilisent le même dossier Drive. C’est irréversible.';

  @override
  String get backupDevConfirmContinue => 'Continuer quand même';

  @override
  String get backupDevConfirmDeleteButton => 'Supprimer quand même';

  @override
  String get songAdd => 'Ajouter une chanson';

  @override
  String get songSheetTitle => 'Chanson de l’entrée';

  @override
  String get songSearchHint => 'Chercher un titre ou un artiste';

  @override
  String get songNoResults => 'Rien trouvé.';

  @override
  String get songSearchSource =>
      'Recherche, pochettes et extraits fournis par Apple';

  @override
  String get songRemove => 'Retirer la chanson';

  @override
  String get songChange => 'Changer de chanson';

  @override
  String get songPlay => 'Écouter l’extrait';

  @override
  String get songPause => 'Mettre l’extrait en pause';

  @override
  String get songChangeHint => 'Appui long pour changer';

  @override
  String get songOpenAppleMusic => 'Écouter sur Apple Music';

  @override
  String get songOtherServices => 'Autres services';

  @override
  String songRecordLabel(String title, String artist) {
    return 'Chanson : $title de $artist';
  }

  @override
  String songOf(String title, String artist) {
    return '$title · $artist';
  }

  @override
  String get journalHasSong => 'Avec chanson';

  @override
  String get songErrorNetwork => 'Pas de connexion à Apple Music.';

  @override
  String get songErrorSearch => 'La recherche n’a pas fonctionné.';

  @override
  String get songErrorRateLimit =>
      'Trop de requêtes en ce moment. Réessaie dans un instant.';

  @override
  String get songErrorPlayback =>
      'L’extrait n’a pas pu être lu pour le moment.';

  @override
  String get songErrorNoPreview => 'Il n’y a pas d’extrait pour cette chanson.';

  @override
  String get songErrorNotFound =>
      'Cette chanson n’est pas (ou plus) disponible ici sur Apple Music.';

  @override
  String get songErrorOpen => 'Le lien n’a pas pu être ouvert.';

  @override
  String get calendarOpen => 'Ouvrir le calendrier';

  @override
  String get calendarTitle => 'Calendrier';

  @override
  String get calendarToday => 'Aller à aujourd’hui';

  @override
  String get calendarPreviousMonth => 'Mois précédent';

  @override
  String get calendarNextMonth => 'Mois suivant';

  @override
  String get calendarYearView => 'Afficher les années';

  @override
  String get calendarPreviousYear => 'Année précédente';

  @override
  String get calendarNextYear => 'Année suivante';

  @override
  String calendarYearEntries(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count entrées cette année',
      one: '1 entrée cette année',
      zero: 'Aucune entrée cette année',
    );
    return '$_temp0';
  }

  @override
  String calendarMonthEntries(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count entrées ce mois-ci',
      one: '$count entrée ce mois-ci',
      zero: 'Aucune entrée ce mois-ci',
    );
    return '$_temp0';
  }

  @override
  String get calendarDayEmpty => 'Aucune entrée ce jour-là';

  @override
  String calendarDaysAhead(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Dans $count jours',
      one: 'Demain',
    );
    return '$_temp0';
  }

  @override
  String get settingsWhatsNew => 'Nouveautés';

  @override
  String get settingsWhatsNewSubtitle =>
      'Ce qui a changé avec les dernières mises à jour';

  @override
  String whatsNewTitle(String version) {
    return 'Nouveautés de Randnotiz $version';
  }

  @override
  String whatsNewVersion(String version) {
    return 'Version $version';
  }

  @override
  String get whatsNewDone => 'Compris';

  @override
  String get whatsNew130EncryptionTitle => 'Stockées chiffrées';

  @override
  String get whatsNew130EncryptionBody =>
      'Tes notes sont désormais chiffrées sur ton appareil. Seul Randnotiz connaît la clé – elle est gardée dans l’espace protégé d’Android et ne quitte jamais ton téléphone.';

  @override
  String get whatsNew130LifeShareTitle => 'Quelle part de ta vie ?';

  @override
  String get whatsNew130LifeShareBody =>
      'Ajoute ton anniversaire dans les réglages : les souvenirs et le calendrier montrent alors quelle part de ta vie jusqu’ici tu avais déjà vécue à ce moment-là.';

  @override
  String get whatsNew120CalendarTitle => 'Calendrier';

  @override
  String get whatsNew120CalendarBody =>
      'Touche l’icône calendrier dans le journal pour voir les jours où tu as écrit – mois par mois, ou toute l’année d’un coup d’œil.';

  @override
  String get whatsNew120CollectionsTitle => 'Collections';

  @override
  String get whatsNew120CollectionsBody =>
      'Les entrées les plus récentes apparaissent désormais en premier – comme dans le journal.';

  @override
  String get whatsNew120TitlesTitle => 'Écrit à la main';

  @override
  String get whatsNew120TitlesBody =>
      'Quand tu changes d’onglet, l’ancien titre est barré et le nouveau écrit à la main.';

  @override
  String get whatsNew120PolishTitle => 'Finitions';

  @override
  String get whatsNew120PolishBody =>
      'Les longues notes restent bien sur les lignes, et le menu ne remonte plus au-dessus du clavier pendant que tu écris.';
}
