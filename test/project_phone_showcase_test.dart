import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:portfolio_mobile/features/settings/application/settings_view_model.dart';

import 'widget_test.dart' as harness;

Transform phoneTransform(WidgetTester tester, String kind, int index) =>
    tester.widget<Transform>(find.byKey(ValueKey('phone-$kind-$index')));

double phoneScale(WidgetTester tester, int index) =>
    phoneTransform(tester, 'scale', index).transform.storage[0];

List<double> phonePosition(WidgetTester tester, int index) =>
    List.of(phoneTransform(tester, 'motion', index).transform.storage);

void expectFrontPhone(WidgetTester tester, int index) {
  for (var i = 0; i < 4; i++) {
    final distance = (i - index) % 4;
    final expected = distance == 0 ? 1.16 : (distance == 2 ? .72 : .94);
    expect(phoneScale(tester, i), closeTo(expected, .0001));
  }
  final stack = tester.widget<Stack>(
    find.byKey(const ValueKey('phone-carousel-stack')),
  );
  expect(stack.children.last.key, ValueKey('phone-slot-$index'));
}

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
          expect(bounds.left, greaterThanOrEqualTo(showcase.left));
          expect(bounds.right, lessThanOrEqualTo(showcase.right));
        }
        expectFrontPhone(tester, 0);
        expect(tester.takeException(), isNull);
      }
    },
  );

  testWidgets(
    'Motion preference starts horizontal travel and restores a still layout',
    (tester) async {
      final container = await harness.mountApp(
        tester,
        '/home',
        savedPreferences: {'animations': false},
      );
      final restingPosition = phonePosition(tester, 1);
      await container.read(settingsProvider.notifier).setAnimations(true);
      await tester.pump();
      await tester.pump(Duration.zero);
      await tester.pump(const Duration(milliseconds: 500));
      final first = phonePosition(tester, 1)[12];
      await tester.pump(const Duration(milliseconds: 700));
      expect(phonePosition(tester, 1)[12], isNot(closeTo(first, .001)));
      final perspective = phoneTransform(tester, 'perspective', 1).transform;
      expect(perspective.storage[2].abs(), greaterThan(.01));
      expect(perspective.storage[11].abs(), greaterThan(.0001));
      await container.read(settingsProvider.notifier).setAnimations(false);
      await tester.pumpAndSettle();
      expect(phonePosition(tester, 1), restingPosition);
      expectFrontPhone(tester, 0);
      await tester.pump(const Duration(seconds: 8));
      expect(phonePosition(tester, 1), restingPosition);
      expect(tester.binding.hasScheduledFrame, isFalse);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('All four phones slide into the enlarged foreground in order', (
    tester,
  ) async {
    final container = await harness.mountApp(
      tester,
      '/home',
      savedPreferences: {'animations': false},
    );
    expectFrontPhone(tester, 0);
    await container.read(settingsProvider.notifier).setAnimations(true);
    await tester.pump();
    await tester.pump(Duration.zero);
    for (final index in [1, 2, 3, 0, 1]) {
      await tester.pump(const Duration(seconds: 4));
      expectFrontPhone(tester, index);
      expect(phonePosition(tester, index)[12], closeTo(0, .0001));
    }
    expect(tester.takeException(), isNull);
  });

  testWidgets(
    'Positions, scale and perspective remain continuous across the loop seam',
    (tester) async {
      final container = await harness.mountApp(
        tester,
        '/home',
        savedPreferences: {'animations': false},
      );
      await container.read(settingsProvider.notifier).setAnimations(true);
      await tester.pump();
      await tester.pump(Duration.zero);
      await tester.pump(const Duration(milliseconds: 15984));
      final positions = List.generate(4, (i) => phonePosition(tester, i));
      final scales = List.generate(4, (i) => phoneScale(tester, i));
      final perspectives = List.generate(
        4,
        (i) =>
            List.of(phoneTransform(tester, 'perspective', i).transform.storage),
      );
      await tester.pump(const Duration(milliseconds: 32));
      for (var i = 0; i < 4; i++) {
        final position = phonePosition(tester, i);
        expect(position[12], closeTo(positions[i][12], 2));
        expect(position[13], closeTo(positions[i][13], 2));
        expect(phoneScale(tester, i), closeTo(scales[i], .005));
        final perspective = phoneTransform(
          tester,
          'perspective',
          i,
        ).transform.storage;
        for (var entry = 0; entry < 16; entry++) {
          expect(perspective[entry], closeTo(perspectives[i][entry], .01));
        }
      }
      expect(tester.binding.hasScheduledFrame, isTrue);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'Phones stay within the narrow canvas throughout a complete orbit',
    (tester) async {
      final container = await harness.mountApp(
        tester,
        '/home',
        size: const Size(320, 1000),
        scale: 2,
        savedPreferences: {'animations': false},
      );
      await container.read(settingsProvider.notifier).setAnimations(true);
      await tester.pump();
      await tester.pump(Duration.zero);
      for (var frame = 0; frame < 64; frame++) {
        await tester.pump(const Duration(milliseconds: 250));
        final canvas = tester.getRect(
          find.byKey(const ValueKey('project-phone-showcase')),
        );
        for (var i = 0; i < 4; i++) {
          final bounds = tester.getRect(
            find.byKey(ValueKey('showcase-phone-$i')),
          );
          expect(bounds.left, greaterThanOrEqualTo(canvas.left));
          expect(bounds.right, lessThanOrEqualTo(canvas.right));
          expect(bounds.top, greaterThanOrEqualTo(canvas.top));
          expect(bounds.bottom, lessThanOrEqualTo(canvas.bottom));
        }
        expect(tester.takeException(), isNull);
      }
    },
  );

  for (final accessibleNavigation in [false, true]) {
    testWidgets(
      'Accessibility stops a running carousel (navigation: $accessibleNavigation)',
      (tester) async {
        await harness.mountApp(tester, '/home', settle: false);
        await tester.pump(const Duration(seconds: 1));
        expect(tester.binding.hasScheduledFrame, isTrue);
        tester.platformDispatcher.accessibilityFeaturesTestValue =
            FakeAccessibilityFeatures(
              disableAnimations: !accessibleNavigation,
              accessibleNavigation: accessibleNavigation,
            );
        addTearDown(
          tester.platformDispatcher.clearAccessibilityFeaturesTestValue,
        );
        await tester.pumpAndSettle();
        expectFrontPhone(tester, 0);
        final positions = List.generate(4, (i) => phonePosition(tester, i));
        await tester.pump(const Duration(seconds: 8));
        for (var i = 0; i < 4; i++) {
          expect(phonePosition(tester, i), positions[i]);
        }
        expect(tester.binding.hasScheduledFrame, isFalse);
        expect(tester.takeException(), isNull);
      },
    );
  }
}
