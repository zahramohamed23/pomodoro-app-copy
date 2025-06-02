import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'settings_provider.dart';
import 'notification_provider.dart';
import 'tasks_provider.dart';
import 'stats_provider.dart';
import 'active_task_provider.dart';
import '../models/pomodoro_stats.dart';
import '../soundService//sound_service.dart';

enum TimerMode {
  work,
  shortBreak,
  longBreak,
}

class TimerState {
  final int remainingSeconds;
  final TimerMode mode;
  final bool isRunning;
  final int workDuration;
  final int shortBreakDuration;
  final int longBreakDuration;
  final int completedWorkSessions;

  TimerState({
    required this.remainingSeconds,
    required this.mode,
    required this.isRunning,
    required this.workDuration,
    required this.shortBreakDuration,
    required this.longBreakDuration,
    this.completedWorkSessions = 0,
  });

  TimerState copyWith({
    int? remainingSeconds,
    TimerMode? mode,
    bool? isRunning,
    int? workDuration,
    int? shortBreakDuration,
    int? longBreakDuration,
    int? completedWorkSessions,
  }) {
    return TimerState(
      remainingSeconds: remainingSeconds ?? this.remainingSeconds,
      mode: mode ?? this.mode,
      isRunning: isRunning ?? this.isRunning,
      workDuration: workDuration ?? this.workDuration,
      shortBreakDuration: shortBreakDuration ?? this.shortBreakDuration,
      longBreakDuration: longBreakDuration ?? this.longBreakDuration,
      completedWorkSessions: completedWorkSessions ?? this.completedWorkSessions,
    );
  }

  bool get shouldTakeLongBreak => completedWorkSessions > 0 && completedWorkSessions % 4 == 0;
}

class TimerNotifier extends StateNotifier<TimerState> {
  Timer? _timer;
  final SettingsNotifier _settings;
  final NotificationStateNotifier _notifications;
  final Ref _ref;

  TimerNotifier(this._settings, this._notifications, this._ref)
      : super(TimerState(
    remainingSeconds: _settings.state.workDuration * 60,
    mode: TimerMode.work,
    isRunning: false,
    workDuration: _settings.state.workDuration,
    shortBreakDuration: _settings.state.shortBreakDuration,
    longBreakDuration: _settings.state.longBreakDuration,
    completedWorkSessions: 0,
  ));

  void startTimer() {
    if (!state.isRunning) {
      state = state.copyWith(isRunning: true);
      _timer = Timer.periodic(const Duration(seconds: 1), (_) {
        if (state.remainingSeconds > 0) {
          state = state.copyWith(
            remainingSeconds: state.remainingSeconds - 1,
          );
        } else {
          _onTimerComplete();
        }
      });

      // Schedule notification for when timer completes
      _notifications.scheduleNotification(
        scheduledDate: DateTime.now().add(Duration(seconds: state.remainingSeconds)),
        isWorkMode: state.mode == TimerMode.work,
        nextDuration: state.mode == TimerMode.work
            ? state.shortBreakDuration
            : state.mode == TimerMode.shortBreak
            ? state.longBreakDuration
            : state.workDuration,
      );
    }
  }

  void pauseTimer() {
    _timer?.cancel();
    state = state.copyWith(isRunning: false);
    _notifications.cancelNotifications();
  }

  void resetTimer() {
    _timer?.cancel();
    state = state.copyWith(
      remainingSeconds: state.mode == TimerMode.work
          ? state.workDuration * 60
          : state.mode == TimerMode.shortBreak
          ? state.shortBreakDuration * 60
          : state.longBreakDuration * 60,
      isRunning: false,
    );
    _notifications.cancelNotifications();
  }

  void _onTimerComplete() {
    _timer?.cancel();

    // Play the appropriate sound
    final soundService = _ref.read(soundServiceProvider);
    if (state.mode == TimerMode.work) {
      soundService.playWorkCompleteSound();
    } else {
      soundService.playBreakCompleteSound();
    }

    // If work session completed and there's an active task
    if (state.mode == TimerMode.work) {
      final activeTask = _ref.read(activeTaskProvider);
      if (activeTask != null) {
        // Increment pomodoro count for the task
        _ref.read(tasksProvider.notifier).incrementPomodorosCompleted(activeTask.id);

        // Record the session in stats
        final session = PomodoroSession(
          taskTitle: activeTask.title,
          date: DateTime.now(),
          durationMinutes: state.workDuration,
        );

        // Make sure to await the session addition
        Future.microtask(() async {
          await _ref.read(statsProvider.notifier).addSession(session);
        });
      }
    }

    // Show immediate notification
    _notifications.showTimerComplete(
      isWorkMode: state.mode == TimerMode.work,
      nextDuration: state.mode == TimerMode.work
          ? state.shortBreakDuration
          : state.mode == TimerMode.shortBreak
          ? state.longBreakDuration
          : state.workDuration,
    );

    switchMode();
  }

  void switchMode() {
    final newMode = state.mode == TimerMode.work ? TimerMode.shortBreak : state.mode == TimerMode.shortBreak ? TimerMode.longBreak : TimerMode.work;
    final newDuration = newMode == TimerMode.work
        ? state.workDuration * 60
        : newMode == TimerMode.shortBreak
        ? state.shortBreakDuration * 60
        : state.longBreakDuration * 60;

    // Update durations from settings if they've changed
    final workDuration = _settings.state.workDuration;
    final shortBreakDuration = _settings.state.shortBreakDuration;
    final longBreakDuration = _settings.state.longBreakDuration;

    state = state.copyWith(
      mode: newMode,
      remainingSeconds: newDuration,
      isRunning: false,
      workDuration: workDuration,
      shortBreakDuration: shortBreakDuration,
      longBreakDuration: longBreakDuration,
    );
  }

  void skipTimer() {
    resetTimer();
    switchMode();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _notifications.cancelNotifications();
    super.dispose();
  }
}

final timerProvider = StateNotifierProvider<TimerNotifier, TimerState>((ref) {
  final settings = ref.watch(settingsProvider);
  final notifications = ref.watch(notificationStateProvider.notifier);
  final timerNotifier = TimerNotifier(
    ref.read(settingsProvider.notifier),
    notifications,
    ref,
  );

  // Update timer when settings change
  if (!timerNotifier.state.isRunning) {
    timerNotifier.state = timerNotifier.state.copyWith(
      workDuration: settings.workDuration,
      shortBreakDuration: settings.shortBreakDuration,
      longBreakDuration: settings.longBreakDuration,
      remainingSeconds: timerNotifier.state.mode == TimerMode.work
          ? settings.workDuration * 60
          : timerNotifier.state.mode == TimerMode.shortBreak
          ? settings.shortBreakDuration * 60
          : settings.longBreakDuration * 60,
    );
  }

  return timerNotifier;
});