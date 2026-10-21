import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:portfolio_mobile/features/settings/application/settings_view_model.dart';

import 'widget_test.dart' as harness;

void main() {
  testWidgets(
    'Home shows four phones below its project action at every width',
    (tester) async {
      await harness.mountApp(
        tester,
        '/home',
        savedPreferences: {'animations': false},
      );
      for (final width in [320.0, 390.0, 834.0, 1440.0]) {
        tester.view.physicalSize = Size(width, 1000);
        await tester.pumpAndSettle();
        final showcase = tester.getRect(
          find.byKey(const ValueKey('project-phone-showcase')),
        );
        expect(
          showcase.top,
          greaterThan(tester.getRect(find.text('View projects')).bottom),
        );
        for (var i = 0; i < 4; i++) {
          final phone = find.byKey(ValueKey('showcase-phone-$i'));
          expect(phone, findsOneWidget);
          final bounds = tester.getRect(phone);
          expect(bounds.left, greaterThanOrEqualTo(0));
          expect(bounds.right, lessThanOrEqualTo(width));
        }
        expect(tester.takeException(), isNull);
      }
    },
  );

  testWidgets('Phone motion starts and stops with the animation preference', (
    tester,
  ) async {
    final container = await harness.mountApp(
      tester,
      '/home',
      savedPreferences: {'animations': false},
    );
    final phone = find.byKey(const ValueKey('phone-motion-1'));
    double verticalOffset() =>
        tester.widget<Transform>(phone).transform.storage[13];
    expect(verticalOffset(), 0);
    await container.read(settingsProvider.notifier).setAnimations(true);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
    final first = verticalOffset();
    await tester.pump(const Duration(milliseconds: 700));
    expect(verticalOffset(), isNot(closeTo(first, .001)));
    await container.read(settingsProvider.notifier).setAnimations(false);
    await tester.pumpAndSettle();
    expect(verticalOffset(), 0);
    await tester.pump(const Duration(seconds: 8));
    expect(verticalOffset(), 0);
    expect(tester.takeException(), isNull);
  });

  testWidgets('The first phone is larger and emphasis cycles through all four', (
    tester,
  ) async {
    final container = await harness.mountApp(
      tester,
      '/home',
      savedPreferences: {'animations': false},
    );
    double scale(int index) => tester
        .widget<Transform>(find.byKey(ValueKey('phone-scale-$index')))
        .transform.storage[0];
    void expectFocused(int index) {
      for (var i = 0; i < 4; i++) {
        expect(scale(i), closeTo(i == index ? 1.16 : .88, .001));
      }
      final stack = tester.widget<Stack>(
        find.ancestor(
          of: find.byKey(ValueKey('phone-slot-$index')),
          matching: find.byType(Stack),
        ).first,
      );
      expect(stack.children.last.key, ValueKey('phone-slot-$index'));
    }

    expectFocused(0);
    await container.read(settingsProvider.notifier).setAnimations(true);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 4200));
    expectFocused(1);
    for (final index in [2, 3, 0]) {
      await tester.pump(const Duration(milliseconds: 1400));
      await tester.pump(const Duration(milliseconds: 4200));
      expectFocused(index);
    }
    await container.read(settingsProvider.notifier).setAnimations(false);
    await tester.pumpAndSettle();
    expectFocused(0);
    expect(tester.takeException(), isNull);
  });

  testWidgets('System reduced motion keeps all four phone screens still', (
    tester,
  ) async {
    tester.platformDispatcher.accessibilityFeaturesTestValue =
        const FakeAccessibilityFeatures(disableAnimations: true);
    addTearDown(tester.platformDispatcher.clearAccessibilityFeaturesTestValue);
    await harness.mountApp(tester, '/home');
    for (var i = 0; i < 4; i++) {
      final phone = find.byKey(ValueKey('phone-motion-$i'));
      expect(tester.widget<Transform>(phone).transform.storage[13], 0);
    }
    await tester.pump(const Duration(seconds: 8));
    expect(tester.binding.hasScheduledFrame, isFalse);
    expect(tester.takeException(), isNull);
  });
}
