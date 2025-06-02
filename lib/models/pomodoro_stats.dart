import 'package:hive/hive.dart';

part 'pomodoro_stats.g.dart';

@HiveType(typeId: 1)
class PomodoroSession extends HiveObject {
  @HiveField(0)
  final DateTime date;

  @HiveField(1)
  final String taskTitle;

  @HiveField(2)
  final int durationMinutes;

  PomodoroSession({
    required this.date,
    required this.taskTitle,
    required this.durationMinutes,
  });
}

class DailyStats {
  final DateTime date;
  final int totalSessions;
  final int totalMinutes;
  final Map<String, int> taskDistribution;

  DailyStats({
    required this.date,
    required this.totalSessions,
    required this.totalMinutes,
    required this.taskDistribution,
  });
}