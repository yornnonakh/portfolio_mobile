import 'dart:ui' show PointerDeviceKind;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:portfolio_mobile/features/home/presentation/tools_icon_marquee.dart';
import 'package:portfolio_mobile/features/projects/presentation/project_card.dart';
import 'package:portfolio_mobile/features/settings/application/settings_view_model.dart';

import 'widget_test.dart' as harness;

const toolNames = [
  'Flutter',
  'Dart',
  'Kotlin',
  'Swift',
  'GitHub',
  'Firebase',
  'Supabase',
  'VS Code',
  'Android Studio',
  'iOS',
];

double marqueeOffset(WidgetTester tester) => tester
    .widget<Transform>(find.byKey(const ValueKey('tools-marquee-left')))
    .transform
    .storage[12];

Future<void> showAnimatedTools(WidgetTester tester) async {
  final container = await harness.mountApp(
    tester,
    '/home',
    savedPreferences: {'animations': false},
  );
  // Keep the pointer target stationary while testing the marquee itself.
  await tester.pumpWidget(
    UncontrolledProviderScope(
      container: container,
      child: const MaterialApp(
        home: Scaffold(body: Center(child: ToolsIconMarquee())),
      ),
    ),
  );
  await container.read(settingsProvider.notifier).setAnimations(true);
  await tester.pump();
  await tester.pump(Duration.zero);
  await tester.pump(const Duration(milliseconds: 500));
}

void main() {
  testWidgets('Home lists all ten tools below the project cards', (
    tester,
  ) async {
    await harness.mountApp(
      tester,
      '/home',
      savedPreferences: {'animations': false},
    );
    final section = find.byKey(const ValueKey('home-tools'));
    expect(
      tester.getTopLeft(section).dy,
      greaterThan(tester.getBottomLeft(find.byType(ProjectCard).last).dy),
    );
    for (final name in toolNames) {
      expect(
        find.descendant(of: section, matching: find.text(name)),
        findsOneWidget,
      );
    }
    expect(find.byKey(const ValueKey('tools-static')), findsOneWidget);
    final scroll = tester.widget<SingleChildScrollView>(
      find.byKey(const ValueKey('tools-static')),
    );
    expect(scroll.scrollDirection, Axis.horizontal);
    expect(tester.takeException(), isNull);
  });

  testWidgets(
    'One row glides steadily and fills a wide viewport across the seam',
    (tester) async {
      final container = await harness.mountApp(
        tester,
        '/home',
        size: const Size(1440, 1300),
        savedPreferences: {'animations': false},
      );
      await container.read(settingsProvider.notifier).setAnimations(true);
      await tester.pump();
      await tester.pump(Duration.zero);
      await tester.pump(const Duration(milliseconds: 500));
      final left = find.byKey(const ValueKey('tools-marquee-left'));
      expect(find.byKey(const ValueKey('tools-marquee-right')), findsNothing);
      double offset(Finder finder) =>
          tester.widget<Transform>(finder).transform.storage[12];
      final firstLeft = offset(left);
      await tester.pump(const Duration(milliseconds: 500));
      expect(offset(left), lessThan(firstLeft));
      // Equal frame intervals should travel equal distances, without easing
      // pulses or rounding away the fractional movement at slower speeds.
      var previousLeft = offset(left);
      await tester.pump(const Duration(milliseconds: 16));
      final leftStep = offset(left) - previousLeft;
      expect(leftStep, lessThan(0));
      for (var frame = 0; frame < 8; frame++) {
        previousLeft = offset(left);
        await tester.pump(const Duration(milliseconds: 16));
        expect(offset(left) - previousLeft, closeTo(leftStep, .0001));
      }
      for (var frame = 0; frame < 31; frame++) {
        await tester.pump(const Duration(seconds: 6));
        final viewport = tester.getRect(
          find.ancestor(of: left, matching: find.byType(ClipRect)).first,
        );
        final strip = tester.getRect(left);
        expect(strip.left, lessThanOrEqualTo(viewport.left));
        expect(strip.right, greaterThanOrEqualTo(viewport.right));
        expect(tester.takeException(), isNull);
      }
    },
  );

  testWidgets('Repeated visual logos are announced only once', (tester) async {
    final semantics = tester.ensureSemantics();
    try {
      await harness.mountApp(tester, '/home', settle: false);
      final section = find.byKey(const ValueKey('home-tools'));
      await tester.ensureVisible(section);
      await tester.pump(const Duration(milliseconds: 500));
      final label = toolNames.join(', ');
      expect(find.bySemanticsLabel(label), findsOneWidget);
      expect(tester.takeException(), isNull);
    } finally {
      semantics.dispose();
    }
  });

  testWidgets(
    'Hover pauses the row and leaving resumes from the same position',
    (tester) async {
      await showAnimatedTools(tester);
      final mouse = await tester.createGesture(kind: PointerDeviceKind.mouse);
      await mouse.addPointer(location: const Offset(1, 1));
      try {
        await mouse.moveTo(
          tester.getCenter(find.byKey(const ValueKey('tools-pause-region'))),
        );
        await tester.pump();
        final held = marqueeOffset(tester);
        await tester.pump(const Duration(seconds: 2));
        expect(marqueeOffset(tester), held);
        await mouse.moveTo(const Offset(1, 1));
        await tester.pump();
        expect(marqueeOffset(tester), closeTo(held, .0001));
        await tester.pump(const Duration(seconds: 1));
        expect(marqueeOffset(tester), closeTo(held - 18, .01));
        expect(tester.takeException(), isNull);
      } finally {
        await mouse.removePointer();
      }
    },
  );

  testWidgets(
    'Touch holds pause until every pointer is released or cancelled',
    (tester) async {
      await showAnimatedTools(tester);
      final center = tester.getCenter(
        find.byKey(const ValueKey('tools-pause-region')),
      );
      final first = await tester.startGesture(center, pointer: 41);
      await tester.pump();
      final held = marqueeOffset(tester);
      await tester.pump(const Duration(seconds: 2));
      expect(marqueeOffset(tester), held);
      final second = await tester.startGesture(
        center + const Offset(30, 0),
        pointer: 42,
      );
      await first.up();
      await tester.pump(const Duration(seconds: 2));
      expect(marqueeOffset(tester), held);
      await second.cancel();
      await tester.pump();
      expect(marqueeOffset(tester), closeTo(held, .0001));
      await tester.pump(const Duration(seconds: 1));
      expect(marqueeOffset(tester), closeTo(held - 18, .01));
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'A held mouse button keeps the row paused after the cursor leaves',
    (tester) async {
      await showAnimatedTools(tester);
      final mouse = await tester.createGesture(kind: PointerDeviceKind.mouse);
      final center = tester.getCenter(
        find.byKey(const ValueKey('tools-pause-region')),
      );
      await mouse.addPointer(location: center);
      try {
        await mouse.down(center);
        await tester.pump();
        final held = marqueeOffset(tester);
        await mouse.moveTo(const Offset(1, 1));
        await tester.pump(const Duration(seconds: 2));
        expect(marqueeOffset(tester), held);
        await mouse.up();
        await tester.pump();
        expect(marqueeOffset(tester), closeTo(held, .0001));
        await tester.pump(const Duration(seconds: 1));
        expect(marqueeOffset(tester), closeTo(held - 18, .01));
        expect(tester.takeException(), isNull);
      } finally {
        await mouse.removePointer();
      }
    },
  );

  for (final systemReducedMotion in [false, true]) {
    testWidgets(
      'Motion can stop without hiding any tools (system: $systemReducedMotion)',
      (tester) async {
        final container = await harness.mountApp(
          tester,
          '/home',
          settle: false,
        );
        await tester.pump(const Duration(seconds: 1));
        expect(
          find.byKey(const ValueKey('tools-marquee-left')),
          findsOneWidget,
        );
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
        expect(find.byKey(const ValueKey('tools-marquee-left')), findsNothing);
        final staticTools = find.byKey(const ValueKey('tools-static'));
        for (final name in toolNames) {
          expect(
            find.descendant(of: staticTools, matching: find.text(name)),
            findsOneWidget,
          );
        }
        await tester.pump(const Duration(seconds: 35));
        expect(tester.binding.hasScheduledFrame, isFalse);
        expect(tester.takeException(), isNull);
      },
    );
  }
}
