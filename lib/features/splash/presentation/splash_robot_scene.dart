import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../core/localization/app_localizations.dart';
import 'waving_robot.dart';

class SplashRobotScene extends StatelessWidget {
  const SplashRobotScene({
    super.key,
    required this.size,
    required this.progress,
    required this.animate,
  });

  static const asset = 'assets/images/splash_robot.png';

  final double size, progress;
  final bool animate;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final phase = animate ? progress * math.pi * 2 : 0.0;
    final float = math.sin(phase);
    final waveEnvelope =
        Curves.easeInOut.transform((progress / .12).clamp(0.0, 1.0)) *
        Curves.easeInOut.transform(((1 - progress) / .12).clamp(0.0, 1.0));
    final handAngle = animate
        ? math.sin(progress * math.pi * 6) * .26 * waveEnvelope
        : 0.0;
    final greeting = animate ? ((progress - .1) / .2).clamp(0.0, 1.0) : 1.0;

    return SizedBox.square(
      dimension: size,
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.center,
        children: [
          ExcludeSemantics(
            child: Container(
              width: size * .9,
              height: size * .9,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    scheme.primary.withValues(alpha: .14),
                    scheme.primary.withValues(alpha: 0),
                  ],
                ),
              ),
            ),
          ),
          ExcludeSemantics(
            child: Container(
              width: size * .78,
              height: size * .78,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: scheme.primary.withValues(alpha: .09),
                ),
              ),
            ),
          ),
          Positioned(
            bottom: 5,
            child: ExcludeSemantics(
              child: Transform.scale(
                scale: 1 + float * .08,
                child: Container(
                  width: size * .44,
                  height: 16,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(100),
                    gradient: RadialGradient(
                      colors: [
                        scheme.primary.withValues(alpha: .16),
                        scheme.primary.withValues(alpha: 0),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
          ExcludeSemantics(
            child: Transform.translate(
              offset: Offset(
                math.cos(phase * .3 + .6) * size * .43,
                math.sin(phase * .3 + .6) * size * .35,
              ),
              child: Container(
                width: 7,
                height: 7,
                decoration: BoxDecoration(
                  color: scheme.primary.withValues(alpha: .5),
                  shape: BoxShape.circle,
                ),
              ),
            ),
          ),
          Positioned.fill(
            top: size * .08,
            child: Transform.translate(
              key: const ValueKey('splash-robot-float'),
              offset: Offset(0, -float * 8),
              child: Transform.rotate(
                angle: float * .025,
                child: Semantics(
                  image: true,
                  label: context.tr(
                    'A friendly robot holding a phone and waving',
                  ),
                  child: WavingRobot(asset: asset, handAngle: handAngle),
                ),
              ),
            ),
          ),
          PositionedDirectional(
            top: 0,
            end: 0,
            child: Opacity(
              opacity: greeting,
              child: Transform.scale(
                scale: .8 + .2 * Curves.easeOutBack.transform(greeting),
                alignment: Alignment.bottomLeft,
                child: Semantics(
                  header: true,
                  child: ConstrainedBox(
                    constraints: BoxConstraints(maxWidth: size * .75),
                    child: Stack(
                      clipBehavior: Clip.none,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 18,
                            vertical: 10,
                          ),
                          decoration: BoxDecoration(
                            color: scheme.surface,
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: scheme.primary.withValues(alpha: .1),
                                blurRadius: 24,
                                offset: const Offset(0, 8),
                              ),
                            ],
                          ),
                          child: Text(
                            'Wellcome',
                            textAlign: TextAlign.center,
                            style: Theme.of(context).textTheme.titleMedium
                                ?.copyWith(color: scheme.primary),
                          ),
                        ),
                        PositionedDirectional(
                          start: 22,
                          bottom: -5,
                          child: Transform.rotate(
                            angle: math.pi / 4,
                            child: ColoredBox(
                              color: scheme.surface,
                              child: const SizedBox.square(dimension: 12),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
