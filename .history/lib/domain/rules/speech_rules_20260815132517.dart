class SpeechRules {
  List<int> buildSpeechQueue({
    required List<int> aliveSeats,
    required int? lastSpeakerOfPreviousDay,
  }) {
    final queue = List<int>.from(aliveSeats)..sort();

    if (lastSpeakerOfPreviousDay != null &&
        queue.contains(lastSpeakerOfPreviousDay)) {
      final index = queue.indexOf(lastSpeakerOfPreviousDay);
      final newQueue = <int>[];
      for (int i = index + 1; i < queue.length; i++) {
        newQueue.add(queue[i]);
      }
      for (int i = 0; i <= index; i++) {
        newQueue.add(queue[i]);
      }
      return newQueue;
    } else if ()
    return queue;
  }

  int? findNextSpeaker({
    required int currentSpeaker,
    required List<int> aliveSeats,
    required List<int> speechHistory,
  }) {
    for (int i = currentSpeaker + 1; i <= 10; i++) {
      if (aliveSeats.contains(i) && !speechHistory.contains(i)) return i;
    }
    for (int i = 1; i < currentSpeaker; i++) {
      if (aliveSeats.contains(i) && !speechHistory.contains(i)) return i;
    }
    return null;
  }
}
