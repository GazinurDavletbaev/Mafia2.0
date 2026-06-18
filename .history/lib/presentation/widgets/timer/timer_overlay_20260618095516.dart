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
    print('=== TIMER OVERLAY INIT ===');
    print('seconds = ${widget.seconds}');
    print('seat = ${widget.key}');
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
    print('=== TIMER OVERLAY DID UPDATE ===');
    print('old seconds = ${oldWidget.seconds}');
    print('new seconds = ${widget.seconds}');
    if (oldWidget.seconds != widget.seconds) {
      print('seconds changed, restarting timer');
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
    print('=== TIMER OVERLAY DISPOSE ===');
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: widget.radius * 2,
        height: widget.radius * 2,
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.8),
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white, width: 3),
        ),
        child: Center(
          child: Text(
            '$_currentSeconds',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 32,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }
}
