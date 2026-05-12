import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mafia_help/domain/helpers/vote_controller.dart';
import 'package:mafia_help/data/local/models/sub_phase.dart';
import 'package:mafia_help/data/local/models/phase.dart';
import '../../core/logger/app_logger.dart';
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
    _vm.setStateFromVoteCalculator(newState);
  }

  void submitVote(int votes) {
    final controller = _vm.state.voteController;
    if (controller == null) {
      AppLogger.d('submitVote: no active controller');
      return;
    }
    
    AppLogger.d('submitVote: seat=${controller.currentSeat}, votes=$votes');
    controller.setVotes(votes);
    
    if (controller.isComplete) {
      AppLogger.d('submitVote: all votes collected, finalizing');
      _finalizeVoting(controller.results);
    } else {
      controller.nextCandidate();
      final newState = _vm.state.copyWith(voteController: controller);
      _vm.setStateFromVoteCalculator(newState);
    }
  }

  void _finalizeVoting(Map<int, int> votes) {
    AppLogger.d('_finalizeVoting: votes=$votes');
    final aliveCount = _vm.state.players.where((p) => p.isAlive).length;
    final result = VoteController.determineResult(votes, aliveCount);
    
    AppLogger.d('_finalizeVoting: result=${result.type}');
    
    GameState newState;
    
    switch (result.type) {
      case VoteResultType.winner:
        newState = _vm.state.copyWith(
          currentSubPhase: SubPhase.finalWord,
          currentSpeakerSeat: result.winnerSeat,
          voteController: null,
          isVotingActive: false,
        );
        break;
        
      case VoteResultType.tieBreak:
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
          currentSubPhase: SubPhase.eliminationVote,
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
    }
    
    _vm.setStateFromVoteCalculator(newState);
  }

  void hideVoteCalculator() {
    final controller = _vm.state.voteController;
    if (controller != null) {
      controller.hide();
      final newState = _vm.state.copyWith(voteController: controller);
      _vm.setStateFromVoteCalculator(newState);
    }
  }

  void showVoteCalculator() {
    final controller = _vm.state.voteController;
    if (controller != null) {
      controller.show();
      final newState = _vm.state.copyWith(voteController: controller);
      _vm.setStateFromVoteCalculator(newState);
    }
  }

  VoteController? getVoteController() {
    return _vm.state.voteController;
  }
}