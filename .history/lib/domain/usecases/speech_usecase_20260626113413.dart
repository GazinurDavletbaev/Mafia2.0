import 'package:mafia_help/data/local/models/player_model.dart';
import 'package:mafia_help/data/local/models/sub_phase.dart';
import 'package:mafia_help/domain/rules/speech_rules.dart';
import 'package:mafia_help/presentation/state/game_state.dart';
import 'package:mafia_help/presentation/widgets/player_timer_type.dart';

import '../../data/local/models/phase.dart';
import '../helpers/vote_controller.dart';

class SpeechUsecase {
  final SpeechRules _rules = SpeechRules();

  /// Обработать нажатие "дальше" в фазе speeches
  /// Возвращает: (новое состояние, нужно ли обновить UI)
  (GameState, bool) processNextSpeaker(GameState state) {
    print('=== PROCESS NEXT SPEAKER CALLED ===');
    print('currentSpeakerSeat = ${state.currentSpeakerSeat}');
    // Обработка текущего говорящего после его речи
    final currentSpeaker = state.currentSpeakerSeat;
    if (currentSpeaker != null) {
      final player =
          state.players.firstWhere((p) => p.seatNumber == currentSpeaker);
      if (player.fouls == 3 && !player.hasSkippedSpeech) {
        final updatedPlayer = player.copyWith(hasSkippedSpeech: true);
        final newPlayers = List<PlayerModel>.from(state.players);
        final index =
            newPlayers.indexWhere((p) => p.seatNumber == currentSpeaker);
        newPlayers[index] = updatedPlayer;
        state = state.copyWith(players: newPlayers);
      }
      if (player.gotThirdFoulDuringSpeech) {
        // Сбрасываем флаг, чтобы в следующий раз дать 60 секунд
        final updatedPlayer = player.copyWith(gotThirdFoulDuringSpeech: false);
        // ...
      }
    }
    final allAlive = state.players
        .where((p) => p.isAlive)
        .map((p) => p.seatNumber)
        .toList()
      ..sort();
    final nextSpeaker = _rules.findNextSpeaker(
      currentSpeaker: state.currentSpeakerSeat ?? 0,
      aliveSeats: allAlive,
      speechHistory: state.speechHistory,
    );
    if (nextSpeaker != null) {
      // Есть следующий говорящий
      final player =
          state.players.firstWhere((p) => p.seatNumber == nextSpeaker);

      // Проверяем, нужно ли дать 5 секунд
      final shouldGive5Seconds =
          (player.fouls == 3 && !player.hasSkippedSpeech) ||
              (player.fouls == 3 && player.gotThirdFoulDuringSpeech);

      // Если даём 5 секунд из-за gotThirdFoulDuringSpeech — сбрасываем флаг
      List<PlayerModel> newPlayers = state.players;
      if (player.fouls == 3 && player.gotThirdFoulDuringSpeech) {
        final updatedPlayer = player.copyWith(gotThirdFoulDuringSpeech: false);
        final index = newPlayers.indexWhere((p) => p.seatNumber == nextSpeaker);
        newPlayers[index] = updatedPlayer;
      }

      final timerType = shouldGive5Seconds
          ? PlayerTimerType.seconds5
          : PlayerTimerType.seconds60;

      return (
        state.copyWith(
          currentSpeakerSeat: nextSpeaker,
          speechHistory: [...state.speechHistory, nextSpeaker],
          currentSpeakerTimer: timerType,
          players: newPlayers,
        ),
        true,
      );
    }
    // День закончен - определяем следующую фазу
    final candidates = state.nominatedSeats;
    

    print('=== TRANSITION TO VOTING ===');
    print('currentSpeakerSeat before = ${state.currentSpeakerSeat}');
    print('candidates = $candidates');
    return (
      state.copyWith(
        currentSubPhase: SubPhase.voting,
        currentSpeakerSeat: -1,
        isVotingActive: true,
        voteController: VoteController(candidates),
        currentSpeakerTimer: null,
      ),
      true,
    );
  }

  /// Обработать нажатие "дальше" в фазе tieBreak
  (GameState, bool) processNextTieBreak(GameState state) {
    final tiedSeats = state.tiedSeats;
    final currentIndex = state.currentTieIndex;

    if (currentIndex + 1 < tiedSeats.length) {
      return (
        state.copyWith(
          currentTieIndex: currentIndex + 1,
          currentSpeakerSeat: tiedSeats[currentIndex + 1],
          currentSpeakerTimer: PlayerTimerType.seconds30,
        ),
        true,
      );
    }
    final isVotingDay = state.isVotingDay;
    if (!isVotingDay) {
      return (
        state.copyWith(
          currentPhase: Phase.night,
          currentSubPhase: SubPhase.mafiaShoot,
          currentSpeakerSeat: -1,
          nominatedSeats: [],
          currentDay: state.currentDay + 1,
          isVotingDay: true,
          currentSpeakerTimer: null,
        ),
        true,
      );
    }
    return (
      state.copyWith(
        currentSubPhase: SubPhase.revote,
        currentSpeakerSeat: -1,
        nominatedSeats: tiedSeats,
        currentTieIndex: 0,
        voteController: VoteController(tiedSeats),
        isVotingActive: true,
        currentSpeakerTimer: null,
      ),
      true,
    );
  }
}
