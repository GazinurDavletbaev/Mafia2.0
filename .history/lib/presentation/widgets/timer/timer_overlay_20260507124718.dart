import 'package:flutter/material.dart';
import 'timer_controller.dart';

class TimerOverlay extends StatefulWidget {
  final Widget child;
  final int seconds;
  final VoidCallback? onComplete;
  final Color overlayColor;
  final Color blinkColor;
  
  const TimerOverlay({
    super.key,
    required this.child,
    required this.seconds,
    this.onComplete,
    this.overlayColor = Colors.black87,
    this.blinkColor = Colors.red,
  });
  
  @override
  State<TimerOverlay> createState() => _TimerOverlayState();
}

class _TimerOverlayState extends State<TimerOverlay> with SingleTickerProviderStateMixin {
  late TimerController _controller;
  late AnimationController _blinkController;
  int _currentSeconds = 0;
  bool _isBlinking = false;
  
  @override
  void initState() {
    super.initState();
    _currentSeconds = widget.seconds;
    _controller = TimerController(
      totalSeconds: widget.seconds,
      onTick: () {
        setState(() {
          _currentSeconds = _controller.remaining;
          // Мигаем последние 5 секунд
          if (_currentSeconds <= 5 && _currentSeconds > 0) {
            _startBlinking();
          }
        });
      },
      onComplete: () {
        widget.onComplete?.call();
      },
    );
    
    _blinkController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    )..addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _blinkController.reverse();
      } else if (status == AnimationStatus.dismissed) {
        if (_isBlinking) _blinkController.forward();
      }
    });
    
    _controller.start();
  }
  
  void _startBlinking() {
    if (!_isBlinking) {
      _isBlinking = true;
      _blinkController.forward();
    }
  }
  
  @override
  void dispose() {
    _controller.dispose();
    _blinkController.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _blinkController,
      builder: (context, child) {
        final isVisible = !_isBlinking || _blinkController.value > 0.5;
        
        return Stack(
          children: [
            widget.child,
            if (_controller.isActive)
              Positioned.fill(
                child: Container(
                  color: widget.overlayColor,
                ),
              ),
            if (_controller.isActive)
              Center(
                child: AnimatedOpacity(
                  opacity: isVisible ? 1.0 : 0.0,
                  duration: const Duration(milliseconds: 100),
                  child: Container(
                    width: 150,
                    height: 150,
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.8),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: _currentSeconds <= 5 ? widget.blinkColor : Colors.white,
                        width: 3,
                      ),
                    ),
                    child: Center(
                      child: Text(
                        '$_currentSeconds',
                        style: TextStyle(
                          color: _currentSeconds <= 5 ? widget.blinkColor : Colors.white,
                          fontSize: 48,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}