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

  // ========== NIGHT ==========

  GameState _nextNight(GameState state) {
    final isFirstNight = state.currentDay == 0;
    
    if (isFirstNight) {
      return _nextFirstNight(state);
    } else {
      return _nextRegularNight(state);
    }
  }

  GameState _nextFirstNight(GameState state) {
    final subPhases = [SubPhase.roleDistribution, SubPhase.contract, SubPhase.sheriffLook];
    
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
    );
  }

  GameState _nextRegularNight(GameState state) {
    final subPhases = [SubPhase.mafiaShoot, SubPhase.donCheck, SubPhase.sheriffCheck];
    
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

  // ========== DAY ==========

  GameState _nextDay(GameState state) {
    final isFirstDay = state.currentDay == 1;
    final subPhases = isFirstDay
        ? [SubPhase.speeches]  // день 1: без bestMove
        : (state.currentSubPhase == SubPhase.bestMove 
            ? [SubPhase.bestMove, SubPhase.speeches]
            : [SubPhase.speeches]);
    
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
    );
  }

  // ========== VOTING ==========

  GameState _nextVoting(GameState state) {
    final candidatesCount = GameRuleChecker.getCandidatesCount(state);
    final hasValidCandidates = GameRuleChecker.hasValidCandidatesForVoting(state);
    
    switch (state.currentSubPhase) {
      case SubPhase.voting:
        if (!hasValidCandidates) {
          // 0 или 1 кандидат — голосование не проводится, сразу в ночь
          return _goToNight(state);
        }
        // >=2 кандидата → revote
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