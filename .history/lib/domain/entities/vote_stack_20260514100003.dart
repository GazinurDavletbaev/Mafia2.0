// lib/domain/entities/vote_stack.dart

class VoteStack {
  final List<Map<int, int>> _history = []; // каждый элемент - голоса за кандидатов
  
  void push(Map<int, int> votes) => _history.add(Map.from(votes));
  
  void pop() {
    if (_history.length > 1) _history.removeLast();
  }
  
  Map<int, int> get current => _history.isEmpty ? {} : Map.from(_history.last);
  
  bool get isEmpty => _history.isEmpty;
  
  void clear() => _history.clear();
}