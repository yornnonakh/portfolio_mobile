import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../../core/localization/app_localizations.dart';
import '../../../core/design_system/components.dart';
import '../../../shared/models/portfolio.dart';
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
  Widget build(BuildContext context, WidgetRef ref) {
    final data = ref.watch(portfolioProvider);
    return PageContent(
      children: [
        const PageHeader(
          eyebrow: 'Skills',
          title: 'Skills',
          description:
              'The technologies and practical skills behind my mobile work.',
        ),
        if (data.programmingLanguages.isNotEmpty) ...[
          SurfaceCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AppText(
                  'Programming Languages',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 16),
                for (var i = 0; i < data.programmingLanguages.length; i++) ...[
                  _SkillProgrammingLanguageRow(
                    language: data.programmingLanguages[i],
                  ),
                  if (i < data.programmingLanguages.length - 1)
                    const SizedBox(height: 16),
                ],
              ],
            ),
          ),
          const SizedBox(height: 24),
        ],
        ResponsiveGrid(
          minimumWidth: 330,
          children: [
            for (final category in data.skills)
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
}

class _SkillProgrammingLanguageRow extends StatelessWidget {
  const _SkillProgrammingLanguageRow({required this.language});
  final ProgrammingLanguage language;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final lower = language.name.toLowerCase();
    final color = switch (lower) {
      'dart' => const Color(0xFF0175C2),
      'kotlin' => const Color(0xFF7F52FF),
      'java' => const Color(0xFFF89820),
      'swift' => const Color(0xFFF05138),
      _ => const Color(0xFF007AFF),
    };
    final assetPath = 'assets/icons/tools/$lower.svg';

    return Row(
      children: [
        Container(
          width: 36,
          height: 36,
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: color.withValues(alpha: 0.25),
              width: 1,
            ),
          ),
          child: SvgPicture.asset(
            assetPath,
            width: 22,
            height: 22,
            excludeFromSemantics: true,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: AppText(
            language.name,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        TechBadge(
          language.percentage,
          accent: language.proficiency >= 0.7,
        ),
      ],
    );
  }
}
