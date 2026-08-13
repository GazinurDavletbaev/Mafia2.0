// lib/domain/constants/protocol_constants.dart

class ProtocolConstants {
  // 🔥 ПРАВИЛА УДАЛЕНИЯ (бизнес-логика)
  static const List<String> removalRules = [
    'п.8.4.1',
    'п.8.4.2',
    'п.8.4.3',
    'п.8.5.1',
    'п.8.5.2',
  ];

  // 🔥 ЗНАЧЕНИЯ БОНУСОВ (бизнес-логика)
  static const List<double> bonusValues = [
    0.0, 0.1, 0.2, 0.3, 0.4, 0.5, 0.6, 0.7
  ];

  // 🔥 КОРОТКИЕ НАЗВАНИЯ РОЛЕЙ (бизнес-логика)
  static const Map<String, String> roleShortNames = {
    'don': 'Д',
    'mafia': 'Ч',
    'sheriff': 'Ш',
    'citizen': 'К',
  };

  // 🔥 СТАТУСЫ ИГРОКОВ
  static const String statusPpk = 'ППК';
  static const String statusRemoved = 'Удалён';
  static const String statusActive = 'Активен';
}