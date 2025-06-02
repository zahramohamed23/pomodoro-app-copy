import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../firebaseServices/firebase_service.dart';
import '../models/task.dart';
import 'tasks_provider.dart';

final firebaseServiceProvider = Provider<FirebaseService>((ref) {
  return FirebaseService();
});

final syncStatusProvider = StateProvider<bool>((ref) => false);

final firebaseTasksProvider = Provider<FirebaseTasksNotifier>((ref) {
  return FirebaseTasksNotifier(ref);
});

class FirebaseTasksNotifier {
  final Ref _ref;

  FirebaseTasksNotifier(this._ref) {
    _initialize();
  }

  Future<void> _initialize() async {
    try {
      await _ref.read(firebaseServiceProvider).signInAnonymously();
    } catch (e) {
      // Avoid using print in production
      _handleError('Failed to initialize Firebase', e);
    }
  }

  void _handleError(String message, dynamic error) {
    // TODO: Implement proper error handling
    // For now, we'll just ignore the print warning
    // In production, this should use proper logging
    if (error != null) {
      message = '$message: $error';
    }
  }

  Map<String, dynamic> _taskToMap(Task task) {
    return {
      'id': task.id,
      'title': task.title,
      'isCompleted': task.isCompleted,
      'pomodorosCompleted': task.pomodorosCompleted,
      'estimatedPomodoros': task.estimatedPomodoros,
    };
  }

  Future<void> syncTasks() async {
    try {
      _ref.read(syncStatusProvider.notifier).state = true;

      final firebaseService = _ref.read(firebaseServiceProvider);
      final tasksNotifier = _ref.read(tasksProvider.notifier);
      final localTasks = _ref.read(tasksProvider);

      // Convert List<Task> to List<Map<String, dynamic>>
      final taskMaps = localTasks.map(_taskToMap).toList();

      // Sync with Firebase
      await firebaseService.syncTasks(taskMaps);

      // Fetch and convert the latest tasks from Firestore
      final cloudTaskMaps = await firebaseService.fetchTasks().first;
      final cloudTasks = cloudTaskMaps.map((map) => Task(
        id: map['id'] as String,
        title: map['title'] as String,
        isCompleted: map['isCompleted'] as bool,
        pomodorosCompleted: map['pomodorosCompleted'] as int,
        estimatedPomodoros: map['estimatedPomodoros'] as int,
      )).toList();

      // Update local tasks with cloud data
      await tasksNotifier.updateTasks(cloudTasks);

      _ref.read(syncStatusProvider.notifier).state = false;
    } catch (e) {
      _handleError('Failed to sync tasks', e);
      _ref.read(syncStatusProvider.notifier).state = false;
    }
  }
}