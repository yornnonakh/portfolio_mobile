import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/localization/app_localizations.dart';
import '../../../core/utils/motion.dart';
import 'showcase_phone.dart';

/// A continuously looping, perspective carousel on a transparent canvas.
class ProjectPhoneShowcase extends ConsumerStatefulWidget {
  const ProjectPhoneShowcase({super.key});

  @override
  ConsumerState<ProjectPhoneShowcase> createState() =>
      _ProjectPhoneShowcaseState();
}

class _ProjectPhoneShowcaseState extends ConsumerState<ProjectPhoneShowcase>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  bool _motionOn = false;

  // Each screen is painted independently so its content can be cached while
  // the carousel changes only its transform and position in the paint order.
  static const _phones = [
    RepaintBoundary(child: ShowcasePhone(index: 0)),
    RepaintBoundary(child: ShowcasePhone(index: 1)),
    RepaintBoundary(child: ShowcasePhone(index: 2)),
    RepaintBoundary(child: ShowcasePhone(index: 3)),
  ];

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 16),
    );
  }

  void _syncMotion(bool enabled) {
    if (_motionOn == enabled) return;
    _motionOn = enabled;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      if (_motionOn) {
        _controller.repeat();
      } else {
        _controller
          ..stop()
          ..value = 0;
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    _syncMotion(motionEnabled(context, ref));
    return Semantics(
      image: true,
      label: context.tr('Four illustrative mobile app screens'),
      child: ExcludeSemantics(
        child: IgnorePointer(
          child: RepaintBoundary(
            child: LayoutBuilder(
              builder: (context, constraints) {
                final width = math.min(constraints.maxWidth, 900.0);
                return Center(
                  child: SizedBox(
                    key: const ValueKey('project-phone-showcase'),
                    width: width,
                    height: width * 620 / 860,
                    child: FittedBox(
                      child: SizedBox(
                        width: 860,
                        height: 620,
                        child: AnimatedBuilder(
                          animation: _controller,
                          builder: (context, _) {
                            final step = _controller.value * _phones.length;
                            final fraction = step - step.floorToDouble();
                            // Slow down as each phone reaches the front while
                            // preserving nonzero, matching velocity at every
                            // quarter turn and at the end of the full loop.
                            final turn =
                                step.floorToDouble() +
                                fraction * .35 +
                                Curves.easeInOutSine.transform(fraction) * .65;
                            final poses =
                                List.generate(
                                  _phones.length,
                                  (index) => _PhonePose(
                                    index: index,
                                    angle: (index - turn) * math.pi / 2,
                                  ),
                                )..sort((a, b) {
                                  final depth = a.depth.compareTo(b.depth);
                                  return depth == 0
                                      ? a.index.compareTo(b.index)
                                      : depth;
                                });
                            return Stack(
                              key: const ValueKey('phone-carousel-stack'),
                              clipBehavior: Clip.none,
                              children: [
                                for (final pose in poses)
                                  Positioned(
                                    key: ValueKey('phone-slot-${pose.index}'),
                                    left: 325,
                                    top: 42,
                                    child: Transform.translate(
                                      key: ValueKey(
                                        'phone-motion-${pose.index}',
                                      ),
                                      offset: pose.offset,
                                      child: Transform(
                                        key: ValueKey(
                                          'phone-perspective-${pose.index}',
                                        ),
                                        alignment: Alignment.center,
                                        transform: Matrix4.identity()
                                          ..setEntry(3, 2, .0014)
                                          ..rotateY(pose.yaw)
                                          ..rotateZ(pose.roll),
                                        child: Transform.scale(
                                          key: ValueKey(
                                            'phone-scale-${pose.index}',
                                          ),
                                          scale: pose.scale,
                                          child: _phones[pose.index],
                                        ),
                                      ),
                                    ),
                                  ),
                              ],
                            );
                          },
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}

/// Every property follows the same periodic orbit, including across the seam.
/// Phones always face the viewer; the back half changes depth, not screen side.
class _PhonePose {
  _PhonePose({required this.index, required double angle})
    : depth = (math.cos(angle) + 1) / 2,
      side = math.sin(angle);

  final int index;
  final double depth;
  final double side;

  Offset get offset => Offset(side * 245, (depth * 2 - 1) * 75);
  double get scale => .72 + depth * .44;
  double get yaw => -side * .35;
  double get roll => side * .045;
}
