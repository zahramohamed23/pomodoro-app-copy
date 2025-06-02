import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/pomodoro_stats.dart';

class StatsNotifier extends StateNotifier<List<DailyStats>> {
  final Box<PomodoroSession> sessionsBox;

  StatsNotifier(this.sessionsBox) : super([]) {
    _loadStats();
  }

  void _loadStats() {
    final now = DateTime.now();
    final lastWeek = now.subtract(const Duration(days: 7));

    // Group sessions by date
    final Map<DateTime, List<PomodoroSession>> sessionsByDate = {};
    for (var session in sessionsBox.values) {
      final date = DateTime(
        session.date.year,
        session.date.month,
        session.date.day,
      );
      sessionsByDate.putIfAbsent(date, () => []).add(session);
    }

    // Calculate daily stats for the last 7 days
    final List<DailyStats> stats = [];
    for (var i = 6; i >= 0; i--) {
      final date = DateTime(
        now.year,
        now.month,
        now.day,
      ).subtract(Duration(days: i));

      final sessions = sessionsByDate[date] ?? [];
      final taskDistribution = <String, int>{};

      for (var session in sessions) {
        taskDistribution.update(
          session.taskTitle,
              (count) => count + 1,
          ifAbsent: () => 1,
        );
      }

      stats.add(DailyStats(
        date: date,
        totalSessions: sessions.length,
        totalMinutes: sessions.fold(0, (sum, session) => sum + session.durationMinutes),
        taskDistribution: taskDistribution,
      ));
    }

    state = stats;
  }

  Future<void> addSession(PomodoroSession session) async {
    await sessionsBox.add(session);
    _loadStats(); // Reload stats after adding a new session
  }

  int get totalFocusTime {
    return state.fold(0, (sum, stats) => sum + stats.totalMinutes);
  }

  Map<String, int> get totalTaskDistribution {
    final distribution = <String, int>{};
    for (var dailyStats in state) {
      for (var entry in dailyStats.taskDistribution.entries) {
        distribution.update(
          entry.key,
              (count) => count + entry.value,
          ifAbsent: () => entry.value,
        );
      }
    }
    return distribution;
  }
}

final sessionsBoxProvider = Provider<Box<PomodoroSession>>((ref) {
  throw UnimplementedError();
});

final statsProvider = StateNotifierProvider<StatsNotifier, List<DailyStats>>((ref) {
  final sessionsBox = ref.watch(sessionsBoxProvider);
  return StatsNotifier(sessionsBox);
});