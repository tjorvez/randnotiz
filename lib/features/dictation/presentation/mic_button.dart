import 'dart:async';

import 'package:flutter/material.dart';

import '../../../l10n/generated/app_localizations.dart';
import '../domain/dictation_service.dart';
import 'dictation_controller.dart';

/// Microphone button of the editor. Never disappears silently: every reason
/// why dictation is not possible is explained to the user.
///
/// It is only there while the keyboard is closed: typing and dictating do
/// not mix. When the keyboard opens, the button fades out and a running
/// dictation ends cleanly – the text recognised so far stays, and a final
/// result arriving shortly afterwards is still applied (see
/// [DictationController.stop]). When the keyboard closes, it fades back in.
class MicButton extends StatefulWidget {
  const MicButton({super.key, required this.controller, required this.service});

  final DictationController controller;
  final DictationService service;

  @override
  State<MicButton> createState() => _MicButtonState();
}

class _MicButtonState extends State<MicButton> {
  bool _unavailable = false;
  bool _keyboardOpen = false;

  /// Fade of the button when the keyboard opens or closes.
  static const fadeDuration = Duration(milliseconds: 180);

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_onChange);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final open = MediaQuery.viewInsetsOf(context).bottom > 0;
    if (open && !_keyboardOpen && widget.controller.isActive) {
      unawaited(widget.controller.stop());
    }
    _keyboardOpen = open;
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onChange);
    super.dispose();
  }

  void _onChange() {
    final problem = widget.controller.lastProblem;
    if (problem != null) {
      widget.controller.clearProblem();
      _showProblem(problem);
    }
    if (mounted) setState(() {});
  }

  void _snack(String text) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(text)));
  }

  void _showProblem(DictationProblem problem) {
    if (!mounted) return;
    final l10n = AppLocalizations.of(context);
    _snack(switch (problem) {
      DictationProblem.unavailable => l10n.micUnavailable,
      DictationProblem.permissionDenied => l10n.micDenied,
      DictationProblem.noSpeechRecognized => l10n.dictationNoSpeech,
      DictationProblem.network => l10n.dictationNetwork,
      DictationProblem.busy => l10n.dictationBusy,
      DictationProblem.languageUnsupported => l10n.dictationLanguage,
      DictationProblem.audio => l10n.dictationAudio,
      DictationProblem.unknown => l10n.dictationUnknown,
    });
  }

  Future<void> _onPressed() async {
    final controller = widget.controller;
    if (controller.isActive) {
      await controller.stop();
      return;
    }
    final l10n = AppLocalizations.of(context);
    var outcome = await controller.start();
    if (!mounted) return;

    if (outcome == DictationStartOutcome.needsRationale) {
      final ok = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          icon: const Icon(Icons.mic_none),
          title: Text(l10n.micRationaleTitle),
          content: Text(l10n.micRationaleBody),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: Text(l10n.cancel),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(context, true),
              child: Text(l10n.micRationaleContinue),
            ),
          ],
        ),
      );
      if (ok != true || !mounted) return;
      outcome = await controller.start(rationaleShown: true);
      if (!mounted) return;
    }

    switch (outcome) {
      case DictationStartOutcome.started:
      case DictationStartOutcome.alreadyRunning:
      case DictationStartOutcome.needsRationale:
        setState(() => _unavailable = false);
      case DictationStartOutcome.permissionDenied:
        _snack(l10n.micDenied);
      case DictationStartOutcome.unavailable:
        setState(() => _unavailable = true);
        _snack(l10n.micUnavailable);
      case DictationStartOutcome.permissionPermanentlyDenied:
        setState(() => _unavailable = true);
        await showDialog<void>(
          context: context,
          builder: (context) => AlertDialog(
            icon: const Icon(Icons.mic_off_outlined),
            title: Text(l10n.micPermanentlyDeniedTitle),
            content: Text(l10n.micPermanentlyDeniedBody),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(l10n.cancel),
              ),
              FilledButton(
                onPressed: () {
                  Navigator.pop(context);
                  unawaited(widget.service.openAppSettings());
                },
                child: Text(l10n.openSystemSettings),
              ),
            ],
          ),
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final scheme = Theme.of(context).colorScheme;
    final phase = widget.controller.phase;
    final listening = phase != DictationPhase.idle;
    // Hidden while the keyboard is open.
    final visible = MediaQuery.viewInsetsOf(context).bottom <= 0;
    final reduceMotion = MediaQuery.disableAnimationsOf(context);
    final duration = reduceMotion ? Duration.zero : fadeDuration;

    final button = FloatingActionButton.extended(
      heroTag: 'mic',
      onPressed: _onPressed,
      tooltip: listening
          ? l10n.micStop
          : _unavailable
          ? l10n.micUnavailableTooltip
          : l10n.micStart,
      backgroundColor: listening ? scheme.secondary : scheme.primaryContainer,
      foregroundColor: listening
          ? scheme.onSecondary
          : scheme.onPrimaryContainer,
      icon: AnimatedSwitcher(
        duration: const Duration(milliseconds: 200),
        child: Icon(
          listening
              ? Icons.stop_rounded
              : _unavailable
              ? Icons.mic_off_outlined
              : Icons.mic_none_rounded,
          key: ValueKey('$listening$_unavailable'),
        ),
      ),
      label: AnimatedSize(
        duration: const Duration(milliseconds: 200),
        child: Text(listening ? l10n.micListening : l10n.micStart),
      ),
    );

    return IgnorePointer(
      ignoring: !visible,
      child: ExcludeSemantics(
        excluding: !visible,
        child: AnimatedOpacity(
          opacity: visible ? 1 : 0,
          duration: duration,
          curve: Curves.easeOut,
          child: AnimatedScale(
            scale: visible ? 1 : 0.85,
            duration: duration,
            curve: Curves.easeOut,
            child: button,
          ),
        ),
      ),
    );
  }
}
