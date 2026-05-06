import 'package:mafia_help/data/local/models/phase.dart';
import 'package:mafia_help/data/local/models/sub_phase.dart';
import 'package:mafia_help/presentation/state/game_state.dart';

import '../../presentation/state/game_state_copy.dart';

class PhaseTransitionHelper {
  
  GameState nextPhase(GameState state) {
    final subPhases = _getSubPhasesForPhase(state.currentPhase);
    
    if (state.currentSubPhaseIndex < subPhases.length - 1) {
      // Следующая подфаза в той же фазе
      return state.copyWith(
        currentSubPhase: subPhases[state.currentSubPhaseIndex + 1],
        currentSubPhaseIndex: state.currentSubPhaseIndex + 1,
      );
    } else {
      // Переход к следующей фазе
      final nextPhase = _getNextPhase(state.currentPhase);
      final nextSubPhases = _getSubPhasesForPhase(nextPhase);
      
      return state.copyWith(
        currentPhase: nextPhase,
        currentSubPhase: nextSubPhases.isNotEmpty ? nextSubPhases[0] : SubPhase.contract,
        currentSubPhaseIndex: 0,
        currentDay: nextPhase == Phase.day ? state.currentDay + 1 : state.currentDay,
      );
    }
  }

  GameState previousPhase(GameState state) {
    final subPhases = _getSubPhasesForPhase(state.currentPhase);
    
    if (state.currentSubPhaseIndex > 0) {
      // Предыдущая подфаза в той же фазе
      return state.copyWith(
        currentSubPhase: subPhases[state.currentSubPhaseIndex - 1],
        currentSubPhaseIndex: state.currentSubPhaseIndex - 1,
      );
    } else {
      // Переход к предыдущей фазе
      final previousPhase = _getPreviousPhase(state.currentPhase);
      final previousSubPhases = _getSubPhasesForPhase(previousPhase);
      
      return state.copyWith(
        currentPhase: previousPhase,
        currentSubPhase: previousSubPhases.isNotEmpty ? previousSubPhases.last : SubPhase.contract,
        currentSubPhaseIndex: previousSubPhases.length - 1,
        currentDay: previousPhase == Phase.day ? state.currentDay - 1 : state.currentDay,
      );
    }
  }

  List<SubPhase> _getSubPhasesForPhase(Phase phase) {
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

  Phase _getNextPhase(Phase currentPhase) {
    switch (currentPhase) {
      case Phase.night:
        return Phase.day;
      case Phase.day:
        return Phase.voting;
      case Phase.voting:
        return Phase.night;
    }
  }

  Phase _getPreviousPhase(Phase currentPhase) {
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