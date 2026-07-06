import 'package:hive_ce/hive.dart';

part 'user.g.dart';

@HiveType(typeId: 1)
class User {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String nickname;

  @HiveField(2)
  final String clubId;

  @HiveField(3)
  final String city;

  @HiveField(4)
  final String avatarUrl;

  const User({
    required this.id,
    required this.nickname,
    required this.clubId,
    required this.city,
    required this.avatarUrl,
  });
}