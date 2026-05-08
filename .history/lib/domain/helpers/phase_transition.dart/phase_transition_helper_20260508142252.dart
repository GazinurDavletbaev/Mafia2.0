import 'package:mafia_help/presentation/state/game_state.dart';
import 'night_transitions.dart';
import 'day_transitions.dart';
import 'voting_transitions.dart';

class PhaseTransitionHelper {
  GameState nextPhase(GameState state) {
    switch (state.currentPhase) {
      case Phase.night:
        return NightTransitions.next(state);
      case Phase.day:
        return DayTransitions.next(state);
      case Phase.voting:
        return VotingTransitions.next(state);
    }
  }

  GameState previousPhase(GameState state) {
    switch (state.currentPhase) {
      case Phase.night:
        return NightTransitions.previous(state);
      case Phase.day:
        return DayTransitions.previous(state);
      case Phase.voting:
        return VotingTransitions.previous(state);
    }
  }
}