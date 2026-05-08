import 'package:mafia_help/data/local/models/phase.dart';
import 'package:mafia_help/data/local/models/sub_phase.dart';
import 'package:mafia_help/presentation/state/game_state.dart';
import '../game_rule_checker.dart';
import '../night_phase_factory.dart';
import '../vote_calculator.dart';
import 'vote_calculator.dart';
import 'game_rule_checker.dart';

class VotingTransitions {
  static GameState next(GameState state) {
    final hasValidCandidates = GameRuleChecker.hasValidCandidatesForVoting(state);

    switch (state.currentSubPhase) {
      case SubPhase.voting:
        if (!hasValidCandidates) return _goToNight(state);
        return state.copyWith(currentSubPhase: SubPhase.revote, currentSubPhaseIndex: 1);

      case SubPhase.revote:
        if (VoteCalculator.isTie(state)) {
          return state.copyWith(
            currentSubPhase: SubPhase.tieBreak,
            currentSubPhaseIndex: 2,
            tiedSeats: VoteCalculator.getTiedSeats(state),
            currentTieIndex: 0,
            votes: {},
          );
        } else if (VoteCalculator.hasWinner(state)) {
          return state.copyWith(currentSubPhase: SubPhase.finalWord, currentSubPhaseIndex: 2);
        }
        return _goToNight(state);

      case SubPhase.tieBreak:
        return _goToNight(state);

      case SubPhase.eliminationVote:
        if (VoteCalculator.isEliminationPassed(state)) {
          return state.copyWith(currentSubPhase: SubPhase.finalWord, currentSubPhaseIndex: 2);
        }
        return _goToNight(state);

      case SubPhase.finalWord:
        return _goToNight(state);

      default:
        return state;
    }
  }

  static GameState previous(GameState state) {
    final isFirstDay = state.currentDay == 1;

    if (state.currentSubPhaseIndex > 0) {
      return state.copyWith(currentSubPhaseIndex: state.currentSubPhaseIndex - 1);
    }

    return state.copyWith(
      currentPhase: Phase.day,
      currentSubPhase: isFirstDay ? SubPhase.speeches : SubPhase.speeches,
      currentSubPhaseIndex: 0,
    );
  }

  static GameState _goToNight(GameState state) {
    final nextDay = state.currentDay + 1;
    return NightPhaseFactory.createRegularNight(state, day: nextDay);
  }
}