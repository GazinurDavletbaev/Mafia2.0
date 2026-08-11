// lib/presentation/widgets/timer/timer_over_all.dart (свечение)
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

    print('🔍 TimerOverAll: seconds = $seconds, isRunning = $isRunning');

    if (seconds <= 0 || !isRunning) {
      return const SizedBox.shrink();
    }

    final isUrgent = seconds <= 10;

    return Positioned(
      bottom: 4,
      left: 0,
      right: 0,
      child: Container(
        height: 70,
        alignment: Alignment.center,
        child: Stack(
          alignment: Alignment.center,
          children: [
            // 🔥 КРУГОВОЙ ПРОГРЕСС
            SizedBox(
              width: 64,
              height: 64,
              child: CircularProgressIndicator(
                value: seconds / 60,
                strokeWidth: 5,
                backgroundColor: Colors.transparent,
                valueColor: AlwaysStoppedAnimation<Color>(
                  isUrgent ? Colors.red : Colors.orange,
                ),
              ),
            ),
            // 🔥 ВНЕШНЕЕ СВЕЧЕНИЕ
            Container(
              width: 70,
              height: 70,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: (isUrgent ? Colors.red : Colors.orange).withOpacity(0.3),
                    blurRadius: 20,
                    spreadRadius: 5,
                  ),
                ],
              ),
            ),
            // 🔥 ФОН ДЛЯ ЦИФР
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: Colors.black87,
                shape: BoxShape.circle,
                border: Border.all(
                  color: isUrgent ? Colors.red : Colors.orange,
                  width: 2,
                ),
              ),
              child: Center(
                child: Text(
                  '$seconds',
                  style: TextStyle(
                    color: isUrgent ? Colors.red : Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}