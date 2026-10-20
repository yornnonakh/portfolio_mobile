import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/design_system/components.dart';
import '../../core/utils/motion.dart';
import '../../core/widgets/app_frame.dart';
import '../../features/about/presentation/about_screen.dart';
import '../../features/contact/presentation/contact_screen.dart';
import '../../features/experience/presentation/experience_screen.dart';
import '../../features/home/presentation/home_screen.dart';
import '../../features/projects/presentation/project_details_screen.dart';
import '../../features/projects/application/projects_view_model.dart';
import '../../features/projects/presentation/projects_screen.dart';
import '../../features/resume/presentation/resume_screen.dart';
import '../../features/settings/presentation/settings_screen.dart';
import '../../features/settings/presentation/licenses_screen.dart';
import '../../features/skills/presentation/skills_screen.dart';
import '../../features/splash/presentation/splash_screen.dart';

GoRoute _screen(
  String path,
  Widget Function(BuildContext, GoRouterState) builder,
) => GoRoute(
  path: path,
  pageBuilder: (context, state) =>
      IosPage<void>(key: state.pageKey, child: builder(context, state)),
);

final routerProvider = Provider<GoRouter>((ref) {
  final router = GoRouter(
    initialLocation: '/',
    routes: [
      _screen('/', (_, state) => const SplashScreen()),
      StatefulShellRoute.indexedStack(
        pageBuilder: (_, state, shell) => IosPage<void>(
          key: state.pageKey,
          child: AppFrame(navigationShell: shell, child: shell),
        ),
        branches: [
          StatefulShellBranch(
            routes: [_screen('/home', (_, state) => const HomeScreen())],
          ),
          StatefulShellBranch(
            routes: [
              _screen('/projects', (_, state) => const ProjectsScreen()),
            ],
          ),
          StatefulShellBranch(
            routes: [_screen('/about', (_, state) => const AboutScreen())],
          ),
          StatefulShellBranch(
            routes: [_screen('/contact', (_, state) => const ContactScreen())],
          ),
        ],
      ),
      _screen(
        '/projects/:id',
        (_, state) => AppFrame(
          title:
              ref.read(projectProvider(state.pathParameters['id']!))?.title ??
              'Project',
          child: ProjectDetailsScreen(
            projectId: state.pathParameters['id']!,
            heroSource: state.uri.queryParameters['from'] == 'home'
                ? 'home'
                : 'projects',
          ),
        ),
      ),
      _screen(
        '/skills',
        (_, state) => const AppFrame(title: 'Skills', child: SkillsScreen()),
      ),
      _screen(
        '/experience',
        (_, state) =>
            const AppFrame(title: 'Experience', child: ExperienceScreen()),
      ),
      _screen(
        '/resume',
        (_, state) => const AppFrame(title: 'Resume', child: ResumeScreen()),
      ),
      _screen(
        '/settings',
        (_, state) =>
            const AppFrame(title: 'Settings', child: SettingsScreen()),
      ),
      _screen(
        '/licenses',
        (_, state) =>
            const AppFrame(title: 'Licenses', child: LicensesScreen()),
      ),
    ],
    errorPageBuilder: (context, state) => IosPage<void>(
      key: state.pageKey,
      child: AppFrame(
        title: 'Page not found',
        child: PageContent(
          children: [
            EmptyState(
              icon: CupertinoIcons.compass,
              title: 'This page isn’t here',
              message: 'Explore the portfolio from the home screen.',
              action: IosButton.filled(
                onPressed: () => context.go('/home'),
                child: const Text('Back to home'),
              ),
            ),
          ],
        ),
      ),
    ),
  );
  ref.onDispose(router.dispose);
  return router;
});
