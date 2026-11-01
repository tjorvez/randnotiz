import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../core/widgets/polaroid.dart';
import '../../../l10n/generated/app_localizations.dart';

/// The title, written by hand on the polaroid's rim. While not editing, a
/// long title shows with an ellipsis like everywhere else; tapping it
/// edits it (one line, the script shrinks as the title grows).
///
/// The text field always stays in the tree (only hidden behind the display
/// text), so a tap can focus it.
class RimTitleField extends StatelessWidget {
  const RimTitleField({
    super.key,
    required this.controller,
    required this.focusNode,
  });

  final TextEditingController controller;
  final FocusNode focusNode;

  /// Long enough for a headline, short enough for the rim.
  static const maxLength = 80;

  void _edit() {
    controller.selection = TextSelection.collapsed(
      offset: controller.text.length,
    );
    focusNode.requestFocus();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return LayoutBuilder(
      builder: (context, constraints) => ListenableBuilder(
        listenable: Listenable.merge([controller, focusNode]),
        builder: (context, _) {
          final text = controller.text;
          final display = !focusNode.hasFocus && text.trim().isNotEmpty;
          final fit = PolaroidTitleFit.compute(
            text.isEmpty ? l10n.editorTitleHint : text,
            width: constraints.maxWidth * 0.84,
            rimHeight: constraints.maxHeight,
          );
          final style = PolaroidTitleFit.style(fit.fontSize, polaroidInk);
          final field = Center(
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: constraints.maxWidth * 0.04,
              ),
              child: TextField(
                controller: controller,
                focusNode: focusNode,
                maxLines: 1,
                textAlign: TextAlign.center,
                textCapitalization: TextCapitalization.sentences,
                textInputAction: TextInputAction.done,
                onSubmitted: (_) => focusNode.unfocus(),
                inputFormatters: [
                  LengthLimitingTextInputFormatter(maxLength),
                  FilteringTextInputFormatter.deny(RegExp(r'[\n\r]')),
                ],
                style: style,
                cursorColor: polaroidInk,
                cursorWidth: 1.5,
                scrollPadding: const EdgeInsets.all(80),
                decoration: InputDecoration.collapsed(
                  hintText: l10n.editorTitleHint,
                  hintStyle: style.copyWith(
                    color: polaroidInk.withValues(alpha: 0.38),
                  ),
                ),
              ),
            ),
          );
          return Stack(
            fit: StackFit.expand,
            children: [
              ExcludeSemantics(
                excluding: display,
                child: Opacity(
                  opacity: display ? 0 : 1,
                  // The faint hint fades in once the polaroid has landed
                  // (it is not part of the flight).
                  child: TweenAnimationBuilder<double>(
                    tween: Tween(begin: 0, end: 1),
                    duration: MediaQuery.disableAnimationsOf(context)
                        ? Duration.zero
                        : const Duration(milliseconds: 260),
                    builder: (context, t, child) =>
                        Opacity(opacity: t, child: child),
                    child: field,
                  ),
                ),
              ),
              if (display)
                Semantics(
                  button: true,
                  label: l10n.editorTitleLabel,
                  value: text,
                  excludeSemantics: true,
                  child: GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: _edit,
                    child: PolaroidTitle(text),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}
