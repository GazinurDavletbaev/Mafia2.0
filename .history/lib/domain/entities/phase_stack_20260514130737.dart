import 'package:hive_ce/hive.dart';
import '../../data/local/models/sub_phase.dart';

part 'phase_stack.g.dart';

@HiveType(typeId: 20)
class PhaseStack {
  @HiveField(0)
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