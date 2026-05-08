import 'package:mafia_help/data/local/models/phase.dart';
import 'package:mafia_help/data/local/models/sub_phase.dart';
import 'package:mafia_help/presentation/state/game_state.dart';
import 'vote_calculator.dart';
import 'game_rule_checker.dart';
import 'night_phase_factory.dart';

class PhaseTransitionHelper {
  // ========== ОСНОВНЫЕ МЕТОДЫ ==========

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
    switch (state.currentPhase) {
      case Phase.night:
        return _previousNight(state);
      case Phase.day:
        return _previousDay(state);
      case Phase.voting:
        return _previousVoting(state);
    }
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

    // Ночь 1 закончена → день 1 (без bestMove)
    return state.copyWith(
      currentPhase: Phase.day,
      currentSubPhase: SubPhase.speeches,
      currentSubPhaseIndex: 0,
      currentDay: 1,
      currentSpeakerSeat: _getFirstAliveSeat(state),
      hasKillInLastNight: false,
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

    // Ночь закончена → день
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

  // ========== ОБРАТНЫЙ ПЕРЕХОД (НОЧЬ) ==========

  GameState _previousNight(GameState state) {
    final isFirstNight = state.currentDay == 0;

    if (isFirstNight) {
      return _previousFirstNight(state);
    } else {
      return _previousRegularNight(state);
    }
  }

  GameState _previousFirstNight(GameState state) {
    final subPhases = [
      SubPhase.roleDistribution,
      SubPhase.contract,
      SubPhase.sheriffLook,
    ];

    if (state.currentSubPhaseIndex > 0) {
      return state.copyWith(
        currentSubPhase: subPhases[state.currentSubPhaseIndex - 1],
        currentSubPhaseIndex: state.currentSubPhaseIndex - 1,
      );
    }

    // Возврат из ночи 1 в конец голосования
    return state.copyWith(
      currentPhase: Phase.voting,
      currentSubPhase: SubPhase.finalWord,
      currentSubPhaseIndex: 2,
      hasKillInLastNight: false,
    );
  }

  GameState _previousRegularNight(GameState state) {
    final subPhases = [
      SubPhase.mafiaShoot,
      SubPhase.donCheck,
      SubPhase.sheriffCheck,
    ];

    if (state.currentSubPhaseIndex > 0) {
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
      currentSubPhaseIndex: prevSubPhase == SubPhase.bestMove ? 1 : 0,
      currentDay: state.currentDay,
      currentSpeakerSeat: state.currentSpeakerSeat,
    );
  }

  // ========== ПРЯМОЙ ПЕРЕХОД (ДЕНЬ) ==========

  GameState _nextDay(GameState state) {
    final isFirstDay = state.currentDay == 1;
    final hasBestMove = state.currentSubPhase == SubPhase.bestMove;

    // Определяем список подфаз для текущего дня
    List<SubPhase> subPhases;
    if (isFirstDay) {
      subPhases = [SubPhase.speeches];
    } else if (hasBestMove) {
      subPhases = [SubPhase.bestMove, SubPhase.speeches];
    } else {
      subPhases = [SubPhase.speeches];
    }

    if (state.currentSubPhaseIndex < subPhases.length - 1) {
      return state.copyWith(
        currentSubPhase: subPhases[state.currentSubPhaseIndex + 1],
        currentSubPhaseIndex: state.currentSubPhaseIndex + 1,
      );
    }

    // День закончился → голосование
    return state.copyWith(
      currentPhase: Phase.voting,
      currentSubPhase: SubPhase.voting,
      currentSubPhaseIndex: 0,
      nominatedSeats: [],
      votes: {},
    );
  }

  // ========== ОБРАТНЫЙ ПЕРЕХОД (ДЕНЬ) ==========

  GameState _previousDay(GameState state) {
    final isFirstDay = state.currentDay == 1;
    final hasBestMove = state.currentSubPhase == SubPhase.bestMove;

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
            eliminationVotes: 0,
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

  // ========== ОБРАТНЫЙ ПЕРЕХОД (ГОЛОСОВАНИЕ) ==========

  GameState _previousVoting(GameState state) {
    final isFirstDay = state.currentDay == 1;

    if (state.currentSubPhaseIndex > 0) {
      return state.copyWith(
        currentSubPhaseIndex: state.currentSubPhaseIndex - 1,
      );
    }

    // Возврат в день
    return state.copyWith(
      currentPhase: Phase.day,
      currentSubPhase: isFirstDay ? SubPhase.speeches : SubPhase.speeches,
      currentSubPhaseIndex: isFirstDay ? 0 : 0,
    );
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
