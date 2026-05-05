import 'package:mafia_help/data/local/models/phase.dart';
import 'package:mafia_help/data/local/models/sub_phase.dart';

import '../../data/local/models/phase_config.dart';

class PhaseTransitionHelper {
  static ({Phase phase, SubPhase subPhase, int subPhaseIndex, int day}) next({
    required Phase currentPhase,
    required SubPhase currentSubPhase,
    required int currentSubPhaseIndex,
    required int currentDay,
    required bool goForward,
  }) {
    final subPhases = _getSubPhasesForPhase(currentPhase);
    
    if (goForward) {
      if (currentSubPhaseIndex < subPhases.length - 1) {
        return (
          phase: currentPhase,
          subPhase: subPhases[currentSubPhaseIndex + 1],
          subPhaseIndex: currentSubPhaseIndex + 1,
          day: currentDay,
        );
      } else {
        final nextPhase = _getNextPhase(currentPhase);
        final nextSubPhases = _getSubPhasesForPhase(nextPhase);
        return (
          phase: nextPhase,
          subPhase: nextSubPhases.isNotEmpty ? nextSubPhases[0] : SubPhase.contract,
          subPhaseIndex: 0,
          day: nextPhase == Phase.day ? currentDay + 1 : currentDay,
        );
      }
    } else {
      if (currentSubPhaseIndex > 0) {
        return (
          phase: currentPhase,
          subPhase: subPhases[currentSubPhaseIndex - 1],
          subPhaseIndex: currentSubPhaseIndex - 1,
          day: currentDay,
        );
      } else {
        final previousPhase = _getPreviousPhase(currentPhase);
        final previousSubPhases = _getSubPhasesForPhase(previousPhase);
        return (
          phase: previousPhase,
          subPhase: previousSubPhases.isNotEmpty ? previousSubPhases.last : SubPhase.contract,
          subPhaseIndex: previousSubPhases.length - 1,
          day: previousPhase == Phase.day ? currentDay - 1 : currentDay,
        );
      }
    }
  }

  static List<SubPhase> _getSubPhasesForPhase(Phase phase) {
    switch (phase) {
      case Phase.night:
        return [
          SubPhase.roleDistribution,
          SubPhase.contract,
          SubPhase.sheriffLook,
        ];
      case Phase.day:
        return [
          SubPhase.bestMove,
          SubPhase.speeches,
          SubPhase.voting,
          SubPhase.revote,
          SubPhase.eliminationVote,
          SubPhase.finalWord,
        ];
      case Phase.voting:
        return [];
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