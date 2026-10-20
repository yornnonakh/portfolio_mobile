import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/localization/app_localizations.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/design_system/components.dart';
import '../../../core/widgets/profile_avatar.dart';
import '../../../core/widgets/language_flag.dart';
import '../../../shared/providers/portfolio_providers.dart';
import '../application/settings_view_model.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);
    final viewModel = ref.read(settingsProvider.notifier);
    final profile = ref.watch(portfolioProvider).profile;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return PageContent(
      children: [
        const PageHeader(eyebrow: 'Settings', title: 'Settings'),
        IosGroupedList(
          children: [
            CupertinoButton(
              padding: const EdgeInsets.all(15),
              onPressed: () => context.go('/about'),
              child: Row(
                children: [
                  ProfileAvatar(profile: profile, size: 60),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        AppText(
                          profile.name,
                          style: Theme.of(context).textTheme.titleLarge
                              ?.copyWith(fontWeight: FontWeight.w600),
                        ),
                        const SizedBox(height: 2),
                        AppText(
                          profile.title,
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(
                                color: Theme.of(context).colorScheme.primary,
                              ),
                        ),
                        const SizedBox(height: 2),
                        MutedText(profile.email),
                      ],
                    ),
                  ),
                  const SizedBox(width: 10),
                  Icon(
                    CupertinoIcons.chevron_right,
                    size: 15,
                    color: Theme.of(
                      context,
                    ).colorScheme.onSurfaceVariant.withValues(alpha: .6),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),
        const Eyebrow('Language'),
        const SizedBox(height: 8),
        IosGroupedList(
          children: [
            _SettingsToggleRow(
              switchKey: const ValueKey('settings-language'),
              leading: LanguageFlag(languageCode: settings.languageCode),
              title: 'Language',
              subtitle: AppTranslations.languageNames[settings.languageCode],
              value: settings.languageCode == 'km',
              onChanged: settings.saving
                  ? null
                  : (useKhmer) => viewModel.setLanguage(useKhmer ? 'km' : 'en'),
            ),
          ],
        ),
        const SizedBox(height: 8),
        const MutedText(
          'Off for English. On for Khmer.',
        ),
        const SizedBox(height: 24),
        const Eyebrow('APPEARANCE'),
        const SizedBox(height: 8),
        IosGroupedList(
          children: [
            _SettingsToggleRow(
              switchKey: const ValueKey('settings-system-theme'),
              leading: const IconTile(CupertinoIcons.device_phone_portrait),
              title: 'Follow system',
              value: settings.themeMode == ThemeMode.system,
              onChanged: settings.saving
                  ? null
                  : (followSystem) => viewModel.setTheme(
                      followSystem
                          ? ThemeMode.system
                          : isDark
                          ? ThemeMode.dark
                          : ThemeMode.light,
                    ),
            ),
            _SettingsToggleRow(
              switchKey: const ValueKey('settings-dark-mode'),
              leading: const IconTile(CupertinoIcons.moon_fill),
              title: 'Dark mode',
              subtitle: isDark ? 'Dark' : 'Light',
              value: isDark,
              onChanged: settings.saving
                  ? null
                  : (dark) => viewModel.setTheme(
                      dark ? ThemeMode.dark : ThemeMode.light,
                    ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        const MutedText(
          'Turn Dark mode off for light mode. Follow system matches your device automatically.',
        ),
        const SizedBox(height: 24),
        const Eyebrow('MOTION'),
        const SizedBox(height: 8),
        IosGroupedList(
          children: [
            _SettingsToggleRow(
              switchKey: const ValueKey('settings-motion'),
              leading: const IconTile(CupertinoIcons.sparkles),
              title: 'Interface animations',
              value: settings.animations,
              onChanged: settings.saving ? null : viewModel.setAnimations,
            ),
          ],
        ),
        const SizedBox(height: 8),
        const MutedText(
          'Subtle transitions. Your device’s Reduce Motion setting always takes priority.',
        ),
        if (settings.error != null) ...[
          const SizedBox(height: 16),
          Semantics(
            liveRegion: true,
            child: AppText(
              settings.error!,
              style: TextStyle(color: Theme.of(context).colorScheme.error),
            ),
          ),
        ],
        const SizedBox(height: 24),
        const Eyebrow('ABOUT'),
        const SizedBox(height: 8),
        IosGroupedList(
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  const IconTile(CupertinoIcons.info_circle_fill),
                  const SizedBox(width: 14),
                  Expanded(
                    child: AppText(
                      'Version',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  const MutedText(AppConstants.version),
                ],
              ),
            ),
            IosActionRow(
              icon: CupertinoIcons.doc_text_fill,
              title: 'Open source licenses',
              onPressed: () => context.push('/licenses'),
            ),
          ],
        ),
        const SizedBox(height: 8),
        const MutedText('Built with Flutter. Preferences stay on this device.'),
      ],
    );
  }
}

class _SettingsToggleRow extends StatelessWidget {
  const _SettingsToggleRow({
    required this.switchKey,
    required this.leading,
    required this.title,
    this.subtitle,
    required this.value,
    required this.onChanged,
  });

  final Key switchKey;
  final Widget leading;
  final String title;
  final String? subtitle;
  final bool value;
  final ValueChanged<bool>? onChanged;

  @override
  Widget build(BuildContext context) {
    final label = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppText(
          title,
          style: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w400),
        ),
        if (subtitle != null) ...[
          const SizedBox(height: 4),
          MutedText(subtitle!),
        ],
      ],
    );
    return MergeSemantics(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            leading,
            const SizedBox(width: 14),
            Expanded(
              child: label,
            ),
            const SizedBox(width: 12),
            CupertinoSwitch(
              key: switchKey,
              value: value,
              activeTrackColor: CupertinoColors.systemGreen,
              onChanged: onChanged,
            ),
          ],
        ),
      ),
    );
  }
}
