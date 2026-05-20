import 'package:mafia_help/presentation/state/game_state.dart';
import 'package:mafia_help/core/logger/app_logger.dart';
import 'package:mafia_help/data/local/models/phase.dart';
import 'package:mafia_help/data/local/models/sub_phase.dart';
import '../night_phase_factory.dart';
import 'speech_initializer.dart';
import '../vote_calculator.dart';
import 'package:mafia_help/domain/helpers/vote_controller.dart';

class DayTransitions {
  static GameState next(GameState state) {
    final isFirstDay = state.currentDay == 1;
    final hasBestMove = state.currentSubPhase == SubPhase.bestMove;

    AppLogger.d(
      'DayTransitions.next() → isFirstDay=$isFirstDay, hasBestMove=$hasBestMove, day=${state.currentDay}, subPhase=${state.currentSubPhase}',
    );

    // ========== ГОЛОСОВАНИЕ ==========
    if (state.currentSubPhase == SubPhase.voting) {
      AppLogger.d('  в голосовании → проверяем кандидатов');

      if (state.nominatedSeats.isEmpty) {
        AppLogger.d('  нет кандидатов → переход в ночь');
        final nextDay = state.currentDay + 1;
        return NightPhaseFactory.createRegularNight(state, day: nextDay);
      }

      if (state.nominatedSeats.length == 1) {
        AppLogger.d('  один кандидат → переход на finalWord');
        return state.copyWith(
          currentSubPhase: SubPhase.finalWord,
          currentSubPhaseIndex: 0,
          currentSpeakerSeat: state.nominatedSeats.first,
          nominatedSeats: [],
          votes: {},
        );
      }

      // 2+ кандидата → начинаем голосование
      AppLogger.d(
        '  ${state.nominatedSeats.length} кандидата → начинаем голосование',
      );
      return state.copyWith(
        isVotingActive: true,
        voteController: VoteController(state.nominatedSeats),
      );
    }

    // ========== ПЕРЕГОЛОСОВАНИЕ ==========
    if (state.currentSubPhase == SubPhase.revote) {
      AppLogger.d('  в переголосовании → проверяем результат');

      if (VoteCalculator.isTie(state)) {
        AppLogger.d('  равный счёт → переход на tieBreak');
        return state.copyWith(
          currentSubPhase: SubPhase.tieBreak,
          currentSubPhaseIndex: 0,
          tiedSeats: VoteCalculator.getTiedSeats(state),
          currentTieIndex: 0,
          currentSpeakerSeat: VoteCalculator.getTiedSeats(state).isNotEmpty
              ? VoteCalculator.getTiedSeats(state)[0]
              : null,
          votes: {},
        );
      }

      if (VoteCalculator.hasWinner(state)) {
        final winnerSeat = VoteCalculator.getWinnerSeat(state);
        AppLogger.d(
          '  есть победитель → переход на finalWord (место $winnerSeat)',
        );
        return state.copyWith(
          currentSubPhase: SubPhase.finalWord,
          currentSubPhaseIndex: 0,
          currentSpeakerSeat: winnerSeat,
          votes: {},
        );
      }

      AppLogger.d('  нет результата → переход в ночь');
      final nextDay = state.currentDay + 1;
      return NightPhaseFactory.createRegularNight(state, day: nextDay);
    }

    // ========== ПЕРЕСТРЕЛКА ==========
    if (state.currentSubPhase == SubPhase.tieBreak) {
      AppLogger.d('  tieBreak закончен → переход на revote');
      return state.copyWith(
        currentSubPhase: SubPhase.revote,
        currentSubPhaseIndex: 0,
        votes: {},
      );
    }

    // ========== ЗАКЛЮЧИТЕЛЬНАЯ МИНУТА ==========
    if (state.currentSubPhase == SubPhase.finalWord) {
      AppLogger.d('  finalWord закончен → переход в ночь');
      final nextDay = state.currentDay + 1;
      return NightPhaseFactory.createRegularNight(state, day: nextDay);
    }

    // ========== ЛУЧШИЙ ХОД ==========
    if (state.currentSubPhase == SubPhase.bestMove) {
      AppLogger.d('  bestMove закончен → переход на finalWord');
      return state.copyWith(
        currentSubPhase: SubPhase.finalWord,
        currentSubPhaseIndex: 0,
      );
    }
    // ========== РЕЧИ ==========
    List<SubPhase> subPhases;
    if (isFirstDay) {
      subPhases = [SubPhase.speeches];
    } else if (hasBestMove) {
      subPhases = [SubPhase.bestMove, SubPhase.speeches];
    } else {
      subPhases = [SubPhase.speeches];
    }

    AppLogger.d(
      '  subPhases = $subPhases, currentIndex=${state.currentSubPhaseIndex}',
    );

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
    AppLogger.d(
      'DayTransitions.previous() → isFirstDay=$isFirstDay, day=${state.currentDay}, subPhase=${state.currentSubPhase}, index=${state.currentSubPhaseIndex}',
    );

    if (state.currentSubPhaseIndex > 0) {
      AppLogger.d('  возврат к предыдущей подфазе дня');
      return state.copyWith(
        currentSubPhaseIndex: state.currentSubPhaseIndex - 1,
      );
    }

    AppLogger.d('  возврат в ночь');
    if (isFirstDay) {
      return NightPhaseFactory.createFirstNight(state);
    } else {
      return NightPhaseFactory.createRegularNight(state, day: state.currentDay);
    }
  }
}
