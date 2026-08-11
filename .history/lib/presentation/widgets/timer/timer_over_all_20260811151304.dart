// lib/presentation/widgets/timer/timer_over_all.dart (обводка)
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
            boxShadow: [
              BoxShadow(
                color: (isUrgent ? Colors.red : Colors.orange).withOpacity(0.2),
                blurRadius: 15,
                spreadRadius: 5,
              ),
            ],
          ),
          child: CustomPaint(
            painter: BottomNavGradientPainter(
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

class BottomNavGradientPainter extends CustomPainter {
  final double progress;
  final Color color;
  final double strokeWidth;

  BottomNavGradientPainter({
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

    final path = Path()
      ..addRRect(RRect.fromRectAndRadius(rect, Radius.circular(radius)));
    canvas.drawPath(path, backgroundPaint);

    // 🔥 ПРОГРЕСС (градиентная обводка)
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

      // Рисуем дугу
      final path = Path();
      // Используем простой подход — рисуем по периметру
      final startAngle = -90 * (3.14159 / 180);
      final sweepAngle = 360 * (3.14159 / 180) * progress;

      // Для скруглённого прямоугольника рисуем по краям
      final centerX = size.width / 2;
      final centerY = size.height / 2;

      // Упрощённо — рисуем дугу на верхней части
      final arcRect = Rect.fromLTWH(
        strokeWidth / 2,
        strokeWidth / 2,
        size.width - strokeWidth,
        size.height - strokeWidth,
      );

      canvas.drawArc(
        arcRect,
        startAngle,
        sweepAngle,
        false,
        progressPaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    if (oldDelegate is BottomNavGradientPainter) {
      return oldDelegate.progress != progress ||
          oldDelegate.color != color ||
          oldDelegate.strokeWidth != strokeWidth;
    }
    return true;
  }
}
