import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/localization/app_localizations.dart';
import '../../../core/design_system/components.dart';
import '../../../shared/providers/portfolio_providers.dart';
import '../../home/presentation/home_screen.dart';

class ExperienceScreen extends ConsumerWidget {
  const ExperienceScreen({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final data = ref.watch(portfolioProvider);
    return PageContent(
      children: [
        const PageHeader(
          eyebrow: 'Experience',
          title: 'Experience',
          description:
              'From teaching computer skills to building mobile applications.',
        ),
        for (final experience in data.experiences) ...[
          SurfaceCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Eyebrow(experience.period),
                const SizedBox(height: 10),
                AppText(
                  experience.title,
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
                const SizedBox(height: 8),
                AppText(
                  experience.organization,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 4),
                MutedText(experience.location),
                const Divider(height: 32),
                BulletList(experience.responsibilities),
              ],
            ),
          ),
          const SizedBox(height: 16),
        ],
        DeploymentCard(text: data.deployment),
        const SizedBox(height: 32),
        const SectionHeading('Education & Training'),
        for (final edu in data.educations) ...[
          SurfaceCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Eyebrow(edu.period),
                const SizedBox(height: 12),
                AppText(
                  edu.program,
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 8),
                MutedText(edu.institute),
                const SizedBox(height: 16),
                TechBadge(edu.status, accent: true),
              ],
            ),
          ),
          const SizedBox(height: 16),
        ],
      ],
    );
  }
}
