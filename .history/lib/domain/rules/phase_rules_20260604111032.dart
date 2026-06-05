import '../../data/local/models/sub_phase.dart';

class PhaseRules {
  static const List<SubPhase> night0Order = [
    SubPhase.roleDistribution,
    SubPhase.contract,
    SubPhase.sheriffLook,
    SubPhase.freeSeating,
  ];

  static const List<SubPhase> nightOrder = [
    SubPhase.mafiaShoot,
    SubPhase.donCheck,
    SubPhase.sheriffCheck,
  ];

  static const List<SubPhase> dayOrder = [
    SubPhase.speeches,
    SubPhase.voting,
    SubPhase.revote,
    SubPhase.tieBreak,
    SubPhase.eliminationVote,
    SubPhase.finalWord,
  ];

  // Получить следующую фазу на основе текущей фазы и истории
  SubPhase? getNextPhase({
    required List<SubPhase> phaseHistory,
    required bool isNight0Completed,
  }) {
    if (phaseHistory.isEmpty) {
      if (isNight0Completed) return dayOrder[0];
      return night0Order[0];
    }

    final current = phaseHistory.last;

    // Ночь 0
    if (night0Order.contains(current)) {
      final index = night0Order.indexOf(current);
      if (index + 1 < night0Order.length) {
        return night0Order[index + 1];
      }
      // Конец ночи 0 → день 0
      return dayOrder[0];
    }

    // День
    if (dayOrder.contains(current)) {
      final index = dayOrder.indexOf(current);
      if (index + 1 < dayOrder.length) {
        return dayOrder[index + 1];
      }
      // Конец дня → ночь
      return nightOrder[0];
    }

    // Ночь 1+
    if (nightOrder.contains(current)) {
      final index = nightOrder.indexOf(current);
      if (index + 1 < nightOrder.length) {
        return nightOrder[index + 1];
      }
      // Конец ночи → день
      return dayOrder[0];
    }

    return null;
  }

  bool shouldIncrementDay(SubPhase nextPhase) {
    return nextPhase == SubPhase.mafiaShoot;
  }

  bool shouldDecrementDay(SubPhase previousPhase) {
    return previousPhase == SubPhase.mafiaShoot;
  }
}