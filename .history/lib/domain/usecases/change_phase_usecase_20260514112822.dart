// lib/domain/usecases/change_phase_usecase.dart

import '../rules/phase_rules.dart';
import '../entities/phase_stack.dart';

class ChangePhaseUsecase {
  final PhaseRules _phaseRules;
  
  ChangePhaseUsecase({required PhaseRules phaseRules})
      : _phaseRules = phaseRules;
  
  /// Перейти к следующей фазе
  (PhaseStack, dynamic) nextPhase({
    required PhaseStack stack,
    required bool isNight0Completed,
  }) {
    final next = _phaseRules.getNextPhase(stack, isNight0Completed);
    
    if (next == null) return (stack, null);
    
    final newStack = stack.push(next);
    return (newStack, next);
  }
  
  /// Вернуться к предыдущей фазе
  PhaseStack previousPhase(PhaseStack stack) {
    stack.pop();
    return stack;
  }
}