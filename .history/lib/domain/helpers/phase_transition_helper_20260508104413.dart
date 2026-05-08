import 'package:mafia_help/data/local/models/phase.dart';
import 'package:mafia_help/data/local/models/sub_phase.dart';
import 'package:mafia_help/presentation/state/game_state.dart';
import 'vote_calculator.dart';
import 'game_rule_checker.dart';
import 'night_phase_factory.dart';

class PhaseTransitionHelper {
  GameState nextPhase(GameState state) {
    switch (state.currentPhase) {
      case Phase.night:
        return _nextNight(state);
      case Phase.day:
        return _nextDay(state);
      case Phase.voting:
        return _nextVoting(state);
    }
  }

  GameState previousPhase(GameState state) {
    // Обратный переход (упрощённая версия)
    switch (state.currentPhase) {
      case Phase.night:
        return _previousNight(state);
      case Phase.day:
        return _previousDay(state);
      case Phase.voting:
        return _previousVoting(state);
    }
  }

  // ========== ОБРАТНЫЙ ПЕРЕХОД (НОЧЬ) ==========

  GameState _previousNight(GameState state) {
    final isFirstNight = state.currentDay == 0;

    if (isFirstNight) {
      if (state.currentSubPhaseIndex > 0) {
        final subPhases = [
          SubPhase.roleDistribution,
          SubPhase.contract,
          SubPhase.sheriffLook,
        ];
        return state.copyWith(
          currentSubPhase: subPhases[state.currentSubPhaseIndex - 1],
          currentSubPhaseIndex: state.currentSubPhaseIndex - 1,
        );
      }
      // Возврат из ночи 1 в голосование (если возможно)
      return state.copyWith(
        currentPhase: Phase.voting,
        currentSubPhase: SubPhase.finalWord,
        currentSubPhaseIndex: 2,
      );
    } else {
      if (state.currentSubPhaseIndex > 0) {
        final subPhases = [
          SubPhase.mafiaShoot,
          SubPhase.donCheck,
          SubPhase.sheriffCheck,
        ];
        return state.copyWith(
          currentSubPhase: subPhases[state.currentSubPhaseIndex - 1],
          currentSubPhaseIndex: state.currentSubPhaseIndex - 1,
        );
      }
      // Возврат из ночи 2+ в день
      final hasKill = GameRuleChecker.hasKillInLastNight(state);
      final prevSubPhase = hasKill ? SubPhase.bestMove : SubPhase.speeches;
      return state.copyWith(
        currentPhase: Phase.day,
        currentSubPhase: prevSubPhase,
        currentSubPhaseIndex: prevSubPhase == SubPhase.bestMove ? 0 : 0,
        currentDay: state.currentDay,
      );
    }
  }

  // ========== ОБРАТНЫЙ ПЕРЕХОД (ДЕНЬ) ==========

  GameState _previousDay(GameState state) {
    final isFirstDay = state.currentDay == 1;

    if (state.currentSubPhaseIndex > 0) {
      return state.copyWith(
        currentSubPhaseIndex: state.currentSubPhaseIndex - 1,
      );
    }

    // Возврат в ночь
    if (isFirstDay) {
      return NightPhaseFactory.createFirstNight(state);
    } else {
      return NightPhaseFactory.createRegularNight(state, day: state.currentDay);
    }
  }

  // ========== ОБРАТНЫЙ ПЕРЕХОД (ГОЛОСОВАНИЕ) ==========

  GameState _previousVoting(GameState state) {
    if (state.currentSubPhaseIndex > 0) {
      return state.copyWith(
        currentSubPhaseIndex: state.currentSubPhaseIndex - 1,
      );
    }

    // Возврат в день
    final isFirstDay = state.currentDay == 1;
    final prevSubPhase = isFirstDay ? SubPhase.speeches : SubPhase.speeches;
    return state.copyWith(
      currentPhase: Phase.day,
      currentSubPhase: prevSubPhase,
      currentSubPhaseIndex: 0,
    );
  }

  // ========== ПРЯМОЙ ПЕРЕХОД (НОЧЬ) ==========

  GameState _nextNight(GameState state) {
    final isFirstNight = state.currentDay == 0;

    if (isFirstNight) {
      return _nextFirstNight(state);
    } else {
      return _nextRegularNight(state);
    }
  }

  GameState _nextFirstNight(GameState state) {
    final subPhases = [
      SubPhase.roleDistribution,
      SubPhase.contract,
      SubPhase.sheriffLook,
    ];

    if (state.currentSubPhaseIndex < subPhases.length - 1) {
      return state.copyWith(
        currentSubPhase: subPhases[state.currentSubPhaseIndex + 1],
        currentSubPhaseIndex: state.currentSubPhaseIndex + 1,
      );
    }

    return state.copyWith(
      currentPhase: Phase.day,
      currentSubPhase: SubPhase.speeches,
      currentSubPhaseIndex: 0,
      currentDay: 1,
      currentSpeakerSeat: _getFirstAliveSeat(state),
    );
  }

  GameState _nextRegularNight(GameState state) {
    final subPhases = [
      SubPhase.mafiaShoot,
      SubPhase.donCheck,
      SubPhase.sheriffCheck,
    ];

    if (state.currentSubPhaseIndex < subPhases.length - 1) {
      return state.copyWith(
        currentSubPhase: subPhases[state.currentSubPhaseIndex + 1],
        currentSubPhaseIndex: state.currentSubPhaseIndex + 1,
      );
    }

    final hasKill = GameRuleChecker.hasKillInLastNight(state);
    final nextSubPhase = hasKill ? SubPhase.bestMove : SubPhase.speeches;

    return state.copyWith(
      currentPhase: Phase.day,
      currentSubPhase: nextSubPhase,
      currentSubPhaseIndex: 0,
      currentDay: state.currentDay,
      currentSpeakerSeat: _getFirstAliveSeat(state),
    );
  }

  // ========== ПРЯМОЙ ПЕРЕХОД (ДЕНЬ) ==========

  GameState _nextDay(GameState state) {
    final isFirstDay = state.currentDay == 1;
    final subPhases = isFirstDay
        ? [SubPhase.speeches]
        : (state.currentSubPhase == SubPhase.bestMove
              ? [SubPhase.bestMove, SubPhase.speeches]
              : [SubPhase.speeches]);

    if (state.currentSubPhaseIndex < subPhases.length - 1) {
      return state.copyWith(
        currentSubPhase: subPhases[state.currentSubPhaseIndex + 1],
        currentSubPhaseIndex: state.currentSubPhaseIndex + 1,
      );
    }

    return state.copyWith(
      currentPhase: Phase.voting,
      currentSubPhase: SubPhase.voting,
      currentSubPhaseIndex: 0,
    );
  }

  // ========== ПРЯМОЙ ПЕРЕХОД (ГОЛОСОВАНИЕ) ==========

  GameState _nextVoting(GameState state) {
    final hasValidCandidates = GameRuleChecker.hasValidCandidatesForVoting(
      state,
    );

    switch (state.currentSubPhase) {
      case SubPhase.voting:
        if (!hasValidCandidates) {
          return _goToNight(state);
        }
        return state.copyWith(
          currentSubPhase: SubPhase.revote,
          currentSubPhaseIndex: 1,
        );

      case SubPhase.revote:
        if (VoteCalculator.isTie(state)) {
          return state.copyWith(
            currentSubPhase: SubPhase.eliminationVote,
            currentSubPhaseIndex: 2,
          );
        } else if (VoteCalculator.hasWinner(state)) {
          return state.copyWith(
            currentSubPhase: SubPhase.finalWord,
            currentSubPhaseIndex: 2,
          );
        }
        return _goToNight(state);

      case SubPhase.eliminationVote:
        if (VoteCalculator.isEliminationPassed(state)) {
          return state.copyWith(
            currentSubPhase: SubPhase.finalWord,
            currentSubPhaseIndex: 2,
          );
        }
        return _goToNight(state);

      case SubPhase.finalWord:
        return _goToNight(state);

      default:
        return state;
    }
  }

  // ========== HELPERS ==========

  GameState _goToNight(GameState state) {
    final nextDay = state.currentDay + 1;
    return NightPhaseFactory.createRegularNight(state, day: nextDay);
  }

  int _getFirstAliveSeat(GameState state) {
    final firstAlive = state.players.firstWhere(
      (p) => p.isAlive,
      orElse: () => state.players.first,
    );
    return firstAlive.seatNumber;
  }
}
