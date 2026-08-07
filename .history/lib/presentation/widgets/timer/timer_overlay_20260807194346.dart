import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mafia_help/application/providers/timer_provider.dart';
import 'package:mafia_help/core/themes/app_theme.dart';
import 'timer_controller.dart';

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

class _TimerOverlayState extends ConsumerState<TimerOverlay>
    with SingleTickerProviderStateMixin {
  late TimerController _controller;
  int _currentSeconds = 0;

  @override
  void initState() {
    super.initState();
    _currentSeconds = widget.seconds;

    print('🔥🔥🔥 TimerOverlay INIT: секунды = ${widget.seconds}'); // 👈 ЛОГ

    _controller = TimerController(
      totalSeconds: widget.seconds,
      onTick: () {
        final remaining = _controller.remaining;
        print('🔥🔥🔥 TimerOverlay TICK: remaining = $remaining'); // 👈 ЛОГ
        setState(() {
          _currentSeconds = remaining;
        });
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) {
            print(
                '🔥🔥🔥 обновляем floatingTimerProvider: $remaining'); // 👈 ЛОГ
            ref.read(floatingTimerProvider.notifier).state = remaining;
          }
        });
      },
      onComplete: () {
        print('🔥🔥🔥 TimerOverlay COMPLETE'); // 👈 ЛОГ
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) {
            ref.read(floatingTimerProvider.notifier).state = null;
          }
        });
        widget.onComplete?.call();
      },
    );
    _controller.start();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        print('🔥🔥🔥 показать floatingTimer: ${widget.seconds}'); // 👈 ЛОГ
        ref.read(floatingTimerProvider.notifier).state = widget.seconds;
      }
    });
  }

  @override
  void didUpdateWidget(covariant TimerOverlay oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.seconds != widget.seconds) {
      _controller.reset();
      _controller = TimerController(
        totalSeconds: widget.seconds,
        onTick: () {
          final remaining = _controller.remaining;
          setState(() {
            _currentSeconds = remaining;
          });
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) {
              ref.read(floatingTimerProvider.notifier).state = remaining;
            }
          });
        },
        onComplete: () {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) {
              ref.read(floatingTimerProvider.notifier).state = null;
            }
          });
          widget.onComplete?.call();
        },
      );
      _controller.start();
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          ref.read(floatingTimerProvider.notifier).state = widget.seconds;
        }
      });
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        ref.read(floatingTimerProvider.notifier).state = null;
      }
    });
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
          CustomPaint(
            size: Size(widget.width, widget.height),
            painter: CircularProgressPainter(
              progress: progress,
              color: progressColor,
              strokeWidth: 3,
            ),
          ),
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
