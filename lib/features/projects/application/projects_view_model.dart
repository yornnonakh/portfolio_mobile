import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../shared/models/portfolio.dart';
import '../../../shared/providers/portfolio_providers.dart';

final projectCategoriesProvider = Provider<List<String>>(
  (ref) => [
    'All projects',
    ...ref.watch(portfolioProvider).projects.map((p) => p.category).toSet(),
  ],
);
final projectFilterProvider = NotifierProvider<ProjectFilterViewModel, String>(
  ProjectFilterViewModel.new,
);

class ProjectFilterViewModel extends Notifier<String> {
  @override
  String build() => 'All projects';
  void select(String category) {
    if (ref.read(projectCategoriesProvider).contains(category)) {
      state = category;
    }
  }
}

final filteredProjectsProvider = Provider<List<PortfolioProject>>((ref) {
  final projects = ref.watch(portfolioProvider).projects;
  final category = ref.watch(projectFilterProvider);
  return projects
      .where((p) => category == 'All projects' || p.category == category)
      .toList(growable: false);
});
final projectProvider = Provider.family<PortfolioProject?, String>((ref, id) {
  for (final project in ref.watch(portfolioProvider).projects) {
    if (project.id == id) return project;
  }
  return null;
});
