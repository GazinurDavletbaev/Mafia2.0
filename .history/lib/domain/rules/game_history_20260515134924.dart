// lib/domain/rules/game_history.dart

import '../../presentation/state/game_state.dart';

class GameHistory {
  final List<GameState> _states = [];
  
  void push(GameState state) {
    _states.add(state);
  }
  
  GameState pop() {
    if (_states.length <= 1) return _states.last;
    _states.removeLast();
    return _states.last;
  }
  
  GameState get current => _states.last;
  
  bool get canPop => _states.length > 1;
  GameState get last => _states.last;
List<GameState> get states => List.unmodifiable(_states);
  void clear() {
    _states.clear();
  }
  
  int get length => _states.length;
}