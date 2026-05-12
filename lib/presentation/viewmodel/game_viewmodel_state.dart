import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mafia_help/application/providers/providers.dart';
import '../../core/logger/app_logger.dart';
import '../state/game_state.dart';
import 'game_viewmodel.dart';

class GameViewModelState {
  final GameViewModel _vm;
  final Ref _ref;

  GameViewModelState(this._vm, this._ref);

  Future<void> loadSavedGame() async {
    AppLogger.d('loadSavedGame START');
    final repository = _ref.read(gameRepositoryProvider);
    final saved = await repository.getCurrentGameState();
    if (saved != null) {
      _vm.state = saved;
    }
    AppLogger.d('loadSavedGame END: subPhase=${_vm.state.currentSubPhase}');
  }
}