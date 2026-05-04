import 'package:mafia_help/data/local/models/phase_model.dart';

class PhaseTransitionHelper {
  // Возвращает новую фазу, подфазу и день
  static ({Phase phase, int subPhaseIndex, int day}) next({
    required Phase currentPhase,
    required int currentSubPhaseIndex,
    required int currentDay,
    required bool goForward, // true = следующая, false = предыдущая
  }) {
    // Определяем последовательность подфаз для каждой фазы
    final subPhases = _getSubPhases(currentPhase);
    
    if (goForward) {
      // Вперёд
      if (currentSubPhaseIndex < subPhases.length - 1) {
        // Следующая подфаза в той же фазе
        return (
          phase: currentPhase,
          subPhaseIndex: currentSubPhaseIndex + 1,
          day: currentDay,
        );
      } else {
        // Конец фазы — переходим к следующей фазе
        final nextPhase = _getNextPhase(currentPhase, currentDay);
        return (
          phase: nextPhase,
          subPhaseIndex: 0,
          day: nextPhase == Phase.day ? currentDay + 1 : currentDay,
        );
      }
    } else {
      // Назад
      if (currentSubPhaseIndex > 0) {
        // Предыдущая подфаза в той же фазе
        return (
          phase: currentPhase,
          subPhaseIndex: currentSubPhaseIndex - 1,
          day: currentDay,
        );
      } else {
        // Начало фазы — переходим к предыдущей фазе
        final previousPhase = _getPreviousPhase(currentPhase, currentDay);
        final previousSubPhases = _getSubPhases(previousPhase);
        return (
          phase: previousPhase,
          subPhaseIndex: previousSubPhases.length - 1,
          day: previousPhase == Phase.day ? currentDay - 1 : currentDay,
        );
      }
    }
  }

  static List<String> _getSubPhases(Phase phase) {
    switch (phase) {
      case Phase.night:
        return ['договорка', 'шериф'];
      case Phase.day:
        return ['речи', 'голосование', 'переголосование', 'подъём', 'заключительная'];
      case Phase.voting:
        return ['голосование']; // голосование за подъём
      default:
        return [''];
    }
  }

  static Phase _getNextPhase(Phase currentPhase, int currentDay) {
    switch (currentPhase) {
      case Phase.night:
        return Phase.day;
      case Phase.day:
        return Phase.voting;
      case Phase.voting:
        return Phase.night;
      default:
        return Phase.night;
    }
  }

  static Phase _getPreviousPhase(Phase currentPhase, int currentDay) {
    switch (currentPhase) {
      case Phase.night:
        return Phase.voting;
      case Phase.day:
        return Phase.night;
      case Phase.voting:
        return Phase.day;
      default:
        return Phase.day;
    }
  }
}