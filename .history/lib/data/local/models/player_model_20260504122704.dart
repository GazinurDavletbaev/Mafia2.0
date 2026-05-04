import 'package:hive_ce/hive.dart';

part 'player_model.g.dart';

@HiveType(typeId: 13)
class PlayerModel {
  @HiveField(0)
  final String id;  // ← добавить

  @HiveField(1)
  final int seatNumber;

  @HiveField(2)
  final String name;

  @HiveField(3)
  final String team;

  @HiveField(4)
  final String role;

  @HiveField(5)
  final bool isAlive;

  @HiveField(6)
  final int fouls;

  @HiveField(7)
  final bool isSpeaking;

  @HiveField(8)
  final String gameId;

  const PlayerModel({
    required this.id,  // ← добавить
    required this.seatNumber,
    required this.name,
    required this.team,
    required this.role,
    required this.isAlive,
    required this.fouls,
    required this.isSpeaking,
    required this.gameId,
  });

  PlayerModel copyWith({
    String? id,
    int? seatNumber,
    String? name,
    String? team,
    String? role,
    bool? isAlive,
    int? fouls,
    bool? isSpeaking,
  }) {
    return PlayerModel(
      id: id ?? this.id,
      seatNumber: seatNumber ?? this.seatNumber,
      name: name ?? this.name,
      team: team ?? this.team,
      role: role ?? this.role,
      isAlive: isAlive ?? this.isAlive,
      fouls: fouls ?? this.fouls,
      isSpeaking: isSpeaking ?? this.isSpeaking,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'seatNumber': seatNumber,
      'name': name,
      'team': team,
      'role': role,
      'isAlive': isAlive,
      'fouls': fouls,
      'isSpeaking': isSpeaking,
    };
  }

  factory PlayerModel.fromJson(Map<String, dynamic> json) {
    return PlayerModel(
      id: json['id'],
      seatNumber: json['seatNumber'],
      name: json['name'],
      team: json['team'],
      role: json['role'],
      isAlive: json['isAlive'],
      fouls: json['fouls'],
      isSpeaking: json['isSpeaking'],
    );
  }
}