import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:device_preview/device_preview.dart';
import 'package:firebase_core/firebase_core.dart';
import 'models/task.dart';
import 'models/pomodoro_stats.dart';
import 'screens/settings_screen.dart';
import 'screens/stats_screen.dart';
import 'screens/login_screen.dart';
import 'screens/signup_screen.dart';
import 'screens/forgot_password_screen.dart';
import 'providers/settings_provider.dart';
import 'providers/stats_provider.dart';
import 'providers/tasks_provider.dart';
import 'providers/auth_provider.dart';
import 'screens/timer_screen.dart';
import 'screens/tasks_screen.dart';
import 'package:go_router/go_router.dart';

// Firebase configuration
const firebaseConfig = {
  'apiKey': "AIzaSyDKgJFhbQ5-9-QPQYK5kU2-NSOg3Txzdus",
  'authDomain': "pomo2-tracker.firebaseapp.com",
  'projectId': "pomodorotracker-ead08",
  'storageBucket': "pomo2-tracker.appspot.com",
  'messagingSenderId': "670041738631",
  'appId': "1:670041738631:android:9e3e2cbf7f0ad4d22c5722"
};
// Provider to track app initialization status
final appInitializationProvider = StateProvider<bool>((ref) => false);

final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/login',
    redirect: (context, state) {
      final isInitialized = ref.read(appInitializationProvider);
      if (!isInitialized) return null;

      final user = ref.read(authStateProvider).value;
      final isAuthRoute = state.matchedLocation == '/login' ||
          state.matchedLocation == '/signup';

      if (user == null) {
        return isAuthRoute ? null : '/login';
      } else {
        return isAuthRoute ? '/' : null;
      }
    },
    routes: [
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/signup',
        builder: (context, state) => const SignUpScreen(),
      ),
      GoRoute(
        path: '/forgot-password',
        builder: (context, state) => const ForgotPasswordScreen(),
      ),
      ShellRoute(
        builder: (context, state, child) {
          return ScaffoldWithNavBar(child: child);
        },
        routes: [
          GoRoute(
            path: '/',
            builder: (context, state) => const TimerScreen(),
            routes: [
              GoRoute(
                path: 'settings',
                builder: (context, state) => const SettingsScreen(),
              ),
            ],
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
    ],
  );
});

Future<void> main() async {
  try {
    WidgetsFlutterBinding.ensureInitialized();

    // Initialize Firebase with configuration
    await Firebase.initializeApp(
      options: FirebaseOptions(
        apiKey: firebaseConfig['apiKey']!,
        authDomain: firebaseConfig['authDomain']!,
        projectId: firebaseConfig['projectId']!,
        storageBucket: firebaseConfig['storageBucket']!,
        messagingSenderId: firebaseConfig['messagingSenderId']!,
        appId: firebaseConfig['appId']!,
      ),
    );

    // Initialize Hive
    await Hive.initFlutter();

    // Register Hive adapters if not already registered
    if (!Hive.isAdapterRegistered(0)) {
      Hive.registerAdapter(TaskAdapter());
    }
    if (!Hive.isAdapterRegistered(1)) {
      Hive.registerAdapter(PomodoroSessionAdapter());
    }

    // Open Hive boxes
    final tasksBox = await Hive.openBox<Task>('tasks');
    final sessionsBox = await Hive.openBox<PomodoroSession>('sessions');

    // Initialize SharedPreferences
    final prefs = await SharedPreferences.getInstance();

    runApp(
      ProviderScope(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(prefs),
          sessionsBoxProvider.overrideWithValue(sessionsBox),
          tasksBoxProvider.overrideWithValue(tasksBox),
          // Set initialization to true once everything is ready
          appInitializationProvider.overrideWith((ref) => true),
        ],
        child: DevicePreview(
          enabled: true,
          builder: (context) => const MyApp(),
        ),
      ),
    );
  } catch (e, stack) {
    debugPrint('Error during initialization: $e\n$stack');
    // Show error screen if initialization fails
    runApp(
      MaterialApp(
        home: Scaffold(
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.error_outline,
                  color: Colors.red,
                  size: 60,
                ),
                const SizedBox(height: 16),
                const Text(
                  'Failed to initialize app',
                  style: TextStyle(fontSize: 20),
                ),
                const SizedBox(height: 8),
                Text(
                  e.toString(),
                  style: const TextStyle(fontSize: 14, color: Colors.grey),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDarkMode = ref.watch(settingsProvider).isDarkMode;
    final isInitialized = ref.watch(appInitializationProvider);
    final router = ref.watch(routerProvider);

    if (!isInitialized) {
      return MaterialApp(
        builder: DevicePreview.appBuilder,
        home: const Scaffold(
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(),
                SizedBox(height: 16),
                Text(
                  'Initializing...',
                  style: TextStyle(fontSize: 16),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return MaterialApp.router(
      title: 'Pomodoro Timer',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.deepPurple,
          brightness: isDarkMode ? Brightness.dark : Brightness.light,
        ),
        useMaterial3: true,
      ),
      routerConfig: router,
      builder: DevicePreview.appBuilder,
    );
  }
}

class ScaffoldWithNavBar extends StatelessWidget {
  const ScaffoldWithNavBar({
    required this.child,
    super.key,
  });

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: child,
      bottomNavigationBar: NavigationBar(
        onDestinationSelected: (index) {
          switch (index) {
            case 0:
              context.go('/');
              break;
            case 1:
              context.go('/tasks');
              break;
            case 2:
              context.go('/stats');
              break;
          }
        },
        selectedIndex: _calculateSelectedIndex(context),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.timer_outlined),
            selectedIcon: Icon(Icons.timer),
            label: 'Timer',
          ),
          NavigationDestination(
            icon: Icon(Icons.task_outlined),
            selectedIcon: Icon(Icons.task),
            label: 'Tasks',
          ),
          NavigationDestination(
            icon: Icon(Icons.bar_chart_outlined),
            selectedIcon: Icon(Icons.bar_chart),
            label: 'Stats',
          ),
        ],
      ),
    );
  }

  int _calculateSelectedIndex(BuildContext context) {
    final String location = GoRouterState.of(context).matchedLocation;
    if (location.startsWith('/tasks')) {
      return 1;
    }
    if (location.startsWith('/stats')) {
      return 2;
    }
    return 0;
  }
}