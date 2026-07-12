import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../features/positive_news/presentation/positive_news_screen.dart';
import '../features/saved/presentation/saved_screen.dart';
import '../features/settings/presentation/settings_screen.dart';
import '../features/stories/presentation/story_detail_screen.dart';
import '../features/underreported/presentation/underreported_screen.dart';
import '../features/world/presentation/world_screen.dart';

final _rootNavigatorKey = GlobalKey<NavigatorState>();
final _worldNavigatorKey = GlobalKey<NavigatorState>();
final _underreportedNavigatorKey = GlobalKey<NavigatorState>();
final _positiveNavigatorKey = GlobalKey<NavigatorState>();
final _savedNavigatorKey = GlobalKey<NavigatorState>();

final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: '/world',
    routes: [
      StatefulShellRoute.indexedStack(
        builder: (context, state, shell) => AppShell(shell: shell),
        branches: [
          StatefulShellBranch(
            navigatorKey: _worldNavigatorKey,
            routes: [
              GoRoute(path: '/world', builder: (context, state) => const WorldScreen()),
            ],
          ),
          StatefulShellBranch(
            navigatorKey: _underreportedNavigatorKey,
            routes: [
              GoRoute(
                path: '/underreported',
                builder: (context, state) => const UnderreportedScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            navigatorKey: _positiveNavigatorKey,
            routes: [
              GoRoute(path: '/positive', builder: (context, state) => const PositiveNewsScreen()),
            ],
          ),
          StatefulShellBranch(
            navigatorKey: _savedNavigatorKey,
            routes: [
              GoRoute(path: '/saved', builder: (context, state) => const SavedScreen()),
            ],
          ),
        ],
      ),
      GoRoute(
        parentNavigatorKey: _rootNavigatorKey,
        path: '/stories/:id',
        builder: (context, state) => StoryDetailScreen(storyId: state.pathParameters['id']!),
      ),
      GoRoute(
        parentNavigatorKey: _rootNavigatorKey,
        path: '/settings',
        builder: (context, state) => const SettingsScreen(),
      ),
    ],
  );
});

class AppShell extends StatelessWidget {
  const AppShell({required this.shell, super.key});

  final StatefulNavigationShell shell;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: shell,
      bottomNavigationBar: NavigationBar(
        selectedIndex: shell.currentIndex,
        onDestinationSelected: shell.goBranch,
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.public),
            selectedIcon: Icon(Icons.public),
            label: 'World',
          ),
          NavigationDestination(icon: Icon(Icons.travel_explore), label: 'Underreported'),
          NavigationDestination(icon: Icon(Icons.volunteer_activism), label: 'Positive'),
          NavigationDestination(icon: Icon(Icons.bookmark), label: 'Saved'),
        ],
      ),
    );
  }
}
