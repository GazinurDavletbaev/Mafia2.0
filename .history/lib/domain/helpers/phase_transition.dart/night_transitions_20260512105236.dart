import 'package:mafia_help/presentation/state/game_state.dart';
import 'package:mafia_help/core/logger/app_logger.dart';
import 'package:mafia_help/data/local/models/phase.dart';
import 'package:mafia_help/data/local/models/sub_phase.dart';
import '../game_rule_checker.dart';
import 'speech_initializer.dart';

class NightTransitions {
  static GameState next(GameState state) {
    final isFirstNight = state.currentDay == 0;
    AppLogger.d('NightTransitions.next() → isFirstNight=$isFirstNight, day=${state.currentDay}, subPhase=${state.currentSubPhase}');
    return isFirstNight ? _nextFirstNight(state) : _nextRegularNight(state);
  }

  static GameState previous(GameState state) {
    final isFirstNight = state.currentDay == 0;
    AppLogger.d('NightTransitions.previous() → isFirstNight=$isFirstNight, day=${state.currentDay}, subPhase=${state.currentSubPhase}');
    return isFirstNight ? _previousFirstNight(state) : _previousRegularNight(state);
  }

  static GameState _nextFirstNight(GameState state) {
    AppLogger.d('_nextFirstNight() → currentSubPhaseIndex=${state.currentSubPhaseIndex}');
    const subPhases = [SubPhase.roleDistribution, SubPhase.contract, SubPhase.sheriffLook];

    if (state.currentSubPhaseIndex < subPhases.length - 1) {
      final next = subPhases[state.currentSubPhaseIndex + 1];
      AppLogger.d('  переход к следующей подфазе ночи: $next');
      return state.copyWith(
        currentSubPhase: next,
        currentSubPhaseIndex: state.currentSubPhaseIndex + 1,
      );
    }

    AppLogger.d('  ночь 1 закончена → переход в день 1');
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
    AppLogger.d('_nextRegularNight() → currentSubPhaseIndex=${state.currentSubPhaseIndex}, day=${state.currentDay}');
    const subPhases = [SubPhase.mafiaShoot, SubPhase.donCheck, SubPhase.sheriffCheck];

    if (state.currentSubPhaseIndex < subPhases.length - 1) {
      final next = subPhases[state.currentSubPhaseIndex + 1];
      AppLogger.d('  переход к следующей подфазе ночи: $next');
      return state.copyWith(
        currentSubPhase: next,
        currentSubPhaseIndex: state.currentSubPhaseIndex + 1,
      );
    }

    final hasKill = GameRuleChecker.hasKillInLastNight(state);
    final nextSubPhase = hasKill ? SubPhase.bestMove : SubPhase.speeches;
    AppLogger.d('  ночь закончена → переход в день, hasKill=$hasKill, nextSubPhase=$nextSubPhase');

    var newState = state.copyWith(
      currentPhase: Phase.day,
      currentSubPhase: nextSubPhase,
      currentSubPhaseIndex: 0,
      currentDay: state.currentDay,
    );

    if (nextSubPhase == SubPhase.speeches) {
      AppLogger.d('  переход на speeches → инициализируем');
      newState = SpeechInitializer.initialize(newState);
    }
    return newState;
  }

  static GameState _previousFirstNight(GameState state) {
    AppLogger.d('_previousFirstNight() → currentSubPhaseIndex=${state.currentSubPhaseIndex}');
    const subPhases = [SubPhase.roleDistribution, SubPhase.contract, SubPhase.sheriffLook];

    if (state.currentSubPhaseIndex > 0) {
      final prev = subPhases[state.currentSubPhaseIndex - 1];
      AppLogger.d('  возврат к предыдущей подфазе ночи: $prev');
      return state.copyWith(
        currentSubPhase: prev,
        currentSubPhaseIndex: state.currentSubPhaseIndex - 1,
      );
    }

    AppLogger.d('  возврат из ночи 1 в конец голосования');
    return state.copyWith(
      currentPhase: Phase.day,
      currentSubPhase: SubPhase.finalWord,
      currentSubPhaseIndex: 2,
      hasKillInLastNight: false,
    );
  }

  static GameState _previousRegularNight(GameState state) {
    AppLogger.d('_previousRegularNight() → currentSubPhaseIndex=${state.currentSubPhaseIndex}');
    const subPhases = [SubPhase.mafiaShoot, SubPhase.donCheck, SubPhase.sheriffCheck];

    if (state.currentSubPhaseIndex > 0) {
      final prev = subPhases[state.currentSubPhaseIndex - 1];
      AppLogger.d('  возврат к предыдущей подфазе ночи: $prev');
      return state.copyWith(
        currentSubPhase: prev,
        currentSubPhaseIndex: state.currentSubPhaseIndex - 1,
      );
    }

    final wasBestMove = state.hasKillInLastNight;
    AppLogger.d('  возврат из ночи в день, wasBestMove=$wasBestMove, day=${state.currentDay}');

    var newState = state.copyWith(currentPhase: Phase.day, currentDay: state.currentDay);

    if (wasBestMove && state.currentDay > 1) {
      AppLogger.d('  возврат на bestMove');
      newState = newState.copyWith(currentSubPhase: SubPhase.bestMove, currentSubPhaseIndex: 0);
    } else {
      AppLogger.d('  возврат на speeches');
      newState = newState.copyWith(currentSubPhase: SubPhase.speeches, currentSubPhaseIndex: 0);
    }
    return newState;
  }
}