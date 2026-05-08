import 'package:mafia_help/data/local/models/phase.dart';
import 'package:mafia_help/data/local/models/sub_phase.dart';
import 'package:mafia_help/presentation/state/game_state.dart';
import '../night_phase_factory.dart';
import 'speech_initializer.dart';

class DayTransitions {
  static GameState next(GameState state) {
    final isFirstDay = state.currentDay == 1;
    final hasBestMove = state.currentSubPhase == SubPhase.bestMove;

    List<SubPhase> subPhases;
    if (isFirstDay) {
      subPhases = [SubPhase.speeches];
    } else if (hasBestMove) {
      subPhases = [SubPhase.bestMove, SubPhase.speeches];
    } else {
      subPhases = [SubPhase.speeches];
    }

    if (state.currentSubPhaseIndex < subPhases.length - 1) {
      final nextSubPhase = subPhases[state.currentSubPhaseIndex + 1];
      if (nextSubPhase == SubPhase.speeches) {
        return SpeechInitializer.initialize(state);
      }
      return state.copyWith(
        currentSubPhase: nextSubPhase,
        currentSubPhaseIndex: state.currentSubPhaseIndex + 1,
      );
    }

    if (state.currentSubPhase == SubPhase.speeches) {
      return state.copyWith(
        currentPhase: Phase.voting,
        currentSubPhase: SubPhase.voting,
        currentSubPhaseIndex: 0,
        nominatedSeats: [],
        votes: {},
      );
    }

    return SpeechInitializer.initialize(state);
  }

  static GameState previous(GameState state) {
    final isFirstDay = state.currentDay == 1;
    if (state.currentSubPhaseIndex > 0) {
      return state.copyWith(currentSubPhaseIndex: state.currentSubPhaseIndex - 1);
    }

    if (isFirstDay) {
      return NightPhaseFactory.createFirstNight(state);
    } else {
      return NightPhaseFactory.createRegularNight(state, day: state.currentDay);
    }
  }
}