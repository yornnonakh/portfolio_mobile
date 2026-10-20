import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/design_system/components.dart';
import '../../../core/services/link_service.dart';
import '../../../core/utils/action_feedback.dart';
import '../../../shared/models/portfolio.dart';
import '../application/projects_view_model.dart';
import 'project_art.dart';

class ProjectDetailsScreen extends ConsumerWidget {
  const ProjectDetailsScreen({
    super.key,
    required this.projectId,
    this.heroSource = 'projects',
  });
  final String projectId;
  final String heroSource;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final project = ref.watch(projectProvider(projectId));
    if (project == null) {
      return PageContent(
        children: [
          EmptyState(
            icon: CupertinoIcons.search,
            title: 'Project not found',
            message: 'This project is not in the portfolio.',
            action: IosButton.filled(
              onPressed: () => context.go('/projects'),
              child: const Text('Browse projects'),
            ),
          ),
        ],
      );
    }
    final links = ref.read(linkServiceProvider);
    return PageContent(
      children: [
        PageHeader(
          eyebrow: 'Case study ${project.number} / ${project.category}',
          title: project.title,
          description: project.description,
        ),
        BadgeList(project.technologies),
        const SizedBox(height: 28),
        Hero(
          tag: '$heroSource-${project.id}',
          child: ProjectArt(project: project, height: 330),
        ),
        const SizedBox(height: 36),
        const SectionHeading('Project overview', eyebrow: 'The work'),
        ResponsiveGrid(
          minimumWidth: 430,
          children: [
            SurfaceCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Features',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 20),
                  BulletList(project.features, checks: true),
                ],
              ),
            ),
            SurfaceCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'My contributions',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 20),
                  BulletList(project.contributions),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 36),
        const SectionHeading('How it works', eyebrow: 'Development'),
        SurfaceCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Architecture & state management',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 14),
              MutedText(project.architecture),
              const SizedBox(height: 22),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  const TechBadge('Flutter views'),
                  const Icon(CupertinoIcons.arrow_right_arrow_left, size: 18),
                  TechBadge(project.id == 'notes' ? 'GetX' : 'Provider'),
                  const Icon(CupertinoIcons.arrow_right_arrow_left, size: 18),
                  TechBadge(
                    project.id == 'notes' ? 'Dio / REST API' : 'REST API',
                  ),
                ],
              ),
              const Divider(height: 40),
              Text(
                'API integration',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 12),
              MutedText(project.integration),
            ],
          ),
        ),
        const SizedBox(height: 28),
        const SectionHeading('Screenshots'),
        _ScreenshotGallery(project: project),
        const SizedBox(height: 32),
        SurfaceCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Technical discussion',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 12),
              const MutedText(
                'Topics to explore in a project walkthrough. Detailed case studies are not available yet.',
              ),
              const SizedBox(height: 20),
              BulletList(project.discussionTopics),
            ],
          ),
        ),
        const SizedBox(height: 28),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            IosButton.tinted(
              onPressed: LinkService.isWebUrl(project.repositoryUrl)
                  ? () => performAction(
                      context,
                      () => links.website(project.repositoryUrl),
                    )
                  : null,
              icon: const Icon(CupertinoIcons.chevron_left_slash_chevron_right, size: 18),
              label: Text(
                LinkService.isWebUrl(project.repositoryUrl)
                    ? 'View repository'
                    : 'Repository unavailable',
              ),
            ),
            if (LinkService.isWebUrl(project.appStoreUrl))
              IosButton.filled(
                onPressed: () => performAction(
                  context,
                  () => links.website(project.appStoreUrl),
                ),
                icon: const LiquidGlassIcon(CupertinoIcons.device_phone_portrait, size: 18),
                label: const Text('View on App Store'),
              ),
            IosButton.plain(
              onPressed: () => context.go('/contact'),
              child: const Text('Discuss this project'),
            ),
          ],
        ),
      ],
    );
  }
}

class _ScreenshotGallery extends StatelessWidget {
  const _ScreenshotGallery({required this.project});
  final PortfolioProject project;
  @override
  Widget build(BuildContext context) {
    if (project.screenshots.isEmpty) {
      return const EmptyState(
        icon: CupertinoIcons.photo_on_rectangle,
        title: 'Screenshots not available yet',
        message:
            'The preview above is an illustration, rather than an original app screenshot.',
      );
    }
    return ResponsiveGrid(
      minimumWidth: 240,
      children: [
        for (final asset in project.screenshots)
          ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Image.asset(
              asset,
              fit: BoxFit.contain,
              semanticLabel: '${project.title} screenshot',
              errorBuilder: (_, error, stack) => const EmptyState(
                icon: CupertinoIcons.photo_fill,
                title: 'Image unavailable',
                message: 'This screenshot could not be loaded.',
              ),
            ),
          ),
      ],
    );
  }
}
