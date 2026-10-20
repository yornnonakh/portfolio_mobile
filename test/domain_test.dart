import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:portfolio_mobile/core/services/cv_service.dart';
import 'package:portfolio_mobile/core/services/link_service.dart';
import 'package:portfolio_mobile/core/services/settings_repository.dart';
import 'package:portfolio_mobile/features/projects/application/projects_view_model.dart';
import 'package:portfolio_mobile/features/settings/application/settings_view_model.dart';
import 'package:portfolio_mobile/shared/data/portfolio_repository.dart';

class TestBundle extends CachingAssetBundle {
  TestBundle(this.bytes);
  final Uint8List? bytes;
  @override
  Future<ByteData> load(String key) async {
    if (bytes == null) throw FlutterError('Asset not found');
    return ByteData.sublistView(bytes!);
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  test('Local data preserves CV facts and omits unverified links', () {
    final data = const LocalPortfolioRepository().load();
    expect(data.profile.name, 'Yorn Nona');
    expect(data.profile.experience, '6 months');
    expect(data.projects, hasLength(2));
    expect(data.profile.linkedIn, isNull);
    expect(data.profile.telegramUrl, isNull);
    expect(
      data.projects.every(
        (p) =>
            p.repositoryUrl == null &&
            p.appStoreUrl == null &&
            p.screenshots.isEmpty,
      ),
      isTrue,
    );
    expect(
      data.experiences[0].organization,
      'Flutter Mobile Application Projects',
    );
    expect(data.experiences[1].organization, 'Addbook Computer Center');
  });

  test('Filters select real categories and ignore invalid values', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);
    expect(container.read(filteredProjectsProvider), hasLength(2));
    container.read(projectFilterProvider.notifier).select('E-commerce');
    expect(container.read(filteredProjectsProvider).single.id, 'products');
    container.read(projectFilterProvider.notifier).select('Invented');
    expect(container.read(projectFilterProvider), 'E-commerce');
    expect(container.read(projectProvider('missing')), isNull);
  });

  test(
    'Email, phone and verified GitHub actions produce correct URIs',
    () async {
      final calls = <Uri>[];
      final service = LinkService(
        launcher: (uri) async {
          calls.add(uri);
          return true;
        },
      );
      final profile = const LocalPortfolioRepository().load().profile;
      expect((await service.email(profile.email)).succeeded, isTrue);
      expect((await service.phone(profile.phoneUri)).succeeded, isTrue);
      expect((await service.website(profile.github)).succeeded, isTrue);
      expect(calls.map((u) => u.scheme), ['mailto', 'tel', 'https']);
      expect(calls[0].path, profile.email);
      expect(calls[1].path, '+855968093758');
      expect(calls[2].host, 'github.com');
      expect((await service.website('javascript:alert(1)')).succeeded, isFalse);
      expect((await service.website(null)).succeeded, isFalse);
      expect(calls, hasLength(3));
    },
  );

  test('Unavailable URL handlers produce recoverable feedback', () async {
    final service = LinkService(launcher: (_) async => false);
    final result = await service.email('example@example.com');
    expect(result.succeeded, isFalse);
    expect(result.message, contains('Could not open email or Gmail'));
    final broken = LinkService(
      launcher: (_) async => throw PlatformException(code: 'missing'),
    );
    expect((await broken.phone('+855968093758')).succeeded, isFalse);
  });

  test('Missing, valid and invalid CV assets are distinguished', () async {
    expect(await CvService(TestBundle(null)).load('cv.pdf'), isNull);
    final bytes = Uint8List.fromList(utf8.encode('%PDF-1.4\nTest fixture'));
    expect(await CvService(TestBundle(bytes)).load('cv.pdf'), bytes);
    final invalid = CvService(TestBundle(Uint8List.fromList([1, 2, 3])));
    expect(() => invalid.load('cv.pdf'), throwsFormatException);
  });

  test(
    'Storage failures preserve current settings and report feedback',
    () async {
      final container = ProviderContainer(
        overrides: [
          settingsRepositoryProvider.overrideWithValue(
            SettingsRepository(null),
          ),
        ],
      );
      addTearDown(container.dispose);
      await container.read(settingsProvider.notifier).setTheme(ThemeMode.dark);
      expect(container.read(settingsProvider).themeMode, ThemeMode.system);
      expect(container.read(settingsProvider).saving, isFalse);
      expect(container.read(settingsProvider).error, isNotNull);
    },
  );
}
