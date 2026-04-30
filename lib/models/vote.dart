import 'package:hive_ce/hive.dart';

part 'vote.g.dart';

@HiveType(typeId: 7)
class Vote {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String gameId;

  @HiveField(2)
  final int round;

  @HiveField(3)
  final int targetSeatNumber; // на кого голосуют (место)

  @HiveField(4)
  final int votesCount; // сколько голосов получил

  const Vote({
    required this.id,
    required this.gameId,
    required this.round,
    required this.targetSeatNumber,
    required this.votesCount,
  });
}