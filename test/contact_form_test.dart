import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:portfolio_mobile/app/theme/app_theme.dart';
import 'package:portfolio_mobile/core/services/link_service.dart';
import 'package:portfolio_mobile/features/contact/domain/contact_message.dart';
import 'package:portfolio_mobile/features/contact/presentation/contact_form.dart';

Future<void> mountForm(
  WidgetTester tester,
  LinkService service, {
  Brightness brightness = Brightness.light,
  Size size = const Size(390, 844),
}) async {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
  final theme = brightness == Brightness.dark ? AppTheme.dark : AppTheme.light;
  await tester.pumpWidget(
    ProviderScope(
      overrides: [linkServiceProvider.overrideWithValue(service)],
      child: CupertinoApp(
        theme: MaterialBasedCupertinoThemeData(materialTheme: theme),
        home: Theme(
          data: theme,
          child: DefaultTextStyle(
            style: theme.textTheme.bodyLarge!,
            child: CupertinoPageScaffold(
              child: SafeArea(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: const RepaintBoundary(
                    key: ValueKey('contact-form-preview'),
                    child: ContactForm(recipient: 'Yornnonaistad@gmail.com'),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

Finder input(String key) => find.descendant(
  of: find.byKey(ValueKey(key)),
  matching: find.byType(CupertinoTextField),
);

Future<void> fillForm(WidgetTester tester) async {
  for (final entry in {
    'contact-name': '  Dara & Team  ',
    'contact-email': '  dara+work@example.com  ',
    'contact-phone': '  +855 12 345 678  ',
    'contact-message':
        '  Hello Nona,\nCan we build an app for សួស្តី & friends?  ',
  }.entries) {
    await tester.ensureVisible(input(entry.key));
    await tester.enterText(input(entry.key), entry.value);
  }
  tester.testTextInput.hide();
  await tester.ensureVisible(find.text('Send'));
  await tester.pumpAndSettle();
}

void main() {
  test('Contact form validates required and malformed inputs', () {
    expect(ContactMessage.validateName('  '), isNotNull);
    expect(ContactMessage.validateEmail('bad@'), isNotNull);
    expect(ContactMessage.validateEmail('bad name@example.com'), isNotNull);
    expect(ContactMessage.validatePhone('call me'), isNotNull);
    expect(ContactMessage.validateMessage('\n  '), isNotNull);
    expect(ContactMessage.validateEmail('dara+work@example.com'), isNull);
    expect(ContactMessage.validatePhone('+855 (12) 345-678'), isNull);
    expect(ContactMessage.validateName('ដារ៉ា'), isNull);
  });

  testWidgets('Empty form displays errors without opening an email app', (
    tester,
  ) async {
    final calls = <Uri>[];
    await mountForm(
      tester,
      LinkService(
        launcher: (uri) async {
          calls.add(uri);
          return true;
        },
      ),
    );
    await tester.ensureVisible(find.text('Send'));
    await tester.tap(find.text('Send'));
    await tester.pumpAndSettle();
    expect(find.text('Please enter your name.'), findsOneWidget);
    expect(find.text('Please enter your email.'), findsOneWidget);
    expect(find.text('Please enter your phone number.'), findsOneWidget);
    expect(find.text('Please enter a message.'), findsOneWidget);
    expect(calls, isEmpty);
    expect(tester.takeException(), isNull);
  });

  for (final opened in [true, false]) {
    testWidgets(
      'Form includes every detail and retains input when email app ${opened ? 'opens' : 'fails'}',
      (tester) async {
        final calls = <Uri>[];
        await mountForm(
          tester,
          LinkService(
            launcher: (uri) async {
              calls.add(uri);
              return opened;
            },
          ),
        );
        await fillForm(tester);
        await tester.tap(find.text('Send'));
        await tester.pumpAndSettle();
        expect(calls, hasLength(opened ? 1 : 2));
        final uri = calls.first;
        if (!opened) {
          expect(calls.last.host, 'mail.google.com');
          expect(calls.last.queryParameters['to'], uri.path);
          expect(
            calls.last.queryParameters['su'],
            uri.queryParameters['subject'],
          );
          expect(
            calls.last.queryParameters['body'],
            uri.queryParameters['body'],
          );
          expect(find.text('Copy message'), findsOneWidget);
        }
        expect(uri.scheme, 'mailto');
        expect(uri.path, 'Yornnonaistad@gmail.com');
        expect(
          uri.queryParameters['subject'],
          'Portfolio contact from Dara & Team',
        );
        expect(
          uri.queryParameters['body'],
          'New message from your portfolio\n\nName: Dara & Team\nEmail: dara+work@example.com\nPhone: +855 12 345 678\n\nMessage:\nHello Nona,\nCan we build an app for សួស្តី & friends?',
        );
        expect(uri.query, contains('%20'));
        expect(
          tester
              .widget<CupertinoTextField>(input('contact-email'))
              .controller!
              .text,
          '  dara+work@example.com  ',
        );
        expect(
          find.textContaining(
            opened ? 'Email draft opened.' : 'Could not open email or Gmail.',
          ),
          findsOneWidget,
        );
        expect(find.text('Message sent'), findsNothing);
        expect(tester.takeException(), isNull);
      },
    );
  }

  testWidgets('Missing mail app falls back to Gmail with every detail', (
    tester,
  ) async {
    final calls = <Uri>[];
    await mountForm(
      tester,
      LinkService(
        launcher: (uri) async {
          calls.add(uri);
          if (uri.scheme == 'mailto') {
            throw PlatformException(code: 'no_handler');
          }
          return true;
        },
      ),
    );
    await fillForm(tester);
    await tester.tap(find.text('Send'));
    await tester.pumpAndSettle();
    expect(calls.map((uri) => uri.scheme), ['mailto', 'https']);
    expect(calls.last.host, 'mail.google.com');
    expect(calls.last.queryParameters['to'], 'Yornnonaistad@gmail.com');
    expect(
      calls.last.queryParameters['su'],
      calls.first.queryParameters['subject'],
    );
    expect(
      calls.last.queryParameters['body'],
      calls.first.queryParameters['body'],
    );
    expect(
      find.textContaining('Gmail opened in your browser.'),
      findsOneWidget,
    );
    expect(find.text('Copy message'), findsNothing);
  });

  testWidgets(
    'Browser send opens Gmail directly without needing a mail handler',
    (tester) async {
      final calls = <Uri>[];
      await mountForm(
        tester,
        LinkService(
          preferWebMail: true,
          launcher: (uri) async {
            calls.add(uri);
            return true;
          },
        ),
      );
      await fillForm(tester);
      await tester.tap(find.text('Send'));
      await tester.pumpAndSettle();
      expect(calls, hasLength(1));
      expect(calls.single.scheme, 'https');
      expect(calls.single.host, 'mail.google.com');
      expect(
        calls.single.queryParameters['body'],
        contains('សួស្តី & friends?'),
      );
      expect(
        calls.single.queryParameters['body'],
        contains('dara+work@example.com'),
      );
      expect(
        find.textContaining('Gmail opened in your browser.'),
        findsOneWidget,
      );
    },
  );

  testWidgets(
    'Gmail button is available if a mail handler silently does nothing',
    (tester) async {
      final calls = <Uri>[];
      await mountForm(
        tester,
        LinkService(
          launcher: (uri) async {
            calls.add(uri);
            return true;
          },
        ),
      );
      await fillForm(tester);
      await tester.ensureVisible(find.text('Open in Gmail'));
      await tester.tap(find.text('Open in Gmail'));
      await tester.pumpAndSettle();
      expect(calls, hasLength(1));
      expect(calls.single.host, 'mail.google.com');
      expect(calls.single.queryParameters['to'], 'Yornnonaistad@gmail.com');
    },
  );

  testWidgets('Both launch failures allow copying the complete email', (
    tester,
  ) async {
    String? copied;
    tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
      SystemChannels.platform,
      (call) async {
        if (call.method == 'Clipboard.setData') {
          copied = (call.arguments as Map)['text'] as String;
        }
        return null;
      },
    );
    addTearDown(
      () => tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
        SystemChannels.platform,
        null,
      ),
    );
    await mountForm(tester, LinkService(launcher: (_) async => false));
    await fillForm(tester);
    await tester.tap(find.text('Send'));
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('Copy message'));
    await tester.tap(find.text('Copy message'));
    await tester.pumpAndSettle();
    expect(
      copied,
      startsWith(
        'To: Yornnonaistad@gmail.com\nSubject: Portfolio contact from Dara & Team',
      ),
    );
    expect(
      copied,
      contains('Email: dara+work@example.com\nPhone: +855 12 345 678'),
    );
    expect(copied, contains('សួស្តី & friends?'));
    expect(find.textContaining('Message copied.'), findsOneWidget);
    expect(
      tester
          .widget<CupertinoTextField>(input('contact-email'))
          .controller!
          .text,
      '  dara+work@example.com  ',
    );
  });

  testWidgets(
    'Capture contact form previews',
    (tester) async {
      await tester.runAsync(() async {
        final icons = FontLoader('packages/cupertino_icons/CupertinoIcons')
          ..addFont(
            rootBundle.load(
              'packages/cupertino_icons/assets/CupertinoIcons.ttf',
            ),
          );
        await icons.load();
        await (FontLoader(
          'NotoSansKhmer',
        )..addFont(rootBundle.load('assets/fonts/NotoSansKhmer.ttf'))).load();
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
      for (final brightness in [Brightness.light, Brightness.dark]) {
        await mountForm(
          tester,
          const LinkService(),
          brightness: brightness,
          size: const Size(390, 1100),
        );
        final boundary = tester.renderObject<RenderRepaintBoundary>(
          find.byKey(const ValueKey('contact-form-preview')),
        );
        await tester.runAsync(() async {
          final capture = await boundary.toImage();
          final bytes = await capture.toByteData(
            format: ui.ImageByteFormat.png,
          );
          await File(
            'docs/previews/contact-form-${brightness.name}.png',
          ).writeAsBytes(bytes!.buffer.asUint8List());
          capture.dispose();
        });
      }
    },
    skip: !const bool.fromEnvironment('CAPTURE_PREVIEWS'),
  );
}
