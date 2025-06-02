import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/timer_provider.dart';

class TimerControls extends ConsumerWidget {
  const TimerControls({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final timerState = ref.watch(timerProvider);

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        IconButton(
          icon: const Icon(Icons.skip_previous),
          onPressed: () => ref.read(timerProvider.notifier).skipTimer(),
          tooltip: 'Skip to next phase',
        ),
        const SizedBox(width: 16),
        FloatingActionButton.large(
          onPressed: () {
            if (timerState.isRunning) {
              ref.read(timerProvider.notifier).pauseTimer();
            } else {
              ref.read(timerProvider.notifier).startTimer();
            }
          },
          child: Icon(
            timerState.isRunning ? Icons.pause : Icons.play_arrow,
            size: 36,
          ),
        ),
        const SizedBox(width: 16),
        IconButton(
          icon: const Icon(Icons.refresh),
          onPressed: () => ref.read(timerProvider.notifier).resetTimer(),
          tooltip: 'Reset timer',
        ),
      ],
    );
  }
}