// lib/application/providers/timer_provider.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:async';

// 🔥 ГЛОБАЛЬНЫЙ ТАЙМЕР ДЛЯ ОТОБРАЖЕНИЯ (TimerOverAll)
final floatingTimerProvider = StateProvider<int?>((ref) => null);

// 🔥 СОСТОЯНИЕ ТАЙМЕРА
class TimerState {
  final int remainingSeconds;
  final bool isRunning;
  final int initialSeconds;

  const TimerState({
    required this.remainingSeconds,
    required this.isRunning,
    required this.initialSeconds,
  });

  factory TimerState.initial() {
    return const TimerState(
      remainingSeconds: 60,
      isRunning: false,
      initialSeconds: 60,
    );
  }

  TimerState copyWith({
    int? remainingSeconds,
    bool? isRunning,
    int? initialSeconds,
  }) {
    return TimerState(
      remainingSeconds: remainingSeconds ?? this.remainingSeconds,
      isRunning: isRunning ?? this.isRunning,
      initialSeconds: initialSeconds ?? this.initialSeconds,
    );
  }
}

class TimerNotifier extends StateNotifier<TimerState> {
  final Ref _ref;
  Timer? _timer;
  VoidCallback? _onComplete;

  TimerNotifier(this._ref) : super(TimerState.initial());

  // 🔥 ЗАПУСК ТАЙМЕРА С КОЛБЭКОМ
  void startTimer({
    required int seconds,
    VoidCallback? onComplete,
  }) {
    // Останавливаем старый таймер
    _stopTimer();

    _onComplete = onComplete;

    // Обновляем состояние
    state = TimerState(
      remainingSeconds: seconds,
      isRunning: true,
      initialSeconds: seconds,
    );

    // 🔥 ОБНОВЛЯЕМ ГЛОБАЛЬНЫЙ floatingTimerProvider
    _ref.read(floatingTimerProvider.notifier).state = seconds;

    // Запускаем периодический таймер
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (state.remainingSeconds <= 0) {
        _stopTimer();
        _onComplete?.call();
        _ref.read(floatingTimerProvider.notifier).state = null;
        return;
      }

      // Уменьшаем секунды
      state = state.copyWith(
        remainingSeconds: state.remainingSeconds - 1,
      );

      // 🔥 ОБНОВЛЯЕМ ГЛОБАЛЬНЫЙ floatingTimerProvider
      _ref.read(floatingTimerProvider.notifier).state = state.remainingSeconds;
    });
  }

  // 🔥 ПАУЗА (сохраняем текущие секунды)
  void pauseTimer() {
    _timer?.cancel();
    _timer = null;
    state = state.copyWith(isRunning: false);
    // floatingTimerProvider оставляем как есть (показываем последнее значение)
  }

  // 🔥 ВОЗОБНОВЛЕНИЕ
  void resumeTimer({VoidCallback? onComplete}) {
    if (state.remainingSeconds <= 0) {
      _onComplete?.call();
      _ref.read(floatingTimerProvider.notifier).state = null;
      return;
    }

    _onComplete = onComplete ?? _onComplete;

    // Если таймер уже запущен — не перезапускаем
    if (_timer != null && state.isRunning) {
      return;
    }

    state = state.copyWith(isRunning: true);

    // 🔥 ОБНОВЛЯЕМ ГЛОБАЛЬНЫЙ floatingTimerProvider
    _ref.read(floatingTimerProvider.notifier).state = state.remainingSeconds;

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (state.remainingSeconds <= 0) {
        _stopTimer();
        _onComplete?.call();
        _ref.read(floatingTimerProvider.notifier).state = null;
        return;
      }

      state = state.copyWith(
        remainingSeconds: state.remainingSeconds - 1,
      );

      _ref.read(floatingTimerProvider.notifier).state = state.remainingSeconds;
    });
  }

  // 🔥 ОСТАНОВКА
  void stopTimer() {
    _stopTimer();
    state = state.copyWith(
      remainingSeconds: 0,
      isRunning: false,
    );
    _ref.read(floatingTimerProvider.notifier).state = null;
  }

  void _stopTimer() {
    _timer?.cancel();
    _timer = null;
  }

  // 🔥 СБРОС
  void resetTimer() {
    _stopTimer();
    state = TimerState.initial();
    _ref.read(floatingTimerProvider.notifier).state = null;
  }

  // 🔥 УСТАНОВИТЬ СЕКУНДЫ (без запуска)
  void setSeconds(int seconds) {
    state = state.copyWith(
      remainingSeconds: seconds,
      initialSeconds: seconds,
      isRunning: false,
    );
    _ref.read(floatingTimerProvider.notifier).state = seconds;
  }

  // 🔥 ТИК (для ручного обновления)
  void tick() {
    if (state.isRunning && state.remainingSeconds > 0) {
      state = state.copyWith(remainingSeconds: state.remainingSeconds - 1);
      _ref.read(floatingTimerProvider.notifier).state = state.remainingSeconds;
    } else if (state.remainingSeconds == 0) {
      state = state.copyWith(isRunning: false);
      _ref.read(floatingTimerProvider.notifier).state = null;
    }
  }

  @override
  void dispose() {
    _stopTimer();
    super.dispose();
  }
}

// 🔥 ОСНОВНОЙ ПРОВАЙДЕР
final timerProvider = StateNotifierProvider<TimerNotifier, TimerState>((ref) {
  return TimerNotifier(ref);
});
