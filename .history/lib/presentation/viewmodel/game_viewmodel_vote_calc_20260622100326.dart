import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mafia_help/domain/helpers/vote_controller.dart';
import 'package:mafia_help/data/local/models/sub_phase.dart';
import 'package:mafia_help/data/local/models/phase.dart';
import 'package:mafia_help/presentation/widgets/player_timer_type.dart';
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
    print('isBestMove before = ${_vm.state.isBestMove}');
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
      AppLogger.d('submitVote: all votes collected, finalizing');
      _finalizeVoting(controller.results);
    } else {
      controller.nextCandidate();
      final newState = _vm.state.copyWith(voteController: controller);
      _vm.updateState(newState);
    }
  }

  void _finalizeEliminationVote() {
    final aliveCount = _vm.state.players.where((p) => p.isAlive).length;
    final majority = aliveCount ~/ 2 + 1;

    // Сохраняем eliminationVote в историю
    final day = _vm.state.currentDay;
    final votes = _vm.state.voteController?.results ?? {};
    Map<int, int> record = {11: day, ...votes};

    if (_vm.state.eliminationVotes >= majority) {
      final tiedSeats = _vm.state.tiedSeats;
      final aliveAfter = aliveCount - tiedSeats.length;
      final canHaveBestMove = aliveAfter >= 9;
      final isVotingDay = _vm.state.isVotingDay;

      print('=== FINALIZE ELIMINATION VOTE ===');
      print('aliveAfter = $aliveAfter');
      print('canHaveBestMove = $canHaveBestMove');
      print('isvonitgday = $isVotingDay');

      // Добавляем ушедших игроков
      for (int i = 0; i < tiedSeats.length && i < 4; i++) {
        record[12 + i] = tiedSeats[i];
      }

      final newState = _vm.state.copyWith(
        currentSubPhase: SubPhase.finalWord,
        currentSpeakerSeat: tiedSeats.isNotEmpty ? tiedSeats[0] : -1,
        tiedSeats: tiedSeats,
        voteController: null,
        isVotingActive: false,
        isBestMove: canHaveBestMove,
        voteHistory: [..._vm.state.voteHistory, record],
      );
      _vm.updateState(newState);
    } else {
      final canHaveBestMove = aliveCount >= 9;
      final nextDay = _vm.state.currentDay + 1;
      print('=== else FINALIZE ELIMINATION VOTE ===');
      print('canHaveBestMove = $canHaveBestMove');

      // Никто не ушёл — без ключей 12-15
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
        voteHistory: [..._vm.state.voteHistory, record],
      );
      _vm.updateState(newState);
    }
  }

  void _finalizeVoting(Map<int, int> votes) {
    AppLogger.d('_finalizeVoting: votes=$votes');
    final aliveCount = _vm.state.players.where((p) => p.isAlive).length;
    final isRevote = _vm.state.currentSubPhase == SubPhase.revote;
    final previousTiedCount = _vm.state.tiedSeats.length;
    print(previousTiedCount);

    final result = VoteController.determineResult(
      votes,
      aliveCount,
      isRevote: isRevote,
      previousTiedCount: previousTiedCount,
    );

    AppLogger.d('_finalizeVoting: result=${result.type}');

    // Сначала показываем последний введённый голос (обновляем состояние с голосами)
    // Сохраняем результаты голосования, но пока не переходим
    final stateWithVotes = _vm.state.copyWith(
      voteController: _vm.state.voteController,
      isVotingActive: false,
    );
    _vm.updateState(stateWithVotes);

    // Задержка 2 секунды перед переходом
    Future.delayed(const Duration(seconds: 2), () {
      GameState newState;

      // Формируем запись для голосования
      final day = _vm.state.currentDay;
      Map<int, int> record = {11: day, ...votes};

      switch (result.type) {
        case VoteResultType.winner:
          // Уходит 1 игрок
          record[12] = result.winnerSeat!;

          newState = _vm.state.copyWith(
            currentSubPhase: SubPhase.finalWord,
            currentSpeakerSeat: result.winnerSeat,
            tiedSeats: [],
            voteController: null,
            isVotingActive: false,
            currentSpeakerTimer: PlayerTimerType.seconds60,
            voteHistory: [..._vm.state.voteHistory, record],
          );
          break;

        case VoteResultType.tieBreak:
          // Никто не уходит
          newState = _vm.state.copyWith(
            currentSubPhase: SubPhase.tieBreak,
            tiedSeats: result.seats,
            currentTieIndex: 0,
            currentSpeakerSeat:
                result.seats.isNotEmpty ? result.seats[0] : null,
            voteController: null,
            isVotingActive: false,
            currentSpeakerTimer: PlayerTimerType.seconds30,
            voteHistory: [..._vm.state.voteHistory, record],
          );
          break;

        case VoteResultType.eliminationVote:
          // Уходят все лидеры (result.seats)
          for (int i = 0; i < result.seats.length && i < 4; i++) {
            record[12 + i] = result.seats[i];
          }

          newState = _vm.state.copyWith(
            currentSubPhase: SubPhase.eliminationVote,
            tiedSeats: result.seats,
            voteController: null,
            isVotingActive: false,
            currentSpeakerTimer: PlayerTimerType.seconds60,
            voteHistory: [..._vm.state.voteHistory, record],
          );
          break;

        case VoteResultType.noCandidates:
          // Нет кандидатов
          final nextDay = _vm.state.currentDay + 1;

          newState = _vm.state.copyWith(
            currentPhase: Phase.night,
            currentSubPhase: SubPhase.mafiaShoot,
            currentDay: nextDay,
            voteController: null,
            isVotingActive: false,
            nominatedSeats: [],
            votes: {},
            voteHistory: [..._vm.state.voteHistory, record],
          );
          break;
        default:
          newState = _vm.state.copyWith();
          break;
      }

      print(
          'tieBreak: seats=${result.seats}, currentSubPhase=${newState.currentSubPhase}');
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
