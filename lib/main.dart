import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'app/app.dart';
import 'core/services/settings_repository.dart';
import 'features/settings/application/settings_view_model.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  GoogleFonts.config.allowRuntimeFetching = false;
  SharedPreferences? preferences;
  try {
    preferences = await SharedPreferences.getInstance();
  } catch (error) {
    debugPrint('Preferences unavailable; using session defaults: $error');
  }
  LicenseRegistry.addLicense(() async* {
    yield LicenseEntryWithLineBreaks([
      'Inter',
    ], await rootBundle.loadString('assets/fonts/OFL.txt'));
  });
  LicenseRegistry.addLicense(() async* {
    yield LicenseEntryWithLineBreaks([
//www.pinterest.com/pin/472737292154502425/      'Poppins',
    ], await rootBundle.loadString('assets/fonts/Poppins-OFL.txt'));
  });
  LicenseRegistry.addLicense(() async* {
    yield LicenseEntryWithLineBreaks([
      'Noto Sans Khmer',
    ], await rootBundle.loadString('assets/fonts/NotoSansKhmer-OFL.txt'));
  });
  LicenseRegistry.addLicense(() async* {
    yield LicenseEntryWithLineBreaks([
      'flag-icons',
    ], await rootBundle.loadString('assets/icons/flags/LICENSE.txt'));
  });
  runApp(
    ProviderScope(
      overrides: [
        settingsRepositoryProvider.overrideWithValue(
          SettingsRepository(preferences),
        ),
      ],
      child: const PortfolioApp(),
    ),
  );
}
