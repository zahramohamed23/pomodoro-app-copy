import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../widgets/timer_display.dart';
import '../widgets/timer_controls.dart';
import '../providers/active_task_provider.dart';

class TimerScreen extends ConsumerWidget {
  const TimerScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final activeTask = ref.watch(activeTaskProvider);

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      appBar: AppBar(
        title: const Text('Pomodoro Timer'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () => context.go('/settings'),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  color: Theme.of(context).colorScheme.background,
                  padding: const EdgeInsets.symmetric(vertical: 32),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (activeTask != null)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 24),
                          child: Card(
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 12,
                              ),
                              child: Column(
                                children: [
                                  Text(
                                    activeTask.title,
                                    style: Theme.of(context).textTheme.titleLarge,
                                    textAlign: TextAlign.center,
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    '${activeTask.pomodorosCompleted}/${activeTask.estimatedPomodoros} pomodoros completed',
                                    style: Theme.of(context).textTheme.bodyMedium,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        )
                      else
                        Padding(
                          padding: const EdgeInsets.only(bottom: 24),
                          child: TextButton.icon(
                            onPressed: () => context.go('/tasks'),
                            icon: const Icon(Icons.add_task),
                            label: const Text('Select a task'),
                          ),
                        ),
                      const TimerDisplay(),
                      const SizedBox(height: 32),
                      const TimerControls(),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}