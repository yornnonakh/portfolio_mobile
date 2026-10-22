import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../features/settings/application/settings_view_model.dart';

bool motionEnabled(BuildContext context, WidgetRef ref) =>
    ref.watch(settingsProvider).animations &&
    !MediaQuery.disableAnimationsOf(context) &&
    !MediaQuery.accessibleNavigationOf(context);

class IosPage<T> extends CupertinoPage<T> {
  const IosPage({required super.child, super.key});
  @override
  Route<T> createRoute(BuildContext context) => _IosPageRoute<T>(page: this);
}

class IosPageRoute<T> extends CupertinoPageRoute<T> {
  IosPageRoute({required super.builder, super.settings});

  @override
  Widget buildPage(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
  ) => ColoredBox(
    // Paint nested tab pages over Cupertino's navigation scrim.
    color: CupertinoTheme.of(context).scaffoldBackgroundColor,
    child: super.buildPage(context, animation, secondaryAnimation),
  );

  @override
  Widget buildTransitions(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    if (MediaQuery.disableAnimationsOf(context) ||
        MediaQuery.accessibleNavigationOf(context)) {
      return child;
    }
    return super.buildTransitions(
      context,
      animation,
      secondaryAnimation,
      child,
    );
  }
}

class _IosPageRoute<T> extends IosPageRoute<T> {
  _IosPageRoute({required IosPage<T> page})
    : super(builder: (_) => page.child, settings: page);
  @override
  Widget buildContent(BuildContext context) => (settings as IosPage<T>).child;
}
