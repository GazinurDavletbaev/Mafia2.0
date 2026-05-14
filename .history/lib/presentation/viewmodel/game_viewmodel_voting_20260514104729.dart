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
    // TODO: переписать через VotingRules
    _vm.updateState(_vm.state);
  }

  Future<void> onRevote() async {
    AppLogger.d('onRevote called');
    // TODO: переписать через VotingRules
    _vm.updateState(_vm.state);
  }

  Future<void> onNextTieCandidate() async {
    AppLogger.d('onNextTieCandidate called');
    // TODO: переписать через VotingRules
    _vm.updateState(_vm.state);
  }

  Future<void> onFinishTieBreak() async {
    AppLogger.d('onFinishTieBreak called');
    // TODO: переписать через VotingRules
    _vm.updateState(_vm.state);
  }

  Future<void> onEliminationVote(int votes) async {
    AppLogger.d('onEliminationVote: votes=$votes');
    // TODO: переписать через VotingRules
    _vm.updateState(_vm.state);
  }

  Future<void> onCheckEliminationResult() async {
    AppLogger.d('onCheckEliminationResult called');
    // TODO: переписать через VotingRules
    _vm.updateState(_vm.state);
  }
}
