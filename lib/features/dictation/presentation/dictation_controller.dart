import 'dart:async';

import 'package:flutter/widgets.dart';

import '../domain/dictation_insertion.dart';
import '../domain/dictation_service.dart';

enum DictationPhase { idle, starting, listening }

/// What the UI must do before dictation can start.
enum DictationStartOutcome {
  started,

  /// Show the friendly explanation, then call [DictationController.start]
  /// again with `rationaleShown: true`.
  needsRationale,

  /// Permission was denied permanently – offer the system settings.
  permissionPermanentlyDenied,

  /// The user declined the system dialog.
  permissionDenied,

  /// No speech recognition on this device.
  unavailable,

  alreadyRunning,
}

/// Connects a [DictationService] with a [TextEditingController]: recognized
/// text is inserted live at the cursor (see [DictationInsertion]).
///
/// Interruptions (app goes to background, incoming call, user starts typing)
/// end the session; the text written so far stays in the field.
class DictationController extends ChangeNotifier {
  DictationController({
    required this._service,
    required TextEditingController textController,
    this.localeId = 'de_DE',
    this.onTextChanged,
  }) : _text = textController {
    _text.addListener(_onFieldChanged);
  }

  final DictationService _service;
  final TextEditingController _text;
  final String localeId;

  /// Called after dictation changed the field, e.g. to trigger autosave.
  final VoidCallback? onTextChanged;

  DictationPhase _phase = DictationPhase.idle;
  DictationPhase get phase => _phase;
  bool get isActive => _phase != DictationPhase.idle;

  DictationProblem? _lastProblem;

  /// The last problem; the UI shows it once and calls [clearProblem].
  DictationProblem? get lastProblem => _lastProblem;

  DictationInsertion? _insertion;
  bool _applying = false;
  bool _initialized = false;
  bool _preferOnDevice = true;
  bool _receivedText = false;
  int _session = 0;
  bool _disposed = false;

  void clearProblem() {
    _lastProblem = null;
  }

  Future<DictationStartOutcome> start({bool rationaleShown = false}) async {
    if (isActive) return DictationStartOutcome.alreadyRunning;

    var permission = await _service.micPermission();
    if (permission == MicPermission.permanentlyDenied) {
      return DictationStartOutcome.permissionPermanentlyDenied;
    }
    if (permission == MicPermission.canAsk) {
      if (!rationaleShown) return DictationStartOutcome.needsRationale;
      permission = await _service.requestMicPermission();
      if (permission == MicPermission.permanentlyDenied) {
        return DictationStartOutcome.permissionPermanentlyDenied;
      }
      if (permission != MicPermission.granted) {
        return DictationStartOutcome.permissionDenied;
      }
    }

    _setPhase(DictationPhase.starting);
    if (!_initialized) {
      _initialized = await _service.initialize();
      if (!_initialized) {
        _setPhase(DictationPhase.idle);
        return DictationStartOutcome.unavailable;
      }
    }
    await _listen();
    return DictationStartOutcome.started;
  }

  Future<void> _listen() async {
    final session = ++_session;
    _insertion = DictationInsertion.start(_text.value);
    _receivedText = false;
    _lastProblem = null;
    debugPrint('Dictation: start (onDevice preferred: $_preferOnDevice)');
    try {
      await _service.start(
        localeId: localeId,
        preferOnDevice: _preferOnDevice,
        onEvent: (event) {
          if (session == _session) _handle(event);
        },
      );
      if (session == _session && _phase == DictationPhase.starting) {
        _setPhase(DictationPhase.listening);
      }
    } on Exception catch (e) {
      debugPrint('Dictation: start failed: $e');
      _insertion = null;
      _lastProblem = DictationProblem.unavailable;
      _setPhase(DictationPhase.idle);
    }
  }

  void _handle(DictationEvent event) {
    switch (event) {
      case DictationText(:final text, :final isFinal):
        if (_phase == DictationPhase.starting) {
          _setPhase(DictationPhase.listening);
        }
        _receivedText = _receivedText || text.trim().isNotEmpty;
        _applyText(text);
        if (isFinal) {
          _insertion = null;
          _setPhase(DictationPhase.idle);
        }
      case DictationDone():
        // Android often ends a silent session with "done" instead of an
        // error. Tell the user instead of silently going idle – unless the
        // user stopped it (then the phase is already idle).
        if (_phase != DictationPhase.idle && !_receivedText) {
          _insertion = null;
          _lastProblem = DictationProblem.noSpeechRecognized;
        }
        _setPhase(DictationPhase.idle);
      case DictationFailed(:final code):
        debugPrint('Dictation: error $code');
        if (_preferOnDevice &&
            !_receivedText &&
            isOnDeviceLanguageError(code)) {
          // On-device model missing for German: use the system recognizer.
          _preferOnDevice = false;
          unawaited(_listen());
          return;
        }
        _insertion = null;
        _lastProblem = problemFromErrorCode(code);
        _setPhase(DictationPhase.idle);
    }
  }

  /// Writes [text] into the field. Late results (e.g. the final result after
  /// [stop]) are still applied as long as the user has not edited the text.
  void _applyText(String text) {
    final insertion = _insertion;
    if (insertion == null) return;
    if (!insertion.isUnchanged(_text.value)) {
      _insertion = null;
      return;
    }
    _applying = true;
    _text.value = insertion.apply(text);
    _applying = false;
    onTextChanged?.call();
  }

  void _onFieldChanged() {
    if (_applying) return;
    final insertion = _insertion;
    if (insertion != null && !insertion.isUnchanged(_text.value)) {
      // The user typed: keep everything, stop listening, ignore late results.
      _insertion = null;
      if (isActive) unawaited(stop());
    }
  }

  /// Ends dictation. Text written so far stays; a final result that arrives
  /// shortly afterwards still replaces the last partial result.
  Future<void> stop() async {
    if (!isActive) return;
    _setPhase(DictationPhase.idle);
    try {
      await _service.stop();
    } on Exception catch (e) {
      debugPrint('Dictation: stop failed: $e');
    }
  }

  /// Called when the app leaves the foreground (call, home button, …).
  Future<void> interrupt() => stop();

  void _setPhase(DictationPhase phase) {
    if (_disposed) return;
    _phase = phase;
    notifyListeners();
  }

  @override
  void dispose() {
    _disposed = true;
    _text.removeListener(_onFieldChanged);
    if (_phase != DictationPhase.idle) unawaited(_service.cancel());
    super.dispose();
  }
}
