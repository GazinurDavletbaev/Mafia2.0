import 'package:hive_ce/hive.dart';

part 'user.g.dart';

@HiveType(typeId: 0)
class User {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String nickname;

  @HiveField(2)
  final String club;

  @HiveField(3)
  final String city;

  const Club({
    required this.id,
    required this.title,
    required this.president,
    required this.city,
  });
}