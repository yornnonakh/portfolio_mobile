import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/design_system/components.dart';
import '../../../shared/models/portfolio.dart';
import 'project_art.dart';

class ProjectCard extends StatelessWidget {
  const ProjectCard({
    super.key,
    required this.project,
    this.heroSource = 'projects',
  });
  final PortfolioProject project;
  final String heroSource;
  @override
  Widget build(BuildContext context) => SurfaceCard(
    padding: const EdgeInsets.all(0),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Hero(
          tag: '$heroSource-${project.id}',
          child: ProjectArt(project: project, height: 240),
        ),
        Padding(
          padding: const EdgeInsets.all(22),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                project.title,
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 8),
              MutedText(project.description),
              const SizedBox(height: 18),
              BadgeList(project.technologies),
              const SizedBox(height: 18),
              IosButton.plain(
                onPressed: () =>
                    context.push('/projects/${project.id}?from=$heroSource'),
                label: const Text('Explore case study'),
                icon: const Icon(CupertinoIcons.chevron_right, size: 15),
                iconAlignment: IconAlignment.end,
              ),
            ],
          ),
        ),
      ],
    ),
  );
}
