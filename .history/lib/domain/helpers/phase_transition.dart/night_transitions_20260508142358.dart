import 'package:mafia_help/data/local/models/phase.dart';
import 'package:mafia_help/data/local/models/sub_phase.dart';
import 'package:mafia_help/presentation/state/game_state.dart';
import '../game_rule_checker.dart';
import 'game_rule_checker.dart';
import 'speech_initializer.dart';

class NightTransitions {
  static GameState next(GameState state) {
    final isFirstNight = state.currentDay == 0;
    return isFirstNight ? _nextFirstNight(state) : _nextRegularNight(state);
  }

  static GameState previous(GameState state) {
    final isFirstNight = state.currentDay == 0;
    return isFirstNight ? _previousFirstNight(state) : _previousRegularNight(state);
  }

  static GameState _nextFirstNight(GameState state) {
    const subPhases = [SubPhase.roleDistribution, SubPhase.contract, SubPhase.sheriffLook];

    if (state.currentSubPhaseIndex < subPhases.length - 1) {
      return state.copyWith(
        currentSubPhase: subPhases[state.currentSubPhaseIndex + 1],
        currentSubPhaseIndex: state.currentSubPhaseIndex + 1,
      );
    }

    var newState = state.copyWith(
      currentPhase: Phase.day,
      currentSubPhase: SubPhase.speeches,
      currentSubPhaseIndex: 0,
      currentDay: 1,
      hasKillInLastNight: false,
    );
    return SpeechInitializer.initialize(newState);
  }

  static GameState _nextRegularNight(GameState state) {
    const subPhases = [SubPhase.mafiaShoot, SubPhase.donCheck, SubPhase.sheriffCheck];

    if (state.currentSubPhaseIndex < subPhases.length - 1) {
      return state.copyWith(
        currentSubPhase: subPhases[state.currentSubPhaseIndex + 1],
        currentSubPhaseIndex: state.currentSubPhaseIndex + 1,
      );
    }

    final hasKill = GameRuleChecker.hasKillInLastNight(state);
    final nextSubPhase = hasKill ? SubPhase.bestMove : SubPhase.speeches;

    var newState = state.copyWith(
      currentPhase: Phase.day,
      currentSubPhase: nextSubPhase,
      currentSubPhaseIndex: 0,
      currentDay: state.currentDay,
    );

    if (nextSubPhase == SubPhase.speeches) {
      newState = SpeechInitializer.initialize(newState);
    }
    return newState;
  }

  static GameState _previousFirstNight(GameState state) {
    const subPhases = [SubPhase.roleDistribution, SubPhase.contract, SubPhase.sheriffLook];

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

  static GameState _previousRegularNight(GameState state) {
    const subPhases = [SubPhase.mafiaShoot, SubPhase.donCheck, SubPhase.sheriffCheck];

    if (state.currentSubPhaseIndex > 0) {
      return state.copyWith(
        currentSubPhase: subPhases[state.currentSubPhaseIndex - 1],
        currentSubPhaseIndex: state.currentSubPhaseIndex - 1,
      );
    }

    final wasBestMove = state.hasKillInLastNight;
    var newState = state.copyWith(currentPhase: Phase.day, currentDay: state.currentDay);

    if (wasBestMove && state.currentDay > 1) {
      newState = newState.copyWith(currentSubPhase: SubPhase.bestMove, currentSubPhaseIndex: 0);
    } else {
      newState = newState.copyWith(currentSubPhase: SubPhase.speeches, currentSubPhaseIndex: 0);
    }
    return newState;
  }
}