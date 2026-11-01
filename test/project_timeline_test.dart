import 'dart:ui' show PointerDeviceKind;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:portfolio_mobile/core/services/link_service.dart';

import 'widget_test.dart' as harness;

bool selected(WidgetTester tester, String id) => tester
    .widget<Semantics>(find.byKey(ValueKey('timeline-project-$id')))
    .properties
    .selected!;

void main() {
  testWidgets(
    'View project opens the phone screen before launching the web app',
    (tester) async {
      final calls = <Uri>[];
      await harness.mountApp(
        tester,
        '/projects',
        size: const Size(1440, 1400),
        linkService: LinkService(
          launcher: (uri) async {
            calls.add(uri);
            return true;
          },
        ),
      );
      expect(find.text('Open app'), findsNothing);
      await tester.ensureVisible(find.text('View project').last);
      await tester.tap(find.text('View project').last);
      await tester.pumpAndSettle();
      expect(calls, isEmpty);
      expect(
        find.byKey(const ValueKey('project-detail-phone')),
        findsOneWidget,
      );
      expect(find.text('Google Play'), findsOneWidget);
      expect(find.text('App Store'), findsOneWidget);
      expect(find.text('Coming soon'), findsNWidgets(2));
      expect(
        tester
            .getTopLeft(find.byKey(const ValueKey('project-store-actions')))
            .dy,
        greaterThan(
          tester
              .getBottomLeft(find.byKey(const ValueKey('project-detail-phone')))
              .dy,
        ),
      );
      await Scrollable.ensureVisible(
        tester.element(find.text('Open app')),
        alignment: .5,
      );
      await tester.pumpAndSettle();
      await tester.tap(find.text('Open app'));
      await tester.pumpAndSettle();
      expect(calls, [
        Uri.parse('https://expen-tracker-07042.firebaseapp.com/'),
      ]);
      expect(find.text('Expense Tracker'), findsWidgets);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'Timeline markers select one project and retain case-study links',
    (tester) async {
      await harness.mountApp(tester, '/projects', size: const Size(1440, 1400));
      expect(find.byKey(const ValueKey('project-timeline')), findsOneWidget);
      expect(selected(tester, 'notes'), isTrue);
      expect(selected(tester, 'products'), isFalse);
      await tester.tap(find.byKey(const ValueKey('timeline-select-products')));
      await tester.pumpAndSettle();
      expect(selected(tester, 'notes'), isFalse);
      expect(selected(tester, 'products'), isTrue);
      await tester.ensureVisible(find.text('View project').last);
      await tester.tap(find.text('View project').last);
      await tester.pumpAndSettle();
      expect(find.text('Project overview'), findsOneWidget);
      expect(find.text('Expense Tracker'), findsWidgets);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'Hover moves the active timeline highlight smoothly between cards',
    (tester) async {
      await harness.mountApp(tester, '/projects', size: const Size(1440, 1400));
      final mouse = await tester.createGesture(kind: PointerDeviceKind.mouse);
      await mouse.addPointer(location: const Offset(1, 1));
      try {
        await mouse.moveTo(
          tester.getCenter(
            find.byKey(const ValueKey('timeline-project-products')),
          ),
        );
        await tester.pump();
        expect(selected(tester, 'products'), isTrue);
        await tester.pump(const Duration(milliseconds: 240));
        expect(tester.binding.hasScheduledFrame, isTrue);
        await tester.pumpAndSettle();
        await mouse.moveTo(
          tester.getCenter(
            find.byKey(const ValueKey('timeline-project-notes')),
          ),
        );
        await tester.pumpAndSettle();
        expect(selected(tester, 'notes'), isTrue);
        expect(selected(tester, 'products'), isFalse);
        expect(tester.takeException(), isNull);
      } finally {
        await mouse.removePointer();
      }
    },
  );

  testWidgets(
    'Scrolling updates the active project and category filters keep a valid selection',
    (tester) async {
      await harness.mountApp(tester, '/projects');
      final second = find.byKey(const ValueKey('timeline-project-products'));
      await Scrollable.ensureVisible(tester.element(second), alignment: .25);
      await tester.pumpAndSettle();
      expect(selected(tester, 'products'), isTrue);
      await Scrollable.ensureVisible(
        tester.element(find.text('Productivity').first),
        alignment: .3,
      );
      await tester.pumpAndSettle();
      await tester.tap(find.text('Productivity').first);
      await tester.pumpAndSettle();
      expect(
        find.byKey(const ValueKey('timeline-project-products')),
        findsNothing,
      );
      expect(selected(tester, 'notes'), isTrue);
      await tester.tap(find.text('All').first);
      await tester.pumpAndSettle();
      expect(
        find.byKey(const ValueKey('timeline-project-products')),
        findsOneWidget,
      );
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('Reduced motion keeps timeline selection immediate and static', (
    tester,
  ) async {
    tester.platformDispatcher.accessibilityFeaturesTestValue =
        const FakeAccessibilityFeatures(disableAnimations: true);
    addTearDown(tester.platformDispatcher.clearAccessibilityFeaturesTestValue);
    await harness.mountApp(tester, '/projects', size: const Size(1440, 1400));
    await tester.tap(find.byKey(const ValueKey('timeline-select-products')));
    await tester.pumpAndSettle();
    expect(selected(tester, 'products'), isTrue);
    await tester.pump(const Duration(seconds: 2));
    expect(tester.binding.hasScheduledFrame, isFalse);
    expect(tester.takeException(), isNull);
  });
}
