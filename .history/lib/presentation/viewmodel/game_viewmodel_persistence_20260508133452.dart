import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mafia_help/application/providers/providers.dart';
import 'package:mafia_help/domain/helpers/game_end_helper.dart';
import '../../core/logger/app_logger.dart';
import '../state/game_state.dart';

class PersistenceActions {
  final GameViewModel _vm;
  final Ref _ref;

  PersistenceActions(this._vm, this._ref);

  Future<void> loadSavedGame() async {
    AppLogger.d('_loadSavedGame START');
    final repository = _ref.read(gameRepositoryProvider);
    final saved = await repository.getCurrentGameState();
    _vm.state = saved;
    AppLogger.d('_loadSavedGame END: subPhase=${_vm.state.currentSubPhase}');
  }

  Future<void> saveGame() async {
    AppLogger.d('saveGame: saving current state');
    final repository = _ref.read(gameRepositoryProvider);
    await repository.saveCurrentGameState(_vm.state);
  }

  Future<void> saveCompletedGame() async {
    final repository = _ref.read(gameRepositoryProvider);
    await repository.saveCompletedGame(_vm.state);
    await repository.clearCurrentGameState();
  }

  Future<void> checkGameEnd() async {
    final usecase = _ref.read(checkGameEndUsecaseProvider);
    final result = await usecase();
    if (result != null) {
      _showGameEndDialog(result);
    }
  }

  void _showGameEndDialog(GameResult result) {
    // TODO: реализовать показ диалога через контекст
  }
}