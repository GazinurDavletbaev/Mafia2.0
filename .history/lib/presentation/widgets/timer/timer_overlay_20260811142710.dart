// lib/presentation/widgets/timer/timer_overlay.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mafia_help/application/providers/timer_provider.dart';

class TimerOverlay extends ConsumerStatefulWidget {
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
  ConsumerState<TimerOverlay> createState() => _TimerOverlayState();
}

class _TimerOverlayState extends ConsumerState<TimerOverlay> {
  int _currentSeconds = 0;

  @override
  void initState() {
    super.initState();
    _currentSeconds = widget.seconds;

    // 🔥 ОБЕРНУТЬ В addPostFrameCallback
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _startTimer();
      }
    });
  }

  void _startTimer() {
    final timerNotifier = ref.read(timerProvider.notifier);

    timerNotifier.startTimer(
      seconds: widget.seconds,
      onComplete: () {
        if (mounted) {
          widget.onComplete?.call();
        }
      },
    );
  }

  @override
  void didUpdateWidget(covariant TimerOverlay oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.seconds != widget.seconds) {
      // 🔥 ОБЕРНУТЬ В addPostFrameCallback
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          final timerNotifier = ref.read(timerProvider.notifier);
          timerNotifier.startTimer(
            seconds: widget.seconds,
            onComplete: () {
              if (mounted) {
                widget.onComplete?.call();
              }
            },
          );
        }
      });
    }
  }

  @override
  void dispose() {
    // 🔥 НЕ ОСТАНАВЛИВАЕМ ТАЙМЕР ПРИ DISPOSE!
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final timerState = ref.watch(timerProvider);
    final currentSeconds = timerState.remainingSeconds;

    if (_currentSeconds != currentSeconds) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          setState(() {
            _currentSeconds = currentSeconds;
          });
        }
      });
    }

    final progress = _currentSeconds / widget.seconds;

    return SizedBox(
      width: widget.width,
      height: widget.height,
      child: Stack(
        alignment: Alignment.center,
        children: [
          CustomPaint(
            size: Size(widget.width, widget.height),
            painter: CircularProgressPainter(
              progress: progress.clamp(0.0, 1.0),
              color: _currentSeconds <= 10 ? Colors.red : Colors.green.shade400,
              strokeWidth: 3,
            ),
          ),
          Container(
            width: widget.width * 0.7,
            height: widget.height * 0.7,
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.5),
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

    final backgroundPaint = Paint()
      ..color = Colors.grey.withOpacity(0.3)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;

    canvas.drawCircle(center, radius, backgroundPaint);

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