import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/utils/motion.dart';
import 'splash_robot_scene.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen>
    with SingleTickerProviderStateMixin {
  static const _greetingDuration = Duration(milliseconds: 2800);
  late final AnimationController _animation;
  Timer? _timer;
  bool? _motionOn;

  @override
  void initState() {
    super.initState();
    _animation = AnimationController(vsync: this, duration: _greetingDuration);
  }

  void _syncMotion(bool animate) {
    if (_motionOn == animate) return;
    _motionOn = animate;
    _timer?.cancel();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!mounted || _motionOn != animate) return;
      if (animate) {
        await precacheImage(
          const AssetImage(SplashRobotScene.asset),
          context,
          onError: (error, stack) => debugPrint('Splash artwork: $error'),
        );
        if (!mounted || _motionOn != animate) return;
        _animation.forward(from: 0);
      } else {
        _animation
          ..stop()
          ..value = 1;
      }
      _timer = Timer(animate ? _greetingDuration : Duration.zero, () {
        if (mounted) context.go('/home');
      });
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _animation.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final animate = motionEnabled(context, ref);
    _syncMotion(animate);
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return CupertinoPageScaffold(
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: RadialGradient(
            center: const Alignment(0, -.15),
            radius: 1.05,
            colors: [
              Color.alphaBlend(
                scheme.primary.withValues(alpha: .1),
                theme.scaffoldBackgroundColor,
              ),
              theme.scaffoldBackgroundColor,
            ],
          ),
        ),
        child: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              final padding = (constraints.biggest.shortestSide * .05).clamp(
                8.0,
                32.0,
              );
              // Keep a readable composition, then scale it as a whole when
              // either dimension is tight (landscape or split-screen).
              final heroSize = (constraints.maxWidth - padding * 2).clamp(
                280.0,
                480.0,
              );
              return Padding(
                padding: EdgeInsets.all(padding),
                child: Center(
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: AnimatedBuilder(
                      animation: _animation,
                      builder: (context, _) {
                        final progress = _animation.value;
                        final arrival = animate
                            ? Curves.easeOutCubic.transform(
                                (progress / .28).clamp(0.0, 1.0),
                              )
                            : 1.0;
                        return SizedBox(
                          key: const ValueKey('splash-content'),
                          width: heroSize,
                          child: Padding(
                            // Leave room for the arrival and floating animations.
                            padding: const EdgeInsets.symmetric(vertical: 24),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Opacity(
                                  opacity: arrival,
                                  child: Transform.translate(
                                    offset: Offset(0, (1 - arrival) * 24),
                                    child: SplashRobotScene(
                                      size: heroSize,
                                      progress: progress,
                                      animate: animate,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 32),
                                ExcludeSemantics(
                                  child: SizedBox(
                                    width: heroSize * .32,
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(4),
                                      child: LinearProgressIndicator(
                                        key: const ValueKey('splash-progress'),
                                        value: progress,
                                        minHeight: 3,
                                        color: scheme.primary,
                                        backgroundColor: scheme.primary
                                            .withValues(alpha: .12),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
