import 'dart:ui' show lerpDouble;

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/design_system/components.dart';
import '../../../core/localization/app_localizations.dart';
import '../../../core/utils/motion.dart';
import '../../../shared/models/portfolio.dart';
import 'project_art.dart';

class ProjectTimeline extends ConsumerStatefulWidget {
  const ProjectTimeline({super.key, required this.projects});
  final List<PortfolioProject> projects;

  @override
  ConsumerState<ProjectTimeline> createState() => _ProjectTimelineState();
}

class _ProjectTimelineState extends ConsumerState<ProjectTimeline> {
  final _anchors = <String, GlobalKey>{};
  ScrollPosition? _scrollPosition;
  String? _activeId;
  bool _scrollUpdatePending = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final position = Scrollable.maybeOf(context)?.position;
    if (position == _scrollPosition) return;
    _scrollPosition?.removeListener(_scheduleScrollUpdate);
    _scrollPosition = position;
    position?.addListener(_scheduleScrollUpdate);
    if (position != null && position.hasPixels && position.pixels > 0) {
      _scheduleScrollUpdate();
    }
  }

  @override
  void didUpdateWidget(ProjectTimeline oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.projects != widget.projects) _scheduleScrollUpdate();
  }

  void _activate(String id) {
    if (_activeId != id && mounted) setState(() => _activeId = id);
  }

  void _scheduleScrollUpdate() {
    if (_scrollUpdatePending) return;
    _scrollUpdatePending = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollUpdatePending = false;
      if (!mounted) return;
      final viewport = MediaQuery.sizeOf(context);
      final visibleArea = Rect.fromLTWH(
        0,
        64,
        viewport.width,
        viewport.height - 128,
      );
      final focusY = viewport.height * .45;
      var nearestDistance = double.infinity;
      String? nearest;
      for (final project in widget.projects) {
        final box = _anchors[project.id]?.currentContext?.findRenderObject();
        if (box is! RenderBox || !box.hasSize) continue;
        final bounds = box.localToGlobal(Offset.zero) & box.size;
        if (!bounds.overlaps(visibleArea)) continue;
        final distance = (bounds.center.dy - focusY).abs();
        if (distance < nearestDistance) {
          nearest = project.id;
          nearestDistance = distance;
        }
      }
      if (nearest != null) _activate(nearest);
    });
  }

  @override
  void dispose() {
    _scrollPosition?.removeListener(_scheduleScrollUpdate);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.projects.isEmpty) return const SizedBox.shrink();
    final animate = motionEnabled(context, ref);
    var activeIndex = widget.projects.indexWhere((p) => p.id == _activeId);
    if (activeIndex < 0) activeIndex = 0;
    final duration = animate
        ? const Duration(milliseconds: 480)
        : Duration.zero;
    return Column(
      key: const ValueKey('project-timeline'),
      children: [
        for (var index = 0; index < widget.projects.length; index++)
          _TimelineEntry(
            key: _anchors.putIfAbsent(widget.projects[index].id, GlobalKey.new),
            project: widget.projects[index],
            active: index == activeIndex,
            first: index == 0,
            last: index == widget.projects.length - 1,
            progress: index < activeIndex ? 2 : (index == activeIndex ? 1 : 0),
            duration: duration,
            onActivate: () => _activate(widget.projects[index].id),
          ),
      ],
    );
  }
}

class _TimelineEntry extends StatelessWidget {
  const _TimelineEntry({
    super.key,
    required this.project,
    required this.active,
    required this.first,
    required this.last,
    required this.progress,
    required this.duration,
    required this.onActivate,
  });

  final PortfolioProject project;
  final bool active, first, last;
  final double progress;
  final Duration duration;
  final VoidCallback onActivate;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    // The card determines the row height. The rail stretches behind it without
    // intrinsic measurement, so responsive previews can use LayoutBuilder.
    return Stack(
      children: [
        if (!first || !last)
          Positioned(
            left: 0,
            top: 0,
            bottom: 0,
            width: 44,
            child: TweenAnimationBuilder<double>(
              tween: Tween(begin: 0, end: progress),
              duration: duration,
              curve: Curves.easeInOutCubic,
              builder: (context, value, _) => CustomPaint(
                painter: _RailPainter(
                  first: first,
                  last: last,
                  progress: value,
                  color: scheme.primary,
                  trackColor: scheme.onSurface.withValues(alpha: .09),
                ),
              ),
            ),
          ),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _TimelineMarker(
              project: project,
              active: active,
              duration: duration,
              onActivate: onActivate,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Padding(
                padding: EdgeInsets.only(bottom: last ? 0 : 28),
                child: TweenAnimationBuilder<double>(
                  tween: Tween(begin: 0, end: 1),
                  duration: duration,
                  curve: Curves.easeOutCubic,
                  builder: (context, value, child) => Opacity(
                    opacity: value,
                    child: Transform.translate(
                      offset: Offset(0, (1 - value) * 16),
                      child: child,
                    ),
                  ),
                  child: _TimelineCard(
                    project: project,
                    active: active,
                    duration: duration,
                    onActivate: onActivate,
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

class _TimelineMarker extends StatelessWidget {
  const _TimelineMarker({
    required this.project,
    required this.active,
    required this.duration,
    required this.onActivate,
  });
  final PortfolioProject project;
  final bool active;
  final Duration duration;
  final VoidCallback onActivate;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Semantics(
      selected: active,
      label: '${context.tr('Focus project')}: ${context.tr(project.title)}',
      child: CupertinoButton(
        key: ValueKey('timeline-select-${project.id}'),
        padding: EdgeInsets.zero,
        minimumSize: const Size(44, 44),
        onPressed: onActivate,
        child: ExcludeSemantics(
          child: AnimatedContainer(
            duration: duration,
            curve: Curves.easeOutCubic,
            width: 38,
            height: 38,
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: active
                  ? scheme.primary.withValues(alpha: .12)
                  : Colors.transparent,
            ),
            child: AnimatedContainer(
              duration: duration,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: active ? scheme.primary : scheme.surface,
                border: Border.all(
                  color: active ? scheme.primary : scheme.outlineVariant,
                ),
                boxShadow: [
                  BoxShadow(
                    color: scheme.primary.withValues(alpha: active ? .2 : 0),
                    blurRadius: 10,
                  ),
                ],
              ),
              alignment: Alignment.center,
              child: Text(
                project.number,
                textScaler: TextScaler.noScaling,
                style: TextStyle(
                  fontSize: 9,
                  fontWeight: FontWeight.w700,
                  color: active ? scheme.onPrimary : scheme.onSurfaceVariant,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _TimelineCard extends StatelessWidget {
  const _TimelineCard({
    required this.project,
    required this.active,
    required this.duration,
    required this.onActivate,
  });
  final PortfolioProject project;
  final bool active;
  final Duration duration;
  final VoidCallback onActivate;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final content = Padding(
      padding: const EdgeInsets.all(22),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TechBadge(project.category, accent: active),
          const SizedBox(height: 14),
          AppText(project.title, style: theme.textTheme.headlineMedium),
          const SizedBox(height: 10),
          MutedText(project.description),
          const SizedBox(height: 20),
          BadgeList(project.technologies),
          const SizedBox(height: 16),
          IosButton.plain(
            onPressed: () =>
                context.push('/projects/${project.id}?from=projects'),
            label: const AppText('Explore case study'),
            icon: const Icon(CupertinoIcons.arrow_up_right, size: 16),
            iconAlignment: IconAlignment.end,
          ),
        ],
      ),
    );
    return Semantics(
      key: ValueKey('timeline-project-${project.id}'),
      container: true,
      selected: active,
      child: MouseRegion(
        onEnter: (_) => onActivate(),
        child: Focus(
          canRequestFocus: false,
          onFocusChange: (focused) {
            if (focused) onActivate();
          },
          child: GestureDetector(
            onTap: onActivate,
            excludeFromSemantics: true,
            child: AnimatedScale(
              scale: active ? 1 : .99,
              duration: duration,
              curve: Curves.easeOutCubic,
              alignment: Alignment.centerLeft,
              child: AnimatedContainer(
                duration: duration,
                curve: Curves.easeOutCubic,
                clipBehavior: Clip.antiAlias,
                decoration: BoxDecoration(
                  color: scheme.surface,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(
                        alpha: active ? .06 : .025,
                      ),
                      blurRadius: active ? 28 : 12,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final wide =
                        constraints.maxWidth >= 760 &&
                        MediaQuery.textScalerOf(context).scale(1) <= 1.3;
                    final art = Hero(
                      tag: 'projects-${project.id}',
                      child: ProjectArt(
                        project: project,
                        height: wide ? 300 : 220,
                      ),
                    );
                    return wide
                        ? Row(
                            children: [
                              SizedBox(width: 300, child: art),
                              Expanded(child: content),
                            ],
                          )
                        : Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [art, content],
                          );
                  },
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _RailPainter extends CustomPainter {
  const _RailPainter({
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
    final start = first ? 22.0 : 0.0;
    final end = last ? 22.0 : size.height;
    final paint = Paint()
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(
      Offset(22, start),
      Offset(22, end),
      paint..color = trackColor,
    );
    final filledEnd = progress <= 1
        ? lerpDouble(start, 22, progress)!
        : lerpDouble(22, end, progress - 1)!;
    if (filledEnd > start) {
      canvas.drawLine(
        Offset(22, start),
        Offset(22, filledEnd),
        paint..color = color,
      );
    }
  }

  @override
  bool shouldRepaint(_RailPainter oldDelegate) =>
      first != oldDelegate.first ||
      last != oldDelegate.last ||
      progress != oldDelegate.progress ||
      color != oldDelegate.color ||
      trackColor != oldDelegate.trackColor;
}
