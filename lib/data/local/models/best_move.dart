import 'package:hive_ce/hive.dart';

part 'best_move.g.dart';

@HiveType(typeId: 10)
class BestMove {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String gameId;

  @HiveField(2)
  final int killedSeatNumber; // кто убит (его место за столом)

  @HiveField(3)
  final int suspectSeat1; // первое подозреваемое место

  @HiveField(4)
  final int suspectSeat2; // второе подозреваемое место

  @HiveField(5)
  final int suspectSeat3; // третье подозреваемое место

  const BestMove({
    required this.id,
    required this.gameId,
    required this.killedSeatNumber,
    required this.suspectSeat1,
    required this.suspectSeat2,
    required this.suspectSeat3,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'gameId': gameId,
      'killedSeatNumber': killedSeatNumber,
      'suspectSeat1': suspectSeat1,
      'suspectSeat2': suspectSeat2,
      'suspectSeat3': suspectSeat3,
    };
  }

  factory BestMove.fromJson(Map<String, dynamic> json) {
    return BestMove(
      id: json['id'],
      gameId: json['gameId'],
      killedSeatNumber: json['killedSeatNumber'],
      suspectSeat1: json['suspectSeat1'],
      suspectSeat2: json['suspectSeat2'],
      suspectSeat3: json['suspectSeat3'],
    );
  }
}