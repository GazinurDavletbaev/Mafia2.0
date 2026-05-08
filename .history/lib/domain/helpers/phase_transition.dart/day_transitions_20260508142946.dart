import 'package:mafia_help/presentation/state/game_state.dart';
import 'package:mafia_help/core/logger/app_logger.dart';
import 'package:mafia_help/data/local/models/phase.dart';
import 'package:mafia_help/data/local/models/sub_phase.dart';
import '../night_phase_factory.dart';
import 'speech_initializer.dart';
import 'night_phase_factory.dart';

class DayTransitions {
  static GameState next(GameState state) {
    final isFirstDay = state.currentDay == 1;
    final hasBestMove = state.currentSubPhase == SubPhase.bestMove;

    AppLogger.d('DayTransitions.next() → isFirstDay=$isFirstDay, hasBestMove=$hasBestMove, day=${state.currentDay}, subPhase=${state.currentSubPhase}');

    List<SubPhase> subPhases;
    if (isFirstDay) {
      subPhases = [SubPhase.speeches];
    } else if (hasBestMove) {
      subPhases = [SubPhase.bestMove, SubPhase.speeches];
    } else {
      subPhases = [SubPhase.speeches];
    }
    AppLogger.d('  subPhases = $subPhases, currentIndex=${state.currentSubPhaseIndex}');

    if (state.currentSubPhaseIndex < subPhases.length - 1) {
      final nextSubPhase = subPhases[state.currentSubPhaseIndex + 1];
      AppLogger.d('  переход к следующей подфазе дня: $nextSubPhase');
      if (nextSubPhase == SubPhase.speeches) {
        AppLogger.d('  переход на speeches → инициализируем');
        return SpeechInitializer.initialize(state);
      }
      return state.copyWith(
        currentSubPhase: nextSubPhase,
        currentSubPhaseIndex: state.currentSubPhaseIndex + 1,
      );
    }

    if (state.currentSubPhase == SubPhase.speeches) {
      AppLogger.d('  речи закончены → переход к голосованию');
      return state.copyWith(
        currentPhase: Phase.voting,
        currentSubPhase: SubPhase.voting,
        currentSubPhaseIndex: 0,
        nominatedSeats: [],
        votes: {},
      );
    }

    AppLogger.d('  инициализация речей');
    return SpeechInitializer.initialize(state);
  }

  static GameState previous(GameState state) {
    final isFirstDay = state.currentDay == 1;
    AppLogger.d('DayTransitions.previous() → isFirstDay=$isFirstDay, day=${state.currentDay}, subPhase=${state.currentSubPhase}, index=${state.currentSubPhaseIndex}');

    if (state.currentSubPhaseIndex > 0) {
      AppLogger.d('  возврат к предыдущей подфазе дня');
      return state.copyWith(currentSubPhaseIndex: state.currentSubPhaseIndex - 1);
    }

    AppLogger.d('  возврат в ночь');
    if (isFirstDay) {
      return NightPhaseFactory.createFirstNight(state);
    } else {
      return NightPhaseFactory.createRegularNight(state, day: state.currentDay);
    }
  }
}