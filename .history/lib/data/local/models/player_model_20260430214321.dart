import 'package:hive_ce/hive.dart';

part 'player_model.g.dart';

@HiveType(typeId: 13)
class PlayerModel {
  @HiveField(0)
  final int seatNumber;        // 1–10

  @HiveField(1)
  final String name;           // никнейм или 'Игрок X'

  @HiveField(2)
  final String team;           // 'red' или 'black'

  @HiveField(3)
  final String role;           // 'peaceful', 'sheriff', 'mafia', 'don'

  @HiveField(4)
  final bool isAlive;

  @HiveField(5)
  final int fouls;             // 0–4 (4 = удалён)

  @HiveField(6)
  final bool isSpeaking;       // сейчас говорит (только для дня)

  const PlayerModel({
    required this.seatNumber,
    required this.name,
    required this.team,
    required this.role,
    required this.isAlive,
    required this.fouls,
    required this.isSpeaking,
  });

  PlayerModel copyWith({
    int? seatNumber,
    String? name,
    String? team,
    String? role,
    bool? isAlive,
    int? fouls,
    bool? isSpeaking,
  }) {
    return PlayerModel(
      seatNumber: seatNumber ?? this.seatNumber,
      name: name ?? this.name,
      team: team ?? this.team,
      role: role ?? this.role,
      isAlive: isAlive ?? this.isAlive,
      fouls: fouls ?? this.fouls,
      isSpeaking: isSpeaking ?? this.isSpeaking,
    );
  }
}