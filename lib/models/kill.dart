import 'package:hive_ce/hive.dart';

part 'kill.g.dart';

@HiveType(typeId: 6)
class Kill {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String gameId;

  @HiveField(2)
  final int phaseId;

  @HiveField(3)
  final int playerSeatNumber; // кто убит (место за столом)

  @HiveField(4)
  final String type; // 'mafia', 'day_vote', 'don'

  const Kill({
    required this.id,
    required this.gameId,
    required this.phaseId,
    required this.playerSeatNumber,
    required this.type,
  });
}