import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mafia_help/application/providers/providers.dart';
import 'package:mafia_help/domain/helpers/game_end_helper.dart';
import '../../core/logger/app_logger.dart';
import '../state/game_state.dart';

class EndGameActions {
  final GameViewModel _vm;
  final Ref _ref;

  EndGameActions(this._vm, this._ref);

  Future<void> onEndGame(GameResult result) async {
    final usecase = _ref.read(endGameUsecaseProvider);
    final newState = await usecase(result);
    _vm.state = newState;
    await _ref.read(gameViewModelFamily(_vm.gameId).notifier)._saveCompletedGame();
  }

  Future<void> checkGameEnd() async {
    final usecase = _ref.read(checkGameEndUsecaseProvider);
    final result = await usecase();
    if (result != null) {
      _showGameEndDialog(result);
    }
  }

  void _showGameEndDialog(GameResult result) {
    AppLogger.d('Game ended: ${result == GameResult.redWin ? "Красные победили" : "Чёрные победили"}');
    // TODO: реализовать показ диалога через контекст
  }
}