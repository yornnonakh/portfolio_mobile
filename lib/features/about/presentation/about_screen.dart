import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import '../../../core/localization/app_localizations.dart';
import '../../../core/design_system/components.dart';
import '../../../core/services/analytics_service.dart';
import '../../../core/widgets/profile_avatar.dart';
import '../../../shared/models/portfolio.dart';
import '../../../shared/providers/portfolio_providers.dart';

class AboutScreen extends ConsumerWidget {
  const AboutScreen({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final data = ref.watch(portfolioProvider);
    final profile = data.profile;
    return PageContent(
      children: [
        const PageHeader(
          eyebrow: 'About',
          title: 'About me',
          description:
              "I'm Yorn Nona  a Mobile engineer. I enjoy designing clean architectures and solving complex engineering problems",
        ),
        SurfaceCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              ProfileAvatar(profile: profile, size: 90),
              const SizedBox(height: 16),
              AppText(
                profile.name,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              const SizedBox(height: 4),
              AppText(
                profile.title,
                textAlign: TextAlign.center,
                style: TextStyle(color: Theme.of(context).colorScheme.primary),
              ),
              const SizedBox(height: 4),
              MutedText(profile.location),
              const SizedBox(height: 20),
              AppText(
                profile.summary,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyLarge,
              ),
            ],
          ),
        ),
        const SizedBox(height: 36),
        const SectionHeading('How I got here'),
        MutedText(data.journey, large: true),
        const SizedBox(height: 26),
        SurfaceCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                CupertinoIcons.book_fill,
                color: Theme.of(context).colorScheme.primary,
                size: 24,
              ),
              const SizedBox(height: 12),
              AppText(
                'Education & Training',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 16),
              for (final edu in data.educations) ...[
                AppText(
                  edu.program,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 4),
                MutedText(edu.institute),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    TechBadge(edu.period),
                    TechBadge(edu.status, accent: true),
                  ],
                ),
                if (edu != data.educations.last) const Divider(height: 24),
              ],
            ],
          ),
        ),
        if (data.programmingLanguages.isNotEmpty) ...[
          const SizedBox(height: 36),
          const SectionHeading('Programming Languages'),
          SurfaceCard(
            child: Column(
              children: [
                for (var i = 0; i < data.programmingLanguages.length; i++) ...[
                  _ProgrammingLanguageRow(
                    language: _ProgrammingLanguageUiModel.fromDomain(
                      data.programmingLanguages[i],
                    ),
                  ),
                  if (i < data.programmingLanguages.length - 1)
                    const SizedBox(height: 18),
                ],
              ],
            ),
          ),
        ],
        const SizedBox(height: 36),
        SectionHeading(
          'What I bring',
          action: 'All skills',
          onAction: () {
            ref.read(analyticsServiceProvider).trackEvent('explore_skills_clicked');
            context.push('/skills');
          },
        ),
        SurfaceCard(child: BulletList(data.skills.last.skills, checks: true)),
        const SizedBox(height: 36),
        SectionHeading(
          'Experience',
          action: 'Full timeline',
          onAction: () {
            ref.read(analyticsServiceProvider).trackEvent('full_timeline_clicked');
            context.push('/experience');
          },
        ),
        for (final experience in data.experiences)
          Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: SurfaceCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Eyebrow(experience.period),
                  const SizedBox(height: 10),
                  AppText(
                    experience.title,
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 6),
                  MutedText(experience.organization),
                ],
              ),
            ),
          ),
        const SizedBox(height: 12),
        IosButton.tinted(
          onPressed: () {
            ref.read(analyticsServiceProvider).trackEvent('view_resume_clicked');
            context.push('/resume');
          },
          icon: const LiquidGlassIcon(CupertinoIcons.doc_text, size: 18),
          label: const AppText('View resume'),
        ),
      ],
    );
  }
}

class _ProgrammingLanguageUiModel {
  const _ProgrammingLanguageUiModel({
    required this.name,
    required this.proficiency,
    required this.percentage,
    required this.color,
    required this.assetPath,
  });

  final String name;
  final double proficiency;
  final String percentage;
  final Color color;
  final String assetPath;

  static _ProgrammingLanguageUiModel fromDomain(ProgrammingLanguage lang) {
    final lower = lang.name.toLowerCase();
    return _ProgrammingLanguageUiModel(
      name: lang.name,
      proficiency: lang.proficiency,
      percentage: lang.percentage,
      color: switch (lower) {
        'dart' => const Color(0xFF0175C2),
        'kotlin' => const Color(0xFF7F52FF),
        'java' => const Color(0xFFF89820),
        'swift' => const Color(0xFFF05138),
        _ => const Color(0xFF007AFF),
      },
      assetPath: 'assets/icons/tools/$lower.svg',
    );
  }
}

class _ProgrammingLanguageRow extends StatelessWidget {
  const _ProgrammingLanguageRow({required this.language});
  final _ProgrammingLanguageUiModel language;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 38,
              height: 38,
              padding: const EdgeInsets.all(7),
              decoration: BoxDecoration(
                color: language.color.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: language.color.withValues(alpha: 0.25),
                  width: 1,
                ),
              ),
              child: SvgPicture.asset(
                language.assetPath,
                width: 24,
                height: 24,
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
        ),
        const SizedBox(height: 10),
        ClipRRect(
          borderRadius: BorderRadius.circular(6),
          child: LinearProgressIndicator(
            value: language.proficiency,
            minHeight: 8,
            backgroundColor:
                theme.colorScheme.onSurface.withValues(alpha: 0.08),
            valueColor: AlwaysStoppedAnimation<Color>(language.color),
          ),
        ),
      ],
    );
  }
}
