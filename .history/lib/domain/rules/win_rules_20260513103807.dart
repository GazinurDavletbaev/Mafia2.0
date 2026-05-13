// lib/domain/rules/win_checker.dart

class WinChecker {
  /// Проверяет, закончена ли игра и кто победил.
  /// Возвращает:
  /// - null: игра не закончена
  /// - true: победили красные
  /// - false: победили чёрные
  bool? check({
    required int blackAlive,
    required int redAlive,
    required int totalAlive,
  }) {
    if (blackAlive == 0) return true;

    // Красных меньше или равно чёрным → победа чёрных
    if (redAlive <= blackAlive) return false;

    // Живых игроков меньше 3 → победа чёрных
    if (totalAlive < 3) return false;

    // Игра продолжается
    return null;
  }
}