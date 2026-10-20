import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/design_system/components.dart';
import '../application/settings_view_model.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);
    final viewModel = ref.read(settingsProvider.notifier);
    return PageContent(
      children: [
        const PageHeader(
          eyebrow: 'Settings',
          title: 'Settings',
          description: 'A few preferences to make this feel like home.',
        ),
        const Eyebrow('Appearance'),
        const SizedBox(height: 10),
        SurfaceCard(
          child: IosSelectionControl<ThemeMode>(
            items: const {
              ThemeMode.system: 'System',
              ThemeMode.light: 'Light',
              ThemeMode.dark: 'Dark',
            },
            value: settings.themeMode,
            onChanged: settings.saving ? null : viewModel.setTheme,
          ),
        ),
        const SizedBox(height: 10),
        const MutedText('System follows the appearance of your device.'),
        const SizedBox(height: 28),
        const Eyebrow('Motion'),
        const SizedBox(height: 10),
        SurfaceCard(
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
        const SizedBox(height: 10),
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
        const SizedBox(height: 28),
        const Eyebrow('About'),
        const SizedBox(height: 10),
        IosGroupedList(
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
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
              icon: CupertinoIcons.doc_text,
              title: 'Open source licenses',
              onPressed: () => context.push('/licenses'),
            ),
          ],
        ),
        const SizedBox(height: 16),
        const MutedText('Built with Flutter. Preferences stay on this device.'),
      ],
    );
  }
}
