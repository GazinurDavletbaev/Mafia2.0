class SpeechRules {
  // Найти следующего живого, которого ещё не было в стеке
  int? findNextSpeaker({
    required int currentSpeaker,
    required List<int> aliveSeats,
    required List<int> spokenSeats, // стек
  }) {
    for (int i = currentSpeaker + 1; i <= 10; i++) {
      if (aliveSeats.contains(i) && !spokenSeats.contains(i)) return i;
    }
    for (int i = 1; i < currentSpeaker; i++) {
      if (aliveSeats.contains(i) && !spokenSeats.contains(i)) return i;
    }
    return null; // все живые уже говорили
  }
}