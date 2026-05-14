// lib/domain/usecases/tie_break_usecase.dart

import '../../data/local/models/sub_phase.dart';

class TieBreakUsecase {
  TieBreakUsecase();
  
  /// Перейти к следующему кандидату в перестрелке
  (int? nextSpeaker, bool isFinished) nextCandidate({
    required List<int> tiedSeats,
    required int currentIndex,
  }) {
    final nextIndex = currentIndex + 1;
    
    if (nextIndex < tiedSeats.length) {
      return (tiedSeats[nextIndex], false);
    }
    
    // Перестрелка закончена
    return (null, true);
  }
  
  /// Завершить перестрелку, перейти к переголосованию
  SubPhase finishTieBreak() {
    return SubPhase.revote;
  }
}