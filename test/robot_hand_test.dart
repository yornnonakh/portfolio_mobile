import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:portfolio_mobile/features/splash/presentation/splash_robot_scene.dart';
import 'package:portfolio_mobile/features/splash/presentation/waving_robot.dart';

void main() {
  testWidgets('Hand waves while the phone, face and body stay still', (
    tester,
  ) async {
    const dimension = 400;
    final angle = ValueNotifier(-.26);
    addTearDown(angle.dispose);
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Center(
            child: RepaintBoundary(
              key: const ValueKey('hand-capture'),
              child: SizedBox.square(
                dimension: dimension.toDouble(),
                child: ValueListenableBuilder<double>(
                  valueListenable: angle,
                  builder: (context, value, _) => WavingRobot(
                    asset: SplashRobotScene.asset,
                    handAngle: value,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
    await tester.runAsync(
      () => precacheImage(
        const AssetImage(SplashRobotScene.asset),
        tester.element(find.byType(WavingRobot)),
      ),
    );
    await tester.pumpAndSettle();

    Future<Uint8List> pixels(String pose) async {
      final boundary = tester.renderObject<RenderRepaintBoundary>(
        find.byKey(const ValueKey('hand-capture')),
      );
      return (await tester.runAsync(() async {
        final image = await boundary.toImage(pixelRatio: 1);
        final data = await image.toByteData(format: ui.ImageByteFormat.rawRgba);
        if (const bool.fromEnvironment('CAPTURE_SPLASH_PREVIEWS')) {
          final png = await image.toByteData(format: ui.ImageByteFormat.png);
          await File(
            '/tmp/robot-hand-$pose.png',
          ).writeAsBytes(png!.buffer.asUint8List());
        }
        image.dispose();
        return data!.buffer.asUint8List();
      }))!;
    }

    final left = await pixels('left');
    angle.value = .26;
    await tester.pump();
    final right = await pixels('right');
    int changedPixels(Rect region) {
      var changed = 0;
      for (
        var y = (region.top * dimension).round();
        y < (region.bottom * dimension).round();
        y++
      ) {
        for (
          var x = (region.left * dimension).round();
          x < (region.right * dimension).round();
          x++
        ) {
          final offset = (y * dimension + x) * 4;
          for (var channel = 0; channel < 4; channel++) {
            if (left[offset + channel] != right[offset + channel]) {
              changed++;
              break;
            }
          }
        }
      }
      return changed;
    }

    expect(
      changedPixels(const Rect.fromLTRB(.15, .33, .32, .58)),
      0,
      reason: 'The phone stays steady.',
    );
    expect(
      changedPixels(const Rect.fromLTRB(.4, .18, .68, .4)),
      0,
      reason: 'The face stays steady.',
    );
    expect(
      changedPixels(const Rect.fromLTRB(.4, .55, .62, .75)),
      0,
      reason: 'The body stays steady.',
    );
    expect(
      changedPixels(const Rect.fromLTRB(.75, .34, .97, .6)),
      greaterThan(400),
      reason: 'The raised hand visibly changes pose.',
    );
    expect(tester.takeException(), isNull);
  });
}
