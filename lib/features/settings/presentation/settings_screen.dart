import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/design_system/components.dart';
import '../../../core/widgets/profile_avatar.dart';
import '../../../shared/providers/portfolio_providers.dart';
import '../application/settings_view_model.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);
    final viewModel = ref.read(settingsProvider.notifier);
    final profile = ref.watch(portfolioProvider).profile;
    return PageContent(
      children: [
        const PageHeader(
          eyebrow: 'Settings',
          title: 'Settings',
          description: 'A few preferences to make this feel like home.',
        ),
        IosGroupedList(
          children: [
            CupertinoButton(
              padding: const EdgeInsets.all(16),
              onPressed: () => context.go('/about'),
              child: Row(
                children: [
                  ProfileAvatar(profile: profile, size: 60),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          profile.name,
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          profile.title,
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
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
                    color: Theme.of(context).colorScheme.onSurfaceVariant.withValues(alpha: .6),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),
        const Eyebrow('APPEARANCE'),
        const SizedBox(height: 8),
        IosGroupedList(
          children: [
            _ThemeModeRow(
              title: 'System (Default)',
              mode: ThemeMode.system,
              currentMode: settings.themeMode,
              onChanged: settings.saving ? (_) {} : viewModel.setTheme,
            ),
            _ThemeModeRow(
              title: 'Light',
              mode: ThemeMode.light,
              currentMode: settings.themeMode,
              onChanged: settings.saving ? (_) {} : viewModel.setTheme,
            ),
            _ThemeModeRow(
              title: 'Dark',
              mode: ThemeMode.dark,
              currentMode: settings.themeMode,
              onChanged: settings.saving ? (_) {} : viewModel.setTheme,
            ),
          ],
        ),
        const SizedBox(height: 8),
        const MutedText('System follows the appearance of your device by default.'),
        const SizedBox(height: 24),
        const Eyebrow('MOTION'),
        const SizedBox(height: 8),
        IosGroupedList(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                children: [
                  const IconTile(CupertinoIcons.sparkles),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Text(
                      'Interface animations',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  CupertinoSwitch(
                    value: settings.animations,
                    activeTrackColor: CupertinoColors.systemGreen,
                    onChanged: settings.saving ? null : viewModel.setAnimations,
                  ),
                ],
              ),
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
            child: Text(
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
                    child: Text(
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

class _ThemeModeRow extends StatelessWidget {
  const _ThemeModeRow({
    required this.title,
    required this.mode,
    required this.currentMode,
    required this.onChanged,
  });

  final String title;
  final ThemeMode mode;
  final ThemeMode currentMode;
  final ValueChanged<ThemeMode> onChanged;

  @override
  Widget build(BuildContext context) {
    final isSelected = mode == currentMode;
    return CupertinoButton(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      onPressed: () => onChanged(mode),
      child: Row(
        children: [
          Expanded(
            child: Text(
              title,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w400,
              ),
            ),
          ),
          if (isSelected)
            Icon(
              CupertinoIcons.checkmark_circle,
              size: 18,
              color: Theme.of(context).colorScheme.primary,
            ),
        ],
      ),
    );
  }
}
