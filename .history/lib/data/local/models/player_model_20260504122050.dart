import 'package:hive_ce/hive.dart';

part 'player_model.g.dart';

@HiveType(typeId: 13)
class PlayerModel {
  @HiveField(0)
  final int seatNumber;

  @HiveField(1)
  final String name;

  @HiveField(2)
  final String team;

  @HiveField(3)
  final String role;

  @HiveField(4)
  final bool isAlive;

  @HiveField(5)
  final int fouls;

  @HiveField(6)
  final bool isSpeaking;

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

  Map<String, dynamic> toJson() {
    return {
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