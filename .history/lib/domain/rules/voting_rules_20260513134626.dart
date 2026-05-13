// lib/domain/rules/voting_rules.dart

class VotingRules {
  /// Найти лидеров (кандидаты с максимальным количеством голосов)
  List<int> findLeaders(Map<int, int> voteCounts) {
    if (voteCounts.isEmpty) return [];
    final maxVotes = voteCounts.values.reduce((a, b) => a > b ? a : b);
    return voteCounts.entries
        .where((e) => e.value == maxVotes)
        .map((e) => e.key)
        .toList();
  }

  /// Нужно ли проводить голосование?
  bool needsVoting({
    required int dayNumber,
    required List<int> nominatedSeats,
  }) {
    // День 0: если 1 кандидат → голосования нет
    if (dayNumber == 0 && nominatedSeats.length == 1) {
      return false;
    }
    return true;
  }

  /// Для дня 0 с 1 кандидатом: сразу переходим в ночь
  bool shouldSkipToNight(int dayNumber, List<int> nominatedSeats) {
    return dayNumber == 0 && nominatedSeats.length == 1;
  }

  /// Нужна ли перестрелка
  bool needsTieBreak({
    required List<int> currentLeaders,
    required List<int>? previousLeaders,
    required bool tieBreakDone,
  }) {
    // Состав уменьшился → новая перестрелка
    if (previousLeaders != null && currentLeaders.length < previousLeaders.length) {
      return true;
    }
    
    // Состав не изменился
    if (_isSameSet(currentLeaders, previousLeaders)) {
      return !tieBreakDone;
    }
    
    return true;
  }

  /// Нужно ли eliminationVote
  bool needsEliminationVote({
    required List<int> currentLeaders,
    required List<int>? previousLeaders,
    required bool tieBreakDone,
  }) {
    // После перестрелки, если состав не изменился и перестрелка была
    if (_isSameSet(currentLeaders, previousLeaders) && tieBreakDone) {
      return true;
    }
    return false;
  }

  /// Проверка: выбывает ли кандидат при eliminationVote
  bool isEliminated(int votesFor, int totalAlive) {
    return votesFor > totalAlive / 2;
  }

  bool _isSameSet(List<int> a, List<int>? b) {
    if (b == null) return false;
    if (a.length != b.length) return false;
    return a.toSet().containsAll(b);
  }
}