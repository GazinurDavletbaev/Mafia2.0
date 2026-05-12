import 'package:mafia_help/presentation/state/game_state.dart';
import 'package:mafia_help/core/logger/app_logger.dart';
import 'package:mafia_help/data/local/models/phase.dart';
import 'night_transitions.dart';
import 'day_transitions.dart';
import 'voting_transitions.dart';

class PhaseTransitionHelper {
  GameState nextPhase(GameState state) {
    AppLogger.d('PhaseTransitionHelper.nextPhase() → phase=${state.currentPhase}, subPhase=${state.currentSubPhase}, day=${state.currentDay}');
    
    final result = switch (state.currentPhase) {
      Phase.night => NightTransitions.next(state),
      Phase.day => DayTransitions.next(state),
      Phase.day => VotingTransitions.next(state),
    };
    
    AppLogger.d('PhaseTransitionHelper.nextPhase() → результат: phase=${result.currentPhase}, subPhase=${result.currentSubPhase}, speaker=${result.currentSpeakerSeat}');
    return result;
  }

  GameState previousPhase(GameState state) {
    AppLogger.d('PhaseTransitionHelper.previousPhase() → phase=${state.currentPhase}, subPhase=${state.currentSubPhase}, day=${state.currentDay}');
    
    final result = switch (state.currentPhase) {
      Phase.night => NightTransitions.previous(state),
      Phase.day => DayTransitions.previous(state),
      Phase.day => VotingTransitions.previous(state),
    };
    
    AppLogger.d('PhaseTransitionHelper.previousPhase() → результат: phase=${result.currentPhase}, subPhase=${result.currentSubPhase}');
    return result;
  }
}