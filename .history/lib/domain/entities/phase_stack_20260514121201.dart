// lib/domain/entities/phase_stack.dart

class PhaseStack {
  final List<dynamic> history = [];
  
  void push(dynamic phase) {
    history.add(phase);
  }
  
  void pop() {
    if (history.isNotEmpty) history.removeLast();
  }
  
  dynamic get current => history.isEmpty ? null : history.last;
  
  bool get isEmpty => history.isEmpty;
  
  void clear() => history.clear();
}