import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../features/settings/application/settings_view_model.dart';
import '../localization/app_localizations.dart';
import '../services/link_service.dart';
import '../utils/action_feedback.dart';
import 'language_flag.dart';

class LanguageButton extends ConsumerWidget {
  const LanguageButton({super.key});

  Future<void> _toggleLanguage(BuildContext context, WidgetRef ref) async {
    final settings = ref.read(settingsProvider);
    if (settings.saving) return;
    await ref
        .read(settingsProvider.notifier)
        .setLanguage(settings.languageCode == 'en' ? 'km' : 'en');
    if (!context.mounted) return;
    final error = ref.read(settingsProvider).error;
    if (error != null) {
      await performAction(context, () async => ActionResult(false, error));
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);
    final isKhmer = settings.languageCode == 'km';
    return Semantics(
      key: const ValueKey('language-button'),
      label: context.tr('Language'),
      value: AppTranslations.languageNames[settings.languageCode],
      hint: context.tr(isKhmer ? 'Switch to English' : 'Switch to Khmer'),
      button: true,
      child: CupertinoButton(
        padding: const EdgeInsets.symmetric(horizontal: 4),
        minimumSize: const Size(44, 44),
        onPressed: settings.saving ? null : () => _toggleLanguage(context, ref),
        child: ExcludeSemantics(
          child: MediaQuery.withNoTextScaling(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                LanguageFlag(
                  languageCode: settings.languageCode,
                  width: 22,
                  height: 16.5,
                ),
                const SizedBox(width: 6),
                Text(
                  isKhmer ? 'ខ្មែរ' : 'English',
                  style: CupertinoTheme.of(context).textTheme.navActionTextStyle
                      .copyWith(fontSize: 13, fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
