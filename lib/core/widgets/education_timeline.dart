import 'dart:ui' show lerpDouble;

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../shared/models/portfolio.dart';
import '../design_system/components.dart';
import '../localization/app_localizations.dart';
import '../utils/motion.dart';
import 'liquid_glass_container.dart';

class EducationTimeline extends ConsumerStatefulWidget {
  const EducationTimeline({super.key, required this.educations});

  final List<Education> educations;

  @override
  ConsumerState<EducationTimeline> createState() => _EducationTimelineState();
}

class _EducationTimelineState extends ConsumerState<EducationTimeline> {
  final _anchors = <String, GlobalKey>{};
  final _revealed = <String>{};
  ScrollPosition? _scrollPosition;
  String? _activeInstitute;
  bool _updatePending = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final position = Scrollable.maybeOf(context)?.position;
    if (_scrollPosition != position) {
      _scrollPosition?.removeListener(_scheduleUpdate);
      _scrollPosition = position;
      position?.addListener(_scheduleUpdate);
    }
    _scheduleUpdate();
  }

  @override
  void didUpdateWidget(EducationTimeline oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.educations != widget.educations) _scheduleUpdate();
  }

  void _activate(String institute) {
    if (_activeInstitute != institute) {
      setState(() => _activeInstitute = institute);
    }
  }

  void _scheduleUpdate() {
    if (_updatePending) return;
    _updatePending = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _updatePending = false;
      if (!mounted || !TickerMode.valuesOf(context).enabled) return;
      final media = MediaQuery.of(context);
      var visibleArea = Rect.fromLTRB(
        0,
        media.padding.top + 12,
        media.size.width,
        media.size.height - media.padding.bottom - 12,
      );
      // Clip the reveal area to the actual scroll viewport.
      final box = context.findRenderObject();
      if (box != null) {
        final Object? viewport = RenderAbstractViewport.maybeOf(box);
        if (viewport is RenderBox && viewport.hasSize) {
          visibleArea = visibleArea.intersect(
            viewport.localToGlobal(Offset.zero) & viewport.size,
          );
        }
      }
      if (visibleArea.isEmpty) return;
      final focusY = visibleArea.top + visibleArea.height * .4;
      var distance = double.infinity;
      String? nearest;
      final newlyVisible = <String>{};
      for (final education in widget.educations) {
        final renderBox = _anchors[education.institute]?.currentContext
            ?.findRenderObject();
        if (renderBox is! RenderBox || !renderBox.hasSize) continue;
        final bounds = renderBox.localToGlobal(Offset.zero) & renderBox.size;
        if (!bounds.overlaps(visibleArea)) continue;
        newlyVisible.add(education.institute);
        final currentDistance = (bounds.center.dy - focusY).abs();
        if (currentDistance < distance) {
          distance = currentDistance;
          nearest = education.institute;
        }
      }
      if (newlyVisible.difference(_revealed).isNotEmpty ||
          (nearest != null && nearest != _activeInstitute)) {
        setState(() {
          _revealed.addAll(newlyVisible);
          if (nearest != null) _activeInstitute = nearest;
        });
      }
    });
  }

  @override
  void dispose() {
    _scrollPosition?.removeListener(_scheduleUpdate);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final animate =
        motionEnabled(context, ref) && TickerMode.valuesOf(context).enabled;
    final duration = animate
        ? const Duration(milliseconds: 420)
        : Duration.zero;
    final selected = widget.educations.indexWhere(
      (education) => education.institute == _activeInstitute,
    );
    final activeIndex = selected < 0 ? 0 : selected;
    return Column(
      key: const ValueKey('education-timeline'),
      children: [
        for (final (index, education) in widget.educations.indexed)
          _EducationMilestone(
            key: _anchors.putIfAbsent(education.institute, GlobalKey.new),
            education: education,
            index: index,
            first: index == 0,
            last: index == widget.educations.length - 1,
            active: index == activeIndex,
            revealed: !animate || _revealed.contains(education.institute),
            progress: index < activeIndex ? 2 : (index == activeIndex ? 1 : 0),
            duration: duration,
            onActivate: () => _activate(education.institute),
          ),
      ],
    );
  }
}

class _EducationMilestone extends StatelessWidget {
  const _EducationMilestone({
    super.key,
    required this.education,
    required this.index,
    required this.first,
    required this.last,
    required this.active,
    required this.revealed,
    required this.progress,
    required this.duration,
    required this.onActivate,
  });

  final Education education;
  final int index;
  final bool first, last, active, revealed;
  final double progress;
  final Duration duration;
  final VoidCallback onActivate;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Stack(
      children: [
        PositionedDirectional(
          start: 0,
          top: 0,
          bottom: 0,
          width: 36,
          child: ExcludeSemantics(
            child: TweenAnimationBuilder<double>(
              tween: Tween(begin: 0, end: revealed ? progress : 0),
              duration: duration,
              curve: Curves.easeInOutCubic,
              builder: (context, value, _) => CustomPaint(
                key: ValueKey('education-rail-${education.institute}'),
                painter: _EducationRailPainter(
                  first: first,
                  last: last,
                  progress: value,
                  color: scheme.primary,
                  trackColor: scheme.outlineVariant.withValues(alpha: .6),
                ),
              ),
            ),
          ),
        ),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ExcludeSemantics(
              child: SizedBox(
                width: 36,
                height: 56,
                child: Center(
                  child: AnimatedContainer(
                    duration: duration,
                    curve: Curves.easeOutCubic,
                    width: 32,
                    height: 32,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: active ? scheme.primary : scheme.surface,
                      border: Border.all(
                        color: active ? scheme.primary : scheme.outlineVariant,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: scheme.primary.withValues(
                            alpha: active ? .2 : 0,
                          ),
                          blurRadius: 12,
                        ),
                      ],
                    ),
                    child: Text(
                      '${index + 1}'.padLeft(2, '0'),
                      textScaler: TextScaler.noScaling,
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        color: active
                            ? scheme.onPrimary
                            : scheme.onSurfaceVariant,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Padding(
                padding: EdgeInsets.only(bottom: last ? 0 : 20),
                child: AnimatedSlide(
                  offset: revealed ? Offset.zero : const Offset(0, .06),
                  duration: duration,
                  curve: Curves.easeOutCubic,
                  child: AnimatedOpacity(
                    opacity: revealed ? 1 : 0,
                    alwaysIncludeSemantics: true,
                    duration: duration,
                    curve: Curves.easeOutCubic,
                    child: _EducationCard(
                      education: education,
                      active: active,
                      duration: duration,
                      onActivate: onActivate,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _EducationCard extends StatelessWidget {
  const _EducationCard({
    required this.education,
    required this.active,
    required this.duration,
    required this.onActivate,
  });

  final Education education;
  final bool active;
  final Duration duration;
  final VoidCallback onActivate;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final details = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppText(
          education.program,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 6),
        MutedText(education.institute),
        const SizedBox(height: 14),
        Wrap(
          spacing: 12,
          runSpacing: 8,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            TechBadge(education.period),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  CupertinoIcons.checkmark_seal_fill,
                  size: 14,
                  color: scheme.primary,
                ),
                const SizedBox(width: 5),
                Flexible(
                  child: AppText(
                    education.status,
                    style: theme.textTheme.labelMedium?.copyWith(
                      color: scheme.primary,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ],
    );
    final logo = LiquidGlassContainer(
      key: ValueKey('education-logo-${education.institute}'),
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: SizedBox(
          width: education.monochromeLogo ? 120 : 52,
          height: 52,
          child: education.logoAsset == null
              ? Icon(CupertinoIcons.book_fill, color: scheme.primary)
              : Image.asset(
                  education.logoAsset!,
                  fit: BoxFit.contain,
                  // The institute is already announced in the adjacent text.
                  excludeFromSemantics: true,
                  color: education.monochromeLogo ? scheme.onSurface : null,
                  errorBuilder: (_, error, stack) =>
                      Icon(CupertinoIcons.book_fill, color: scheme.primary),
                ),
        ),
      ),
    );
    return Semantics(
      key: ValueKey('education-milestone-${education.institute}'),
      container: true,
      selected: active,
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        onEnter: (_) => onActivate(),
        child: Focus(
          canRequestFocus: false,
          onFocusChange: (focused) {
            if (focused) onActivate();
          },
          child: CupertinoButton(
            key: ValueKey('education-select-${education.institute}'),
            padding: EdgeInsets.zero,
            pressedOpacity: .92,
            onPressed: onActivate,
            child: AnimatedContainer(
              duration: duration,
              curve: Curves.easeOutCubic,
              width: double.infinity,
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: Color.alphaBlend(
                  scheme.primary.withValues(alpha: active ? .035 : 0),
                  scheme.surface,
                ),
                borderRadius: BorderRadius.circular(22),
                border: Border.all(
                  color: active
                      ? scheme.primary.withValues(alpha: .5)
                      : scheme.outlineVariant.withValues(alpha: .3),
                ),
                boxShadow: [
                  BoxShadow(
                    color: scheme.primary.withValues(alpha: active ? .07 : 0),
                    blurRadius: 20,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final stacked =
                      constraints.maxWidth < 480 ||
                      MediaQuery.textScalerOf(context).scale(16) > 24;
                  return stacked
                      ? Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [logo, const SizedBox(height: 16), details],
                        )
                      : Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(
                              width: 140,
                              child: Align(
                                alignment: AlignmentDirectional.topStart,
                                child: logo,
                              ),
                            ),
                            const SizedBox(width: 20),
                            Expanded(child: details),
                          ],
                        );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _EducationRailPainter extends CustomPainter {
  const _EducationRailPainter({
    required this.first,
    required this.last,
    required this.progress,
    required this.color,
    required this.trackColor,
  });

  final bool first, last;
  final double progress;
  final Color color, trackColor;

  @override
  void paint(Canvas canvas, Size size) {
    final start = first ? 28.0 : 0.0;
    final end = last ? 28.0 : size.height;
    final paint = Paint()
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(
      Offset(18, start),
      Offset(18, end),
      paint..color = trackColor,
    );
    final filledEnd = progress <= 1
        ? lerpDouble(start, 28, progress)!
        : lerpDouble(28, end, progress - 1)!;
    if (filledEnd > start) {
      canvas.drawLine(
        Offset(18, start),
        Offset(18, filledEnd),
        paint..color = color,
      );
    }
  }

  @override
  bool shouldRepaint(_EducationRailPainter oldDelegate) =>
      first != oldDelegate.first ||
      last != oldDelegate.last ||
      progress != oldDelegate.progress ||
      color != oldDelegate.color ||
      trackColor != oldDelegate.trackColor;
}
