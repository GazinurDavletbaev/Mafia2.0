import 'package:hive_ce/hive.dart';

part 'role.g.dart';

@HiveType(typeId: 4)
class Role {
  @HiveField(0)
  final int id;

  @HiveField(1)
  final String name; // 'мирный', 'шериф', 'мафия', 'дон'

  @HiveField(2)
  final String team; // 'red' или 'black'

  const Role({
    required this.id,
    required this.name,
    required this.team,
  });
}