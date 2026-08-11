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
    final screenWidth = MediaQuery.of(context).size.width;

    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: IgnorePointer(
        // 🔥 ПРОПУСКАЕМ КЛИКИ
        child: Container(
          height: 56,
          margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(50),
            gradient: LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              colors: [
                isUrgent ? Colors.red : Colors.orange,
                isUrgent
                    ? Colors.red.withOpacity(0.3)
                    : Colors.orange.withOpacity(0.3),
                Colors.transparent,
              ],
              stops: const [0.0, 0.3, 0.5],
            ),
            boxShadow: [
              BoxShadow(
                color: (isUrgent ? Colors.red : Colors.orange).withOpacity(0.3),
                blurRadius: 20,
                spreadRadius: 2,
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(50),
            child: LinearProgressIndicator(
              value: seconds / 60,
              backgroundColor: Colors.transparent,
              color: Colors.transparent,
              minHeight: 56,
            ),
          ),
        ),
      ),
    );
  }
}
