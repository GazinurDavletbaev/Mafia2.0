import 'package:hive_ce/hive.dart';

part 'vote_stack.g.dart';

@HiveType(typeId: 22)
class VoteStack {
  @HiveField(0)
  final List<Map<int, int>> history = [];
  
  void push(Map<int, int> votes) {
    history.add(Map.from(votes));
  }
  
  void pop() {
    if (history.isNotEmpty) history.removeLast();
  }
  
  Map<int, int> get current => history.isEmpty ? {} : Map.from(history.last);
  
  bool get isEmpty => history.isEmpty;
  
  void clear() => history.clear();
}