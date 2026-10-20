import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/design_system/components.dart';
import '../../../core/widgets/profile_avatar.dart';
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
              'A Flutter developer in Phnom Penh, learning through hands-on work.',
        ),
        SurfaceCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Wrap(
                spacing: 20,
                runSpacing: 16,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  ProfileAvatar(profile: profile, size: 84),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        profile.name,
                        style: Theme.of(context).textTheme.headlineMedium,
                      ),
                      Text(
                        profile.title,
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      MutedText(profile.location),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Text(
                profile.summary,
                style: Theme.of(context).textTheme.bodyLarge,
              ),
            ],
          ),
        ),
        const SizedBox(height: 36),
        const SectionHeading('How I got here', eyebrow: 'My journey'),
        MutedText(data.journey, large: true),
        const SizedBox(height: 26),
        ResponsiveGrid(
          minimumWidth: 400,
          children: [
            SurfaceCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    CupertinoIcons.book,
                    color: Theme.of(context).colorScheme.primary,
                    size: 28,
                  ),
                  const SizedBox(height: 18),
                  const Eyebrow('Education'),
                  const SizedBox(height: 12),
                  Text(
                    data.education.program,
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 8),
                  MutedText(data.education.institute),
                  const SizedBox(height: 18),
                  Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children: [
                      TechBadge(data.education.period),
                      TechBadge(data.education.status, accent: true),
                    ],
                  ),
                ],
              ),
            ),
            SurfaceCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    CupertinoIcons.globe,
                    color: Theme.of(context).colorScheme.primary,
                    size: 28,
                  ),
                  const SizedBox(height: 18),
                  const Eyebrow('Communication'),
                  const SizedBox(height: 12),
                  Text(
                    'Languages',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 18),
                  for (final language in data.languages)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Wrap(
                        spacing: 16,
                        runSpacing: 8,
                        children: [
                          Text(
                            language.name,
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          TechBadge(language.proficiency),
                        ],
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 36),
        SectionHeading(
          'What I bring',
          action: 'All skills',
          onAction: () => context.push('/skills'),
        ),
        SurfaceCard(child: BulletList(data.skills.last.skills, checks: true)),
        const SizedBox(height: 36),
        SectionHeading(
          'Experience',
          action: 'Full timeline',
          onAction: () => context.push('/experience'),
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
                  Text(
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
          onPressed: () => context.push('/resume'),
          icon: const Icon(CupertinoIcons.doc_text),
          label: const Text('View resume'),
        ),
      ],
    );
  }
}
