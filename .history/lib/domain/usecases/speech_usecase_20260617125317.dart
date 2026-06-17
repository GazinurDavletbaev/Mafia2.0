import 'package:mafia_help/data/local/models/player_model.dart';
import 'package:mafia_help/data/local/models/sub_phase.dart';
import 'package:mafia_help/domain/rules/speech_rules.dart';
import 'package:mafia_help/presentation/state/game_state.dart';

import '../../data/local/models/phase.dart';
import '../helpers/vote_controller.dart';

class SpeechUsecase {
  final SpeechRules _rules = SpeechRules();

  /// Обработать нажатие "дальше" в фазе speeches
  /// Возвращает: (новое состояние, нужно ли обновить UI)
  (GameState, bool) processNextSpeaker(GameState state) {
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
      return (
        state.copyWith(
          currentSpeakerSeat: nextSpeaker,
          speechHistory: [...state.speechHistory, nextSpeaker],
        ),
        true,
      );
    }
    // День закончен - определяем следующую фазу
    final candidates = state.nominatedSeats;
    final isDay0 = state.currentDay == 0;
    final isVotingDay = state.isVotingDay;

    if (candidates.isEmpty ||
        (candidates.length == 1 && isDay0) ||
        !isVotingDay) {
      return (
        state.copyWith(
          currentPhase: Phase.night,
          currentSubPhase: SubPhase.mafiaShoot,
          currentSpeakerSeat: null,
          nominatedSeats: [],
          currentDay: state.currentDay + 1,
          isVotingDay: true,
        ),
        true,
      );
    }
    if (candidates.length == 1 && !isDay0) {
      return (
        state.copyWith(
          currentSubPhase: SubPhase.finalWord,
          currentSpeakerSeat: candidates.first,
        ),
        true,
      );
    }
    return (
      state.copyWith(
        currentSubPhase: SubPhase.voting,
        currentSpeakerSeat: null,
        isVotingActive: true, // ← добавить
        voteController: VoteController(candidates), // ← добавить
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
        ),
        true,
      );
    }

    return (
      state.copyWith(
        currentSubPhase: SubPhase.revote,
        currentSpeakerSeat: null,
        nominatedSeats: tiedSeats,
        currentTieIndex: 0,
        voteController: VoteController(tiedSeats),
        isVotingActive: true,
      ),
      true,
    );
  }
}
