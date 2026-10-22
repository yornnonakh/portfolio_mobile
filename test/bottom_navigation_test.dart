import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:portfolio_mobile/core/widgets/app_frame.dart';

const _items = [
  NavBarItem(
    icon: CupertinoIcons.house,
    activeIcon: CupertinoIcons.house_fill,
    label: 'Home',
  ),
  NavBarItem(
    icon: CupertinoIcons.square_stack,
    activeIcon: CupertinoIcons.square_stack_fill,
    label: 'Projects',
  ),
  NavBarItem(
    icon: CupertinoIcons.person_crop_circle,
    activeIcon: CupertinoIcons.person_crop_circle_fill,
    label: 'About',
  ),
  NavBarItem(
    icon: CupertinoIcons.bubble_left,
    activeIcon: CupertinoIcons.bubble_left_fill,
    label: 'Contact',
  ),
];

Future<List<int>> _mountBar(
  WidgetTester tester, {
  ThemeData? theme,
  TextDirection direction = TextDirection.ltr,
  bool reducedMotion = false,
}) async {
  var currentIndex = 0;
  final selections = <int>[];
  await tester.pumpWidget(
    MaterialApp(
      theme: theme,
      builder: (context, child) => MediaQuery(
        data: MediaQuery.of(context).copyWith(disableAnimations: reducedMotion),
        child: child!,
      ),
      home: Directionality(
        textDirection: direction,
        child: Scaffold(
          body: Center(
            child: SizedBox(
              width: 360,
              child: StatefulBuilder(
                builder: (context, setState) => FloatingPillBottomNavBar(
                  currentIndex: currentIndex,
                  items: _items,
                  onTap: (index) {
                    selections.add(index);
                    setState(() => currentIndex = index);
                  },
                ),
              ),
            ),
          ),
        ),
      ),
    ),
  );
  return selections;
}

Offset _tabCenter(WidgetTester tester, int visualIndex) {
  final rect = tester.getRect(find.byType(FloatingPillBottomNavBar));
  return Offset(
    rect.left + 6 + (rect.width - 12) / 4 * (visualIndex + .5),
    rect.center.dy,
  );
}

void main() {
  for (final brightness in Brightness.values) {
    testWidgets('Navigation follows the $brightness app colors', (
      tester,
    ) async {
      final scheme = ColorScheme.fromSeed(
        seedColor: Colors.teal,
        brightness: brightness,
      );
      await _mountBar(tester, theme: ThemeData(colorScheme: scheme));
      final indicator = tester.widget<DecoratedBox>(
        find.byKey(const ValueKey('bottom-nav-indicator')),
      );
      expect((indicator.decoration as BoxDecoration).color, scheme.primary);
      expect(
        tester.widget<Icon>(find.byIcon(CupertinoIcons.house_fill)).color,
        scheme.onPrimary,
      );
      expect(
        tester.widget<Icon>(find.byIcon(CupertinoIcons.square_stack)).color,
        scheme.onSurfaceVariant,
      );
      final glass = find.byKey(const ValueKey('bottom-nav-glass'));
      final decoration =
          tester.widget<Container>(glass).decoration as BoxDecoration;
      final gradient = decoration.gradient! as LinearGradient;
      expect(gradient.colors.every((color) => color.a < 1), isTrue);
      expect(
        find.ancestor(of: glass, matching: find.byType(BackdropFilter)),
        findsOneWidget,
      );
    });
  }

  testWidgets(
    'Tapping slides one pill smoothly and can retarget mid-animation',
    (tester) async {
      await _mountBar(tester);
      final indicator = find.byKey(const ValueKey('bottom-nav-indicator'));
      final start = tester.getCenter(indicator).dx;
      await tester.tapAt(_tabCenter(tester, 3));
      await tester.pump();
      expect(tester.getCenter(indicator).dx, closeTo(start, .01));
      await tester.pump(const Duration(milliseconds: 80));
      final halfway = tester.getCenter(indicator).dx;
      expect(halfway, greaterThan(start));
      expect(halfway, lessThan(_tabCenter(tester, 3).dx));

      await tester.tapAt(_tabCenter(tester, 1));
      await tester.pump();
      expect(tester.getCenter(indicator).dx, closeTo(halfway, .01));
      await tester.pumpAndSettle();
      expect(
        tester.getCenter(indicator).dx,
        closeTo(_tabCenter(tester, 1).dx, .01),
      );
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'The pill follows the finger between tabs and settles on release',
    (tester) async {
      final selections = await _mountBar(tester);
      final indicator = find.byKey(const ValueKey('bottom-nav-indicator'));
      final home = _tabCenter(tester, 0);
      final between = Offset.lerp(home, _tabCenter(tester, 1), .3)!;
      final gesture = await tester.startGesture(home);
      await tester.pump(const Duration(milliseconds: 600));
      await gesture.moveTo(between);
      await tester.pump();
      expect(tester.getCenter(indicator).dx, closeTo(between.dx, .01));
      expect(selections, isEmpty);
      await gesture.up();
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 80));
      expect(tester.getCenter(indicator).dx, lessThan(between.dx));
      expect(tester.getCenter(indicator).dx, greaterThan(home.dx));
      await tester.pumpAndSettle();
      expect(tester.getCenter(indicator).dx, closeTo(home.dx, .01));
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'Reduced motion selects immediately without a sliding animation',
    (tester) async {
      await _mountBar(tester, reducedMotion: true);
      await tester.tapAt(_tabCenter(tester, 3));
      await tester.pump();
      expect(
        tester.getCenter(find.byKey(const ValueKey('bottom-nav-indicator'))).dx,
        closeTo(_tabCenter(tester, 3).dx, .01),
      );
      expect(tester.binding.hasScheduledFrame, isFalse);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('Hold and slide selects tabs once per crossing, then taps work', (
    tester,
  ) async {
    final selections = await _mountBar(tester);
    final gesture = await tester.startGesture(_tabCenter(tester, 0));
    await tester.pump(const Duration(milliseconds: 600));
    for (final index in [1, 2, 3, 2]) {
      await gesture.moveTo(_tabCenter(tester, index));
      await tester.pump();
      await gesture.moveBy(const Offset(1, 0));
      await tester.pump();
    }
    await gesture.up();
    await tester.pumpAndSettle();
    expect(selections, [1, 2, 3, 2]);
    expect(find.byIcon(CupertinoIcons.person_crop_circle_fill), findsOneWidget);

    await tester.tapAt(_tabCenter(tester, 0));
    await tester.pumpAndSettle();
    expect(selections, [1, 2, 3, 2, 0]);
    expect(find.byIcon(CupertinoIcons.house_fill), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Horizontal dragging works immediately and clamps at bar edges', (
    tester,
  ) async {
    final selections = await _mountBar(tester);
    final gesture = await tester.startGesture(_tabCenter(tester, 0));
    await gesture.moveBy(const Offset(25, 0));
    await tester.pump();
    await gesture.moveTo(_tabCenter(tester, 3) + const Offset(100, 0));
    await tester.pump();
    await gesture.moveTo(_tabCenter(tester, 3) + const Offset(120, 0));
    await gesture.up();
    await tester.pumpAndSettle();
    expect(selections, [3]);
    expect(find.byIcon(CupertinoIcons.bubble_left_fill), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Hold and slide follows the visual tab order in RTL', (
    tester,
  ) async {
    final selections = await _mountBar(tester, direction: TextDirection.rtl);
    final gesture = await tester.startGesture(_tabCenter(tester, 3));
    await tester.pump(const Duration(milliseconds: 600));
    await gesture.moveTo(_tabCenter(tester, 2));
    await tester.pump();
    await gesture.moveTo(_tabCenter(tester, 0));
    await gesture.up();
    await tester.pumpAndSettle();
    expect(selections, [1, 3]);
    expect(find.byIcon(CupertinoIcons.bubble_left_fill), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
