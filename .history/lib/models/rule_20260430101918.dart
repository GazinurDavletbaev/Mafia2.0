import 'package:hive_ce/hive.dart';

part 'rule.g.dart';

@HiveType(typeId: 9)
class Rule {
  @HiveField(0)
  final int id;

  @HiveField(1)
  final String paragraph;  // номер пункта правил

  @HiveField(2)
  final String description; // описание нарушения

  @HiveField(3)
  final String punishment;  // наказание (например, 'предупреждение', 'фол', 'дисквалификация')

  const Rule({
    required this.id,
    required this.paragraph,
    required this.description,
    required this.punishment,
  });
}