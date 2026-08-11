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
          child: CustomPaint(
            painter: BottomNavProgressPainter(
              progress: progress,
              color: isUrgent ? Colors.red : Colors.orange,
              strokeWidth: 3,
            ),
          ),
        ),
      ),
    );
  }
}

class BottomNavProgressPainter extends CustomPainter {
  final double progress;
  final Color color;
  final double strokeWidth;

  BottomNavProgressPainter({
    required this.progress,
    required this.color,
    this.strokeWidth = 3,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Rect.fromLTWH(0, 0, size.width, size.height);
    final radius = size.height / 2;

    // 🔥 ФОН (слабая обводка)
    final backgroundPaint = Paint()
      ..color = Colors.grey.withOpacity(0.15)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;

    final path = Path()..addRRect(RRect.fromRectAndRadius(rect, Radius.circular(radius)));
    canvas.drawPath(path, backgroundPaint);

    // 🔥 ПРОГРЕСС (градиентная обводка по радиусу)
    if (progress > 0) {
      final progressPaint = Paint()
        ..shader = SweepGradient(
          startAngle: 0,
          endAngle: 3.14159 * 2 * progress,
          colors: [
            color.withOpacity(0.8),
            color.withOpacity(0.2),
          ],
        ).createShader(rect)
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth
        ..strokeCap = StrokeCap.round;

      // 🔥 РИСУЕМ ДУГУ ПО РАДИУСУ СКРУГЛЁННОГО ПРЯМОУГОЛЬНИКА
      final progressPath = Path();
      
      // Создаём путь скруглённого прямоугольника
      final rrect = RRect.fromRectAndRadius(rect, Radius.circular(radius));
      progressPath.addRRect(rrect);
      
      // Измеряем длину пути
      final metrics = progressPath.computeMetrics();
      double totalLength = 0;
      for (final metric in metrics) {
        totalLength += metric.length;
      }

      // Рисуем прогресс по длине пути
      double drawnLength = 0;
      for (final metric in metrics) {
        final segmentLength = metric.length;
        final segmentProgress = segmentLength / totalLength;
        final start = drawnLength / totalLength;
        final end = start + segmentProgress;

        if (progress >= start) {
          final localStart = 0.0;
          final localEnd = ((progress - start) / segmentProgress).clamp(0.0, 1.0);
          final subPath = metric.extractPath(localStart, localEnd);
          canvas.drawPath(subPath, progressPaint);
        }

        drawnLength += segmentLength;
        if (drawnLength / totalLength >= progress) break;
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    if (oldDelegate is BottomNavProgressPainter) {
      return oldDelegate.progress != progress ||
          oldDelegate.color != color ||
          oldDelegate.strokeWidth != strokeWidth;
    }
    return true;
  }
}