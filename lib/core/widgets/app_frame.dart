import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../shared/providers/portfolio_providers.dart';
import '../localization/app_localizations.dart';
import '../design_system/components.dart';
import 'language_button.dart';

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
                      builder: (context, ref, child) => AppText(
                        ref.watch(portfolioProvider).profile.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: CupertinoTheme.of(
                          context,
                        ).textTheme.navTitleTextStyle,
                      ),
                    ),
                  ),
                ),
              )
            : shell == null
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
                              _NavBarItem(
                                icon: CupertinoIcons.house,
                                activeIcon: CupertinoIcons.house_fill,
                                label: context.tr('Home'),
                              ),
                              _NavBarItem(
                                icon: CupertinoIcons.square_stack,
                                activeIcon: CupertinoIcons.square_stack_fill,
                                label: context.tr('Projects'),
                              ),
                              _NavBarItem(
                                icon: CupertinoIcons.person_crop_circle,
                                activeIcon: CupertinoIcons.person_crop_circle_fill,
                                label: context.tr('About'),
                              ),
                              _NavBarItem(
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

class FloatingPillBottomNavBar extends StatelessWidget {
  const FloatingPillBottomNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
    required this.items,
  });

  final int currentIndex;
  final ValueChanged<int> onTap;
  final List<_NavBarItem> items;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      height: 64,
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 8),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface.withValues(alpha: .9),
        borderRadius: BorderRadius.circular(36),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? .35 : .12),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
        border: Border.all(
          color: theme.colorScheme.outlineVariant.withValues(alpha: .3),
          width: 0.5,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          for (var i = 0; i < items.length; i++)
            Expanded(
              child: Center(
                child: _NavBarTab(
                  item: items[i],
                  isSelected: i == currentIndex,
                  onTap: () => onTap(i),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _NavBarItem {
  const _NavBarItem({
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
    required this.onTap,
  });

  final _NavBarItem item;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Semantics(
      label: item.label,
      selected: isSelected,
      button: true,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeInOut,
          padding: EdgeInsets.symmetric(
            horizontal: isSelected ? 12 : 8,
            vertical: 8,
          ),
          decoration: BoxDecoration(
            color: isSelected
                ? (isDark ? Colors.white : Colors.black)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                isSelected ? item.activeIcon : item.icon,
                size: 20,
                color: isSelected
                    ? (isDark ? Colors.black : Colors.white)
                    : theme.colorScheme.onSurfaceVariant,
              ),
              if (isSelected) ...[
                const SizedBox(width: 6),
                Flexible(
                  child: AppText(
                    item.label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: isDark ? Colors.black : Colors.white,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
