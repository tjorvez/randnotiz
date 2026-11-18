// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class AppLocalizationsEs extends AppLocalizations {
  AppLocalizationsEs([String locale = 'es']) : super(locale);

  @override
  String get appTitle => 'Randnotiz';

  @override
  String get claim =>
      'Escribe tu propia historia, en lugar de solo deslizar por las de otros.';

  @override
  String get navJournal => 'Diario';

  @override
  String get navMemories => 'Recuerdos';

  @override
  String get settingsTooltip => 'Ajustes';

  @override
  String get cancel => 'Cancelar';

  @override
  String get delete => 'Eliminar';

  @override
  String get save => 'Guardar';

  @override
  String get create => 'Crear';

  @override
  String get done => 'Listo';

  @override
  String get ok => 'OK';

  @override
  String get openSystemSettings => 'Abrir ajustes';

  @override
  String get errorGeneric => 'Algo salió mal. Inténtalo de nuevo, por favor.';

  @override
  String get editorTitleNew => 'Nueva nota';

  @override
  String get editorTitleEdit => 'Nota';

  @override
  String get editorHint => '¿Qué pasó? Escríbelo …';

  @override
  String get editorSaveFailed => 'No se guardó – intentándolo de nuevo …';

  @override
  String get editorCleared => 'Nota vaciada – se eliminará al cerrarla.';

  @override
  String get editorUndoClear => 'Deshacer';

  @override
  String get editorSaved => 'Guardado';

  @override
  String get editorSaving => 'Guardando …';

  @override
  String get editorDelete => 'Eliminar nota';

  @override
  String get editorDeleteConfirmTitle => '¿Eliminar la nota?';

  @override
  String get editorDeleteConfirmBody =>
      'Se eliminarán el texto, los estados de ánimo y el tiempo de esta nota, además de la copia de la foto en Randnotiz. La foto de tu galería o de Google Fotos no se toca.';

  @override
  String get editorPhotoMissing =>
      'Falta la foto en tamaño completo. La vista previa guardada se queda en el diario.';

  @override
  String get editorDateTooltip => 'Cambiar fecha';

  @override
  String get editorEmptyDiscarded => 'Las notas vacías no se guardan.';

  @override
  String weatherKind(String kind) {
    String _temp0 = intl.Intl.selectLogic(kind, {
      'clear': 'Soleado',
      'partlyCloudy': 'Parcialmente nublado',
      'cloudy': 'Nublado',
      'fog': 'Niebla',
      'drizzle': 'Llovizna',
      'rain': 'Lluvia',
      'snow': 'Nieve',
      'thunderstorm': 'Tormenta',
      'other': 'Tiempo',
    });
    return '$_temp0';
  }

  @override
  String weatherTemperature(String temperature) {
    return '$temperature °C';
  }

  @override
  String get weatherLoading => 'Buscando el tiempo …';

  @override
  String get weatherAdd => 'Tiempo';

  @override
  String get weatherFetchAgain => 'Reintentar';

  @override
  String get weatherOffline =>
      'No se pudo obtener el tiempo. Puede que ahora no haya conexión a Internet.';

  @override
  String get weatherTemperatureLabel => 'Temperatura en °C (opcional)';

  @override
  String get weatherRemove => 'Quitar el tiempo';

  @override
  String get tagsAdd => 'Ánimo';

  @override
  String get tagsSheetTitle => 'Estados de ánimo';

  @override
  String get tagsCreateNew => 'Crear un estado de ánimo';

  @override
  String get tagNameLabel => 'Nombre del estado de ánimo';

  @override
  String get tagNameHint => 'p. ej. Feliz';

  @override
  String get tagDuplicate => 'Este estado de ánimo ya existe.';

  @override
  String get tagNameEmpty => 'Escribe un nombre, por favor.';

  @override
  String get tagsNone => 'Aún no hay estados de ánimo. Crea el primero.';

  @override
  String tagRemove(String name) {
    return 'Quitar el estado de ánimo $name';
  }

  @override
  String get micStart => 'Dictar';

  @override
  String get micStop => 'Terminar el dictado';

  @override
  String get micListening => 'Te escucho …';

  @override
  String get micUnavailableTooltip => 'Dictado no disponible';

  @override
  String get micRationaleTitle => 'Notas por voz';

  @override
  String get micRationaleBody =>
      'Para que puedas dictar tu nota, Randnotiz necesita acceso al micrófono. No se graba ni se guarda nada – solo el texto reconocido llega a tu nota. Según el dispositivo, tu móvil reconoce la voz por sí mismo o usa el servicio de reconocimiento de voz de Google.';

  @override
  String get micRationaleContinue => 'Continuar';

  @override
  String get micDenied =>
      'Sin acceso al micrófono no se puede dictar. Por supuesto, puedes seguir escribiendo.';

  @override
  String get micPermanentlyDeniedTitle => 'El micrófono está bloqueado';

  @override
  String get micPermanentlyDeniedBody =>
      'Rechazaste el acceso al micrófono. Si quieres dictar, permítelo en los ajustes de la aplicación.';

  @override
  String get micUnavailable =>
      'No hay reconocimiento de voz disponible en este dispositivo. Activa, por ejemplo, «Speech Services by Google» en los ajustes del sistema.';

  @override
  String get dictationNoSpeech =>
      'No he entendido nada. Toca el micrófono otra vez.';

  @override
  String get dictationNetwork =>
      'El reconocimiento de voz necesita ahora conexión a Internet.';

  @override
  String get dictationBusy =>
      'El reconocimiento de voz está ocupado. Vuelve a intentarlo en un momento.';

  @override
  String get dictationLanguage =>
      'El reconocimiento de voz de este dispositivo no es compatible con el español.';

  @override
  String get dictationAudio =>
      'El micrófono está ocupado, por ejemplo por una llamada. Tu texto se conserva.';

  @override
  String get dictationUnknown =>
      'El dictado se interrumpió. Tu texto se conserva.';

  @override
  String get journalSearchHint => 'Buscar en las notas';

  @override
  String get journalEmptyTitle => 'Tu diario aún está vacío';

  @override
  String get journalEmptyBody =>
      'Toca abajo la foto con el más, elige una imagen de tu galería o de Google Fotos y escribe tu primera nota al margen.';

  @override
  String get journalNoResults => 'No he encontrado nada.';

  @override
  String journalResultCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count notas',
      one: '1 nota',
    );
    return '$_temp0';
  }

  @override
  String get journalClearFilter => 'Restablecer filtros';

  @override
  String get journalClearSearch => 'Borrar búsqueda';

  @override
  String yearsAgo(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Hace $count años',
      one: 'Hace 1 año',
    );
    return '$_temp0';
  }

  @override
  String monthsAgo(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Hace $count meses',
      one: 'Hace 1 mes',
    );
    return '$_temp0';
  }

  @override
  String weeksAgo(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Hace $count semanas',
      one: 'Hace 1 semana',
    );
    return '$_temp0';
  }

  @override
  String daysAgo(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Hace $count días',
      one: 'Ayer',
      zero: 'Hoy',
    );
    return '$_temp0';
  }

  @override
  String get memoriesEmptyTitle => 'Aún no hay recuerdos';

  @override
  String get memoriesEmptyBody =>
      'En cuanto escribas notas, volverán a aparecer aquí en sus aniversarios.';

  @override
  String get lockTitle => 'Randnotiz está bloqueado';

  @override
  String get lockBody =>
      'Desbloquea con tu huella, tu cara o el bloqueo de pantalla.';

  @override
  String get lockButton => 'Desbloquear';

  @override
  String get lockReason => 'Desbloquear Randnotiz';

  @override
  String get lockLockedOut =>
      'Demasiados intentos. Espera un momento y vuelve a intentarlo.';

  @override
  String get lockFailed => 'No se pudo desbloquear.';

  @override
  String get settingsTitle => 'Ajustes';

  @override
  String get settingsSectionAppearance => 'Apariencia';

  @override
  String get settingsTheme => 'Tema';

  @override
  String get themeSystem => 'Sistema';

  @override
  String get themeLight => 'Claro';

  @override
  String get themeDark => 'Oscuro';

  @override
  String get settingsLanguage => 'Idioma';

  @override
  String get languageSystem => 'Idioma del dispositivo';

  @override
  String languageSystemShowing(String language) {
    return 'Idioma del dispositivo ($language)';
  }

  @override
  String get settingsSectionPrivacy => 'Privacidad';

  @override
  String get settingsLock => 'Bloqueo biométrico';

  @override
  String get settingsLockSubtitle =>
      'Huella, cara o bloqueo de pantalla al abrir. Mientras el bloqueo esté activo, las capturas de pantalla y la transmisión de pantalla están bloqueadas.';

  @override
  String get settingsLockUnavailable =>
      'Primero configura un bloqueo de pantalla en tu dispositivo.';

  @override
  String get settingsLockTimeout => 'Bloquear tras';

  @override
  String get lockTimeoutImmediately => 'Inmediatamente';

  @override
  String lockTimeoutMinutes(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count minutos en segundo plano',
      one: '1 minuto en segundo plano',
    );
    return '$_temp0';
  }

  @override
  String get settingsSectionTags => 'Estados de ánimo';

  @override
  String get settingsManageTags => 'Gestionar estados de ánimo';

  @override
  String get settingsSectionWidget => 'Widget';

  @override
  String get settingsWidgetText => 'Vista previa del texto en el widget';

  @override
  String get settingsWidgetTextSubtitle =>
      'Muestra el comienzo de la nota en la pantalla de inicio – visible para cualquiera que vea tu móvil.';

  @override
  String get settingsSectionMemories => 'Recuerdos';

  @override
  String get settingsBirthday => 'Cumpleaños';

  @override
  String get settingsBirthdayNotSet =>
      'Opcional – muestra junto a los recuerdos qué parte de tu vida hasta ahora ya habías vivido entonces. Se queda en el dispositivo.';

  @override
  String get settingsBirthdayRemove => 'Quitar cumpleaños';

  @override
  String lifeShare(String percent) {
    return '$percent de tu vida';
  }

  @override
  String get lostNotesTitle => 'No se pudieron abrir tus notas';

  @override
  String get lostNotesBody =>
      'La clave de tus notas ya no está en este dispositivo; pasa rara vez, por ejemplo cuando Android restablece su almacenamiento protegido. Por eso Randnotiz ha empezado un diario nuevo y vacío. Tus fotos siguen aquí. Si tienes una copia de seguridad en Google Drive, puedes recuperar tus entradas con ella.';

  @override
  String get lostNotesRestore => 'Restaurar copia';

  @override
  String get lostNotesLater => 'Ahora no';

  @override
  String get lostNotesMeanwhile =>
      'Hasta que decidas, Randnotiz conserva todas tus fotos y pausa la copia automática para que tu copia actual no se sustituya.';

  @override
  String get lostNotesStartOver => 'Seguir sin ella';

  @override
  String get backupLostNotesTitle => '¿Sustituir tu copia anterior?';

  @override
  String get backupLostNotesBody =>
      'Hace poco no se pudieron abrir tus notas. Si haces una copia ahora, el diario nuevo y casi vacío irá sustituyendo tu copia anterior. Mejor restáurala primero.';

  @override
  String get backupLostNotesConfirm => 'Copiar de todos modos';

  @override
  String get databaseUnavailableTitle =>
      'Ahora mismo no se pueden abrir tus notas';

  @override
  String get databaseUnavailableBody =>
      'Android no está entregando la clave de tus notas en este momento. No se ha perdido nada. Vuelve a intentarlo en un momento o reinicia el móvil.';

  @override
  String get databaseUnavailableRetry => 'Reintentar';

  @override
  String get widgetTitle => 'Recuerdo del día';

  @override
  String get widgetEmpty => 'Aún no hay recuerdo hoy – abre Randnotiz.';

  @override
  String get settingsSectionBackup => 'Copia de seguridad';

  @override
  String get settingsBackupDrive => 'Copia de seguridad en Google Drive';

  @override
  String get settingsBackupOff =>
      'Desactivada – tus notas solo están en este dispositivo';

  @override
  String get settingsBackupUnavailable => 'No disponible en esta versión';

  @override
  String get settingsBackupNeedsSetup =>
      'Conectado – establece una contraseña de copia';

  @override
  String get settingsBackupNeedsUnlock =>
      'Copia encontrada – toca para desbloquear';

  @override
  String get settingsBackupRestorePending =>
      'En pausa – copia aún no recuperada';

  @override
  String get settingsBackupNever => 'Activada y cifrada – aún sin copia';

  @override
  String settingsBackupLast(String when) {
    return 'Última copia: $when';
  }

  @override
  String get settingsBackupRunning => 'Haciendo la copia …';

  @override
  String get backupTitle => 'Copia de seguridad en Google Drive';

  @override
  String get backupIntro =>
      'Cifrada en tu Google Drive: Google solo ve datos ilegibles.';

  @override
  String get backupConnect => 'Conectar con Google';

  @override
  String get backupConnectFailed => 'No se pudo conectar con Google.';

  @override
  String get backupAccount => 'Cuenta de Google';

  @override
  String get backupSetupIntro =>
      'Con la contraseña de copia abres la copia en un dispositivo nuevo. No es tu contraseña de Google.';

  @override
  String get backupSetupButton => 'Establecer contraseña de copia';

  @override
  String get backupPasswordTitle => 'Contraseña de copia';

  @override
  String get backupPasswordNewTitle => 'Nueva contraseña de copia';

  @override
  String get backupPasswordLabel => 'Contraseña';

  @override
  String get backupPasswordRepeat => 'Repetir contraseña';

  @override
  String backupPasswordTooShort(int count) {
    return 'Al menos $count caracteres';
  }

  @override
  String get backupPasswordMismatch => 'Las contraseñas no coinciden';

  @override
  String get backupPasswordHint =>
      'Fácil de recordar pero difícil de adivinar – p. ej. una frase corta. Sin contraseña ni clave de emergencia, nadie puede abrir la copia, ni siquiera nosotros.';

  @override
  String get backupWorking => 'Un momento …';

  @override
  String get backupEmergencyTitle => 'Tu clave de emergencia';

  @override
  String get backupEmergencyIntro =>
      'Si olvidas la contraseña de copia, esta clave abre tu copia de seguridad. Anótala y guárdala en un lugar seguro – solo se muestra ahora.';

  @override
  String get backupEmergencyCopy => 'Copiar';

  @override
  String get backupEmergencyCopied => 'Clave de emergencia copiada';

  @override
  String get backupEmergencyConfirm =>
      'He anotado la clave de emergencia en un lugar seguro';

  @override
  String get backupEmergencyDone => 'Listo';

  @override
  String get backupUnlockIntro =>
      'En tu cuenta de Google hay una copia de seguridad cifrada. Escribe la contraseña de copia o la clave de emergencia para abrirla en este dispositivo.';

  @override
  String backupUnlockFoundAt(String when) {
    return 'Última copia: $when';
  }

  @override
  String get backupUnlockLabel => 'Contraseña o clave de emergencia';

  @override
  String get backupUnlockButton => 'Desbloquear';

  @override
  String get backupUnlockWrong =>
      'No coincide. Revisa la contraseña o la clave de emergencia.';

  @override
  String get backupRestoreAskTitle => '¿Restaurar las notas?';

  @override
  String get backupRestoreAskBody =>
      'Las entradas de la copia se añaden a este dispositivo. Lo que sea más reciente aquí no cambia.';

  @override
  String get backupRestoreLater => 'Más tarde';

  @override
  String get backupRestore => 'Restaurar';

  @override
  String backupRestoreDone(int added) {
    String _temp0 = intl.Intl.pluralLogic(
      added,
      locale: localeName,
      other: '$added entradas restauradas',
      one: '1 entrada restaurada',
      zero: 'No hay entradas nuevas',
    );
    return '$_temp0';
  }

  @override
  String backupRestoreUpdated(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count entradas actualizadas',
      one: '1 entrada actualizada',
    );
    return '$_temp0';
  }

  @override
  String get backupNow => 'Hacer copia ahora';

  @override
  String get backupDone => 'Copia hecha';

  @override
  String get backupUnchanged => 'Ya está al día – nada que copiar';

  @override
  String get backupStatusNever => 'Aún no hay copia.';

  @override
  String backupStatusLast(String when) {
    return 'Última copia: $when';
  }

  @override
  String backupStatusCounts(int notes, int photos) {
    String _temp0 = intl.Intl.pluralLogic(
      notes,
      locale: localeName,
      other: '$notes entradas',
      one: '1 entrada',
    );
    String _temp1 = intl.Intl.pluralLogic(
      photos,
      locale: localeName,
      other: '$photos imágenes',
      one: '1 imagen',
    );
    return '$_temp0 · $_temp1';
  }

  @override
  String get backupStatusAuto =>
      'La copia se hace automáticamente una vez al día, cuando abres la aplicación.';

  @override
  String get backupStatusPending => 'Copia aún no recuperada';

  @override
  String get backupStatusPendingHint =>
      'La copia automática está en pausa hasta que las entradas de tu copia también estén en este dispositivo – para que nada se sobrescriba. «Restaurar» o «Hacer copia ahora» las trae aquí.';

  @override
  String get backupProblemOffline =>
      'Sin conexión con Google Drive – se volverá a intentar más tarde.';

  @override
  String get backupProblemAuth =>
      'Google ha denegado el acceso. Vuelve a conectarte, por favor.';

  @override
  String get backupProblemQuota =>
      'Tu almacenamiento de Google Drive está lleno.';

  @override
  String get backupProblemDamaged =>
      'La copia de Google Drive está dañada o pertenece a otra clave.';

  @override
  String get backupProblemUnknown => 'La copia de seguridad no funcionó.';

  @override
  String get backupReconnect => 'Volver a conectar';

  @override
  String get backupChangePassword => 'Cambiar la contraseña de copia';

  @override
  String get backupPasswordChanged => 'Contraseña de copia cambiada';

  @override
  String get backupRenewEmergency => 'Crear una nueva clave de emergencia';

  @override
  String get backupRenewEmergencyAsk =>
      'La clave de emergencia actual dejará de funcionar.';

  @override
  String get backupRenewEmergencyButton => 'Crear nueva clave';

  @override
  String get backupDisconnect => 'Cerrar sesión';

  @override
  String get backupDisconnectTitle => '¿Cerrar sesión en Google Drive?';

  @override
  String get backupDisconnectBody =>
      'Este dispositivo dejará de hacer copias. Tus notas aquí se conservan.';

  @override
  String get backupDisconnectDelete =>
      'Eliminar también la copia de Google Drive';

  @override
  String get settingsSectionAbout => 'Acerca de';

  @override
  String get settingsAbout => 'Acerca de Randnotiz';

  @override
  String get settingsPrivacyPolicy => 'Política de privacidad';

  @override
  String settingsPrivacyPolicyOpenFailed(String url) {
    return 'No se pudo abrir el enlace: $url';
  }

  @override
  String settingsAboutLegalese(String url, String copyright, String source) {
    return 'Un diario de fotos privado. Tus notas se quedan en tu dispositivo.\n\nPrivacidad: $url\n\n$copyright. Software libre bajo la GNU General Public License v3 o posterior, sin ninguna garantía. Código fuente: $source\n\nDatos del mapa: Natural Earth (dominio público). Lugares: GeoNames (CC BY 4.0). Búsqueda de canciones, carátulas y fragmentos: Apple (iTunes Search API). Detalles en «Licencias».';
  }

  @override
  String get tagManageTitle => 'Gestionar estados de ánimo';

  @override
  String tagDeleteConfirmTitle(String name) {
    return '¿Eliminar el estado de ánimo «$name»?';
  }

  @override
  String tagDeleteConfirmBody(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Se quitará de $count notas. Las notas en sí se conservan.',
      one: 'Se quitará de 1 nota. La nota en sí se conserva.',
      zero: 'Todavía no se usa en ninguna parte.',
    );
    return '$_temp0';
  }

  @override
  String tagUsage(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count notas',
      one: '1 nota',
      zero: 'Sin usar',
    );
    return '$_temp0';
  }

  @override
  String get tagEdit => 'Editar estado de ánimo';

  @override
  String get newEntryTooltip => 'Nueva entrada – elegir una foto';

  @override
  String get newEntryImporting => 'Importando la foto …';

  @override
  String get newEntryImportFailed => 'No se pudo importar la foto.';

  @override
  String get placeAdd => 'Lugar';

  @override
  String get placeSheetTitle => 'País y lugar';

  @override
  String get placeSearchHint => 'Buscar un lugar, p. ej. Sevilla';

  @override
  String get placeNoResults => 'No se encontró ningún lugar.';

  @override
  String get placePrivacy =>
      'Solo se guardan el país y el nombre del lugar. Para el tiempo, la ubicación aproximada se envía al servicio meteorológico.';

  @override
  String get placeRemove => 'Quitar';

  @override
  String get placeWeatherHint =>
      'Con un lugar, Randnotiz también muestra el tiempo de ese día.';

  @override
  String get weatherAdjust => 'Ajustar el tiempo a mano';

  @override
  String get editorMetaMood => 'Ánimo';

  @override
  String get navCollections => 'Colecciones';

  @override
  String get collectionAddShort => 'Colección';

  @override
  String get collectionPickerTitle => 'Colecciones';

  @override
  String get collectionPickerHint =>
      'Reúne entradas que van juntas – un viaje, un verano, una persona.';

  @override
  String get collectionNew => 'Nueva colección';

  @override
  String get collectionNameLabel => 'Nombre';

  @override
  String get collectionNameHint => 'p. ej. Italia 2024';

  @override
  String get collectionRename => 'Cambiar nombre';

  @override
  String get collectionDelete => 'Eliminar colección';

  @override
  String get collectionDeleteConfirmTitle => '¿Eliminar la colección?';

  @override
  String collectionDeleteConfirmBody(String name) {
    return 'Se eliminará «$name». Las entradas en sí se quedan en el diario.';
  }

  @override
  String collectionEntryCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count entradas',
      one: '1 entrada',
      zero: 'Aún vacía',
    );
    return '$_temp0';
  }

  @override
  String get collectionsReorderHint => 'Mantén pulsado y arrastra para ordenar';

  @override
  String get collectionMoveEarlier => 'Mover hacia delante';

  @override
  String get collectionMoveLater => 'Mover hacia atrás';

  @override
  String get collectionsEmptyTitle => 'Aún no hay colecciones';

  @override
  String get collectionsEmptyBody =>
      'Agrupa las entradas que van juntas – un viaje, un verano, una persona.';

  @override
  String get collectionEmptyBody =>
      'Añade entradas – aquí o directamente en una nota mediante «Colección».';

  @override
  String get collectionAddEntries => 'Añadir entradas';

  @override
  String get collectionAddEntriesNone =>
      'Todas las entradas ya están en esta colección.';

  @override
  String collectionAddSelected(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Añadir $count entradas',
      one: 'Añadir 1 entrada',
      zero: 'Añadir',
    );
    return '$_temp0';
  }

  @override
  String get collectionRemoveEntry => 'Quitar de la colección';

  @override
  String collectionNeighboursTitle(String name, int position, int total) {
    return '$name · $position de $total';
  }

  @override
  String get collectionPrevious => 'Anterior';

  @override
  String get collectionNext => 'Siguiente';

  @override
  String get collectionStart => 'Aquí empieza la colección';

  @override
  String get collectionEnd => 'Aquí termina la colección';

  @override
  String mapEntriesCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count entradas',
      one: '1 entrada',
    );
    return '$_temp0';
  }

  @override
  String get mapShowAll => 'Mostrar todas las entradas';

  @override
  String get mapEmptyTitle => 'Todavía nada en el mapa';

  @override
  String get mapEmptyBody =>
      'Aquí se colorean los países con entradas. Una entrada recibe su país mediante «Lugar».';

  @override
  String get mapEmptyNoNotes =>
      'En cuanto escribas notas, aquí se colorearán los países en los que has estado.';

  @override
  String get editorTitleHint => 'Título';

  @override
  String get editorTitleLabel => 'Título de la entrada';

  @override
  String get emojiPickerTitle => 'Elegir emoji';

  @override
  String get emojiSearchHint => 'Buscar emoji';

  @override
  String get emojiNoRecents =>
      'Aquí aparecerán los emojis que elegiste por última vez.';

  @override
  String get emojiCurrent => 'Emoji actual';

  @override
  String get emojiChange => 'Cambiar emoji';

  @override
  String get memoriesSectionOnThisDay => 'En este día';

  @override
  String get memoriesSectionAround => 'Alrededor de este día';

  @override
  String get memoriesSectionMore => 'Más recuerdos';

  @override
  String memoriesAnniversaryIn(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Aniversario dentro de $count días',
      one: 'Aniversario mañana',
    );
    return '$_temp0';
  }

  @override
  String memoriesAnniversaryAgo(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Aniversario hace $count días',
      one: 'El aniversario fue ayer',
    );
    return '$_temp0';
  }

  @override
  String get memoriesOpen => 'Abrir entrada';

  @override
  String get memoriesSwipeHint => 'Desliza hacia arriba para ver más';

  @override
  String get journalRemoveFilter => 'Quitar filtro';

  @override
  String get suggestionsTags => 'Estados de ánimo';

  @override
  String get suggestionsPlaces => 'Lugares';

  @override
  String get suggestionsCountries => 'Países';

  @override
  String get suggestionsRecent => 'Búsquedas recientes';

  @override
  String get suggestionsClearRecent => 'Borrar todo';

  @override
  String get suggestionsRemoveRecent => 'Quitar de las búsquedas recientes';

  @override
  String geoBackfillProgress(int done, int total) {
    return 'Completando lugares y países … $done de $total';
  }

  @override
  String get mapTitle => 'Mapa del mundo';

  @override
  String get mapOpen => 'Abrir el mapa del mundo';

  @override
  String get mapShowBorders => 'Mostrar fronteras';

  @override
  String get mapHideBorders => 'Ocultar fronteras';

  @override
  String mapCountriesCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count países',
      one: '1 país',
    );
    return '$_temp0';
  }

  @override
  String mapNoEntriesIn(String country) {
    return 'Aún no hay entradas en $country';
  }

  @override
  String get countryLabel => 'País';

  @override
  String get countryNone => 'Sin país';

  @override
  String get countryAdd => 'Elegir';

  @override
  String get countryChange => 'Cambiar';

  @override
  String get countryRemove => 'Quitar el país';

  @override
  String get countryPickerTitle => 'Elegir país';

  @override
  String get countryPickerSearch => 'Buscar un país';

  @override
  String get introSkip => 'Saltar';

  @override
  String get introNext => 'Continuar';

  @override
  String introPageLabel(int page, int count) {
    return 'Página $page de $count';
  }

  @override
  String get introWelcome => 'Te damos la bienvenida a Randnotiz';

  @override
  String get introWelcomeBody =>
      'Un diario de fotos tranquilo para las historias detrás de tus imágenes.';

  @override
  String get introLanguageTitle => 'Tu idioma';

  @override
  String get introCloudCaption => 'solo para ti';

  @override
  String get introCloudTitle => 'Tu diario sigue siendo tuyo.';

  @override
  String get introCloudBody =>
      'Lo que escribes se queda en este dispositivo – sin cuenta, sin servidores nuestros, sin publicidad y sin rastreo. Si quieres, Randnotiz guarda una copia de tus entradas en una carpeta de aplicación oculta de tu propio Google Drive, cifrada antes de extremo a extremo en este dispositivo.';

  @override
  String get introCloudKeys =>
      'Solo tú tienes la clave: tu contraseña de copia y la clave de emergencia. Sin ellas nadie puede abrir la copia – ni Google ni nosotros, los desarrolladores. Guarda bien las dos.';

  @override
  String get introCloudQuestion => '¿Hacer copia en tu Google Drive?';

  @override
  String get introCloudAfterTour =>
      'La configuras justo después de un breve recorrido.';

  @override
  String get introNoCloud => 'Continuar sin copia';

  @override
  String get introOnlineTitle => 'Cuándo se conecta Randnotiz a Internet';

  @override
  String get introOnlineBody =>
      'El tiempo y la búsqueda de lugares consultan a Open-Meteo – con una posición redondeada a aproximadamente 1 km o con tu término de búsqueda. Si buscas una canción para una entrada, el término de búsqueda se envía a Apple. Al dictar, según el dispositivo, escucha el reconocimiento de voz de Google; si no lo quieres, simplemente escribe. Lo que escribes y tus fotos solo salen del dispositivo cifrados – en tu copia de seguridad.';

  @override
  String get introSetUpBackup => 'Configurar copia de seguridad';

  @override
  String get introHaveBackup => 'Ya tengo una copia de seguridad';

  @override
  String get introBackupUnavailable =>
      'La copia de seguridad no está disponible en esta versión.';

  @override
  String get introPhotoCaption => 'una foto';

  @override
  String get introPhotoTitle => 'Una foto, una historia.';

  @override
  String get introPhotoBody =>
      'Toca abajo la foto con el más y elige una imagen – de tu móvil o de Google Fotos. Randnotiz no necesita acceso a tu galería para ello.';

  @override
  String get introWriteCaption => 'al margen';

  @override
  String get introWriteTitle => 'Escribe cómo fue.';

  @override
  String get introWriteBody =>
      '¿Quién estaba? ¿De qué os reísteis? Escribe o dicta unas líneas al margen – todo se guarda solo. Añade el lugar, el tiempo, tu estado de ánimo o la canción del día si te apetece.';

  @override
  String get introJournalCaption => 'tu diario';

  @override
  String get introJournalTitle => 'Página a página, tu diario.';

  @override
  String get introJournalBody =>
      'Tus entradas se juntan como las páginas de un cuaderno. Busca palabras, lugares o estados de ánimo, reúne tus viajes en colecciones y mira cómo se colorea tu mapa del mundo.';

  @override
  String get introMemoriesCaption => 'hace un año';

  @override
  String get introMemoriesTitle => 'Tus momentos vuelven.';

  @override
  String get introMemoriesBody =>
      'En el aniversario, Randnotiz te devuelve tu momento – en la aplicación y, si quieres, como widget en tu pantalla de inicio.';

  @override
  String get introLock =>
      'Si tu dispositivo tiene bloqueo de pantalla, Randnotiz solo se abre con tu huella, tu cara o tu PIN – viene activado desde el principio. Mientras está bloqueado, no hay capturas de pantalla ni vista previa en las aplicaciones recientes. El widget muestra igualmente una foto de tu diario.';

  @override
  String get introLockDebug =>
      'En esta versión de desarrollo, las capturas de pantalla siguen siendo posibles.';

  @override
  String get introStart => 'Vamos allá';

  @override
  String get introStartBackup => 'Continuar a la copia de seguridad';

  @override
  String get introStartRestore => 'Continuar a la restauración';

  @override
  String get introDemoTitle => 'Pícnic junto al lago';

  @override
  String get introDemoText =>
      'Mia trajo demasiadas fresas. Nos quedamos hasta que se puso el sol.';

  @override
  String get introDemoPlace => 'Lago de Constanza';

  @override
  String get introDemoTitle2 => 'La primera nevada';

  @override
  String get introDemoTitle3 => 'El cumpleaños de la abuela';

  @override
  String get introDemoSearch => 'lago';

  @override
  String get settingsIntro => 'Ver la introducción';

  @override
  String get settingsIntroSubtitle =>
      'Idioma, copia de seguridad y un breve recorrido';

  @override
  String get backupRestoreGuide =>
      '¿Ya tienes una copia de seguridad? Conecta la misma cuenta de Google que en tu dispositivo anterior. Después escribe tu contraseña de copia o la clave de emergencia y recupera tus entradas.';

  @override
  String get backupRestoreNoBackup =>
      'En esta cuenta de Google no hay ninguna copia de Randnotiz. Si está en otra cuenta, cierra sesión y conecta la correcta.';

  @override
  String get backupDevBanner =>
      'App de prueba – comparte la copia de seguridad con la app real. Lo que configures, copies o elimines aquí afecta a la misma copia en Google Drive.';

  @override
  String get backupDevConfirmTitle => '¿De verdad en la app de prueba?';

  @override
  String get backupDevConfirmAuto =>
      'Después, la app de prueba hará copias automáticamente en la misma carpeta de Drive que la app real – las entradas de prueba acabarán también en su copia.';

  @override
  String get backupDevConfirmDelete =>
      'Esto también elimina la copia de la app real, porque ambas usan la misma carpeta de Drive. No se puede deshacer.';

  @override
  String get backupDevConfirmContinue => 'Continuar de todos modos';

  @override
  String get backupDevConfirmDeleteButton => 'Eliminar de todos modos';

  @override
  String get songAdd => 'Añadir canción';

  @override
  String get songSheetTitle => 'Canción de la entrada';

  @override
  String get songSearchHint => 'Buscar título o artista';

  @override
  String get songNoResults => 'No se encontró nada.';

  @override
  String get songSearchSource =>
      'Búsqueda, carátulas y fragmentos proporcionados por Apple';

  @override
  String get songRemove => 'Quitar canción';

  @override
  String get songChange => 'Cambiar canción';

  @override
  String get songPlay => 'Reproducir fragmento';

  @override
  String get songPause => 'Pausar fragmento';

  @override
  String get songChangeHint => 'Mantén pulsado para cambiar';

  @override
  String get songOpenAppleMusic => 'Escuchar en Apple Music';

  @override
  String get songOtherServices => 'Otros servicios';

  @override
  String songRecordLabel(String title, String artist) {
    return 'Canción: $title de $artist';
  }

  @override
  String songOf(String title, String artist) {
    return '$title · $artist';
  }

  @override
  String get journalHasSong => 'Con canción';

  @override
  String get songErrorNetwork => 'Sin conexión con Apple Music.';

  @override
  String get songErrorSearch => 'La búsqueda no funcionó.';

  @override
  String get songErrorRateLimit =>
      'Demasiadas solicitudes ahora mismo. Inténtalo de nuevo en un momento.';

  @override
  String get songErrorPlayback => 'No se pudo reproducir el fragmento ahora.';

  @override
  String get songErrorNoPreview => 'No hay fragmento para esta canción.';

  @override
  String get songErrorNotFound =>
      'Esta canción no está (o ya no está) disponible aquí en Apple Music.';

  @override
  String get songErrorOpen => 'No se pudo abrir el enlace.';

  @override
  String get calendarOpen => 'Abrir el calendario';

  @override
  String get calendarTitle => 'Calendario';

  @override
  String get calendarToday => 'Ir a hoy';

  @override
  String get calendarPreviousMonth => 'Mes anterior';

  @override
  String get calendarNextMonth => 'Mes siguiente';

  @override
  String get calendarYearView => 'Ver años';

  @override
  String get calendarPreviousYear => 'Año anterior';

  @override
  String get calendarNextYear => 'Año siguiente';

  @override
  String calendarYearEntries(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count entradas este año',
      one: '1 entrada este año',
      zero: 'Ninguna entrada este año',
    );
    return '$_temp0';
  }

  @override
  String calendarMonthEntries(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count entradas este mes',
      one: '1 entrada este mes',
      zero: 'Sin entradas este mes',
    );
    return '$_temp0';
  }

  @override
  String get calendarDayEmpty => 'Sin entradas este día';

  @override
  String calendarDaysAhead(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Dentro de $count días',
      one: 'Mañana',
    );
    return '$_temp0';
  }

  @override
  String get settingsWhatsNew => 'Novedades';

  @override
  String get settingsWhatsNewSubtitle =>
      'Lo que ha cambiado en las últimas actualizaciones';

  @override
  String whatsNewTitle(String version) {
    return 'Novedades de Randnotiz $version';
  }

  @override
  String whatsNewVersion(String version) {
    return 'Versión $version';
  }

  @override
  String get whatsNewDone => 'Entendido';

  @override
  String get whatsNew130EncryptionTitle => 'Guardado con cifrado';

  @override
  String get whatsNew130EncryptionBody =>
      'Tus notas ahora se guardan cifradas en tu dispositivo. Solo Randnotiz conoce la clave: está en el almacenamiento protegido de Android y nunca sale de tu móvil.';

  @override
  String get whatsNew130LifeShareTitle => '¿Cuánto de tu vida?';

  @override
  String get whatsNew130LifeShareBody =>
      'Añade tu cumpleaños en los ajustes: los recuerdos y el calendario te muestran entonces qué parte de tu vida hasta ahora ya habías vivido en ese momento.';

  @override
  String get whatsNew120CalendarTitle => 'Calendario';

  @override
  String get whatsNew120CalendarBody =>
      'Toca el icono del calendario en el diario para ver qué días escribiste – mes a mes, o el año entero de un vistazo.';

  @override
  String get whatsNew120CollectionsTitle => 'Colecciones';

  @override
  String get whatsNew120CollectionsBody =>
      'Las entradas más recientes aparecen ahora primero, como en el diario.';

  @override
  String get whatsNew120TitlesTitle => 'Escrito a mano';

  @override
  String get whatsNew120TitlesBody =>
      'Al cambiar de pestaña, el título anterior se tacha y el nuevo se escribe a mano.';

  @override
  String get whatsNew120PolishTitle => 'Pequeñas mejoras';

  @override
  String get whatsNew120PolishBody =>
      'Las notas largas se quedan justo sobre las líneas y el menú ya no se sube encima del teclado mientras escribes.';
}
