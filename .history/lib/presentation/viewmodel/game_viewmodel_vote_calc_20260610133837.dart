import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mafia_help/domain/helpers/vote_controller.dart';
import 'package:mafia_help/data/local/models/sub_phase.dart';
import 'package:mafia_help/data/local/models/phase.dart';
import '../../core/logger/app_logger.dart';
import '../state/game_state.dart';
import 'game_viewmodel.dart';

class VoteCalculatorActions {
  final GameViewModel _vm;
  final Ref _ref;

  VoteCalculatorActions(this._vm, this._ref);

  void startVoting(List<int> candidates) {
    AppLogger.d('startVoting: candidates=$candidates');
    final controller = VoteController(candidates);
    final newState = _vm.state.copyWith(
      voteController: controller,
      isVotingActive: true,
    );
    _vm.updateState(newState);
  }

  void submitVote(int votes) {
    // Если eliminationVote - сохраняем голоса и завершаем
    if (_vm.state.currentSubPhase == SubPhase.eliminationVote) {
      _vm.state = _vm.state.copyWith(eliminationVotes: votes);
      _finalizeEliminationVote();
      return;
    }

    // Обычное голосование
    final controller = _vm.state.voteController;
    if (controller == null) {
      AppLogger.d('submitVote: no active controller');
      return;
    }

    AppLogger.d('submitVote: seat=${controller.currentSeat}, votes=$votes');
    controller.setVotes(votes);

    if (controller.isComplete) {
      AppLogger.d(
          'submitVote: all votes collected, waiting for manual forward');
      return;
    } else {
      controller.nextCandidate();
      final newState = _vm.state.copyWith(voteController: controller);
      _vm.updateState(newState);
    }
  }

  void _finalizeEliminationVote() {
    final aliveCount = _vm.state.players.where((p) => p.isAlive).length;
    final majority = aliveCount ~/ 2 + 1;

    if (_vm.state.eliminationVotes >= majority) {
      // Переход в finalWord для всех лидеров
      final tiedSeats = _vm.state.tiedSeats;
      final newState = _vm.state.copyWith(
        currentSubPhase: SubPhase.finalWord,
        currentSpeakerSeat: tiedSeats.isNotEmpty ? tiedSeats[0] : null,
        tiedSeats: tiedSeats,
        voteController: null,
        isVotingActive: false,
      );
      _vm.updateState(newState);
    } else {
      // Ночь
      final nextDay = _vm.state.currentDay + 1;
      final newState = _vm.state.copyWith(
        currentPhase: Phase.night,
        currentSubPhase: SubPhase.mafiaShoot,
        currentDay: nextDay,
        voteController: null,
        isVotingActive: false,
        nominatedSeats: [],
        votes: {},
      );
      _vm.updateState(newState);
    }
  }

  void _finalizeVoting(Map<int, int> votes) {
    AppLogger.d('_finalizeVoting: votes=$votes');
    final aliveCount = _vm.state.players.where((p) => p.isAlive).length;
    final isRevote = _vm.state.currentSubPhase == SubPhase.revote;
    final previousTiedCount = _vm.state.tiedSeats.length; // ← добавить
    print(previousTiedCount);

    final result = VoteController.determineResult(
      votes,
      aliveCount,
      isRevote: isRevote,
      previousTiedCount: previousTiedCount, // ← добавить
    );

    AppLogger.d('_finalizeVoting: result=${result.type}');

    GameState newState;

    switch (result.type) {
      case VoteResultType.winner:
        newState = _vm.state.copyWith(
          currentSubPhase: SubPhase.finalWord,
          currentSpeakerSeat: result.winnerSeat,
          tiedSeats: [], // ← ОЧИСТИТЬ tiedSeats!
          voteController: null,
          isVotingActive: false,
        );
        break;

      case VoteResultType.tieBreak:
        // Всегда перестрелка (determineResult уже решил, что нужно именно это)
        newState = _vm.state.copyWith(
          currentSubPhase: SubPhase.tieBreak,
          tiedSeats: result.seats,
          currentTieIndex: 0,
          currentSpeakerSeat: result.seats.isNotEmpty ? result.seats[0] : null,
          voteController: null,
          isVotingActive: false,
        );
        break;
      case VoteResultType.eliminationVote:
        newState = _vm.state.copyWith(
          currentSubPhase: SubPhase.eliminationVote, // ← а не revote
          tiedSeats: result.seats,
          voteController: null,
          isVotingActive: false,
        );
        break;
      case VoteResultType.noCandidates:
        final nextDay = _vm.state.currentDay + 1;
        newState = _vm.state.copyWith(
          currentPhase: Phase.night,
          currentSubPhase: SubPhase.mafiaShoot,
          currentDay: nextDay,
          voteController: null,
          isVotingActive: false,
          nominatedSeats: [],
          votes: {},
        );
        break;
      default:
        newState = _vm.state.copyWith();
        break;
    }
    print(
      'tieBreak: seats=${result.seats}, currentSubPhase=${newState.currentSubPhase}',
    );
    _vm.updateState(newState);
  }

  void hideVoteCalculator() {
    final controller = _vm.state.voteController;
    if (controller != null) {
      controller.hide();
      final newState = _vm.state.copyWith(voteController: controller);
      _vm.updateState(newState);
    }
  }

  void showVoteCalculator() {
    final controller = _vm.state.voteController;
    if (controller != null) {
      controller.show();
      final newState = _vm.state.copyWith(voteController: controller);
      _vm.updateState(newState);
    }
  }

  VoteController? getVoteController() {
    return _vm.state.voteController;
  }
}
