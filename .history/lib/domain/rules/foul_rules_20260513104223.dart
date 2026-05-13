class FoulRules {
 
  (int newFouls, bool newIsAlive) addFoul({
    required int currentFouls,
    required bool isAlive,
  }) {
    // Мёртвым нельзя добавить фол
    if (!isAlive) return (currentFouls, isAlive);
    
    final newFouls = currentFouls + 1;
    
    // 3 → 4: смерть
    if (newFouls == 4) {
      return (newFouls, false);
    }
    
    // 4 → 5: воскрешение, сброс фолов
    if (newFouls == 5) {
      return (0, true);
    }
    
    // 0→1, 1→2, 2→3: без изменений isAlive
    return (newFouls, true);
  }
}