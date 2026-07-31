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

    final Color fillColor = _currentSeconds <= 10
        ? Colors.red.withOpacity(0.25)
        : theme.primaryColor.withOpacity(0.15);

    return Stack(
      children: [
        // 🔥 ПРОГРЕСС СНИЗУ ВВЕРХ
        Container(
          width: widget.width,
          height: widget.height,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(widget.borderRadius),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(widget.borderRadius),
            child: Align(
              alignment: Alignment.bottomCenter,
              child: Container(
                width: widget.width,
                height: widget.height * progress,
                decoration: BoxDecoration(
                  color: fillColor,
                ),
              ),
            ),
          ),
        ),
        // 🔥 КРУГЛЫЙ ФОН ДЛЯ ЦИФР
        Positioned(
          top: 2,
          left: 46,
          child: Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: isDark
                  ? Colors.black.withOpacity(0.7)
                  : AppTheme.lightTheme.primaryColor.withOpacity(0),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                '$_currentSeconds',
                style: TextStyle(
                  color:
                      _currentSeconds <= 10 ? Colors.red : Colors.grey.shade700,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
