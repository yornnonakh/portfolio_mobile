import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/constants/app_constants.dart';
import '../features/settings/application/settings_view_model.dart';
import 'router/app_router.dart';
import 'theme/app_theme.dart';

class PortfolioApp extends ConsumerWidget {
  const PortfolioApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);
    return CupertinoApp.router(
      title: AppConstants.name,
      debugShowCheckedModeBanner: false,
      routerConfig: ref.watch(routerProvider),
      localizationsDelegates: const [DefaultMaterialLocalizations.delegate],
      builder: (context, child) {
        final data = MediaQuery.of(context);
        final brightness = switch (settings.themeMode) {
          ThemeMode.system => data.platformBrightness,
          ThemeMode.light => Brightness.light,
          ThemeMode.dark => Brightness.dark,
        };
        final theme = brightness == Brightness.dark
            ? AppTheme.dark
            : AppTheme.light;
        final reduced =
            !settings.animations ||
            data.disableAnimations ||
            data.accessibleNavigation;
        return Theme(
          data: theme,
          child: CupertinoTheme(
            data: MaterialBasedCupertinoThemeData(materialTheme: theme),
            child: DefaultTextStyle(
              style: theme.textTheme.bodyLarge!,
              child: MediaQuery(
                data: data.copyWith(disableAnimations: reduced),
                child: HeroMode(
                  enabled: !reduced,
                  child: child ?? const SizedBox.shrink(),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
