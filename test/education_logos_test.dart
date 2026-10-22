import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:portfolio_mobile/core/widgets/liquid_glass_container.dart';
import 'package:portfolio_mobile/features/about/presentation/about_screen.dart';
import 'package:portfolio_mobile/shared/data/portfolio_repository.dart';

import 'widget_test.dart' as harness;

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  final educations = const LocalPortfolioRepository().load().educations;

  test(
    'Each education logo has transparent corners and visible artwork',
    () async {
      expect(
        educations.map((education) => education.logoAsset).toSet(),
        hasLength(4),
      );
      for (final education in educations) {
        final asset = education.logoAsset!;
        final bytes = await rootBundle.load(asset);
        final codec = await ui.instantiateImageCodec(
          bytes.buffer.asUint8List(),
        );
        final frame = await codec.getNextFrame();
        final image = frame.image;
        try {
          final pixels = (await image.toByteData(
            format: ui.ImageByteFormat.rawRgba,
          ))!.buffer.asUint8List();
          for (final position in [
            0,
            image.width - 1,
            (image.height - 1) * image.width,
            image.height * image.width - 1,
          ]) {
            expect(
              pixels[position * 4 + 3],
              0,
              reason: '$asset has an opaque corner',
            );
          }
          var hasArtwork = false;
          for (var index = 3; index < pixels.length; index += 4) {
            if (pixels[index] != 0) {
              hasArtwork = true;
              break;
            }
          }
          expect(hasArtwork, isTrue, reason: '$asset is empty');
        } finally {
          image.dispose();
          codec.dispose();
        }
      }
    },
  );

  for (final configuration in [
    (const Size(320, 700), 2.0, 'dark', 'km'),
    (const Size(390, 844), 1.0, 'light', 'en'),
    (const Size(834, 1194), 1.0, 'light', 'km'),
    (const Size(1440, 1000), 1.0, 'dark', 'en'),
  ]) {
    testWidgets('Education logos render and fit at $configuration', (
      tester,
    ) async {
      await harness.mountApp(
        tester,
        '/about',
        size: configuration.$1,
        scale: configuration.$2,
        savedPreferences: {
          'animations': false,
          'theme': configuration.$3,
          'language': configuration.$4,
        },
      );
      await tester.runAsync(() async {
        final context = tester.element(find.byType(AboutScreen));
        await Future.wait([
          for (final education in educations)
            precacheImage(AssetImage(education.logoAsset!), context),
        ]);
      });
      await tester.pump();
      for (final education in educations) {
        final logo = find.byKey(
          ValueKey('education-logo-${education.institute}'),
        );
        expect(tester.widget(logo), isA<LiquidGlassContainer>());
        final image = tester.widget<RawImage>(
          find.descendant(of: logo, matching: find.byType(RawImage)),
        );
        expect(image.image, isNotNull, reason: education.logoAsset);
        final rect = tester.getRect(logo);
        expect(rect.left, greaterThanOrEqualTo(0));
        expect(rect.right, lessThanOrEqualTo(configuration.$1.width));
      }
      expect(tester.takeException(), isNull);
    });
  }
}
