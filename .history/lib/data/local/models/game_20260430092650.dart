import 'package:hive_ce/hive.dart';

part 'game.g.dart';

@HiveType(typeId: 2)
class Game {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String clubId;

  @HiveField(2)
  final String judgeId;

  @HiveField(3)
  final DateTime date;

  @HiveField(4)
  final String winningTeam; // 'red' или 'black'

  @HiveField(5)
  final String status; // 'in_progress', 'completed'

  const Game({
    required this.id,
    required this.clubId,
    required this.judgeId,
    required this.date,
    required this.winningTeam,
    required this.status,
  });
}