import '../../data/local/models/sub_phase.dart';

class PhaseStack {
  final List<SubPhase> history = [];
  
  void push(SubPhase phase) {
    history.add(phase);
  }
  
  void pop() {
    if (history.isNotEmpty) history.removeLast();
  }
  
  SubPhase? get current => history.isEmpty ? null : history.last;
  
  bool get isEmpty => history.isEmpty;
  
  void clear() => history.clear();
}