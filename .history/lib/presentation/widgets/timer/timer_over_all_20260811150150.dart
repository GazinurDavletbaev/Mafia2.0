// lib/presentation/widgets/timer/timer_over_all.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mafia_help/application/providers/timer_provider.dart';

class TimerOverAll extends ConsumerWidget {
  const TimerOverAll({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final timerState = ref.watch(timerProvider);
    final seconds = timerState.remainingSeconds;
    final isRunning = timerState.isRunning;

    if (seconds <= 0 || !isRunning) {
      return const SizedBox.shrink();
    }

    final isUrgent = seconds <= 10;
    final progress = seconds / 60;

    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: IgnorePointer(
        child: Container(
          height: 56,
          margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(50),
            border: Border.all(
              color: Colors.transparent,
              width: 0,
            ),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(50),
            child: LinearProgressIndicator(
              value: progress,
              backgroundColor: Colors.transparent,
              color: isUrgent ? Colors.red : Colors.orange,
              minHeight: 56,
            ),
          ),
        ),
      ),
    );
  }
}