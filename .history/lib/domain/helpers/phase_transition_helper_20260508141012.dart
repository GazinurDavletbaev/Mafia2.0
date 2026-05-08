import 'package:mafia_help/data/local/models/phase.dart';
import 'package:mafia_help/data/local/models/sub_phase.dart';
import 'package:mafia_help/presentation/state/game_state.dart';
import '../../core/logger/app_logger.dart';
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
    var newState = state.copyWith(
      currentPhase: Phase.day,
      currentSubPhase: SubPhase.speeches,
      currentSubPhaseIndex: 0,
      currentDay: 1,
      hasKillInLastNight: false,
    );

    return _initializeSpeeches(newState);
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

    var newState = state.copyWith(
      currentPhase: Phase.day,
      currentSubPhase: nextSubPhase,
      currentSubPhaseIndex: 0,
      currentDay: state.currentDay,
    );

    // Если переходим на речи — инициализируем
    if (nextSubPhase == SubPhase.speeches) {
      newState = _initializeSpeeches(newState);
    }

    return newState;
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

    // Возврат в день
    final wasBestMove = state.hasKillInLastNight;

    GameState newState = state.copyWith(
      currentPhase: Phase.day,
      currentDay: state.currentDay,
    );

    if (wasBestMove && state.currentDay > 1) {
      newState = newState.copyWith(
        currentSubPhase: SubPhase.bestMove,
        currentSubPhaseIndex: 0,
      );
    } else {
      newState = newState.copyWith(
        currentSubPhase: SubPhase.speeches,
        currentSubPhaseIndex: 0,
      );
    }

    return newState;
  }

  // ========== ПРЯМОЙ ПЕРЕХОД (ДЕНЬ) ==========

  GameState _nextDay(GameState state) {
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
        return _initializeSpeeches(state);
      }

      return state.copyWith(
        currentSubPhase: nextSubPhase,
        currentSubPhaseIndex: state.currentSubPhaseIndex + 1,
      );
    }

    // Если уже в speeches — переходим на голосование
    if (state.currentSubPhase == SubPhase.speeches) {
      return state.copyWith(
        currentPhase: Phase.voting,
        currentSubPhase: SubPhase.voting,
        currentSubPhaseIndex: 0,
        nominatedSeats: [],
        votes: {},
      );
    }

    return _initializeSpeeches(state);
  }

  GameState _initializeSpeeches(GameState state) {
    AppLogger.d(
      '_initializeSpeeches called, currentDay=${state.currentDay}, dayStarterSeat=${state.dayStarterSeat}',
    );

    int startSeat;

    if (state.currentDay == 1) {
      startSeat = 1;
    } else {
      final previousStarter = state.dayStarterSeat ?? 1;
      startSeat = previousStarter + 1;
      if (startSeat > 10) startSeat = 1;
    }

    // Ищем первого живого
    int? firstAliveSeat;
    for (int i = 0; i < 10; i++) {
      final seat = ((startSeat - 1 + i) % 10) + 1;
      final player = state.players.firstWhere((p) => p.seatNumber == seat);
      if (player.isAlive) {
        firstAliveSeat = seat;
        break;
      }
    }

    AppLogger.d(
      '_initializeSpeeches: startSeat=$startSeat, firstAlive=$firstAliveSeat',
    );

    return state.copyWith(
      currentPhase: Phase.day,
      currentSubPhase: SubPhase.speeches,
      currentSubPhaseIndex: 0,
      dayStarterSeat: firstAliveSeat,
      currentSpeakerSeat: firstAliveSeat,
    );
  }

  // ========== ОБРАТНЫЙ ПЕРЕХОД (ДЕНЬ) ==========

  GameState _previousDay(GameState state) {
    final isFirstDay = state.currentDay == 1;

    if (state.currentSubPhaseIndex > 0) {
      return state.copyWith(
        currentSubPhaseIndex: state.currentSubPhaseIndex - 1,
      );
    }

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
            currentSubPhase: SubPhase.tieBreak,
            currentSubPhaseIndex: 2,
            tiedSeats: VoteCalculator.getTiedSeats(state),
            currentTieIndex: 0,
            votes: {},
          );
        } else if (VoteCalculator.hasWinner(state)) {
          return state.copyWith(
            currentSubPhase: SubPhase.finalWord,
            currentSubPhaseIndex: 2,
          );
        }
        return _goToNight(state);

      case SubPhase.tieBreak:
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

    return state.copyWith(
      currentPhase: Phase.day,
      currentSubPhase: isFirstDay ? SubPhase.speeches : SubPhase.speeches,
      currentSubPhaseIndex: 0,
    );
  }

  // ========== HELPERS ==========

  GameState _goToNight(GameState state) {
    final nextDay = state.currentDay + 1;
    return NightPhaseFactory.createRegularNight(state, day: nextDay);
  }
}