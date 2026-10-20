import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/localization/app_localizations.dart';
import '../../../core/design_system/components.dart';
import '../../../shared/providers/portfolio_providers.dart';

class SkillsScreen extends ConsumerWidget {
  const SkillsScreen({super.key});
  static const _icons = {
    'mobile': CupertinoIcons.device_phone_portrait,
    'state': CupertinoIcons.layers_fill,
    'api': CupertinoIcons.chevron_left_slash_chevron_right,
    'architecture': CupertinoIcons.square_stack_3d_up_fill,
    'tools': CupertinoIcons.hammer_fill,
    'people': CupertinoIcons.person_2_fill,
  };

  @override
  Widget build(BuildContext context, WidgetRef ref) => PageContent(
    children: [
      const PageHeader(
        eyebrow: 'Skills',
        title: 'Skills',
        description:
            'The technologies and practical skills behind my mobile work.',
      ),
      ResponsiveGrid(
        minimumWidth: 330,
        children: [
          for (final category in ref.watch(portfolioProvider).skills)
            IosGroupedList(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      IconTile(
                        _icons[category.symbol] ??
                            CupertinoIcons.chevron_left_slash_chevron_right,
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: AppText(
                          category.name,
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                      ),
                    ],
                  ),
                ),
                for (final skill in category.skills)
                  Padding(
                    padding: const EdgeInsets.fromLTRB(64, 14, 16, 14),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: AppText(
                        skill,
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),
                    ),
                  ),
              ],
            ),
        ],
      ),
    ],
  );
}
