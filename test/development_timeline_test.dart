import 'dart:ui' show PointerDeviceKind;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:portfolio_mobile/app/theme/app_theme.dart';
import 'package:portfolio_mobile/features/home/presentation/development_timeline.dart';
import 'package:portfolio_mobile/features/settings/application/settings_view_model.dart';

import 'widget_test.dart' as harness;

bool active(WidgetTester tester, int index) => tester
    .widget<Semantics>(find.byKey(ValueKey('development-milestone-$index')))
    .properties
    .selected!;

Future<ProviderContainer> mountTimeline(
  WidgetTester tester, {
  bool animate = true,
  double width = 390,
}) async {
  final container = await harness.mountApp(
    tester,
    '/home',
    size: Size(width, 900),
    savedPreferences: {'animations': false},
  );
  await tester.pumpWidget(
    UncontrolledProviderScope(
      container: container,
      child: MaterialApp(
        theme: AppTheme.light,
        home: const Scaffold(
          body: Center(
            child: Padding(
              padding: EdgeInsets.all(20),
              child: DevelopmentTimeline(experience: '6 months'),
            ),
          ),
        ),
      ),
    ),
  );
  await container.read(settingsProvider.notifier).setAnimations(animate);
  await tester.pump();
  return container;
}

void main() {
  testWidgets('Active emphasis eases between milestones and loops', (
    tester,
  ) async {
    await mountTimeline(tester);
    Color? mobileColor() =>
        tester.widget<Text>(find.text('iOS & Android')).style?.color;
    final initial = mobileColor();
    expect(active(tester, 0), isTrue);
    await tester.pump(const Duration(seconds: 3));
    expect(active(tester, 1), isTrue);
    expect(mobileColor(), initial);
    await tester.pump(const Duration(milliseconds: 275));
    final halfway = mobileColor();
    expect(halfway, isNot(initial));
    expect(halfway, isNot(AppTheme.light.colorScheme.primary));
    await tester.pump(const Duration(milliseconds: 275));
    expect(mobileColor(), AppTheme.light.colorScheme.primary);
    await tester.pump(const Duration(milliseconds: 2450));
    expect(active(tester, 2), isTrue);
    await tester.pump(const Duration(seconds: 3));
    expect(active(tester, 0), isTrue);
    expect(tester.takeException(), isNull);
  });

  for (final width in [390.0, 1100.0]) {
    testWidgets('Tapping selects a milestone at width $width', (tester) async {
      await mountTimeline(tester, animate: false, width: width);
      await tester.tap(find.byKey(const ValueKey('development-select-2')));
      await tester.pumpAndSettle();
      expect(active(tester, 2), isTrue);
      expect(active(tester, 0), isFalse);
      await tester.pump(const Duration(seconds: 9));
      expect(active(tester, 2), isTrue);
      expect(tester.binding.hasScheduledFrame, isFalse);
      expect(tester.takeException(), isNull);
    });
  }

  testWidgets('Hover focuses a milestone and pauses the automatic cycle', (
    tester,
  ) async {
    await mountTimeline(tester);
    final mouse = await tester.createGesture(kind: PointerDeviceKind.mouse);
    await mouse.addPointer(location: const Offset(1, 1));
    try {
      await mouse.moveTo(
        tester.getCenter(find.byKey(const ValueKey('development-select-2'))),
      );
      await tester.pumpAndSettle();
      expect(active(tester, 2), isTrue);
      await tester.pump(const Duration(seconds: 6));
      expect(active(tester, 2), isTrue);
      await mouse.moveTo(const Offset(1, 1));
      await tester.pump();
      await tester.pump(const Duration(seconds: 3));
      expect(active(tester, 0), isTrue);
      expect(tester.takeException(), isNull);
    } finally {
      await mouse.removePointer();
    }
  });

  for (final systemReducedMotion in [false, true]) {
    testWidgets('Motion stops immediately (system: $systemReducedMotion)', (
      tester,
    ) async {
      final container = await mountTimeline(tester);
      await tester.pump(const Duration(seconds: 3));
      expect(active(tester, 1), isTrue);
      if (systemReducedMotion) {
        tester.platformDispatcher.accessibilityFeaturesTestValue =
            const FakeAccessibilityFeatures(disableAnimations: true);
        addTearDown(
          tester.platformDispatcher.clearAccessibilityFeaturesTestValue,
        );
      } else {
        await container.read(settingsProvider.notifier).setAnimations(false);
      }
      await tester.pumpAndSettle();
      await tester.pump(const Duration(seconds: 12));
      expect(active(tester, 1), isTrue);
      expect(tester.binding.hasScheduledFrame, isFalse);
      expect(tester.takeException(), isNull);
    });
  }

  testWidgets('The automatic cycle pauses while the app is in the background', (
    tester,
  ) async {
    await mountTimeline(tester);
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.paused);
    await tester.pump(const Duration(seconds: 9));
    expect(active(tester, 0), isTrue);
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
    await tester.pump(const Duration(seconds: 3));
    expect(active(tester, 1), isTrue);
    expect(tester.takeException(), isNull);
  });
}
