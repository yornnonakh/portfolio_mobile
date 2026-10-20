import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:portfolio_mobile/app/app.dart';
import 'package:portfolio_mobile/app/router/app_router.dart';
import 'package:portfolio_mobile/core/services/settings_repository.dart';
import 'package:portfolio_mobile/core/design_system/components.dart';
import 'package:portfolio_mobile/features/settings/application/settings_view_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<ProviderContainer> mountApp(
  WidgetTester tester,
  String path, {
  Size size = const Size(390, 844),
  double scale = 1,
}) async {
  GoogleFonts.config.allowRuntimeFetching = false;
  SharedPreferences.setMockInitialValues({});
  final preferences = await SharedPreferences.getInstance();
  final container = ProviderContainer(
    overrides: [
      settingsRepositoryProvider.overrideWithValue(
        SettingsRepository(preferences),
      ),
    ],
  );
  addTearDown(container.dispose);
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1;
  tester.platformDispatcher.textScaleFactorTestValue = scale;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
  addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
  container.read(routerProvider).go(path);
  await tester.pumpWidget(
    UncontrolledProviderScope(
      container: container,
      child: const RepaintBoundary(
        key: ValueKey('portfolio-capture'),
        child: PortfolioApp(),
      ),
    ),
  );
  await tester.pumpAndSettle();
  return container;
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUpAll(() async {
    final interLicense = await rootBundle.loadString('assets/fonts/OFL.txt');
    LicenseRegistry.addLicense(() async* {
      yield LicenseEntryWithLineBreaks(['Inter'], interLicense);
    });
  });
  testWidgets('Splash opens home; tabs, filters and case study navigate', (
    tester,
  ) async {
    await mountApp(tester, '/');
    await tester.pump(const Duration(milliseconds: 1300));
    await tester.pumpAndSettle();
    expect(find.text('Mobile engineer'), findsOneWidget);
    await tester.tap(find.bySemanticsLabel('Projects').last);
    await tester.pumpAndSettle();
    expect(find.text('Projects'), findsWidgets);
    await tester.tap(find.text('Productivity').first);
    await tester.pumpAndSettle();
    expect(find.text('Notes App'), findsOneWidget);
    expect(find.text('E-commerce App'), findsNothing);
    await tester.ensureVisible(find.text('Explore case study').last);
    await tester.tap(find.text('Explore case study').last);
    await tester.pumpAndSettle();
    expect(find.text('Project overview'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  for (final size in [
    const Size(320, 700),
    const Size(834, 1194),
    const Size(1440, 1000),
  ]) {
    testWidgets('Every content route lays out at $size and large text', (
      tester,
    ) async {
      final container = await mountApp(
        tester,
        '/home',
        size: size,
        scale: size.width == 320 ? 2 : 1,
      );
      for (final route in [
        '/home',
        '/projects',
        '/projects/notes',
        '/projects/products',
        '/about',
        '/skills',
        '/experience',
        '/resume',
        '/contact',
        '/settings',
        '/licenses',
        '/projects/missing',
        '/missing',
      ]) {
        container.read(routerProvider).go(route);
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull, reason: 'Route $route at $size');
      }
    });
  }

  testWidgets('Theme and animation changes survive a new provider container', (
    tester,
  ) async {
    final container = await mountApp(tester, '/settings');
    await tester.tap(find.text('Dark'));
    await tester.pumpAndSettle();
    expect(container.read(settingsProvider).themeMode, ThemeMode.dark);
    await tester.ensureVisible(find.byType(CupertinoSwitch));
    await tester.tap(find.byType(CupertinoSwitch));
    await tester.pumpAndSettle();
    final store = container.read(settingsRepositoryProvider);
    final reloaded = ProviderContainer(
      overrides: [settingsRepositoryProvider.overrideWithValue(store)],
    );
    addTearDown(reloaded.dispose);
    expect(reloaded.read(settingsProvider).themeMode, ThemeMode.dark);
    expect(reloaded.read(settingsProvider).animations, isFalse);
  });

  testWidgets(
    'Missing CV and unprovided social links have honest empty states',
    (tester) async {
      final container = await mountApp(tester, '/resume');
      expect(find.text('Resume PDF unavailable'), findsOneWidget);
      expect(find.text('Download / save PDF'), findsNothing);
      container.read(routerProvider).go('/contact');
      await tester.pumpAndSettle();
      expect(find.text('Profile link unavailable'), findsOneWidget);
      final linkedIn = tester.widget<CupertinoButton>(
        find.widgetWithText(CupertinoButton, 'LinkedIn'),
      );
      expect(linkedIn.onPressed, isNull);
    },
  );
  testWidgets('Copy email shows an iOS confirmation and leaves contact open', (
    tester,
  ) async {
    String? copied;
    final messenger =
        TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;
    messenger.setMockMethodCallHandler(SystemChannels.platform, (call) async {
      if (call.method == 'Clipboard.setData') {
        copied = (call.arguments as Map)['text'] as String;
      }
      return null;
    });
    addTearDown(
      () => messenger.setMockMethodCallHandler(SystemChannels.platform, null),
    );
    await mountApp(tester, '/contact');
    await tester.tap(find.text('Copy email'));
    await tester.pumpAndSettle();
    expect(copied, 'Yornnonaistad@gmail.com');
    expect(find.text('Email copied to clipboard.'), findsOneWidget);
    await tester.tap(find.text('OK'));
    await tester.pumpAndSettle();
    expect(find.text('Yorn Nona'), findsOneWidget);
    expect(find.byType(CupertinoAlertDialog), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets(
    'Licenses open from Settings and detail back navigation preserves the list',
    (tester) async {
      await mountApp(tester, '/settings');
      await tester.ensureVisible(find.text('Open source licenses'));
      await tester.tap(find.text('Open source licenses'));
      await tester.pumpAndSettle();
      expect(find.text('Open source'), findsOneWidget);
      final package = tester
          .widget<IosActionRow>(find.byType(IosActionRow).first)
          .title;
      await tester.tap(find.text(package).first);
      await tester.pumpAndSettle();
      expect(find.byType(SelectableText), findsOneWidget);
      await tester.tap(find.bySemanticsLabel('Back').last);
      await tester.pumpAndSettle();
      expect(find.text('Open source'), findsOneWidget);
      expect(find.text(package), findsOneWidget);
      await tester.tap(find.bySemanticsLabel('Back').last);
      await tester.pumpAndSettle();
      expect(find.text('Interface animations'), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'System reduced motion disables animated content and Hero flights',
    (tester) async {
      tester.platformDispatcher.accessibilityFeaturesTestValue =
          const FakeAccessibilityFeatures(disableAnimations: true);
      addTearDown(
        tester.platformDispatcher.clearAccessibilityFeaturesTestValue,
      );
      await mountApp(tester, '/home');
      final heroModes = tester.widgetList<HeroMode>(find.byType(HeroMode));
      expect(heroModes.any((mode) => !mode.enabled), isTrue);
      expect(
        MediaQuery.disableAnimationsOf(
          tester.element(find.text('Mobile engineer')),
        ),
        isTrue,
      );
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('AppBar title is hidden at top and appears when scrolled', (
    tester,
  ) async {
    await mountApp(tester, '/projects');
    final opacityFinder = find.byWidgetPredicate(
      (w) => w is AnimatedOpacity && w.duration == const Duration(milliseconds: 200),
    );
    expect(opacityFinder, findsOneWidget);
    expect(tester.widget<AnimatedOpacity>(opacityFinder).opacity, 0.0);

    await tester.drag(
      find.byType(SingleChildScrollView),
      const Offset(0, -100),
    );
    await tester.pumpAndSettle();
    expect(tester.widget<AnimatedOpacity>(opacityFinder).opacity, 1.0);
  });

  testWidgets(
    'Capture portfolio previews',
    (tester) async {
      final container = await mountApp(
        tester,
        '/home',
        size: const Size(1440, 1800),
      );
      await tester.runAsync(() async {
        final icons = FontLoader('MaterialIcons')
          ..addFont(rootBundle.load('fonts/MaterialIcons-Regular.otf'));
        await icons.load();
        final cupertino = FontLoader('packages/cupertino_icons/CupertinoIcons')
          ..addFont(
            rootBundle.load(
              'packages/cupertino_icons/assets/CupertinoIcons.ttf',
            ),
          );
        await cupertino.load();
        final inter = FontLoader('Inter');
        for (final weight in [
          'Regular',
          'Medium',
          'SemiBold',
          'Bold',
          'ExtraBold',
        ]) {
          inter.addFont(rootBundle.load('assets/fonts/Inter-$weight.ttf'));
        }
        await inter.load();
      });
      final directory = Directory('docs/previews')..createSync(recursive: true);
      for (final mobile in [false, true]) {
        tester.view.physicalSize = mobile
            ? const Size(390, 844)
            : const Size(1440, 1800);
        for (final mode in [ThemeMode.light, ThemeMode.dark]) {
          await container.read(settingsProvider.notifier).setTheme(mode);
          for (final route
              in mobile
                  ? [
                      '/home',
                      '/projects',
                      '/projects/notes',
                      '/about',
                      '/skills',
                      '/experience',
                      '/resume',
                      '/contact',
                      '/settings',
                      '/licenses',
                    ]
                  : ['/home']) {
            container.read(routerProvider).go(route);
            await tester.pumpAndSettle();
            final boundary = tester.renderObject<RenderRepaintBoundary>(
              find.byKey(const ValueKey('portfolio-capture')),
            );
            await tester.runAsync(() async {
              final image = await boundary.toImage();
              final bytes = await image.toByteData(
                format: ui.ImageByteFormat.png,
              );
              final name =
                  '${route.substring(1).replaceAll('/', '-')}${mobile ? '-mobile' : ''}-${mode.name}';
              await File(
                '${directory.path}/$name.png',
              ).writeAsBytes(bytes!.buffer.asUint8List());
              image.dispose();
            });
          }
        }
      }
    },
    skip: !const bool.fromEnvironment('CAPTURE_PREVIEWS'),
  );
}
