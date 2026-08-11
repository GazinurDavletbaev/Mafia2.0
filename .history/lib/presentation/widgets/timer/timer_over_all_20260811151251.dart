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
            painter: BottomNavCircleProgressPainter(
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

class BottomNavCircleProgressPainter extends CustomPainter {
  final double progress;
  final Color color;
  final double strokeWidth;

  BottomNavCircleProgressPainter({
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

    final backgroundPath = Path()
      ..addRRect(RRect.fromRectAndRadius(rect, Radius.circular(radius)));
    canvas.drawPath(backgroundPath, backgroundPaint);

    // 🔥 ПРОГРЕСС (рисуем по кругу)
    if (progress > 0) {
      final progressPaint = Paint()
        ..color = color
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth
        ..strokeCap = StrokeCap.round;

      // 🔥 РИСУЕМ ДУГУ ПО ПЕРИМЕТРУ СКРУГЛЁННОГО ПРЯМОУГОЛЬНИКА
      final progressPath = Path()
        ..addRRect(RRect.fromRectAndRadius(rect, Radius.circular(radius)));

      // Получаем длину пути
      final metrics = progressPath.computeMetrics();
      double totalLength = 0;
      for (final metric in metrics) {
        totalLength += metric.length;
      }

      // Рисуем прогресс
      double drawnLength = 0;
      for (final metric in metrics) {
        final segmentLength = metric.length;
        final start = drawnLength / totalLength;
        final end = (drawnLength + segmentLength) / totalLength;

        if (progress > start) {
          final localStart = 0.0;
          final localEnd = ((progress - start) / (end - start)).clamp(0.0, 1.0);
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
    if (oldDelegate is BottomNavCircleProgressPainter) {
      return oldDelegate.progress != progress ||
          oldDelegate.color != color ||
          oldDelegate.strokeWidth != strokeWidth;
    }
    return true;
  }
}
