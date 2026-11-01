/// Microphone permission as seen by the app.
enum MicPermission {
  granted,

  /// Not granted yet, the system dialog can still be shown.
  canAsk,

  /// Denied permanently ("Nicht mehr fragen"), only the system settings help.
  permanentlyDenied,
}

/// Why dictation stopped or could not start, mapped to user-facing hints.
enum DictationProblem {
  /// No speech recognition service on this device.
  unavailable,
  permissionDenied,
  noSpeechRecognized,
  network,
  busy,
  languageUnsupported,

  /// Microphone taken by something else (e.g. a phone call).
  audio,
  unknown,
}

/// Maps the error codes of Android's SpeechRecognizer (as reported by the
/// speech_to_text plugin, e.g. `error_no_match`) to [DictationProblem].
DictationProblem problemFromErrorCode(String code) {
  final c = code.toLowerCase();
  if (c.startsWith('error_no_match') || c.startsWith('error_speech_timeout')) {
    return DictationProblem.noSpeechRecognized;
  }
  if (c.startsWith('error_network') ||
      c.startsWith('error_server') ||
      c.startsWith('error_too_many_requests')) {
    return DictationProblem.network;
  }
  if (c.startsWith('error_permission')) {
    return DictationProblem.permissionDenied;
  }
  if (c.startsWith('error_busy')) return DictationProblem.busy;
  if (c.startsWith('error_language')) {
    return DictationProblem.languageUnsupported;
  }
  if (c.startsWith('error_audio')) return DictationProblem.audio;
  return DictationProblem.unknown;
}

/// Whether an error means "the on-device recognizer cannot do this language",
/// in which case the system (possibly online) recognizer is tried instead.
bool isOnDeviceLanguageError(String code) =>
    code.startsWith('error_language_not_supported') ||
    code.startsWith('error_language_unavailable') ||
    code.startsWith('error_client');

/// Events emitted by a running dictation.
sealed class DictationEvent {
  const DictationEvent();
}

class DictationText extends DictationEvent {
  const DictationText(this.text, {required this.isFinal});
  final String text;
  final bool isFinal;
}

/// Recognition ended (silence, stop, or after the final result).
class DictationDone extends DictationEvent {
  const DictationDone();
}

class DictationFailed extends DictationEvent {
  const DictationFailed(this.code);

  /// Raw error code, see [problemFromErrorCode].
  final String code;
}

/// Speech-to-text behind an interface so the editor logic is testable and the
/// engine replaceable. Audio is never stored – only text is returned.
abstract interface class DictationService {
  Future<MicPermission> micPermission();

  /// Shows the system permission dialog.
  Future<MicPermission> requestMicPermission();

  Future<void> openAppSettings();

  /// Prepares the recognizer. Must only be called with granted permission.
  /// Returns false if no recognizer is available.
  Future<bool> initialize();

  /// Starts listening for [localeId], preferring on-device recognition.
  Future<void> start({
    required String localeId,
    required bool preferOnDevice,
    required void Function(DictationEvent event) onEvent,
  });

  /// Stops listening; a final result may still be delivered.
  Future<void> stop();

  /// Stops without delivering further results.
  Future<void> cancel();
}
