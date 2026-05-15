class SpeechRules {
  /// Найти следующего живого, которого ещё не было в истории
  int? findNextSpeaker({
    required int currentSpeaker,
    required List<int> aliveSeats,
    required List<int> speechHistory, // история выступлений в текущем дне
  }) {
    // Ищем после currentSpeaker
    for (int i = currentSpeaker + 1; i <= 10; i++) {
      if (aliveSeats.contains(i) && !speechHistory.contains(i)) return i;
    }
    // Ищем сначала
    for (int i = 1; i < currentSpeaker; i++) {
      if (aliveSeats.contains(i) && !speechHistory.contains(i)) return i;
    }
    return null; // все живые уже говорили
  }
}