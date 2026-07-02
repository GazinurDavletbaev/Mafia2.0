import 'package:flutter/material.dart';
import 'timer_controller.dart';

class TimerOverlay extends StatefulWidget {
  final int seconds;
  final VoidCallback? onComplete;
  final double radius;

  const TimerOverlay({
    super.key,
    required this.seconds,
    this.onComplete,
    required this.radius,
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
    final isDark = theme.brightness == Brightness.dark;

    return Center(
      child: Container(
        width: widget.radius * 2,
        height: widget.radius * 2,
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.8),
          shape: BoxShape.circle,
          border: Border.all(
            color: isDark ? Colors.white : Colors.black87,
            width: 3,
          ),
        ),
        child: Center(
          child: Text(
            '$_currentSeconds',
            style: TextStyle(
              color: isDark ? Colors.white : Colors.black87,
              fontSize: 32,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }
}
