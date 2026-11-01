import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:speech_to_text/speech_recognition_error.dart';
import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:speech_to_text/speech_to_text.dart';

import '../domain/dictation_service.dart';

/// [DictationService] using Android's SpeechRecognizer via speech_to_text.
///
/// With `preferOnDevice` the on-device recognizer is used when the device
/// offers one (Android 12+); otherwise the plugin falls back to the system
/// recognizer, which may process audio on Google servers depending on the
/// device settings. No audio is recorded or stored by the app.
class SpeechToTextDictationService implements DictationService {
  SpeechToTextDictationService([SpeechToText? speech])
    : _speech = speech ?? SpeechToText();

  final SpeechToText _speech;
  void Function(DictationEvent event)? _onEvent;

  /// Native bridge in MainActivity.kt (no extra plugin needed).
  static const _permissions = MethodChannel(
    'io.github.randnotiz.app/permissions',
  );

  static MicPermission _parse(String? status) => switch (status) {
    'granted' => MicPermission.granted,
    'permanentlyDenied' => MicPermission.permanentlyDenied,
    _ => MicPermission.canAsk,
  };

  @override
  Future<MicPermission> micPermission() async =>
      _parse(await _permissions.invokeMethod<String>('micStatus'));

  @override
  Future<MicPermission> requestMicPermission() async =>
      _parse(await _permissions.invokeMethod<String>('requestMic'));

  @override
  Future<void> openAppSettings() =>
      _permissions.invokeMethod<bool>('openAppSettings');

  @override
  Future<bool> initialize() async {
    try {
      return await _speech.initialize(
        onError: _handleError,
        onStatus: _handleStatus,
        options: [SpeechToText.androidNoBluetooth],
      );
    } on Exception catch (e) {
      debugPrint('Speech init failed: $e');
      return false;
    }
  }

  @override
  Future<void> start({
    required String localeId,
    required bool preferOnDevice,
    required void Function(DictationEvent event) onEvent,
  }) async {
    _onEvent = onEvent;
    await _speech.listen(
      onResult: _handleResult,
      listenOptions: SpeechListenOptions(
        localeId: localeId,
        onDevice: preferOnDevice,
        partialResults: true,
        listenMode: ListenMode.dictation,
        cancelOnError: true,
        autoPunctuation: true,
        listenFor: const Duration(minutes: 2),
        pauseFor: const Duration(seconds: 5),
      ),
    );
  }

  void _handleResult(SpeechRecognitionResult result) {
    _onEvent?.call(
      DictationText(result.recognizedWords, isFinal: result.finalResult),
    );
  }

  void _handleError(SpeechRecognitionError error) {
    _onEvent?.call(DictationFailed(error.errorMsg));
  }

  void _handleStatus(String status) {
    debugPrint('Speech status: $status');
    if (status == SpeechToText.doneStatus) {
      _onEvent?.call(const DictationDone());
    }
  }

  @override
  Future<void> stop() => _speech.stop();

  @override
  Future<void> cancel() async {
    _onEvent = null;
    await _speech.cancel();
  }
}
