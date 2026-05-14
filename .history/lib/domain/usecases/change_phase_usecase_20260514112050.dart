// lib/domain/usecases/change_phase_usecase.dart

import '../rules/phase_rules.dart';
import '../entities/phase_stack.dart';
import '../../data/local/models/sub_phase.dart';

class ChangePhaseUsecase {
  final PhaseRules _phaseRules;
  
  ChangePhaseUsecase({required PhaseRules phaseRules})
      : _phaseRules = phaseRules;
  
  /// Перейти к следующей фазе
  (PhaseStack, SubPhase?) nextPhase({
    required PhaseStack stack,
    required int currentDay,
    required bool isNight0,
    required bool hasKillInLastNight,
  }) {
    final next = _phaseRules.getNextPhase(
      current: stack.current,
      day: currentDay,
      isNight0: isNight0,
      hasKillInLastNight: hasKillInLastNight,
      history: stack.history,
    );
    
    if (next == null) return (stack, null);
    
    final newStack = stack.push(next);
    return (newStack, next);
  }
  
  /// Вернуться к предыдущей фазе
  PhaseStack previousPhase(PhaseStack stack) {
    return stack.pop();
  }
}