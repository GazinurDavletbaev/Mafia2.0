import 'package:hive_ce/hive.dart';

part 'player_ui_model.g.dart';

@HiveType(typeId: 12)
class PlayerUIModel {
  @HiveField(0)
  final int seatNumber;      // 1–10

  @HiveField(1)
  final String name;          // 'Игрок 1' или реальный никнейм

  @HiveField(2)
  final String? avatarUrl;    // URL аватарки (если есть)

  @HiveField(3)
  final bool isAlive;         // true = жив, false = мёртв

  @HiveField(4)
  final int fouls;            // количество фолов (0–4)

  @HiveField(5)
  final bool isSpeaking;      // true = сейчас говорит (только в фазе День)

  @HiveField(6)
  final String? role;         // роль (для судьи: 'мафия', 'шериф', 'дон', 'мирный')

  @HiveField(7)
  final String? team;         // 'red' или 'black' (для подсветки)

  const PlayerUIModel({
    required this.seatNumber,
    required this.name,
    this.avatarUrl,
    required this.isAlive,
    required this.fouls,
    required this.isSpeaking,
    this.role,
    this.team,
  });

  // copyWith для обновления полей
  PlayerUIModel copyWith({
    int? seatNumber,
    String? name,
    String? avatarUrl,
    bool? isAlive,
    int? fouls,
    bool? isSpeaking,
    String? role,
    String? team,
  }) {
    return PlayerUIModel(
      seatNumber: seatNumber ?? this.seatNumber,
      name: name ?? this.name,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      isAlive: isAlive ?? this.isAlive,
      fouls: fouls ?? this.fouls,
      isSpeaking: isSpeaking ?? this.isSpeaking,
      role: role ?? this.role,
      team: team ?? this.team,
    );
  }
}