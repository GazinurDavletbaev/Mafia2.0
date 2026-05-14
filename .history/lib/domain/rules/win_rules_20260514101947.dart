class WinRules {
  /// Проверяет, закончена ли игра и кто победил.
  /// - null: игра не закончена
  /// - true: победили красные
  /// - false: победили чёрные
  bool? check({
    required int blackAlive,
    required int redAlive,
    required int totalAlive,
  }) {
    if (blackAlive == 0) return true;
    if (redAlive <= blackAlive) return false;
    if (totalAlive < 3) return false;
    return null;
  }
}