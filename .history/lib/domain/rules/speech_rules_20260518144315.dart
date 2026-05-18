// lib/domain/rules/speech_rules.dart

class SpeechRules {
  /// Формирует очередь говорящих на текущий день
  List<int> buildSpeechQueue({
    required List<int> aliveSeats,
    required int? lastSpeakerOfPreviousDay, // последний говоривший в прошлый день
  }) {
    final queue = List<int>.from(aliveSeats)..sort();
    
    if (lastSpeakerOfPreviousDay != null && queue.contains(lastSpeakerOfPreviousDay)) {
      // Начинаем со следующего после lastSpeakerOfPreviousDay
      final index = queue.indexOf(lastSpeakerOfPreviousDay);
      final newQueue = <int>[];
      for (int i = index + 1; i < queue.length; i++) {
        newQueue.add(queue[i]);
      }
      for (int i = 0; i <= index; i++) {
        newQueue.add(queue[i]);
      }
      return newQueue;
    }
    
    return queue;
  }

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