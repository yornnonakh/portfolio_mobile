import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../design_system/components.dart';

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
    final navigationTitle =
        widget.title ??
        (shell == null ? 'Home' : AppFrame._tabTitles[shell.currentIndex]);
    final scheme = Theme.of(context).colorScheme;
    final bottomInset = shell == null
        ? 0.0
        : 56.0 + MediaQuery.viewPaddingOf(context).bottom;
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
        middle: AnimatedOpacity(
          opacity: _isScrolled ? 1.0 : 0.0,
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeInOut,
          child: Text(
            navigationTitle,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: CupertinoTheme.of(context).textTheme.navTitleTextStyle,
          ),
        ),
        leading: shell == null
            ? IosIconButton(
                label: 'Back',
                icon: CupertinoIcons.chevron_back,
                liquidGlass: true,
                circular: true,
                onPressed: () => Navigator.of(context).canPop()
                    ? Navigator.of(context).pop()
                    : context.go('/home'),
              )
            : null,
        trailing: shell != null
            ? IosIconButton(
                label: 'Settings',
                onPressed: () => context.push('/settings'),
                icon: CupertinoIcons.gear_alt_fill,
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
                  child: MediaQuery(
                    data: data.copyWith(
                      padding: data.padding.copyWith(
                        bottom: shell == null
                            ? data.padding.bottom
                            : bottomInset,
                      ),
                    ),
                    child: SafeArea(
                      top: false,
                      bottom: shell == null,
                      child: widget.child,
                    ),
                  ),
                ),
                if (shell != null)
                  Align(
                    alignment: Alignment.bottomCenter,
                    child: CupertinoTabBar(
                      currentIndex: shell.currentIndex,
                      onTap: (index) => shell.goBranch(
                        index,
                        initialLocation: index == shell.currentIndex,
                      ),
                      backgroundColor: scheme.surface.withValues(alpha: .86),
                      activeColor: scheme.primary,
                      inactiveColor: scheme.onSurfaceVariant,
                      iconSize: 24,
                      height: 56,
                      border: Border(
                        top: BorderSide(
                          color: scheme.outlineVariant.withValues(alpha: .5),
                          width: .5,
                        ),
                      ),
                      items: const [
                        BottomNavigationBarItem(
                          icon: Icon(CupertinoIcons.house),
                          activeIcon: Icon(CupertinoIcons.house_fill),
                          label: 'Home',
                        ),
                        BottomNavigationBarItem(
                          icon: Icon(CupertinoIcons.square_stack),
                          activeIcon: Icon(CupertinoIcons.square_stack_fill),
                          label: 'Projects',
                        ),
                        BottomNavigationBarItem(
                          icon: Icon(CupertinoIcons.person_crop_circle),
                          activeIcon: Icon(
                            CupertinoIcons.person_crop_circle_fill,
                          ),
                          label: 'About',
                        ),
                        BottomNavigationBarItem(
                          icon: Icon(CupertinoIcons.bubble_left),
                          activeIcon: Icon(CupertinoIcons.bubble_left_fill),
                          label: 'Contact',
                        ),
                      ],
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
