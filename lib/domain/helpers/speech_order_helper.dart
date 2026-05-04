class SpeechOrderHelper {
  static List<int> getOrder(List<int> aliveSeats, int? currentSpeakerSeat) {
    if (aliveSeats.isEmpty) return [];
    
    if (currentSpeakerSeat == null) {
      return List.from(aliveSeats);
    }
    
    final currentIndex = aliveSeats.indexOf(currentSpeakerSeat);
    if (currentIndex == -1) return List.from(aliveSeats);
    
    final ordered = <int>[];
    for (int i = 0; i < aliveSeats.length; i++) {
      final index = (currentIndex + i) % aliveSeats.length;
      ordered.add(aliveSeats[index]);
    }
    
    return ordered;
  }
}