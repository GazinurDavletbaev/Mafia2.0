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
      bottom: 4,
      left: 8,
      right: 8,
      child: IgnorePointer(
        child: Container(
          height: 52,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(50),
            gradient: LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              colors: [
                (isUrgent ? Colors.red : Colors.orange).withOpacity(0.6),
                (isUrgent ? Colors.red : Colors.orange).withOpacity(0.2),
                Colors.transparent,
              ],
              stops: [0.0, progress * 0.8, progress],
            ),
          ),
        ),
      ),
    );
  }
}
