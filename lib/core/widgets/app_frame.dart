import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../design_system/components.dart';

class AppFrame extends StatelessWidget {
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
  Widget build(BuildContext context) {
    final shell = navigationShell;
    final navigationTitle =
        title ?? (shell == null ? 'Home' : _tabTitles[shell.currentIndex]);
    final scheme = Theme.of(context).colorScheme;
    final bottomInset = shell == null
        ? 0.0
        : 56.0 + MediaQuery.viewPaddingOf(context).bottom;
    return CupertinoPageScaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      navigationBar: CupertinoNavigationBar(
        backgroundColor: Colors.transparent,
        border: null,
        automaticBackgroundVisibility: false,
        enableBackgroundFilterBlur: false,
        automaticallyImplyLeading: false,
        middle: Text(
          navigationTitle,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          textAlign: TextAlign.center,
          style: CupertinoTheme.of(context).textTheme.navTitleTextStyle,
        ),
        leading: shell == null
            ? CupertinoNavigationBarBackButton(
                previousPageTitle: 'Back',
                onPressed: () => Navigator.of(context).canPop()
                    ? Navigator.of(context).pop()
                    : context.go('/home'),
              )
            : null,
        trailing: shell != null
            ? IosIconButton(
                label: 'Settings',
                onPressed: () => context.push('/settings'),
                icon: CupertinoIcons.gear_alt,
              )
            : null,
      ),
      child: Builder(
        builder: (context) {
          final data = MediaQuery.of(context);
          return Stack(
            children: [
              Positioned.fill(
                child: MediaQuery(
                  data: data.copyWith(
                    padding: data.padding.copyWith(
                      bottom: shell == null ? data.padding.bottom : bottomInset,
                    ),
                  ),
                  child: SafeArea(
                    top: false,
                    bottom: shell == null,
                    child: child,
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
    );
  }
}
