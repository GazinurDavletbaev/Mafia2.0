import 'package:flutter_riverpod/flutter_riverpod.dart';

// Состояние таймера
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
  TimerNotifier() : super(TimerState.initial());

  void start() {
    state = state.copyWith(isRunning: true);
  }

  void pause() {
    state = state.copyWith(isRunning: false);
  }

  void stop() {
    state = state.copyWith(
      remainingSeconds: state.initialSeconds,
      isRunning: false,
    );
  }

  void setSeconds(int seconds) {
    state = state.copyWith(
      remainingSeconds: seconds,
      initialSeconds: seconds,
    );
  }

  void tick() {
    if (state.isRunning && state.remainingSeconds > 0) {
      state = state.copyWith(remainingSeconds: state.remainingSeconds - 1);
    } else if (state.remainingSeconds == 0) {
      state = state.copyWith(isRunning: false);
    }
  }

  void reset() {
    state = TimerState.initial();
  }
}

final timerProvider = StateNotifierProvider<TimerNotifier, TimerState>((ref) {
  return TimerNotifier();
});