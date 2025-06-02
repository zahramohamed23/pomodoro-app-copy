import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/task.dart';
import 'package:uuid/uuid.dart';

const _tasksBoxName = 'tasks';

class TasksNotifier extends StateNotifier<List<Task>> {
  final Box<Task> tasksBox;
  static const _uuid = Uuid();

  TasksNotifier(this.tasksBox) : super([]) {
    _loadTasks();
  }

  void _loadTasks() {
    state = tasksBox.values.toList();
  }

  Future<void> addTask(String title, int estimatedPomodoros) async {
    final task = Task(
      id: _uuid.v4(),
      title: title,
      estimatedPomodoros: estimatedPomodoros,
    );
    await tasksBox.put(task.id, task);
    _loadTasks();
  }

  Future<void> toggleTaskCompletion(String taskId) async {
    final task = tasksBox.get(taskId);
    if (task != null) {
      task.isCompleted = !task.isCompleted;
      await tasksBox.put(taskId, task);
      _loadTasks();
    }
  }

  Future<void> incrementPomodorosCompleted(String taskId) async {
    final task = tasksBox.get(taskId);
    if (task != null) {
      task.pomodorosCompleted++;
      await tasksBox.put(taskId, task);
      _loadTasks();
    }
  }

  Future<void> deleteTask(String taskId) async {
    await tasksBox.delete(taskId);
    _loadTasks();
  }

  Future<void> updateTask(String taskId, String title, int estimatedPomodoros) async {
    final task = tasksBox.get(taskId);
    if (task != null) {
      task.title = title;
      task.estimatedPomodoros = estimatedPomodoros;
      await tasksBox.put(taskId, task);
      _loadTasks();
    }
  }

  Future<void> updateTasks(List<Task> tasks) async {
    // Clear existing tasks
    await tasksBox.clear();

    // Add all tasks from the cloud
    for (final task in tasks) {
      await tasksBox.put(task.id, task);
    }

    _loadTasks();
  }
}

final tasksBoxProvider = Provider<Box<Task>>((ref) {
  throw UnimplementedError();
});

final tasksProvider = StateNotifierProvider<TasksNotifier, List<Task>>((ref) {
  final tasksBox = ref.watch(tasksBoxProvider);
  return TasksNotifier(tasksBox);
});