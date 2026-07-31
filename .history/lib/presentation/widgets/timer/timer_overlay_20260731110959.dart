import 'package:flutter/material.dart';
import 'timer_controller.dart';

class TimerOverlay extends StatefulWidget {
  final int seconds;
  final VoidCallback? onComplete;
  final double width;
  final double height;
  final double strokeWidth;
  final double borderRadius;

  const TimerOverlay({
    super.key,
    required this.seconds,
    this.onComplete,
    required this.width,
    required this.height,
    this.strokeWidth = 4,
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
    // 🔥 ПРОГРЕСС УМЕНЬШАЕТСЯ (от 1 к 0)
    final progress = _currentSeconds / widget.seconds;

    return Container(
      width: widget.width,
      height: widget.height,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(widget.borderRadius),
        border: Border.all(
          color: Colors.grey.withOpacity(0.3),
          width: widget.strokeWidth,
        ),
      ),
      child: Stack(
        children: [
          // 🔥 ПРОГРЕСС (СВЕРХУ ВНИЗ)
          ClipRRect(
            borderRadius: BorderRadius.circular(widget.borderRadius),
            child: Align(
              alignment: Alignment.topCenter, // 🔥 ПРИЖИМАЕМ К ВЕРХУ
              child: Container(
                width: widget.width,
                height: widget.height * progress, // 🔥 УМЕНЬШАЕТСЯ
                decoration: BoxDecoration(
                  color: theme.primaryColor.withOpacity(0.15),
                ),
              ),
            ),
          ),
          // 🔥 ОБВОДКА (поверх)
          Container(
            width: widget.width,
            height: widget.height,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(widget.borderRadius),
              border: Border.all(
                color: theme.primaryColor,
                width: widget.strokeWidth,
              ),
            ),
          ),
          // 🔥 СЕКУНДЫ ПО ЦЕНТРУ
          Center(
            child: Text(
              '$_currentSeconds',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
