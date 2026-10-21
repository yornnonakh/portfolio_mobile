import 'dart:async';
import 'dart:ui' show ImageFilter;

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/design_system/components.dart';
import '../../../core/localization/app_localizations.dart';
import '../../../core/utils/motion.dart';

class DevelopmentTimeline extends ConsumerStatefulWidget {
  const DevelopmentTimeline({super.key, required this.experience});

  final String experience;

  @override
  ConsumerState<DevelopmentTimeline> createState() =>
      _DevelopmentTimelineState();
}

class _DevelopmentTimelineState extends ConsumerState<DevelopmentTimeline>
    with WidgetsBindingObserver {
  Timer? _advanceTimer;
  int _activeIndex = 0;
  int? _focusedIndex;
  bool _hovering = false;
  bool _motionOn = false;
  bool _foreground = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    final lifecycle = WidgetsBinding.instance.lifecycleState;
    _foreground = lifecycle == null || lifecycle == AppLifecycleState.resumed;
  }

  void _updatePlayback() {
    _advanceTimer?.cancel();
    if (!_motionOn || !_foreground || _hovering || _focusedIndex != null) {
      return;
    }
    _advanceTimer = Timer.periodic(const Duration(seconds: 3), (_) {
      setState(() => _activeIndex = (_activeIndex + 1) % 3);
    });
  }

  void _activate(int index) {
    if (_activeIndex != index) setState(() => _activeIndex = index);
    _updatePlayback();
  }

  void _setHovering(bool hovering) {
    _hovering = hovering;
    _updatePlayback();
  }

  void _setFocused(int index, bool focused) {
    if (focused) {
      _focusedIndex = index;
      _activate(index);
    } else if (_focusedIndex == index) {
      _focusedIndex = null;
      _updatePlayback();
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    _foreground = state == AppLifecycleState.resumed;
    _updatePlayback();
  }

  @override
  void dispose() {
    _advanceTimer?.cancel();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final animate =
        motionEnabled(context, ref) && TickerMode.valuesOf(context).enabled;
    if (_motionOn != animate) {
      _motionOn = animate;
      _updatePlayback();
    }
    final duration = animate
        ? const Duration(milliseconds: 550)
        : Duration.zero;

    return MouseRegion(
      onEnter: (_) => _setHovering(true),
      onExit: (_) => _setHovering(false),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final horizontal =
              constraints.maxWidth >= 760 &&
              MediaQuery.textScalerOf(context).scale(1) <= 1.3;
          final entries = [
            (
              value: widget.experience,
              label: 'Flutter experience',
              icon: const BrandIcon('flutter', size: 26),
            ),
            (
              value: 'iOS & Android',
              label: 'Mobile development',
              icon: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  BrandIcon('ios', size: 17),
                  SizedBox(width: 4),
                  BrandIcon('android', size: 19),
                ],
              ),
            ),
            (
              value: 'App Store',
              label: 'Deployment experience',
              icon: const BrandIcon('app-store', size: 26),
            ),
          ];
          final milestones = [
            for (final (index, entry) in entries.indexed)
              _Milestone(
                index: index,
                value: entry.value,
                label: entry.label,
                icon: entry.icon,
                horizontal: horizontal,
                active: index == _activeIndex,
                completed: index < _activeIndex,
                last: index == entries.length - 1,
                duration: duration,
                onActivate: () => _activate(index),
                onFocusChange: (focused) => _setFocused(index, focused),
              ),
          ];

          return Container(
            padding: EdgeInsets.all(horizontal ? 32 : 24),
            decoration: BoxDecoration(
              color: scheme.surface,
              borderRadius: BorderRadius.circular(22),
              border: Border.all(
                color: scheme.outlineVariant.withValues(alpha: .35),
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Semantics(
                  header: true,
                  child: AppText(
                    'Development journey',
                    style: theme.textTheme.titleLarge,
                  ),
                ),
                const SizedBox(height: 6),
                const MutedText('From learning to launch'),
                const SizedBox(height: 24),
                Divider(
                  height: 1,
                  color: scheme.outlineVariant.withValues(alpha: .4),
                ),
                const SizedBox(height: 28),
                if (horizontal)
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      for (final milestone in milestones)
                        Expanded(child: milestone),
                    ],
                  )
                else
                  Column(children: milestones),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _Milestone extends StatelessWidget {
  const _Milestone({
    required this.value,
    required this.label,
    required this.icon,
    required this.horizontal,
    required this.index,
    required this.active,
    required this.completed,
    required this.duration,
    required this.onActivate,
    required this.onFocusChange,
    this.last = false,
  });

  final String value, label;
  final Widget icon;
  final int index;
  final bool horizontal, active, completed, last;
  final Duration duration;
  final VoidCallback onActivate;
  final ValueChanged<bool> onFocusChange;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final dark = theme.brightness == Brightness.dark;
    const markerRadius = BorderRadius.all(Radius.circular(16));
    return TweenAnimationBuilder<double>(
      tween: Tween(end: active ? 1 : 0),
      duration: duration,
      curve: Curves.easeInOutCubic,
      builder: (context, emphasis, _) {
        final marker = ExcludeSemantics(
          child: DecoratedBox(
            decoration: BoxDecoration(
              borderRadius: markerRadius,
              boxShadow: [
                BoxShadow(
                  color: scheme.primary.withValues(alpha: .04 + .12 * emphasis),
                  blurRadius: 10 + 8 * emphasis,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: markerRadius,
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
                child: Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    borderRadius: markerRadius,
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Color.lerp(
                          Colors.white.withValues(alpha: dark ? .16 : .85),
                          scheme.primary.withValues(alpha: dark ? .22 : .14),
                          emphasis,
                        )!,
                        scheme.surface.withValues(alpha: dark ? .35 : .3),
                        scheme.primary.withValues(alpha: .03 + .05 * emphasis),
                      ],
                    ),
                    border: Border.all(
                      width: .8,
                      color: Color.lerp(
                        Colors.white.withValues(alpha: dark ? .22 : .9),
                        scheme.primary.withValues(alpha: .5),
                        emphasis,
                      )!,
                    ),
                  ),
                  child: Center(
                    child: Transform.scale(
                      scale: 1 + .08 * emphasis,
                      child: icon,
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
        final content = Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AppText(
              value,
              style: theme.textTheme.titleLarge?.copyWith(
                fontSize: horizontal ? 24 : 21,
                fontWeight: FontWeight.w600,
                color: Color.lerp(scheme.onSurface, scheme.primary, emphasis),
                letterSpacing: -.6,
              ),
            ),
            const SizedBox(height: 6),
            AppText(
              label,
              style: theme.textTheme.bodySmall?.copyWith(
                color: scheme.onSurfaceVariant,
              ),
            ),
          ],
        );

        return Semantics(
          key: ValueKey('development-milestone-$index'),
          container: true,
          selected: active,
          child: MouseRegion(
            onEnter: (_) => onActivate(),
            child: CupertinoButton(
              key: ValueKey('development-select-$index'),
              padding: EdgeInsets.zero,
              minimumSize: Size.zero,
              onPressed: onActivate,
              onFocusChange: onFocusChange,
              child: horizontal
                  ? Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            marker,
                            if (!last)
                              Expanded(
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                  ),
                                  child: _Connector(
                                    color: scheme.primary,
                                    completed: completed,
                                    duration: duration,
                                  ),
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(height: 18),
                        Padding(
                          padding: const EdgeInsetsDirectional.only(end: 16),
                          child: content,
                        ),
                      ],
                    )
                  : IntrinsicHeight(
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          ExcludeSemantics(
                            child: SizedBox(
                              width: 52,
                              child: Stack(
                                children: [
                                  if (!last)
                                    PositionedDirectional(
                                      start: 24.5,
                                      top: 58,
                                      bottom: 6,
                                      width: 3,
                                      child: _Connector(
                                        color: scheme.primary,
                                        vertical: true,
                                        completed: completed,
                                        duration: duration,
                                      ),
                                    ),
                                  marker,
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Padding(
                              padding: EdgeInsets.only(
                                top: 2,
                                bottom: last ? 0 : 28,
                              ),
                              child: ConstrainedBox(
                                constraints: const BoxConstraints(
                                  minHeight: 50,
                                ),
                                child: content,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
            ),
          ),
        );
      },
    );
  }
}

class _Connector extends StatelessWidget {
  const _Connector({
    required this.color,
    required this.completed,
    required this.duration,
    this.vertical = false,
  });

  final Color color;
  final bool completed, vertical;
  final Duration duration;

  @override
  Widget build(BuildContext context) => SizedBox(
    height: vertical ? null : 3,
    child: TweenAnimationBuilder<double>(
      tween: Tween(end: completed ? 1 : 0),
      duration: duration,
      curve: Curves.easeInOutCubic,
      builder: (context, progress, _) => CustomPaint(
        painter: _ConnectorPainter(
          color: color,
          progress: progress,
          vertical: vertical,
          direction: Directionality.of(context),
        ),
      ),
    ),
  );
}

class _ConnectorPainter extends CustomPainter {
  const _ConnectorPainter({
    required this.color,
    required this.progress,
    required this.vertical,
    required this.direction,
  });

  final Color color;
  final double progress;
  final bool vertical;
  final TextDirection direction;

  @override
  void paint(Canvas canvas, Size size) {
    final reverse = !vertical && direction == TextDirection.rtl;
    final start = vertical
        ? Offset(size.width / 2, 0)
        : Offset(reverse ? size.width : 0, size.height / 2);
    final end = vertical
        ? Offset(size.width / 2, size.height)
        : Offset(reverse ? 0 : size.width, size.height / 2);
    final paint = Paint()
      ..color = color.withValues(alpha: .12)
      ..strokeWidth = 1.5
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(start, end, paint);
    if (progress <= 0) return;
    final tip = Offset.lerp(start, end, progress)!;
    paint
      ..color = color.withValues(alpha: .75)
      ..strokeWidth = 2;
    canvas.drawLine(start, tip, paint);
    if (progress < 1) canvas.drawCircle(tip, 2.5, paint);
  }

  @override
  bool shouldRepaint(_ConnectorPainter oldDelegate) =>
      color != oldDelegate.color ||
      progress != oldDelegate.progress ||
      vertical != oldDelegate.vertical ||
      direction != oldDelegate.direction;
}
