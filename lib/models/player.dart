import 'package:hive_ce/hive.dart';

part 'player.g.dart';

@HiveType(typeId: 3)
class Player {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String gameId;

  @HiveField(2)
  final String? userId; // может быть null (неавторизованный игрок)

  @HiveField(3)
  final String? customName; // для неавторизованных игроков

  @HiveField(4)
  final int seatNumber; // 1–10

  @HiveField(5)
  final int roleId;

  @HiveField(6)
  final int score;

  @HiveField(7)
  final bool isAlive;

  const Player({
    required this.id,
    required this.gameId,
    this.userId,
    this.customName,
    required this.seatNumber,
    required this.roleId,
    required this.score,
    required this.isAlive,
  });
}