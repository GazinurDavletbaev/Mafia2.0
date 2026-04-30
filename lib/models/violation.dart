import 'package:hive_ce/hive.dart';

part 'violation.g.dart';

@HiveType(typeId: 8)
class Violation {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String gameId;

  @HiveField(2)
  final int playerSeatNumber;

  @HiveField(3)
  final int ruleId;

  @HiveField(4)
  final int phaseId;

  const Violation({
    required this.id,
    required this.gameId,
    required this.playerSeatNumber,
    required this.ruleId,
    required this.phaseId,
  });
}