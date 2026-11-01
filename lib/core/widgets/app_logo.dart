import 'package:flutter/material.dart';

/// The Randnotiz logo (tilted photo with annotation asterisk), tinted with
/// the current accent colour.
class AppLogo extends StatelessWidget {
  const AppLogo({super.key, this.size = 64, this.color});

  final double size;
  final Color? color;

  @override
  Widget build(BuildContext context) => Image.asset(
    'assets/branding/icon_512.png',
    width: size,
    height: size,
    color: color ?? Theme.of(context).colorScheme.primary,
    colorBlendMode: BlendMode.srcIn,
    semanticLabel: 'Randnotiz',
  );
}
