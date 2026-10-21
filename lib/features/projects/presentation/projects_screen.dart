import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/design_system/components.dart';
import '../application/projects_view_model.dart';
import 'project_timeline.dart';

class ProjectsScreen extends ConsumerWidget {
  const ProjectsScreen({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final projects = ref.watch(filteredProjectsProvider);
    final selected = ref.watch(projectFilterProvider);
    return PageContent(
      children: [
        const PageHeader(
          eyebrow: 'Projects',
          title: 'Projects',
          description:
              'A selection of Flutter apps, from everyday notes to mobile shopping.',
        ),
        IosSelectionControl<String>(
          items: {
            for (final category in ref.watch(projectCategoriesProvider))
              category: category == 'All projects' ? 'All' : category,
          },
          value: selected,
          onChanged: ref.read(projectFilterProvider.notifier).select,
        ),
        const SizedBox(height: 14),
        Semantics(
          liveRegion: true,
          child: MutedText(
            '${projects.length} ${projects.length == 1 ? 'project' : 'projects'}',
          ),
        ),
        const SizedBox(height: 20),
        const SectionHeading('Project timeline'),
        ProjectTimeline(projects: projects),
        const SizedBox(height: 24),
        const MutedText(
          'Previews are illustrations. Original screenshots are not available yet.',
        ),
      ],
    );
  }
}
