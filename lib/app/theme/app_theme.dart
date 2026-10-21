import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

abstract final class AppColors {
  static const blue = Color(0xFF007AFF);
  static const darkBackground = Color(0xFF000000);
  static const darkSurface = Color(0xFF1C1C1E);
}

abstract final class AppTheme {
  static ThemeData get light => _build(Brightness.light);
  static ThemeData get dark => _build(Brightness.dark);
  static String get fontFamily =>
      defaultTargetPlatform == TargetPlatform.iOS ||
          defaultTargetPlatform == TargetPlatform.macOS
      ? 'CupertinoSystemText'
      : 'Poppins';

  static ThemeData _build(Brightness brightness) {
    final dark = brightness == Brightness.dark;
    final scheme =
        ColorScheme.fromSeed(
          seedColor: AppColors.blue,
          brightness: brightness,
        ).copyWith(
          primary: dark ? const Color(0xFF0A84FF) : AppColors.blue,
          onPrimary: Colors.white,
          secondary: dark ? const Color(0xFF0A84FF) : AppColors.blue,
          surface: dark ? AppColors.darkSurface : Colors.white,
          onSurface: dark ? const Color(0xFFF2F2F7) : const Color(0xFF1C1C1E),
          onSurfaceVariant: dark
              ? const Color(0xFFAEAEB2)
              : const Color(0xFF636366),
          outlineVariant: dark
              ? const Color(0xFF38383A)
              : const Color(0xFFD1D1D6),
          surfaceContainerHighest: dark
              ? const Color(0xFF2C2C2E)
              : const Color(0xFFE9E9EF),
        );
    final background = dark
        ? AppColors.darkBackground
        : const Color(0xFFF2F2F7);
    final base = ThemeData(
      useMaterial3: true,
      fontFamily: fontFamily,
      fontFamilyFallback: const ['NotoSansKhmer'],
      brightness: brightness,
      colorScheme: scheme,
    );
    final text = base.textTheme;
    return base.copyWith(
      scaffoldBackgroundColor: background,
      splashFactory: NoSplash.splashFactory,
      highlightColor: Colors.transparent,
      appBarTheme: AppBarTheme(
        backgroundColor: scheme.surface.withValues(alpha: .86),
        scrolledUnderElevation: 0,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
      ),
      cupertinoOverrideTheme: CupertinoThemeData(
        brightness: brightness,
        primaryColor: scheme.primary,
        primaryContrastingColor: scheme.onPrimary,
        scaffoldBackgroundColor: background,
        barBackgroundColor: scheme.surface.withValues(alpha: .86),
        textTheme: CupertinoTextThemeData(
          navTitleTextStyle: TextStyle(
            fontFamily: fontFamily,
            fontFamilyFallback: const ['NotoSansKhmer'],
            fontSize: 17,
            fontWeight: FontWeight.w600,
            color: scheme.onSurface,
            letterSpacing: -.3,
          ),
          navLargeTitleTextStyle: TextStyle(
            fontFamily: fontFamily,
            fontFamilyFallback: const ['NotoSansKhmer'],
            fontSize: 34,
            fontWeight: FontWeight.w700,
            color: scheme.onSurface,
            letterSpacing: -1.1,
          ),
          navActionTextStyle: TextStyle(
            fontFamily: fontFamily,
            fontFamilyFallback: const ['NotoSansKhmer'],
            fontSize: 17,
            color: scheme.primary,
            letterSpacing: -.3,
          ),
          actionTextStyle: TextStyle(
            fontFamily: fontFamily,
            fontFamilyFallback: const ['NotoSansKhmer'],
            fontSize: 17,
            color: scheme.primary,
            letterSpacing: -.3,
          ),
          tabLabelTextStyle: TextStyle(
            fontFamily: fontFamily,
            fontFamilyFallback: const ['NotoSansKhmer'],
            fontSize: 10,
            fontWeight: FontWeight.w500,
            color: scheme.onSurfaceVariant,
          ),
          textStyle: TextStyle(
            fontFamily: fontFamily,
            fontFamilyFallback: const ['NotoSansKhmer'],
            fontSize: 17,
            color: scheme.onSurface,
            letterSpacing: -.3,
          ),
        ),
      ),
      textTheme: text
          .copyWith(
            displayLarge: text.displayLarge?.copyWith(
              fontSize: 48,
              fontWeight: FontWeight.w700,
              letterSpacing: -1.8,
              height: 1.12,
            ),
            displayMedium: text.displayMedium?.copyWith(
              fontSize: 34,
              fontWeight: FontWeight.w700,
              letterSpacing: -1.1,
              height: 1.16,
            ),
            headlineLarge: text.headlineLarge?.copyWith(
              fontSize: 28,
              fontWeight: FontWeight.w700,
              letterSpacing: -.7,
              height: 1.2,
            ),
            headlineMedium: text.headlineMedium?.copyWith(
              fontSize: 22,
              fontWeight: FontWeight.w700,
              letterSpacing: -.5,
              height: 1.25,
            ),
            titleLarge: text.titleLarge?.copyWith(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              letterSpacing: -.4,
              height: 1.3,
            ),
            titleMedium: text.titleMedium?.copyWith(
              fontSize: 17,
              fontWeight: FontWeight.w600,
              letterSpacing: -.3,
              height: 1.35,
            ),
            bodyLarge: text.bodyLarge?.copyWith(
              fontSize: 17,
              height: 1.5,
              letterSpacing: -.3,
            ),
            bodyMedium: text.bodyMedium?.copyWith(
              fontSize: 15,
              height: 1.45,
              letterSpacing: -.2,
            ),
            bodySmall: text.bodySmall?.copyWith(
              fontSize: 13,
              height: 1.4,
              letterSpacing: -.1,
            ),
            labelLarge: text.labelLarge?.copyWith(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              letterSpacing: -.3,
            ),
            labelMedium: text.labelMedium?.copyWith(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              letterSpacing: -.1,
            ),
          )
          .apply(
            fontFamily: fontFamily,
            fontFamilyFallback: const ['NotoSansKhmer'],
            bodyColor: scheme.onSurface,
            displayColor: scheme.onSurface,
          ),
      dividerColor: scheme.outlineVariant.withValues(alpha: .55),
      dividerTheme: DividerThemeData(
        color: scheme.outlineVariant.withValues(alpha: .55),
        thickness: .5,
        space: 1,
      ),
    );
  }
}
