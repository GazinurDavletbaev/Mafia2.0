import 'package:flutter/material.dart';
import 'package:mafia_help/core/themes/app_theme.dart';
import 'timer_controller.dart';

class TimerOverlay extends StatefulWidget {
  final int seconds;
  final VoidCallback? onComplete;
  final double width;
  final double height;
  final double borderRadius;

  const TimerOverlay({
    super.key,
    required this.seconds,
    this.onComplete,
    required this.width,
    required this.height,
    this.borderRadius = 50,
  });

  @override
  State<TimerOverlay> createState() => _TimerOverlayState();
}

class _TimerOverlayState extends State<TimerOverlay>
    with SingleTickerProviderStateMixin {
  late TimerController _controller;
  int _currentSeconds = 0;

  @override
  void initState() {
    super.initState();
    _currentSeconds = widget.seconds;
    _controller = TimerController(
      totalSeconds: widget.seconds,
      onTick: () {
        setState(() {
          _currentSeconds = _controller.remaining - 1;
        });
      },
      onComplete: () {
        widget.onComplete?.call();
      },
    );
    _controller.start();
  }

  @override
  void didUpdateWidget(covariant TimerOverlay oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.seconds != widget.seconds) {
      _controller.reset();
      _controller = TimerController(
        totalSeconds: widget.seconds,
        onTick: () {
          setState(() {
            _currentSeconds = _controller.remaining;
          });
        },
        onComplete: () {
          widget.onComplete?.call();
        },
      );
      _controller.start();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final progress = _currentSeconds / widget.seconds;
    final isDark = theme.brightness == Brightness.dark;

    final Color progressColor =
        _currentSeconds <= 10 ? Colors.red : Colors.green.shade400;

    return SizedBox(
      width: widget.width,
      height: widget.height,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // 🔥 КРУГОВОЙ ПРОГРЕСС (как часы)
          CustomPaint(
            size: Size(widget.width, widget.height),
            painter: CircularProgressPainter(
              progress: progress,
              color: progressColor,
              strokeWidth: 3,
            ),
          ),
          // 🔥 ЦИФРЫ ПО ЦЕНТРУ
          Container(
            width: widget.width * 0.7,
            height: widget.height * 0.7,
            decoration: BoxDecoration(
              color:
                  isDark ? Colors.black.withOpacity(0.5) : Colors.grey.shade500,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                '$_currentSeconds',
                style: TextStyle(
                  color: _currentSeconds <= 10 ? Colors.red : Colors.white,
                  fontSize: widget.width * 0.35,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// 🔥 ПАИНТЕР ДЛЯ КРУГОВОГО ПРОГРЕССА
class CircularProgressPainter extends CustomPainter {
  final double progress;
  final Color color;
  final double strokeWidth;

  CircularProgressPainter({
    required this.progress,
    required this.color,
    this.strokeWidth = 3,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    // 🔥 ФОН (серая обводка)
    final backgroundPaint = Paint()
      ..color = Colors.grey.withOpacity(0.3)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;

    canvas.drawCircle(center, radius, backgroundPaint);

    // 🔥 ПРОГРЕСС (цветная обводка)
    final progressPaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    final startAngle = -90 * (3.14159 / 180);
    final sweepAngle = 360 * (3.14159 / 180) * progress;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      startAngle,
      sweepAngle,
      false,
      progressPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    if (oldDelegate is CircularProgressPainter) {
      return oldDelegate.progress != progress ||
          oldDelegate.color != color ||
          oldDelegate.strokeWidth != strokeWidth;
    }
    return true;
  }
}
