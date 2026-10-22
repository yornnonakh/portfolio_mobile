import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:portfolio_mobile/app/router/app_router.dart';
import 'package:portfolio_mobile/features/settings/application/settings_view_model.dart';
import 'package:portfolio_mobile/features/splash/presentation/splash_robot_scene.dart';
import 'package:portfolio_mobile/features/splash/presentation/splash_screen.dart';
import 'package:portfolio_mobile/features/splash/presentation/waving_robot.dart';

import 'widget_test.dart' as harness;

Future<void> loadRobot(WidgetTester tester) async {
  await tester.runAsync(
    () => precacheImage(
      const AssetImage(SplashRobotScene.asset),
      tester.element(find.byType(SplashScreen)),
    ),
  );
  await tester.pump();
}

void main() {
  testWidgets('Robot floats smoothly before the splash opens Home', (
    tester,
  ) async {
    final container = await harness.mountApp(tester, '/', settle: false);
    await loadRobot(tester);
    await tester.pump(const Duration(milliseconds: 900));
    expect(find.text('Wellcome'), findsOneWidget);
    expect(find.byType(Text), findsOneWidget);
    expect(find.byType(SplashRobotScene), findsOneWidget);
    final robot = find.byKey(const ValueKey('splash-robot-float'));
    double offset() => tester.widget<Transform>(robot).transform.storage[13];
    final first = offset();
    final firstWave = tester
        .widget<WavingRobot>(find.byType(WavingRobot))
        .handAngle;
    final progress = tester
        .widget<LinearProgressIndicator>(
          find.byKey(const ValueKey('splash-progress')),
        )
        .value!;
    expect(progress, inExclusiveRange(0, 1));
    expect(first, isNot(0));
    await tester.pump(const Duration(milliseconds: 400));
    expect(offset(), isNot(closeTo(first, .001)));
    expect(
      tester.widget<WavingRobot>(find.byType(WavingRobot)).handAngle,
      isNot(closeTo(firstWave, .001)),
    );
    expect(
      container.read(routerProvider).routeInformationProvider.value.uri.path,
      '/',
    );
    await tester.pump(const Duration(milliseconds: 1600));
    await tester.pump(const Duration(milliseconds: 500));
    expect(
      container.read(routerProvider).routeInformationProvider.value.uri.path,
      '/home',
    );
    await tester.pump(const Duration(milliseconds: 600));
    expect(find.byType(SplashScreen), findsNothing);
    expect(tester.takeException(), isNull);
  });

  for (final systemReducedMotion in [false, true]) {
    testWidgets(
      'Reduced motion skips the greeting delay ($systemReducedMotion)',
      (tester) async {
        if (systemReducedMotion) {
          tester.platformDispatcher.accessibilityFeaturesTestValue =
              const FakeAccessibilityFeatures(disableAnimations: true);
          addTearDown(
            tester.platformDispatcher.clearAccessibilityFeaturesTestValue,
          );
        }
        final container = await harness.mountApp(
          tester,
          '/',
          savedPreferences: {'animations': systemReducedMotion},
        );
        expect(
          container
              .read(routerProvider)
              .routeInformationProvider
              .value
              .uri
              .path,
          '/home',
        );
        expect(find.byType(SplashScreen), findsNothing);
        expect(tester.takeException(), isNull);
      },
    );
  }

  testWidgets('Turning motion off during the greeting opens Home immediately', (
    tester,
  ) async {
    final container = await harness.mountApp(tester, '/', settle: false);
    await loadRobot(tester);
    await tester.pump(const Duration(milliseconds: 500));
    await container.read(settingsProvider.notifier).setAnimations(false);
    await tester.pumpAndSettle();
    expect(find.byType(SplashScreen), findsNothing);
    expect(tester.takeException(), isNull);
  });

  for (final size in [
    const Size(240, 240),
    const Size(320, 480),
    const Size(320, 700),
    const Size(390, 844),
    const Size(568, 240),
    const Size(844, 390),
    const Size(768, 1024),
    const Size(1024, 768),
    const Size(1440, 1000),
    const Size(2560, 1440),
  ]) {
    testWidgets('Splash fits both languages and themes at $size', (
      tester,
    ) async {
      for (final language in ['en', 'km']) {
        for (final theme in ['light', 'dark']) {
          await harness.mountApp(
            tester,
            '/',
            size: size,
            scale: size.shortestSide <= 320 ? 2 : 1,
            settle: false,
            savedPreferences: {'language': language, 'theme': theme},
          );
          await loadRobot(tester);
          await tester.pump(const Duration(milliseconds: 900));
          expect(find.text('Wellcome'), findsOneWidget);
          for (final finder in [
            find.byKey(const ValueKey('splash-content')),
            find.byType(SplashRobotScene),
            find.text('Wellcome'),
            find.byKey(const ValueKey('splash-progress')),
          ]) {
            final rect = tester.getRect(finder);
            expect(rect.left, greaterThanOrEqualTo(0));
            expect(rect.top, greaterThanOrEqualTo(0));
            expect(rect.right, lessThanOrEqualTo(size.width));
            expect(rect.bottom, lessThanOrEqualTo(size.height));
          }
          expect(find.byType(Scrollable), findsNothing);
          expect(tester.takeException(), isNull);
        }
      }
    });
  }

  testWidgets('Splash respects safe areas and adapts during rotation', (
    tester,
  ) async {
    await harness.mountApp(tester, '/', settle: false, scale: 3);
    addTearDown(tester.view.resetPadding);
    addTearDown(tester.view.resetViewPadding);
    await loadRobot(tester);
    for (final landscape in [false, true]) {
      final size = landscape ? const Size(844, 390) : const Size(390, 844);
      final insets = landscape
          ? const EdgeInsets.fromLTRB(47, 0, 47, 21)
          : const EdgeInsets.fromLTRB(0, 47, 0, 34);
      tester.view.devicePixelRatio = 3;
      tester.view.physicalSize = size * 3;
      tester.view.padding = FakeViewPadding(
        left: insets.left * 3,
        top: insets.top * 3,
        right: insets.right * 3,
        bottom: insets.bottom * 3,
      );
      tester.view.viewPadding = tester.view.padding;
      await tester.pump(const Duration(milliseconds: 700));
      final content = tester.getRect(
        find.byKey(const ValueKey('splash-content')),
      );
      expect(content.left, greaterThanOrEqualTo(insets.left));
      expect(content.top, greaterThanOrEqualTo(insets.top));
      expect(content.right, lessThanOrEqualTo(size.width - insets.right));
      expect(content.bottom, lessThanOrEqualTo(size.height - insets.bottom));
      expect(
        content.center.dx,
        closeTo((insets.left + size.width - insets.right) / 2, .01),
      );
      expect(
        content.center.dy,
        closeTo((insets.top + size.height - insets.bottom) / 2, .01),
      );
      expect(tester.takeException(), isNull);
    }
  });

  testWidgets(
    'Capture splash previews',
    (tester) async {
      await harness.mountApp(tester, '/', settle: false);
      await tester.runAsync(() async {
        final fonts = FontLoader('Poppins');
        for (final weight in ['Regular', 'Medium', 'SemiBold', 'Bold']) {
          fonts.addFont(rootBundle.load('assets/fonts/Poppins-$weight.ttf'));
        }
        await fonts.load();
        await (FontLoader(
          'NotoSansKhmer',
        )..addFont(rootBundle.load('assets/fonts/NotoSansKhmer.ttf'))).load();
      });
      for (final width in [390.0, 1440.0]) {
        for (final theme in ['light', 'dark']) {
          await harness.mountApp(
            tester,
            '/',
            size: Size(width, width == 390 ? 844 : 1000),
            settle: false,
            savedPreferences: {'theme': theme},
          );
          await loadRobot(tester);
          await tester.pump(const Duration(milliseconds: 1000));
          final boundary = tester.renderObject<RenderRepaintBoundary>(
            find.byKey(const ValueKey('portfolio-capture')),
          );
          await tester.runAsync(() async {
            final image = await boundary.toImage();
            final bytes = await image.toByteData(
              format: ui.ImageByteFormat.png,
            );
            final name = 'splash-${width == 390 ? 'mobile' : 'desktop'}-$theme';
            await File(
              'docs/previews/$name.png',
            ).writeAsBytes(bytes!.buffer.asUint8List());
            image.dispose();
          });
        }
      }
    },
    skip: !const bool.fromEnvironment('CAPTURE_SPLASH_PREVIEWS'),
  );
}
