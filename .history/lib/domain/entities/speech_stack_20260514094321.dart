// lib/domain/entities/speech_stack.dart

class SpeechStack {
  final List<int> _history = [];
  
  void push(int seatNumber) {
    _history.add(seatNumber);
  }
  
  void pop() {
    if (_history.isNotEmpty) _history.removeLast();
  }
  
  int? get current => _history.isEmpty ? null : _history.last;
  
  bool get isEmpty => _history.isEmpty;
  
  void clear() {
    _history.clear();
  }
}