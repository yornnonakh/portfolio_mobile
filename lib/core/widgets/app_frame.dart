import 'dart:ui' show ImageFilter;

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/physics.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../shared/providers/portfolio_providers.dart';
import '../localization/app_localizations.dart';
import '../design_system/components.dart';
import 'language_button.dart';
import 'profile_avatar.dart';

class AppFrame extends StatefulWidget {
  const AppFrame({
    super.key,
    required this.child,
    this.navigationShell,
    this.title,
  });
  final Widget child;
  final StatefulNavigationShell? navigationShell;
  final String? title;
  static const _tabTitles = ['Home', 'Projects', 'About', 'Contact'];

  @override
  State<AppFrame> createState() => _AppFrameState();
}

class _AppFrameState extends State<AppFrame> {
  bool _isScrolled = false;

  @override
  void didUpdateWidget(AppFrame oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.title != widget.title ||
        oldWidget.navigationShell?.currentIndex !=
            widget.navigationShell?.currentIndex) {
      setState(() {
        _isScrolled = false;
      });
    }
  }

  bool _onScrollNotification(ScrollNotification notification) {
    if (notification.metrics.axis == Axis.vertical && notification.depth == 0) {
      final isScrolled = notification.metrics.pixels > 20;
      if (isScrolled != _isScrolled) {
        setState(() {
          _isScrolled = isScrolled;
        });
      }
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    final shell = widget.navigationShell;
    final isHome = shell?.currentIndex == 0;
    final navigationTitle =
        widget.title ??
        (shell == null ? 'Home' : AppFrame._tabTitles[shell.currentIndex]);
    final scheme = Theme.of(context).colorScheme;
    final safeBottom = MediaQuery.viewPaddingOf(context).bottom;
    final bottomInset = shell == null
        ? 0.0
        : 64.0 + (safeBottom > 12 ? safeBottom : 12);
    return CupertinoPageScaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      navigationBar: CupertinoNavigationBar(
        backgroundColor: scheme.surface.withValues(alpha: .86),
        border: Border(
          bottom: BorderSide(
            color: scheme.outlineVariant.withValues(alpha: .5),
            width: .5,
          ),
        ),
        automaticallyImplyLeading: false,
        middle: isHome
            ? null
            : AnimatedOpacity(
                opacity: _isScrolled ? 1.0 : 0.0,
                duration: const Duration(milliseconds: 200),
                curve: Curves.easeInOut,
                child: AppText(
                  navigationTitle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                  style: CupertinoTheme.of(context).textTheme.navTitleTextStyle,
                ),
              ),
        leading: isHome
            ? AnimatedOpacity(
                key: const ValueKey('home-navigation-title'),
                opacity: _isScrolled ? 1 : 0,
                duration: MediaQuery.disableAnimationsOf(context)
                    ? Duration.zero
                    : const Duration(milliseconds: 200),
                curve: Curves.easeInOut,
                child: ExcludeSemantics(
                  excluding: !_isScrolled,
                  child: Semantics(
                    header: true,
                    child: Consumer(
                      builder: (context, ref, child) => ProfileAvatar(
                        profile: ref.watch(portfolioProvider).profile,
                        size: 32,
                      ),
                    ),
                  ),
                ),
              )
            : shell == null
            ? _GlassBackButton(
                onPressed: () => Navigator.of(context).canPop()
                    ? Navigator.of(context).pop()
                    : context.go('/home'),
              )
            : null,
        trailing: shell != null
            ? Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const LanguageButton(),
                  const SizedBox(width: 4),
                  IosIconButton(
                    label: 'Settings',
                    onPressed: () => context.push('/settings'),
                    icon: CupertinoIcons.gear_alt_fill,
                  ),
                ],
              )
            : null,
      ),
      child: NotificationListener<ScrollNotification>(
        onNotification: _onScrollNotification,
        child: Builder(
          builder: (context) {
            final data = MediaQuery.of(context);
            return Stack(
              children: [
                Positioned.fill(
                  child: Column(
                    children: [
                      Expanded(
                        child: MediaQuery(
                          data: data.copyWith(
                            padding: data.padding.copyWith(
                              bottom: shell == null ? 0 : bottomInset,
                            ),
                          ),
                          child: SafeArea(
                            top: false,
                            bottom: false,
                            child: PageFooterScope(
                              showInlineFooter: shell != null,
                              child: widget.child,
                            ),
                          ),
                        ),
                      ),
                      if (shell == null) const Footer(pinned: true),
                    ],
                  ),
                ),
                if (shell != null)
                  Align(
                    alignment: Alignment.bottomCenter,
                    child: SafeArea(
                      top: false,
                      minimum: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 560),
                        child: MediaQuery.withNoTextScaling(
                          child: FloatingPillBottomNavBar(
                            currentIndex: shell.currentIndex,
                            onTap: (index) => shell.goBranch(
                              index,
                              initialLocation: index == shell.currentIndex,
                            ),
                            items: [
                              NavBarItem(
                                icon: CupertinoIcons.house,
                                activeIcon: CupertinoIcons.house_fill,
                                label: context.tr('Home'),
                              ),
                              NavBarItem(
                                icon: CupertinoIcons.square_stack,
                                activeIcon: CupertinoIcons.square_stack_fill,
                                label: context.tr('Projects'),
                              ),
                              NavBarItem(
                                icon: CupertinoIcons.person_crop_circle,
                                activeIcon:
                                    CupertinoIcons.person_crop_circle_fill,
                                label: context.tr('About'),
                              ),
                              NavBarItem(
                                icon: CupertinoIcons.bubble_left,
                                activeIcon: CupertinoIcons.bubble_left_fill,
                                label: context.tr('Contact'),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _GlassBackButton extends StatelessWidget {
  const _GlassBackButton({required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final dark = theme.brightness == Brightness.dark;
    const radius = BorderRadius.all(Radius.circular(22));

    return Semantics(
      label: context.tr('Back'),
      button: true,
      child: CupertinoButton(
        padding: EdgeInsets.zero,
        minimumSize: const Size(44, 44),
        borderRadius: radius,
        onPressed: onPressed,
        child: ExcludeSemantics(
          child: DecoratedBox(
            decoration: BoxDecoration(
              borderRadius: radius,
              boxShadow: [
                BoxShadow(
                  color: scheme.shadow.withValues(alpha: dark ? .18 : .07),
                  blurRadius: 10,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: radius,
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
                child: Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    borderRadius: radius,
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Colors.white.withValues(alpha: dark ? .16 : .8),
                        scheme.surface.withValues(alpha: dark ? .45 : .35),
                      ],
                    ),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: dark ? .22 : .85),
                      width: .8,
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsetsDirectional.only(start: 6),
                    child: Icon(
                      Icons.arrow_back_ios,
                      size: 20,
                      color: scheme.onSurface,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class FloatingPillBottomNavBar extends StatefulWidget {
  const FloatingPillBottomNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
    required this.items,
  }) : assert(items.length > 0),
       assert(currentIndex >= 0 && currentIndex < items.length);

  final int currentIndex;
  final ValueChanged<int> onTap;
  final List<NavBarItem> items;

  @override
  State<FloatingPillBottomNavBar> createState() =>
      _FloatingPillBottomNavBarState();
}

class _FloatingPillBottomNavBarState extends State<FloatingPillBottomNavBar>
    with SingleTickerProviderStateMixin {
  late final AnimationController _position;
  bool _dragging = false;
  int? _dragIndex;

  bool get _reducedMotion =>
      MediaQuery.disableAnimationsOf(context) ||
      MediaQuery.accessibleNavigationOf(context);

  @override
  void initState() {
    super.initState();
    _position = AnimationController.unbounded(
      vsync: this,
      value: widget.currentIndex.toDouble(),
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_reducedMotion) {
      _position.value = widget.currentIndex.toDouble();
    }
  }

  @override
  void didUpdateWidget(FloatingPillBottomNavBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.items.length != widget.items.length) {
      _dragging = false;
      _dragIndex = null;
    }
    if (!_dragging &&
        (oldWidget.currentIndex != widget.currentIndex ||
            oldWidget.items.length != widget.items.length)) {
      _settleTo(widget.currentIndex);
    }
  }

  void _settleTo(int index) {
    final target = index.toDouble();
    if (_reducedMotion) {
      _position.value = target;
      return;
    }
    _position.animateWith(
      SpringSimulation(
        const SpringDescription(mass: 1, stiffness: 480, damping: 38),
        _position.value,
        target,
        _position.velocity,
      ),
    );
  }

  void _selectAt(Offset position, double width) {
    final tabWidth = (width - 12) / widget.items.length;
    if (tabWidth <= 0) return;
    var progress = ((position.dx - 6) / tabWidth - .5).clamp(
      0.0,
      widget.items.length - 1.0,
    );
    if (Directionality.of(context) == TextDirection.rtl) {
      progress = widget.items.length - 1 - progress;
    }
    _dragging = true;
    // Follow the finger directly; spring to the selected tab only on release.
    _position.value = progress;
    final index = progress.round();
    if (index == (_dragIndex ?? widget.currentIndex)) return;
    _dragIndex = index;
    widget.onTap(index);
  }

  void _endDrag() {
    if (!_dragging) return;
    _dragging = false;
    _dragIndex = null;
    _settleTo(widget.currentIndex);
  }

  @override
  void dispose() {
    _position.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    return LayoutBuilder(
      builder: (context, constraints) => GestureDetector(
        behavior: HitTestBehavior.opaque,
        onHorizontalDragStart: (details) =>
            _selectAt(details.localPosition, constraints.maxWidth),
        onHorizontalDragUpdate: (details) =>
            _selectAt(details.localPosition, constraints.maxWidth),
        onHorizontalDragEnd: (_) => _endDrag(),
        onHorizontalDragCancel: _endDrag,
        onLongPressStart: (details) =>
            _selectAt(details.localPosition, constraints.maxWidth),
        onLongPressMoveUpdate: (details) =>
            _selectAt(details.localPosition, constraints.maxWidth),
        onLongPressEnd: (_) => _endDrag(),
        onLongPressCancel: _endDrag,
        child: DecoratedBox(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(36),
            boxShadow: [
              BoxShadow(
                color: scheme.shadow.withValues(alpha: isDark ? .35 : .12),
                blurRadius: 24,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(36),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 28, sigmaY: 28),
              child: Container(
                key: const ValueKey('bottom-nav-glass'),
                height: 64,
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 8),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(36),
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Color.alphaBlend(
                        Colors.white.withValues(alpha: isDark ? .1 : .38),
                        scheme.surface.withValues(alpha: isDark ? .75 : .76),
                      ),
                      scheme.surface.withValues(alpha: isDark ? .66 : .68),
                      Color.alphaBlend(
                        scheme.primary.withValues(alpha: .035),
                        scheme.surface.withValues(alpha: isDark ? .7 : .72),
                      ),
                    ],
                  ),
                ),
                foregroundDecoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(36),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: isDark ? .2 : .85),
                    width: .8,
                  ),
                ),
                child: AnimatedBuilder(
                  animation: _position,
                  builder: (context, child) {
                    final progress = _position.value.clamp(
                      0.0,
                      widget.items.length - 1.0,
                    );
                    final visualProgress =
                        Directionality.of(context) == TextDirection.rtl
                        ? widget.items.length - 1 - progress
                        : progress;
                    final tabWidth =
                        (constraints.maxWidth - 12) / widget.items.length;
                    return Stack(
                      fit: StackFit.expand,
                      children: [
                        Positioned(
                          left: visualProgress * tabWidth,
                          top: 0,
                          bottom: 0,
                          width: tabWidth,
                          child: IgnorePointer(
                            child: DecoratedBox(
                              key: const ValueKey('bottom-nav-indicator'),
                              decoration: BoxDecoration(
                                color: scheme.primary,
                                borderRadius: BorderRadius.circular(28),
                              ),
                            ),
                          ),
                        ),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            for (var i = 0; i < widget.items.length; i++)
                              Expanded(
                                child: _NavBarTab(
                                  item: widget.items[i],
                                  isSelected: i == widget.currentIndex,
                                  color: Color.lerp(
                                    scheme.onSurfaceVariant,
                                    scheme.onPrimary,
                                    (1 - (progress - i).abs()).clamp(0.0, 1.0),
                                  )!,
                                  onTap: () => widget.onTap(i),
                                ),
                              ),
                          ],
                        ),
                      ],
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

class NavBarItem {
  const NavBarItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
  });
  final IconData icon;
  final IconData activeIcon;
  final String label;
}

class _NavBarTab extends StatelessWidget {
  const _NavBarTab({
    required this.item,
    required this.isSelected,
    required this.color,
    required this.onTap,
  });

  final NavBarItem item;
  final bool isSelected;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Semantics(
    label: item.label,
    selected: isSelected,
    button: true,
    child: GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              isSelected ? item.activeIcon : item.icon,
              size: 22,
              color: color,
            ),
            const SizedBox(height: 2),
            ExcludeSemantics(
              child: AppText(
                item.label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 11,
                  height: 1.3,
                  fontWeight: FontWeight.w600,
                  color: color,
                ),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}
