import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/tasks_provider.dart';
import '../providers/active_task_provider.dart';
import '../models/task.dart';

class TaskList extends ConsumerWidget {
  const TaskList({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tasks = ref.watch(tasksProvider);
    final activeTask = ref.watch(activeTaskProvider);
    final textController = TextEditingController();

    return Column(
      children: [
        // Add task input field
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: TextField(
            controller: textController,
            decoration: InputDecoration(
              hintText: 'Add a new task',
              suffixIcon: IconButton(
                icon: const Icon(Icons.add),
                onPressed: () {
                  if (textController.text.isNotEmpty) {
                    ref.read(tasksProvider.notifier).addTask(
                      textController.text,
                      1, // Default to 1 pomodoro
                    );
                    textController.clear();
                  }
                },
              ),
              border: const OutlineInputBorder(),
            ),
            onSubmitted: (value) {
              if (value.isNotEmpty) {
                ref.read(tasksProvider.notifier).addTask(
                  value,
                  1, // Default to 1 pomodoro
                );
                textController.clear();
              }
            },
          ),
        ),
        // Task list
        Expanded(
          child: tasks.isEmpty
              ? const Center(
            child: Text('No tasks yet. Add one to get started!'),
          )
              : ListView.builder(
            itemCount: tasks.length,
            itemBuilder: (context, index) {
              final task = tasks[index];
              final isActive = activeTask?.id == task.id;

              return Dismissible(
                key: Key(task.id),
                background: Container(
                  color: Colors.red,
                  alignment: Alignment.centerRight,
                  padding: const EdgeInsets.only(right: 16),
                  child: const Icon(Icons.delete, color: Colors.white),
                ),
                direction: DismissDirection.endToStart,
                onDismissed: (_) {
                  if (isActive) {
                    ref.read(activeTaskProvider.notifier).state = null;
                  }
                  ref.read(tasksProvider.notifier).deleteTask(task.id);
                },
                child: ListTile(
                  leading: Checkbox(
                    value: task.isCompleted,
                    onChanged: (_) {
                      ref.read(tasksProvider.notifier)
                          .toggleTaskCompletion(task.id);
                      if (task.isCompleted && isActive) {
                        ref.read(activeTaskProvider.notifier).state = null;
                      }
                    },
                  ),
                  title: Text(
                    task.title,
                    style: TextStyle(
                      decoration: task.isCompleted
                          ? TextDecoration.lineThrough
                          : null,
                    ),
                  ),
                  subtitle: Text(
                    '${task.pomodorosCompleted}/${task.estimatedPomodoros} pomodoros',
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (!task.isCompleted)
                        IconButton(
                          icon: Icon(
                            isActive ? Icons.timer : Icons.timer_outlined,
                            color: isActive ? Theme.of(context).colorScheme.primary : null,
                          ),
                          onPressed: () {
                            final notifier = ref.read(activeTaskProvider.notifier);
                            notifier.state = isActive ? null : task;
                          },
                        ),
                      IconButton(
                        icon: const Icon(Icons.edit),
                        onPressed: () => _showEditTaskDialog(context, ref, task),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Future<void> _showEditTaskDialog(BuildContext context, WidgetRef ref, Task task) async {
    final titleController = TextEditingController(text: task.title);
    final pomodorosController = TextEditingController(
      text: task.estimatedPomodoros.toString(),
    );

    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Task'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: titleController,
              decoration: const InputDecoration(
                labelText: 'Task Title',
              ),
              autofocus: true,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: pomodorosController,
              decoration: const InputDecoration(
                labelText: 'Estimated Pomodoros',
              ),
              keyboardType: TextInputType.number,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              if (titleController.text.isNotEmpty) {
                final pomodoros = int.tryParse(pomodorosController.text) ?? 1;
                ref.read(tasksProvider.notifier).updateTask(
                  task.id,
                  titleController.text,
                  pomodoros,
                );
                Navigator.pop(context);
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }
}