import 'package:hive_ce/hive.dart';

part 'game_log.g.dart';

@HiveType(typeId: 11)
class GameLog {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String gameId;

  @HiveField(2)
  final int phaseId; // ссылка на фазу (ночь/день/голосование)

  @HiveField(3)
  final String actionType; // 'kill', 'vote', 'violation', 'best_move', 'phase_change'

  @HiveField(4)
  final String description; // текстовое описание действия

  @HiveField(5)
  final DateTime timestamp;

  const GameLog({
    required this.id,
    required this.gameId,
    required this.phaseId,
    required this.actionType,
    required this.description,
    required this.timestamp,
  });
}