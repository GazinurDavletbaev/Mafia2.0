class FoulRules {
  (int newFouls, bool newIsAlive) addFoul({
    required int currentFouls,
    required bool isAlive,
  }) {
    if (!isAlive) return (currentFouls, isAlive);
    final newFouls = currentFouls + 1;
    if (newFouls == 4) {
      return (newFouls, false);
    }
    if (newFouls == 5) {
      return (0, true);
    }
    // 0→1, 1→2, 2→3: без изменений isAlive
    return (newFouls, true);
  }
}