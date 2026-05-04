import 'package:mafia_help/data/local/models/phase.dart';

class PhaseTransitionHelper {
  static ({Phase phase, int subPhaseIndex, int day}) next({
    required Phase currentPhase,
    required int currentSubPhaseIndex,
    required int currentDay,
    required bool goForward,
  }) {
    final subPhases = _getSubPhases(currentPhase);
    
    if (goForward) {
      if (currentSubPhaseIndex < subPhases.length - 1) {
        return (
          phase: currentPhase,
          subPhaseIndex: currentSubPhaseIndex + 1,
          day: currentDay,
        );
      } else {
        final nextPhase = _getNextPhase(currentPhase);
        return (
          phase: nextPhase,
          subPhaseIndex: 0,
          day: nextPhase == PhaseModel.day ? currentDay + 1 : currentDay,
        );
      }
    } else {
      if (currentSubPhaseIndex > 0) {
        return (
          phase: currentPhase,
          subPhaseIndex: currentSubPhaseIndex - 1,
          day: currentDay,
        );
      } else {
        final previousPhase = _getPreviousPhase(currentPhase);
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
        return ['голосование'];
    }
  }

  static Phase _getNextPhase(Phase currentPhase) {
    switch (currentPhase) {
      case Phase.night:
        return Phase.day;
      case Phase.day:
        return Phase.voting;
      case Phase.voting:
        return Phase.night;
    }
  }

  static Phase _getPreviousPhase(Phase currentPhase) {
    switch (currentPhase) {
      case Phase.night:
        return Phase.voting;
      case Phase.day:
        return Phase.night;
      case Phase.voting:
        return Phase.day;
    }
  }
}