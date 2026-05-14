import 'package:hive_ce/hive.dart';

part 'speech_stack.g.dart';

@HiveType(typeId: 21)
class SpeechStack {
  @HiveField(0)
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