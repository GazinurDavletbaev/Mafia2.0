import 'package:flutter/material.dart';
import 'timer_controller.dart';

class TimerOverlay extends StatefulWidget {
  final int seconds;
  final VoidCallback? onComplete;
  final double width;
  final double height;
  final double strokeWidth;

  const TimerOverlay({
    super.key,
    required this.seconds,
    this.onComplete,
    required this.width,
    required this.height,
    this.strokeWidth = 4,
  });

  @override
  State<TimerOverlay> createState() => _TimerOverlayState();
}

class _TimerOverlayState extends State<TimerOverlay> {
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
          _currentSeconds = _controller.remaining;
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

    return CustomPaint(
      painter: OvalTimerPainter(
        progress: progress,
        color: theme.primaryColor,
        width: widget.width,
        height: widget.height,
        strokeWidth: widget.strokeWidth,
      ),
      child: Center(
        child: Text(
          '$_currentSeconds',
          style: const TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}

class OvalTimerPainter extends CustomPainter {
  final double progress;
  final Color color;
  final double width;
  final double height;
  final double strokeWidth;

  OvalTimerPainter({
    required this.progress,
    required this.color,
    required this.width,
    required this.height,
    required this.strokeWidth,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final rect = Rect.fromCenter(
      center: center,
      width: width,
      height: height,
    );

    // 🔥 ФОН (серая линия)
    final backgroundPaint = Paint()
      ..color = Colors.grey.withOpacity(0.3)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;

    canvas.drawArc(
      rect,
      -90 * (3.14159 / 180),
      360 * (3.14159 / 180),
      false,
      backgroundPaint,
    );

    // 🔥 ПРОГРЕСС (оранжевая линия)
    final progressPaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(
      rect,
      -90 * (3.14159 / 180),
      360 * (3.14159 / 180) * progress,
      false,
      progressPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    if (oldDelegate is OvalTimerPainter) {
      return oldDelegate.progress != progress ||
          oldDelegate.color != color ||
          oldDelegate.width != width ||
          oldDelegate.height != height ||
          oldDelegate.strokeWidth != strokeWidth;
    }
    return true;
  }
}
