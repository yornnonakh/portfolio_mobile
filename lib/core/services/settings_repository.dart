import 'package:shared_preferences/shared_preferences.dart';

class SettingsRepository {
  SettingsRepository(this.preferences);
  final SharedPreferences? preferences;
  String get theme => preferences?.getString('theme') ?? 'system';
  bool get animations => preferences?.getBool('animations') ?? true;
  String get languageCode =>
      preferences?.getString('language') == 'km' ? 'km' : 'en';
  bool get canPersist => preferences != null;
  Future<void> saveTheme(String value) async {
    if (preferences == null || !await preferences!.setString('theme', value)) {
      throw StateError(
        'Could not save theme on this device. Please try again.',
      );
    }
  }

  Future<void> saveAnimations(bool value) async {
    if (preferences == null ||
        !await preferences!.setBool('animations', value)) {
      throw StateError('Could not save motion preferences. Please try again.');
    }
  }

  Future<void> saveLanguage(String value) async {
    if (!['en', 'km'].contains(value)) {
      throw ArgumentError.value(value, 'language');
    }
    if (preferences == null ||
        !await preferences!.setString('language', value)) {
      throw StateError(
        'Could not save language preferences. Please try again.',
      );
    }
  }
}
