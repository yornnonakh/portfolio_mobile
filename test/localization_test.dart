import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:portfolio_mobile/app/router/app_router.dart';
import 'package:portfolio_mobile/core/services/settings_repository.dart';
import 'package:portfolio_mobile/features/settings/application/settings_view_model.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:ui' as ui;
import 'widget_test.dart' as harness;

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUpAll(() async {
    final license = await rootBundle.loadString(
      'assets/fonts/NotoSansKhmer-OFL.txt',
    );
    LicenseRegistry.addLicense(() async* {
      yield LicenseEntryWithLineBreaks(['Noto Sans Khmer'], license);
    });
  });

  test(
    'Language persists with appearance and motion and restores on startup',
    () async {
      SharedPreferences.setMockInitialValues({});
      final store = SettingsRepository(await SharedPreferences.getInstance());
      final container = ProviderContainer(
        overrides: [settingsRepositoryProvider.overrideWithValue(store)],
      );
      addTearDown(container.dispose);
      final settings = container.read(settingsProvider.notifier);
      await settings.setTheme(ThemeMode.dark);
      await settings.setAnimations(false);
      await settings.setLanguage('km');
      final restored = ProviderContainer(
        overrides: [settingsRepositoryProvider.overrideWithValue(store)],
      );
      addTearDown(restored.dispose);
      expect(restored.read(settingsProvider).languageCode, 'km');
      expect(restored.read(settingsProvider).themeMode, ThemeMode.dark);
      expect(restored.read(settingsProvider).animations, isFalse);
      await restored.read(settingsProvider.notifier).setLanguage('en');
      expect(store.languageCode, 'en');
    },
  );

  test(
    'Unknown language falls back to English; failed saves retain current choice',
    () async {
      SharedPreferences.setMockInitialValues({'language': 'fr'});
      expect(
        SettingsRepository(await SharedPreferences.getInstance()).languageCode,
        'en',
      );
      final container = ProviderContainer(
        overrides: [
          settingsRepositoryProvider.overrideWithValue(
            SettingsRepository(null),
          ),
        ],
      );
      addTearDown(container.dispose);
      await container.read(settingsProvider.notifier).setLanguage('km');
      expect(container.read(settingsProvider).languageCode, 'en');
      expect(container.read(settingsProvider).error, isNotNull);
      expect(container.read(settingsProvider).saving, isFalse);
      await container.read(settingsProvider.notifier).setLanguage('fr');
      expect(container.read(settingsProvider).languageCode, 'en');
    },
  );

  testWidgets(
    'Language text switches immediately in either direction without leaving the tab',
    (tester) async {
      final container = await harness.mountApp(tester, '/projects');
      await tester.tap(find.text('EN'));
      await tester.pumpAndSettle();
      expect(container.read(settingsProvider).languageCode, 'km');
      expect(find.text('ខ្មែរ'), findsOneWidget);
      expect(find.text('គម្រោង'), findsWidgets);
      expect(find.byKey(const ValueKey('language-picker-popup')), findsNothing);
      expect(
        container.read(routerProvider).routeInformationProvider.value.uri.path,
        '/projects',
      );
      await tester.tap(find.text('ខ្មែរ'));
      await tester.pumpAndSettle();
      expect(container.read(settingsRepositoryProvider).languageCode, 'en');
      expect(find.text('EN'), findsOneWidget);
      tester.view.physicalSize = const Size(320, 700);
      tester.platformDispatcher.textScaleFactorTestValue = 2;
      await tester.pumpAndSettle();
      await tester.tap(find.text('EN'));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      expect(container.read(settingsRepositoryProvider).languageCode, 'km');
    },
  );

  testWidgets(
    'Settings changes the whole app and native controls in either direction',
    (tester) async {
      final container = await harness.mountApp(tester, '/settings');
      await Scrollable.ensureVisible(
        tester.element(find.byKey(const ValueKey('settings-language'))),
        alignment: .5,
      );
      await tester.pumpAndSettle();
      await tester.tap(find.text('English'));
      await tester.pumpAndSettle();
      expect(container.read(settingsProvider).languageCode, 'en');
      await tester.tap(find.byKey(const ValueKey('settings-language')));
      await tester.pumpAndSettle();
      expect(container.read(settingsProvider).languageCode, 'km');
      expect(find.text('ការកំណត់'), findsWidgets);
      expect(find.text('ភាសា'), findsWidgets);
      final context = tester.element(
        find.byKey(const ValueKey('settings-language')),
      );
      expect(Localizations.localeOf(context).languageCode, 'km');
      expect(CupertinoLocalizations.of(context).copyButtonLabel, isNot('Copy'));
      expect(
        container.read(routerProvider).routeInformationProvider.value.uri.path,
        '/settings',
      );
      await Scrollable.ensureVisible(
        tester.element(find.byKey(const ValueKey('settings-language'))),
        alignment: .5,
      );
      await tester.pumpAndSettle();
      await tester.tap(find.text('ភាសាខ្មែរ'));
      await tester.pumpAndSettle();
      expect(container.read(settingsProvider).languageCode, 'km');
      await tester.tap(find.byKey(const ValueKey('settings-language')));
      await tester.pumpAndSettle();
      expect(find.text('Settings'), findsWidgets);
      expect(container.read(settingsRepositoryProvider).languageCode, 'en');
    },
  );

  testWidgets(
    'Language changes retain contact input and translate validation',
    (tester) async {
      final container = await harness.mountApp(tester, '/contact');
      Finder input(String key) => find.descendant(
        of: find.byKey(ValueKey(key)),
        matching: find.byType(CupertinoTextField),
      );
      await tester.ensureVisible(input('contact-name'));
      await tester.enterText(input('contact-name'), 'ដារ៉ា');
      await tester.ensureVisible(input('contact-email'));
      await tester.enterText(input('contact-email'), 'dara@example.com');
      await container.read(settingsProvider.notifier).setLanguage('km');
      await tester.pumpAndSettle();
      expect(
        tester
            .widget<CupertinoTextField>(input('contact-name'))
            .controller!
            .text,
        'ដារ៉ា',
      );
      expect(
        tester
            .widget<CupertinoTextField>(input('contact-email'))
            .controller!
            .text,
        'dara@example.com',
      );
      expect(
        tester.widget<CupertinoTextField>(input('contact-message')).placeholder,
        'ប្រាប់ខ្ញុំអំពីគម្រោងរបស់អ្នក…',
      );
      tester.testTextInput.hide();
      await Scrollable.ensureVisible(
        tester.element(find.text('ផ្ញើ')),
        alignment: .5,
      );
      await tester.pumpAndSettle();
      await tester.tap(find.text('ផ្ញើ'));
      await tester.pumpAndSettle();
      expect(find.text('សូមបញ្ចូលលេខទូរសព្ទរបស់អ្នក។'), findsOneWidget);
      expect(find.text('សូមបញ្ចូលសារ។'), findsOneWidget);
      await container.read(settingsProvider.notifier).setLanguage('en');
      await tester.pumpAndSettle();
      expect(find.text('Please enter a message.'), findsOneWidget);
    },
  );

  testWidgets('Project filters work in Khmer and survive changing to English', (
    tester,
  ) async {
    final container = await harness.mountApp(
      tester,
      '/projects',
      savedPreferences: {'language': 'km', 'animations': false},
    );
    await tester.tap(find.text('ផលិតភាព').first);
    await tester.pumpAndSettle();
    expect(find.text('កម្មវិធីកំណត់ត្រា'), findsOneWidget);
    expect(find.text('កម្មវិធីទិញទំនិញ'), findsNothing);
    expect(find.text('1 គម្រោង'), findsOneWidget);
    await container.read(settingsProvider.notifier).setLanguage('en');
    await tester.pumpAndSettle();
    expect(find.text('Notes App'), findsOneWidget);
    expect(find.text('E-commerce App'), findsNothing);
  });

  for (final size in [
    const Size(320, 700),
    const Size(834, 1194),
    const Size(1440, 1000),
  ]) {
    testWidgets('All Khmer routes lay out in both themes at $size', (
      tester,
    ) async {
      final container = await harness.mountApp(
        tester,
        '/home',
        size: size,
        scale: size.width == 320 ? 2 : 1,
        savedPreferences: {'language': 'km', 'animations': false},
      );
      for (final theme in [ThemeMode.light, ThemeMode.dark]) {
        await container.read(settingsProvider.notifier).setTheme(theme);
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
          expect(
            tester.takeException(),
            isNull,
            reason: '$route, $theme, $size',
          );
          expect(
            Localizations.localeOf(
              tester.element(find.byType(CupertinoPageScaffold).last),
            ).languageCode,
            'km',
          );
        }
      }
    });
  }

  testWidgets(
    'Capture Khmer previews',
    (tester) async {
      final container = await harness.mountApp(
        tester,
        '/settings',
        savedPreferences: {'language': 'km', 'animations': false},
      );
      await tester.runAsync(() async {
        await (FontLoader(
          'NotoSansKhmer',
        )..addFont(rootBundle.load('assets/fonts/NotoSansKhmer.ttf'))).load();
        await (FontLoader('packages/cupertino_icons/CupertinoIcons')..addFont(
              rootBundle.load(
                'packages/cupertino_icons/assets/CupertinoIcons.ttf',
              ),
            ))
            .load();
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
      for (final mode in [ThemeMode.light, ThemeMode.dark]) {
        await container.read(settingsProvider.notifier).setTheme(mode);
        for (final route in [
          '/home',
          '/projects',
          '/about',
          '/skills',
          '/experience',
          '/resume',
          '/contact',
          '/settings',
        ]) {
          container.read(routerProvider).go(route);
          await tester.pumpAndSettle();
          final boundary = tester.renderObject<RenderRepaintBoundary>(
            find.byKey(const ValueKey('portfolio-capture')),
          );
          await tester.runAsync(() async {
            final capture = await boundary.toImage();
            final bytes = await capture.toByteData(
              format: ui.ImageByteFormat.png,
            );
            await File(
              'docs/previews/${route.substring(1)}-khmer-${mode.name}.png',
            ).writeAsBytes(bytes!.buffer.asUint8List());
            capture.dispose();
          });
        }
        for (final language in ['en', 'km']) {
          await container.read(settingsProvider.notifier).setLanguage(language);
          container.read(routerProvider).go('/projects');
          await tester.pumpAndSettle();
          final boundary = tester.renderObject<RenderRepaintBoundary>(
            find.byKey(const ValueKey('portfolio-capture')),
          );
          await tester.runAsync(() async {
            final capture = await boundary.toImage();
            final bytes = await capture.toByteData(
              format: ui.ImageByteFormat.png,
            );
            await File(
              'docs/previews/language-button-$language-${mode.name}.png',
            ).writeAsBytes(bytes!.buffer.asUint8List());
            capture.dispose();
          });
        }
      }
    },
    skip: !const bool.fromEnvironment('CAPTURE_PREVIEWS'),
  );
}
