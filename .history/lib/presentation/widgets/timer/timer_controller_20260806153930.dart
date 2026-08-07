import 'dart:async';

class TimerController {
  int _totalSeconds;
  int _remaining;
  bool _isRunning = false;
  Timer? _timer;
  final VoidCallback onTick;
  final VoidCallback onComplete;

  TimerController({
    required int totalSeconds,
    required this.onTick,
    required this.onComplete,
  }) : _totalSeconds = totalSeconds,
       _remaining = totalSeconds;

  int get remaining => _remaining;

  void start() {
    if (_isRunning) return;
    _isRunning = true;
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      _remaining--;
      
      if (_remaining <= 0) {
        _remaining = 0;
        _isRunning = false;
        timer.cancel();
        onTick();
        onComplete();
        return;
      }
      
      onTick();
    });
  }

  void stop() {
    _timer?.cancel();
    _isRunning = false;
  }

  void reset() {
    _timer?.cancel();
    _isRunning = false;
    _remaining = _totalSeconds;
  }

  void dispose() {
    _timer?.cancel();
    _isRunning = false;
  }

  // 🔥 СИНХРОНИЗАЦИЯ
  void sync(int seconds) {
    _remaining = seconds;
    if (onTick != null) {
      onTick();
    }
  }
}