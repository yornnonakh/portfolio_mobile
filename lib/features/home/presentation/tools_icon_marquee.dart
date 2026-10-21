import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../core/utils/motion.dart';

/// One continuous row of locally bundled tool logos with larger labels.
class ToolsIconMarquee extends ConsumerStatefulWidget {
  const ToolsIconMarquee({super.key});

  @override
  ConsumerState<ToolsIconMarquee> createState() => _ToolsIconMarqueeState();
}

class _ToolsIconMarqueeState extends ConsumerState<ToolsIconMarquee>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  bool _motionOn = false;
  Duration? _cycleDuration;
  bool _hovering = false;
  final Set<int> _pressedPointers = {};

  static const _tools = [
    _Tool('Flutter', 'flutter'),
    _Tool('Dart', 'dart'),
    _Tool('Kotlin', 'kotlin'),
    _Tool('Swift', 'swift'),
    _Tool('GitHub', 'github', adaptiveColor: true),
    _Tool('Firebase', 'firebase'),
    _Tool('Supabase', 'supabase'),
    _Tool('VS Code', 'vscode'),
    _Tool('Android Studio', 'android-studio'),
    _Tool('iOS', 'ios', adaptiveColor: true),
  ];

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      // Linear travel keeps the same gentle speed through every loop boundary.
      duration: const Duration(seconds: 100),
    );
  }

  void _syncMotion(bool enabled, Duration duration) {
    if (_motionOn == enabled && _cycleDuration == duration) return;
    _motionOn = enabled;
    _cycleDuration = duration;
    if (!enabled) {
      _hovering = false;
      _pressedPointers.clear();
    }
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _controller.duration = _cycleDuration;
      if (_motionOn) {
        _updatePlayback(restart: true);
      } else {
        _controller
          ..stop()
          ..value = 0;
      }
    });
  }

  void _updatePlayback({bool restart = false}) {
    if (!_motionOn || _hovering || _pressedPointers.isNotEmpty) {
      // Keep the current phase so releasing a tool never resets the row.
      _controller.stop();
    } else if (restart || !_controller.isAnimating) {
      _controller.repeat();
    }
  }

  void _setHovering(bool hovering) {
    _hovering = hovering;
    _updatePlayback();
  }

  void _releasePointer(int pointer) {
    _pressedPointers.remove(pointer);
    _updatePlayback();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final animate = motionEnabled(context, ref);
    final theme = Theme.of(context);
    final labelStyle = theme.textTheme.bodyMedium!.copyWith(
      fontSize: 20,
      height: 1.25,
      fontWeight: FontWeight.w600,
    );
    final textScaler = MediaQuery.textScalerOf(context);
    // Measure the labels so longer names remain on one line at any text size.
    final itemWidths = _tools.map((tool) {
      final painter = TextPainter(
        text: TextSpan(text: tool.name, style: labelStyle),
        textDirection: Directionality.of(context),
        textScaler: textScaler,
        maxLines: 1,
      )..layout();
      final width = painter.width.ceilToDouble() + 72;
      painter.dispose();
      return width;
    }).toList();
    final rowHeight = math.max(36.0, textScaler.scale(20) * 1.25) + 24;
    final period = itemWidths.fold(0.0, (sum, width) => sum + width + _toolGap);
    // Maintain a gentle 18 logical pixels per second as the text size changes.
    _syncMotion(
      animate,
      Duration(
        microseconds: (period / 18 * Duration.microsecondsPerSecond).round(),
      ),
    );
    return LayoutBuilder(
      builder: (context, constraints) {
        if (!animate) {
          return SingleChildScrollView(
            key: const ValueKey('tools-static'),
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                for (var i = 0; i < _tools.length; i++)
                  Padding(
                    padding: EdgeInsets.only(
                      right: i < _tools.length - 1 ? _toolGap : 0,
                    ),
                    child: SizedBox(
                      width: itemWidths[i],
                      height: rowHeight,
                      child: _ToolBadge(
                        tool: _tools[i],
                        labelStyle: labelStyle,
                      ),
                    ),
                  ),
              ],
            ),
          );
        }
        return Semantics(
          container: true,
          label: _tools.map((tool) => tool.name).join(', '),
          excludeSemantics: true,
          child: MouseRegion(
            key: const ValueKey('tools-pause-region'),
            onEnter: (_) => _setHovering(true),
            onExit: (_) => _setHovering(false),
            child: Listener(
              behavior: HitTestBehavior.opaque,
              onPointerDown: (event) {
                _pressedPointers.add(event.pointer);
                _updatePlayback();
              },
              onPointerUp: (event) => _releasePointer(event.pointer),
              onPointerCancel: (event) => _releasePointer(event.pointer),
              child: _MarqueeRow(
                animation: _controller,
                tools: _tools,
                itemWidths: itemWidths,
                labelStyle: labelStyle,
                width: constraints.maxWidth,
                height: rowHeight,
                period: period,
              ),
            ),
          ),
        );
      },
    );
  }
}

const _toolGap = 20.0;

class _MarqueeRow extends StatelessWidget {
  const _MarqueeRow({
    required this.animation,
    required this.tools,
    required this.itemWidths,
    required this.labelStyle,
    required this.width,
    required this.height,
    required this.period,
  });

  final Animation<double> animation;
  final List<_Tool> tools;
  final List<double> itemWidths;
  final TextStyle labelStyle;
  final double width, height, period;

  @override
  Widget build(BuildContext context) {
    final fadeFraction = (40 / width).clamp(0.0, .18);
    final copies = (width / period).ceil() + 1;
    return SizedBox(
      width: width,
      height: height,
      child: ClipRect(
        child: ShaderMask(
          blendMode: BlendMode.dstIn,
          shaderCallback: (bounds) => LinearGradient(
            colors: const [
              Colors.transparent,
              Colors.black,
              Colors.black,
              Colors.transparent,
            ],
            stops: [0, fadeFraction, 1 - fadeFraction, 1],
          ).createShader(bounds),
          child: OverflowBox(
            alignment: Alignment.centerLeft,
            minWidth: 0,
            maxWidth: double.infinity,
            child: AnimatedBuilder(
              animation: animation,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  for (var copy = 0; copy < copies; copy++)
                    for (var i = 0; i < tools.length; i++)
                      Padding(
                        padding: const EdgeInsets.only(right: _toolGap),
                        child: RepaintBoundary(
                          child: SizedBox(
                            width: itemWidths[i],
                            height: height,
                            child: _ToolBadge(
                              tool: tools[i],
                              labelStyle: labelStyle,
                            ),
                          ),
                        ),
                      ),
                ],
              ),
              builder: (context, child) => Transform.translate(
                key: const ValueKey('tools-marquee-left'),
                offset: Offset(-animation.value * period, 0),
                child: child,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _Tool {
  const _Tool(this.name, this.asset, {this.adaptiveColor = false});
  final String name, asset;
  final bool adaptiveColor;
}

class _ToolBadge extends StatelessWidget {
  const _ToolBadge({required this.tool, required this.labelStyle});
  final _Tool tool;
  final TextStyle labelStyle;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final tint = tool.adaptiveColor ? theme.colorScheme.onSurface : null;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          SvgPicture.asset(
            'assets/icons/tools/${tool.asset}.svg',
            width: 36,
            height: 36,
            excludeFromSemantics: true,
            colorFilter: tint == null
                ? null
                : ColorFilter.mode(tint, BlendMode.srcIn),
          ),
          const SizedBox(width: 12),
          Text(tool.name, maxLines: 1, softWrap: false, style: labelStyle),
        ],
      ),
    );
  }
}
