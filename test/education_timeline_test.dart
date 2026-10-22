import 'dart:ui' show PointerDeviceKind;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:portfolio_mobile/core/widgets/education_timeline.dart';
import 'package:portfolio_mobile/features/settings/application/settings_view_model.dart';
import 'package:portfolio_mobile/shared/data/portfolio_repository.dart';

import 'widget_test.dart' as harness;

final educations = const LocalPortfolioRepository().load().educations;

Finder milestone(int index) =>
    find.byKey(ValueKey('education-milestone-${educations[index].institute}'));

bool selected(WidgetTester tester, int index) =>
    tester.widget<Semantics>(milestone(index)).properties.selected!;

void main() {
  testWidgets('Scrolling reveals milestones and moves the active highlight', (
    tester,
  ) async {
    await harness.mountApp(tester, '/about');
    final fade = find.ancestor(
      of: milestone(0),
      matching: find.byType(AnimatedOpacity),
    );
    expect(tester.renderObject<RenderAnimatedOpacity>(fade).opacity.value, 0);
    await Scrollable.ensureVisible(
      tester.element(milestone(0)),
      alignment: .15,
    );
    await tester.pump();
    // Visibility is discovered after layout; start the reveal on the next frame.
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 180));
    expect(
      tester.renderObject<RenderAnimatedOpacity>(fade).opacity.value,
      inExclusiveRange(0, 1),
    );
    await tester.pumpAndSettle();
    expect(tester.renderObject<RenderAnimatedOpacity>(fade).opacity.value, 1);
    await Scrollable.ensureVisible(
      tester.element(milestone(3)),
      alignment: .25,
    );
    await tester.pumpAndSettle();
    expect(selected(tester, 3), isTrue);
    expect(
      [
        for (var index = 0; index < 4; index++) selected(tester, index),
      ].where((value) => value),
      hasLength(1),
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets('Tap and hover select milestones with a smooth transition', (
    tester,
  ) async {
    await harness.mountApp(tester, '/about', size: const Size(834, 1194));
    await Scrollable.ensureVisible(
      tester.element(milestone(0)),
      alignment: .08,
    );
    await tester.pumpAndSettle();
    await tester.tap(
      find.byKey(ValueKey('education-select-${educations[0].institute}')),
    );
    await tester.pumpAndSettle();
    expect(selected(tester, 0), isTrue);
    final mouse = await tester.createGesture(kind: PointerDeviceKind.mouse);
    await mouse.addPointer(location: const Offset(1, 1));
    try {
      await mouse.moveTo(tester.getCenter(milestone(3)));
      await tester.pump();
      expect(selected(tester, 3), isTrue);
      expect(selected(tester, 0), isFalse);
      await tester.pump(const Duration(milliseconds: 180));
      expect(tester.binding.hasScheduledFrame, isTrue);
      await tester.pumpAndSettle();
      expect(tester.binding.hasScheduledFrame, isFalse);
    } finally {
      await mouse.removePointer();
    }
    expect(tester.takeException(), isNull);
  });

  for (final systemReducedMotion in [false, true]) {
    testWidgets(
      'Reduced motion keeps the timeline static ($systemReducedMotion)',
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
          '/about',
          size: const Size(834, 1194),
          savedPreferences: {'animations': systemReducedMotion},
        );
        expect(find.byType(EducationTimeline), findsOneWidget);
        await Scrollable.ensureVisible(
          tester.element(milestone(0)),
          alignment: .08,
        );
        await tester.pumpAndSettle();
        await tester.tap(
          find.byKey(ValueKey('education-select-${educations[0].institute}')),
        );
        await tester.pump();
        expect(selected(tester, 0), isTrue);
        final fade = find.ancestor(
          of: milestone(0),
          matching: find.byType(AnimatedOpacity),
        );
        expect(
          tester.renderObject<RenderAnimatedOpacity>(fade).opacity.value,
          1,
        );
        await tester.pumpAndSettle();
        expect(tester.binding.hasScheduledFrame, isFalse);
        await container.read(settingsProvider.notifier).setAnimations(false);
        await tester.pumpAndSettle();
        expect(tester.binding.hasScheduledFrame, isFalse);
        expect(tester.takeException(), isNull);
      },
    );
  }
}
