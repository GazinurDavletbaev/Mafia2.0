// lib/domain/rules/game_history.dart

import '../../presentation/state/game_state.dart';

class GameHistory {
  final List<GameState> states = [];

  void push(GameState state) {
    states.add(state);
  }

  GameState pop() {
    if (states.length <= 1) return states.last;
    states.removeLast();
    return states.last;
  }

  GameState get current => states.last;

  bool get canPop => states.length > 1;
  GameState get last => _states.last;
  List<GameState> get states => List.unmodifiable(states);
  void clear() {
    states.clear();
  }

  int get length => _states.length;
}
