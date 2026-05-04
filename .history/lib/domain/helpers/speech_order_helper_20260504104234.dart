class SpeechOrderHelper {
  // Возвращает порядок мест для речей
  // aliveSeats: список мест живых игроков (отсортированный по возрастанию)
  // currentSpeakerSeat: место текущего говорящего (или null если речь ещё не началась)
  static List<int> getOrder(List<int> aliveSeats, int? currentSpeakerSeat) {
    if (aliveSeats.isEmpty) return [];
    
    // Если нет текущего говорящего, начинаем с первого живого
    if (currentSpeakerSeat == null) {
      return List.from(aliveSeats);
    }
    
    // Находим индекс текущего говорящего
    final currentIndex = aliveSeats.indexOf(currentSpeakerSeat);
    if (currentIndex == -1) return List.from(aliveSeats);
    
    // Сдвигаем список, чтобы текущий говорящий был первым
    final ordered = <int>[];
    for (int i = 0; i < aliveSeats.length; i++) {
      final index = (currentIndex + i) % aliveSeats.length;
      ordered.add(aliveSeats[index]);
    }
    
    return ordered;
  }
}