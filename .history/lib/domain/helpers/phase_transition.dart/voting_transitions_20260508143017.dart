import 'package:mafia_help/presentation/state/game_state.dart';
import 'package:mafia_help/core/logger/app_logger.dart';
import 'package:mafia_help/data/local/models/phase.dart';
import 'package:mafia_help/data/local/models/sub_phase.dart';
import '../night_phase_factory.dart';
import 'vote_calculator.dart';
import 'game_rule_checker.dart';
import 'night_phase_factory.dart';

class VotingTransitions {
  static GameState next(GameState state) {
    final hasValidCandidates = GameRuleChecker.hasValidCandidatesForVoting(state);
    AppLogger.d('VotingTransitions.next() → subPhase=${state.currentSubPhase}, hasValidCandidates=$hasValidCandidates');

    switch (state.currentSubPhase) {
      case SubPhase.voting:
        if (!hasValidCandidates) {
          AppLogger.d('  нет кандидатов → переход в ночь');
          return _goToNight(state);
        }
        AppLogger.d('  есть кандидаты → переход на revote');
        return state.copyWith(currentSubPhase: SubPhase.revote, currentSubPhaseIndex: 1);

      case SubPhase.revote:
        if (VoteCalculator.isTie(state)) {
          AppLogger.d('  равный счёт → переход на tieBreak');
          return state.copyWith(
            currentSubPhase: SubPhase.tieBreak,
            currentSubPhaseIndex: 2,
            tiedSeats: VoteCalculator.getTiedSeats(state),
            currentTieIndex: 0,
            votes: {},
          );
        } else if (VoteCalculator.hasWinner(state)) {
          AppLogger.d('  есть победитель → переход на finalWord');
          return state.copyWith(currentSubPhase: SubPhase.finalWord, currentSubPhaseIndex: 2);
        }
        AppLogger.d('  нет результата → переход в ночь');
        return _goToNight(state);

      case SubPhase.tieBreak:
        AppLogger.d('  tieBreak закончен → переход в ночь');
        return _goToNight(state);

      case SubPhase.eliminationVote:
        if (VoteCalculator.isEliminationPassed(state)) {
          AppLogger.d('  голосование за подъём успешно → переход на finalWord');
          return state.copyWith(currentSubPhase: SubPhase.finalWord, currentSubPhaseIndex: 2);
        }
        AppLogger.d('  голосование за подъём не прошло → переход в ночь');
        return _goToNight(state);

      case SubPhase.finalWord:
        AppLogger.d('  finalWord закончен → переход в ночь');
        return _goToNight(state);

      default:
        return state;
    }
  }

  static GameState previous(GameState state) {
    final isFirstDay = state.currentDay == 1;
    AppLogger.d('VotingTransitions.previous() → subPhase=${state.currentSubPhase}, index=${state.currentSubPhaseIndex}');

    if (state.currentSubPhaseIndex > 0) {
      AppLogger.d('  возврат к предыдущей подфазе голосования');
      return state.copyWith(currentSubPhaseIndex: state.currentSubPhaseIndex - 1);
    }

    AppLogger.d('  возврат в день');
    return state.copyWith(
      currentPhase: Phase.day,
      currentSubPhase: isFirstDay ? SubPhase.speeches : SubPhase.speeches,
      currentSubPhaseIndex: 0,
    );
  }

  static GameState _goToNight(GameState state) {
    final nextDay = state.currentDay + 1;
    AppLogger.d('  → переход в ночь, следующий день = $nextDay');
    return NightPhaseFactory.createRegularNight(state, day: nextDay);
  }
}