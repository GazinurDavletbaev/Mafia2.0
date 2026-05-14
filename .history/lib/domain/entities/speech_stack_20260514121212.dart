// lib/domain/entities/speech_stack.dart

class SpeechStack {
  final List<int> history = [];
  
  void push(int seat) {
    history.add(seat);
  }
  
  void pop() {
    if (history.isNotEmpty) history.removeLast();
  }
  
  int? get current => history.isEmpty ? null : history.last;
  
  bool get isEmpty => history.isEmpty;
  
  void clear() => history.clear();
}