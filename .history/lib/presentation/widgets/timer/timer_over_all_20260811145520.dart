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

    print('🔍 TimerOverAll: seconds = $seconds, isRunning = $isRunning');

    if (seconds <= 0 || !isRunning) {
      return const SizedBox.shrink();
    }

    final isUrgent = seconds <= 10;

    return Positioned(
      bottom: 4,
      left: 8,
      right: 8,
      child: Container(
        height: 56,
        alignment: Alignment.center,
        child: Stack(
          alignment: Alignment.center,
          children: [
            // 🔥 КРУГОВОЙ ПРОГРЕСС ВОКРУГ ВСЕГО BOTTOMNAV
            SizedBox(
              width: MediaQuery.of(context).size.width - 24,
              height: 56,
              child: CustomPaint(
                painter: BottomNavProgressPainter(
                  progress: seconds / 60,
                  color: isUrgent ? Colors.red : Colors.orange,
                  strokeWidth: 3,
                ),
              ),
            ),
            // 🔥 СВЕЧЕНИЕ
            Container(
              width: MediaQuery.of(context).size.width - 24,
              height: 56,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(50),
                boxShadow: [
                  BoxShadow(
                    color: (isUrgent ? Colors.red : Colors.orange).withOpacity(0.15),
                    blurRadius: 25,
                    spreadRadius: 5,
                  ),
                ],
              ),
            ),
            // 🔥 ЦИФРЫ В ЦЕНТРЕ
            Container(
              width: 40,
              height: 40,
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
                    fontSize: 16,
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

// 🔥 КАСТОМНЫЙ ПАИНТЕР ДЛЯ РИСОВАНИЯ ДУГИ ВОКРУГ BOTTOMNAV
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

    // 🔥 ФОНОВАЯ ДУГА (серая)
    final backgroundPaint = Paint()
      ..color = Colors.grey.withOpacity(0.2)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;

    final backgroundPath = Path()..addRRect(RRect.fromRectAndRadius(rect, Radius.circular(radius)));
    canvas.drawPath(backgroundPath, backgroundPaint);

    // 🔥 ПРОГРЕСС ДУГА (цветная)
    if (progress > 0) {
      final progressPaint = Paint()
        ..color = color
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth
        ..strokeCap = StrokeCap.round;

      final progressPath = Path();
      final startAngle = -90 * (3.14159 / 180);
      final sweepAngle = 360 * (3.14159 / 180) * progress;

      // Рисуем дугу по периметру скруглённого прямоугольника
      final path = Path()
        ..addRRect(RRect.fromRectAndRadius(rect, Radius.circular(radius)));

      // Измеряем длину пути
      final metrics = path.computeMetrics();
      double totalLength = 0;
      for (final metric in metrics) {
        totalLength += metric.length;
      }

      // Рисуем прогресс
      double drawnLength = 0;
      for (final metric in metrics) {
        final segmentLength = metric.length;
        final segmentProgress = segmentLength / totalLength;
        final start = drawnLength / totalLength;
        final end = start + segmentProgress;

        // Вычисляем, сколько нужно нарисовать на этом сегменте
        final progressStart = progress.clamp(0.0, 1.0);
        final segmentStart = start;
        final segmentEnd = end;

        if (progressStart > segmentStart && progressStart > 0) {
          final localStart = 0.0;
          final localEnd = ((progressStart - segmentStart) / segmentProgress).clamp(0.0, 1.0);
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