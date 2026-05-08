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
      final nextSubPhase = nextSubPhases.isNotEmpty ? nextSubPhases[0] : SubPhase.contract;
      
      var newState = state.copyWith(
        currentPhase: nextPhase,
        currentSubPhase: nextSubPhase,
        currentSubPhaseIndex: 0,
        currentDay: nextPhase == Phase.day ? state.currentDay + 1 : state.currentDay,
      );
      
      // Бизнес-правило: при переходе в фазу речей — установить первого говорящего
      if (nextSubPhase == SubPhase.speeches) {
        final firstAlive = newState.players.firstWhere(
          (p) => p.isAlive,
          orElse: () => newState.players.first,
        );
        newState = newState.copyWith(currentSpeakerSeat: firstAlive.seatNumber);
      }
      
      // Бизнес-правило: при переходе в договорку — очистить текущего говорящего
      if (nextSubPhase == SubPhase.contract) {
        newState = newState.copyWith(currentSpeakerSeat: null);
      }
      
      return newState;
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
      final previousSubPhase = previousSubPhases.isNotEmpty ? previousSubPhases.last : SubPhase.contract;
      
      var newState = state.copyWith(
        currentPhase: previousPhase,
        currentSubPhase: previousSubPhase,
        currentSubPhaseIndex: previousSubPhases.length - 1,
        currentDay: previousPhase == Phase.day ? state.currentDay - 1 : state.currentDay,
      );
      
      // Бизнес-правило: при возврате из речей — очистить говорящего
      if (previousSubPhase == SubPhase.speeches) {
        newState = newState.copyWith(currentSpeakerSeat: null);
      }
      
      return newState;
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