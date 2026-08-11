// lib/presentation/widgets/timer/timer_over_all.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mafia_help/application/providers/timer_provider.dart';
import 'package:go_router/go_router.dart';

class TimerOverAll extends ConsumerWidget {
  const TimerOverAll({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final timerState = ref.watch(timerProvider);
    final seconds = timerState.remainingSeconds;
    final isRunning = timerState.isRunning;

    // 🔥 ПРОВЕРЯЕМ ТЕКУЩИЙ МАРШРУТ
    final currentRoute = GoRouterState.of(context).uri.path;
    final isGameScreen = currentRoute == '/game' || currentRoute.contains('game');

    print('🔍 TimerOverAll: seconds = $seconds, isRunning = $isRunning, route = $currentRoute');

    // 🔥 ЕСЛИ МЫ НА GAME_SCREEN — СКРЫВАЕМ
    if (isGameScreen) {
      return const SizedBox.shrink();
    }

    if (seconds <= 0 || !isRunning) {
      return const SizedBox.shrink();
    }

    return Positioned(
      top: 200,
      right: 100,
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
            CircularProgressIndicator(
              value: seconds / 60,
              strokeWidth: 4,
              backgroundColor: Colors.grey.withOpacity(0.3),
              valueColor: const AlwaysStoppedAnimation<Color>(Colors.red),
            ),
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