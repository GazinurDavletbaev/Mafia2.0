// lib/services/timer_service.dart
import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final timerServiceProvider = Provider<TimerService>((ref) {
  return TimerService();
});

class TimerService {
  Timer? _timer;
  int _remainingSeconds = 0;
  int _initialSeconds = 0;
  bool _isRunning = false;
  VoidCallback? _onComplete;

  int get remainingSeconds => _remainingSeconds;
  bool get isRunning => _isRunning;

  void startTimer({
    required int seconds,
    VoidCallback? onComplete,
    Function(int)? onTick,
  }) {
    // Останавливаем старый таймер
    stopTimer();

    _initialSeconds = seconds;
    _remainingSeconds = seconds;
    _isRunning = true;
    _onComplete = onComplete;

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_remainingSeconds <= 0) {
        stopTimer();
        _onComplete?.call();
        return;
      }

      _remainingSeconds--;
      onTick?.call(_remainingSeconds);
    });
  }

  void stopTimer() {
    _timer?.cancel();
    _timer = null;
    _isRunning = false;
    _remainingSeconds = 0;
  }

  void pauseTimer() {
    _timer?.cancel();
    _timer = null;
    _isRunning = false;
  }

  void resumeTimer({
    VoidCallback? onComplete,
    Function(int)? onTick,
  }) {
    if (_remainingSeconds <= 0) {
      _onComplete?.call();
      return;
    }

    _isRunning = true;
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_remainingSeconds <= 0) {
        stopTimer();
        _onComplete?.call();
        return;
      }

      _remainingSeconds--;
      onTick?.call(_remainingSeconds);
    });
  }

  void dispose() {
    _timer?.cancel();
    _timer = null;
  }
}