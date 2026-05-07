import 'dart:async';

class TimerController {
  final int totalSeconds;
  final VoidCallback? onTick;
  final VoidCallback? onComplete;
  
  int _remaining;
  Timer? _timer;
  bool _isActive = false;
  
  TimerController({
    required this.totalSeconds,
    this.onTick,
    this.onComplete,
  }) : _remaining = totalSeconds;
  
  int get remaining => _remaining;
  bool get isActive => _isActive;
  double get progress => (_remaining / totalSeconds).clamp(0.0, 1.0);
  
  void start() {
    if (_isActive) return;
    _isActive = true;
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_remaining <= 1) {
        _stop();
        onComplete?.call();
      } else {
        _remaining--;
        onTick?.call();
      }
    });
  }
  
  void stop() {
    _stop();
  }
  
  void reset() {
    _stop();
    _remaining = totalSeconds;
    _isActive = false;
  }
  
  void _stop() {
    _timer?.cancel();
    _timer = null;
    _isActive = false;
  }
  
  void dispose() {
    _timer?.cancel();
  }
}