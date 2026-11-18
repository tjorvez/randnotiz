import 'package:randnotiz/features/dictation/domain/dictation_service.dart';

/// Scriptable [DictationService] for tests.
class FakeDictationService implements DictationService {
  MicPermission permission = MicPermission.canAsk;
  MicPermission answerToRequest = MicPermission.granted;
  bool available = true;
  int requestCount = 0;
  final starts = <bool>[];
  void Function(DictationEvent)? onEvent;
  bool stopped = false;

  @override
  Future<MicPermission> micPermission() async => permission;

  @override
  Future<MicPermission> requestMicPermission() async {
    requestCount++;
    return permission = answerToRequest;
  }

  @override
  Future<void> openAppSettings() async {}

  @override
  Future<bool> initialize() async => available;

  @override
  Future<void> start({
    required String localeId,
    required bool preferOnDevice,
    required void Function(DictationEvent event) onEvent,
  }) async {
    starts.add(preferOnDevice);
    this.onEvent = onEvent;
  }

  @override
  Future<void> stop() async => stopped = true;

  @override
  Future<void> cancel() async {}

  void emit(DictationEvent e) => onEvent!(e);
}
