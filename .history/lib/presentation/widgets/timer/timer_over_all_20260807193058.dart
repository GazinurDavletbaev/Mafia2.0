import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mafia_help/application/providers/timer_provider.dart';

class TimerOverAll extends ConsumerWidget {
  const TimerOverAll({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final seconds = ref.watch(floatingTimerProvider);

    if (seconds == null || seconds <= 0) {
      return const SizedBox.shrink();
    }

    return Positioned(
      top: 60,
      right: 16,
      child: Container(
        width: 60,
        height: 60,
        decoration: const BoxDecoration(
          color: Colors.black87,
          shape: BoxShape.circle,
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            // 🔥 КРУГОВОЙ ПРОГРЕСС
            CircularProgressIndicator(
              value: seconds / 60,
              strokeWidth: 4,
              backgroundColor: Colors.grey.withOpacity(0.3),
              valueColor: const AlwaysStoppedAnimation<Color>(Colors.red),
            ),
            // 🔥 ЦИФРЫ
            Text(
              '$seconds',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}