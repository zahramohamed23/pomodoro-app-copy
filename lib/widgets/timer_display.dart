import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/timer_provider.dart';

class TimerDisplay extends ConsumerWidget {
  const TimerDisplay({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final timerState = ref.watch(timerProvider);
    final minutes = (timerState.remainingSeconds / 60).floor();
    final seconds = timerState.remainingSeconds % 60;

    String getModeText() {
      switch (timerState.mode) {
        case TimerMode.work:
          return 'Work Time';
        case TimerMode.shortBreak:
          return 'Short Break';
        case TimerMode.longBreak:
          return 'Long Break';
      }
    }

    Color getModeColor() {
      switch (timerState.mode) {
        case TimerMode.work:
          return Colors.red;
        case TimerMode.shortBreak:
          return Colors.green;
        case TimerMode.longBreak:
          return Colors.blue;
      }
    }

    final totalSeconds = timerState.mode == TimerMode.work
        ? timerState.workDuration * 60
        : timerState.mode == TimerMode.shortBreak
        ? timerState.shortBreakDuration * 60
        : timerState.longBreakDuration * 60;
    final progress = timerState.remainingSeconds / totalSeconds;
    final color = getModeColor();

    return LayoutBuilder(
      builder: (context, constraints) {
        final size = constraints.maxWidth * 0.7; // 70% of available width

        return SizedBox(
          width: size,
          height: size,
          child: Stack(
            alignment: Alignment.center,
            children: [
              AspectRatio(
                aspectRatio: 1,
                child: CircularProgressIndicator(
                  value: progress,
                  strokeWidth: size * 0.04, // 4% of size for stroke
                  backgroundColor: color.withAlpha(51),
                  color: color,
                ),
              ),
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}',
                    style: TextStyle(
                      fontSize: size * 0.2, // 20% of container size
                      fontWeight: FontWeight.bold,
                      color: color,
                    ),
                  ),
                  SizedBox(height: size * 0.03), // 3% of size for spacing
                  Text(
                    getModeText(),
                    style: TextStyle(
                      fontSize: size * 0.07, // 7% of container size
                      fontWeight: FontWeight.w500,
                      color: color,
                    ),
                  ),
                  if (timerState.mode == TimerMode.work)
                    Text(
                      'Session ${timerState.completedWorkSessions + 1}',
                      style: TextStyle(
                        fontSize: size * 0.05,
                        color: color.withOpacity(0.8),
                      ),
                    ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}