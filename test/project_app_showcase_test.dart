import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/cupertino.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

import 'widget_test.dart' as harness;

void main() {
  testWidgets('Unreleased stores stay disabled below the phone preview', (
    tester,
  ) async {
    await harness.mountApp(
      tester,
      '/projects/products',
      savedPreferences: {'animations': false},
    );
    for (final store in ['project-google-play', 'project-app-store']) {
      final button = find.descendant(
        of: find.byKey(ValueKey(store)),
        matching: find.byType(CupertinoButton),
      );
      expect(tester.widget<CupertinoButton>(button).onPressed, isNull);
    }
    expect(find.text('Coming soon'), findsNWidgets(2));
    expect(tester.takeException(), isNull);
  });

  testWidgets(
    'Capture project detail previews',
    (tester) async {
      await tester.runAsync(() async {
        final fonts = FontLoader('Poppins');
        for (final weight in [
          'Regular',
          'Medium',
          'SemiBold',
          'Bold',
          'ExtraBold',
        ]) {
          fonts.addFont(rootBundle.load('assets/fonts/Poppins-$weight.ttf'));
        }
        await fonts.load();
        await (FontLoader(
          'MaterialIcons',
        )..addFont(rootBundle.load('fonts/MaterialIcons-Regular.otf'))).load();
        await (FontLoader('packages/cupertino_icons/CupertinoIcons')..addFont(
              rootBundle.load(
                'packages/cupertino_icons/assets/CupertinoIcons.ttf',
              ),
            ))
            .load();
      });
      for (final (name, size, theme) in [
        ('mobile-light', const Size(390, 1320), 'light'),
        ('mobile-dark', const Size(390, 1320), 'dark'),
        ('desktop-light', const Size(1440, 1400), 'light'),
      ]) {
        await harness.mountApp(
          tester,
          '/projects/products',
          size: size,
          savedPreferences: {'animations': false, 'theme': theme},
        );
        expect(tester.takeException(), isNull);
        final boundary = tester.renderObject<RenderRepaintBoundary>(
          find.byKey(const ValueKey('portfolio-capture')),
        );
        await tester.runAsync(() async {
          final image = await boundary.toImage();
          final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
          await File(
            '/private/tmp/project-detail-$name.png',
          ).writeAsBytes(bytes!.buffer.asUint8List());
          image.dispose();
        });
      }
    },
    skip: !const bool.fromEnvironment('CAPTURE_PROJECT_PREVIEWS'),
  );
}
