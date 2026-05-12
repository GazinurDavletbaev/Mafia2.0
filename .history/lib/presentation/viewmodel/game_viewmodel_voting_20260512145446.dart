import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mafia_help/application/providers/providers.dart';
import '../../core/logger/app_logger.dart';
import 'game_viewmodel.dart';

class VotingActions {
  final GameViewModel _vm;
  final Ref _ref;

  VotingActions(this._vm, this._ref);

  Future<void> onVote(int seat, int votes) async {
    AppLogger.d('onVote: seat=$seat, votes=$votes');
    final usecase = _ref.read(addVoteUsecaseProvider);
    _vm.state = await usecase(
      _vm.state,
      targetSeatNumber: seat,
      votesCount: votes,
    );
  }

  Future<void> onRevote() async {
    AppLogger.d('onRevote called');
    final usecase = _ref.read(revoteUsecaseProvider);
    _vm.state = await usecase();
  }

  Future<void> onNextTieCandidate() async {
    AppLogger.d('onNextTieCandidate called');
    final usecase = _ref.read(tieBreakUsecaseProvider);
    _vm.state = await usecase.nextCandidate();
  }

  Future<void> onFinishTieBreak() async {
    AppLogger.d('onFinishTieBreak called');
    final usecase = _ref.read(tieBreakUsecaseProvider);
    _vm.state = await usecase.finishTieBreak();
  }

  Future<void> onEliminationVote(int votes) async {
  AppLogger.d('onEliminationVote: votes=$votes');
  final usecase = _ref.read(eliminationVoteUsecaseProvider);
  _vm.state = await usecase.addVotes(_vm.state, votes);
}

Future<void> onCheckEliminationResult() async {
  AppLogger.d('onCheckEliminationResult called');
  final usecase = _ref.read(eliminationVoteUsecaseProvider);
  _vm.state = await usecase.checkResult(_vm.state);
}
ъ