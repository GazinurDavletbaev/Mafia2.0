// lib/domain/usecases/change_phase_usecase.dart

import '../rules/phase_rules.dart';
import '../../data/local/models/sub_phase.dart';

class ChangePhaseUsecase {
  final PhaseRules _phaseRules;
  
  ChangePhaseUsecase({required PhaseRules phaseRules})
      : _phaseRules = phaseRules;
  
  /// Перейти к следующей фазе
  (List<SubPhase>, SubPhase?) nextPhase({
    required List<SubPhase> phaseHistory,
    required bool isNight0Completed,
  }) {
    final next = _phaseRules.getNextPhase(
      phaseHistory: phaseHistory,
      isNight0Completed: isNight0Completed,
    );
    
    if (next == null) return (phaseHistory, null);
    
    final newHistory = List<SubPhase>.from(phaseHistory)..add(next);
    return (newHistory, next);
  }
  
  /// Вернуться к предыдущей фазе
  (List<SubPhase>, SubPhase?) previousPhase(List<SubPhase> phaseHistory) {
    if (phaseHistory.length <= 1) return (phaseHistory, null);
    
    final newHistory = List<SubPhase>.from(phaseHistory)..removeLast();
    final previous = newHistory.last;
    return (newHistory, previous);
  }
}