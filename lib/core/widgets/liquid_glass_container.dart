import 'dart:ui' show ImageFilter;

import 'package:flutter/material.dart';

/// A translucent surface with blur, highlights, and a subtle border.
class LiquidGlassContainer extends StatelessWidget {
  const LiquidGlassContainer({
    super.key,
    required this.child,
    this.borderRadius = const BorderRadius.all(Radius.circular(24)),
  });

  final Widget child;
  final BorderRadius borderRadius;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final dark = theme.brightness == Brightness.dark;

    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: borderRadius,
        boxShadow: [
          BoxShadow(
            color: scheme.shadow.withValues(alpha: dark ? .2 : .08),
            blurRadius: 12,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: borderRadius,
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 24, sigmaY: 24),
          child: DecoratedBox(
            decoration: BoxDecoration(
              borderRadius: borderRadius,
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Colors.white.withValues(alpha: dark ? .16 : .7),
                  scheme.surface.withValues(alpha: dark ? .4 : .24),
                  scheme.primary.withValues(alpha: dark ? .1 : .04),
                ],
              ),
            ),
            child: DecoratedBox(
              position: DecorationPosition.foreground,
              decoration: BoxDecoration(
                borderRadius: borderRadius,
                border: Border.all(
                  color: Colors.white.withValues(alpha: dark ? .24 : .85),
                  width: .8,
                ),
              ),
              child: child,
            ),
          ),
        ),
      ),
    );
  }
}
