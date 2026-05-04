import 'package:hive_ce/hive.dart';

part 'phase.g.dart';

@HiveType(typeId: 5)
class Phase {
  @HiveField(0)
  final int id;

  @HiveField(1)
  final String name; // 'night', 'day', 'voting'

  const Phase({
    required this.id,
    required this.name,
  });
}