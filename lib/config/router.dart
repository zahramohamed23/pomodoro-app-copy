
import 'package:go_router/go_router.dart';
import '../widgets/app_scaffold.dart';
import '../screens/timer_screen.dart';
import '../screens/tasks_screen.dart';
import '../screens/stats_screen.dart';
import '../screens/settings_screen.dart';

final router = GoRouter(
  initialLocation: '/timer',
  routes: [
    ShellRoute(
      builder: (context, state, child) {
        int index = 0;
        switch (state.matchedLocation) {
          case '/timer':
            index = 0;
            break;
          case '/tasks':
            index = 1;
            break;
          case '/stats':
            index = 2;
            break;
        }
        return AppScaffold(currentIndex: index, child: child);
      },
      routes: [
        GoRoute(
          path: '/timer',
          builder: (context, state) => const TimerScreen(),
        ),
        GoRoute(
          path: '/tasks',
          builder: (context, state) => const TasksScreen(),
        ),
        GoRoute(
          path: '/stats',
          builder: (context, state) => const StatsScreen(),
        ),
      ],
    ),
    GoRoute(
      path: '/settings',
      builder: (context, state) => const SettingsScreen(),
    ),
  ],
);