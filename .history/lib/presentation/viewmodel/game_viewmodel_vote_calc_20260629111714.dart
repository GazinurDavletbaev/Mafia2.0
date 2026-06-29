import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mafia_help/domain/helpers/vote_controller.dart';
import 'package:mafia_help/data/local/models/sub_phase.dart';
import 'package:mafia_help/data/local/models/phase.dart';
import 'package:mafia_help/presentation/widgets/player_timer_type.dart';
import 'package:mafia_help/presentation/state/vote_day.dart';
import '../../core/logger/app_logger.dart';
import '../state/game_state.dart';
import 'game_viewmodel.dart';

class VoteCalculatorActions {
  final GameViewModel _vm;
  final Ref _ref;

  VoteCalculatorActions(this._vm, this._ref);

  void submitVote(int votes) {
    print('=== SUBMIT VOTE ===');
    print('votes = $votes');
    print('currentSubPhase = ${_vm.state.currentSubPhase}');

    if (_vm.state.currentSubPhase == SubPhase.eliminationVote) {
      _vm.state = _vm.state.copyWith(eliminationVotes: votes);
      _finalizeEliminationVote();
      return;
    }

    final controller = _vm.state.voteController;
    if (controller == null) {
      AppLogger.d('submitVote: no active controller');
      return;
    }
    print('hihihihii');
    print(controller.totalCandidates);
    if (controller.totalCandidates == 0) {
      AppLogger.d('submitVote: no candidates, going to night');
      _finalizeVoting({});
      return;
    }

    if (controller.totalCandidates == 1) {
      final aliveCount = _vm.state.players.where((p) => p.isAlive).length;
      controller.setVotes(aliveCount);
      _finalizeVoting(controller.results);
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
      _vm.updateState(newState);
    }
    print('controller.isComplete: ${controller.isComplete}');
    print('controller.results: ${controller.results}');
  }

  void _finalizeEliminationVote() {
    final aliveCount = _vm.state.players.where((p) => p.isAlive).length;
    final majority = aliveCount ~/ 2 + 1;

    final day = _vm.state.currentDay;
    final votes = _vm.state.voteController?.results ?? {};
    final eliminationVotes = _vm.state.eliminationVotes;
    final tiedSeats = _vm.state.tiedSeats;

    final stateWithVotes = _vm.state.copyWith(
      voteController: _vm.state.voteController,
      isVotingActive: false,
    );
    _vm.updateState(stateWithVotes);

    Future.delayed(const Duration(seconds: 2), () {
      if (_vm.state.eliminationVotes >= majority) {
        final aliveAfter = aliveCount - tiedSeats.length;
        final canHaveBestMove = aliveAfter >= 9;

        // Создаём VoteDay для записи
        final existingDay = _vm.state.voteHistory[day];
        final updatedDay = existingDay?.copyWith(
              eliminated: true,
              eliminationVotes: eliminationVotes,
              result: tiedSeats,
            ) ??
            VoteDay(
              rounds: [votes],
              eliminated: true,
              eliminationVotes: eliminationVotes,
              result: tiedSeats,
            );

        final newState = _vm.state.copyWith(
          currentSubPhase: SubPhase.finalWord,
          currentSpeakerSeat: tiedSeats.isNotEmpty ? tiedSeats[0] : -1,
          tiedSeats: tiedSeats,
          voteController: null,
          isVotingActive: false,
          isBestMove: canHaveBestMove,
          eliminationVotes: 0,
          voteHistory: {
            ..._vm.state.voteHistory,
            day: updatedDay,
          },
        );
        _vm.updateState(newState);
      } else {
        final canHaveBestMove = aliveCount >= 9;
        final nextDay = _vm.state.currentDay + 1;

        // Создаём VoteDay для записи (никто не ушёл)
        final existingDay = _vm.state.voteHistory[day];
        final updatedDay = existingDay?.copyWith(
              eliminated: false,
              eliminationVotes: eliminationVotes,
              result: [],
            ) ??
            VoteDay(
              rounds: [votes],
              eliminated: false,
              eliminationVotes: eliminationVotes,
              result: [],
            );

        final newState = _vm.state.copyWith(
          currentPhase: Phase.night,
          currentSubPhase: SubPhase.mafiaShoot,
          currentSpeakerSeat: -1,
          currentDay: nextDay,
          voteController: null,
          isVotingActive: false,
          nominatedSeats: [],
          votes: {},
          isBestMove: canHaveBestMove,
          eliminationVotes: 0,
          voteHistory: {
            ..._vm.state.voteHistory,
            day: updatedDay,
          },
        );
        _vm.updateState(newState);
      }
    });
  }

  void _finalizeVoting(Map<int, int> votes) {
    AppLogger.d('_finalizeVoting: votes=$votes');
    print('currentSubPhase: ${_vm.state.currentSubPhase}');

    final aliveCount = _vm.state.players.where((p) => p.isAlive).length;
    final isRevote = _vm.state.currentSubPhase == SubPhase.revote;
    final previousTiedCount = _vm.state.tiedSeats.length;

    final result = VoteController.determineResult(
      votes,
      aliveCount,
      isRevote: isRevote,
      previousTiedCount: previousTiedCount,
    );

    AppLogger.d('_finalizeVoting: result=${result.type}');

    final stateWithVotes = _vm.state.copyWith(
      voteController: _vm.state.voteController,
      isVotingActive: false,
    );
    _vm.updateState(stateWithVotes);

    Future.delayed(const Duration(seconds: 2), () {
      GameState newState;
      final day = _vm.state.currentDay;

      switch (result.type) {
        case VoteResultType.winner:
          final isRevote = _vm.state.currentSubPhase == SubPhase.revote;
          if (isRevote) {
            // Переголосование — добавляем раунд к существующему дню
            final existingDay = _vm.state.voteHistory[day];
            final updatedDay = existingDay?.addRound(votes).copyWith(
              eliminated: true,
              result: [result.winnerSeat!],
            );

            final newVoteHistory =
                Map<int, VoteDay>.from(_vm.state.voteHistory);
            print('=== WINNER REVOTE SAVE ===');
            print('day: $day');
            print('votes: $votes');
            print('existingDay: $existingDay');
            print('existingDay.rounds: ${existingDay?.rounds}');
            print(
                'newVoteHistory[day]?.rounds: ${newVoteHistory[day]?.rounds}');

            newState = _vm.state.copyWith(
              currentSubPhase: SubPhase.finalWord,
              currentSpeakerSeat: result.winnerSeat,
              tiedSeats: [],
              voteController: null,
              isVotingActive: false,
              currentSpeakerTimer: PlayerTimerType.seconds60,
              voteHistory: newVoteHistory,
            );
          } else {
            // Первое голосование — создаём новый день
            final voteDay = VoteDay(
              rounds: [votes],
              eliminated: true,
              result: [result.winnerSeat!],
            );
            newState = _vm.state.copyWith(
              currentSubPhase: SubPhase.finalWord,
              currentSpeakerSeat: result.winnerSeat,
              tiedSeats: [],
              voteController: null,
              isVotingActive: false,
              currentSpeakerTimer: PlayerTimerType.seconds60,
              voteHistory: {
                ..._vm.state.voteHistory,
                day: voteDay,
              },
            );
          }

          break;

        case VoteResultType.tieBreak:
          // ПЕРЕСТРЕЛКА (ничья) — добавляем раунд
          final existingDay = _vm.state.voteHistory[day];
          final updatedDay = existingDay?.addRound(votes) ??
              VoteDay(
                rounds: [votes],
                eliminated: false,
                result: [],
              );

          newState = _vm.state.copyWith(
            currentSubPhase: SubPhase.tieBreak,
            tiedSeats: result.seats,
            currentTieIndex: 0,
            currentSpeakerSeat:
                result.seats.isNotEmpty ? result.seats[0] : null,
            voteController: null,
            isVotingActive: false,
            currentSpeakerTimer: PlayerTimerType.seconds30,
            voteHistory: {
              ..._vm.state.voteHistory,
              day: updatedDay,
            },
          );
          print('=== TIE BREAK SAVE ===');
          print('day: $day');
          print('votes: $votes');
          print('existingDay: $existingDay');
          print('updatedDay.rounds: ${updatedDay.rounds}');
          break;

        case VoteResultType.eliminationVote:
          // Голосование за подъём
          final existingDay = _vm.state.voteHistory[day];
          final updatedDay = existingDay?.addRound(votes) ??
              VoteDay(
                rounds: [votes],
                eliminated: false,
                result: [],
              );

          newState = _vm.state.copyWith(
            currentSubPhase: SubPhase.eliminationVote,
            tiedSeats: result.seats,
            voteController: null,
            isVotingActive: false,
            currentSpeakerTimer: PlayerTimerType.seconds60,
            voteHistory: {
              ..._vm.state.voteHistory,
              day: updatedDay,
            },
          );
          break;

        case VoteResultType.noCandidates:
          final nextDay = _vm.state.currentDay + 1;

          final voteDay = VoteDay(
            rounds: [votes],
            eliminated: false,
            result: [],
          );

          newState = _vm.state.copyWith(
            currentPhase: Phase.night,
            currentSubPhase: SubPhase.mafiaShoot,
            currentDay: nextDay,
            voteController: null,
            isVotingActive: false,
            nominatedSeats: [],
            votes: {},
            voteHistory: {
              ..._vm.state.voteHistory,
              day: voteDay,
            },
          );
          break;
      }
      print('=== FINALIZE VOTING ===');
      print('day: $day');
      print('votes: $votes');
      print('result.type: ${result.type}');
      _vm.updateState(newState);
    });
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
