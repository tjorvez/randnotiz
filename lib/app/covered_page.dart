import 'package:flutter/widgets.dart';

/// A page that another route covers (e.g. the journal below an open note)
/// does not follow the keyboard: while the keyboard slides in, the view
/// insets change every frame, and every page that depends on them would
/// rebuild and lay out again behind the visible one. Covered, it sees no
/// keyboard at all; on top again, it gets the real insets back.
///
/// Always the same structure (only the insets differ), so the page's state
/// is never rebuilt from scratch.
class CoveredPageInsets extends StatelessWidget {
  const CoveredPageInsets({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final covered = !(ModalRoute.isCurrentOf(context) ?? true);
    return MediaQuery.removeViewInsets(
      context: context,
      removeBottom: covered,
      child: child,
    );
  }
}
