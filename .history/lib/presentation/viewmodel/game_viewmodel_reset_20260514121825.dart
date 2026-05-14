import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mafia_help/application/providers/providers.dart';
import '../../core/logger/app_logger.dart';
import 'game_viewmodel.dart';

class ResetActions {
  final GameViewModel _vm;
  final Ref _ref;

  ResetActions(this._vm, this._ref);

  Future<void> onResetGame() async {
    AppLogger.d('onResetGame called');
    final usecase = _ref.read(resetGameUsecaseProvider);
    final newState = await usecase();
    _vm.state = newState;
  }

  Future<void> dealRoles() async {
    AppLogger.d('dealRoles() called');
    
    const roles = ['don', 'mafia', 'mafia', 'sheriff', 'citizen', 'citizen', 'citizen', 'citizen', 'citizen', 'citizen'];
    
    final dealRolesUsecase = _ref.read(dealRolesUsecaseProvider);
    final newPlayers = dealRolesUsecase.execute(
      players: _vm.state.players,
      roles: roles,
    );
    
    _vm.state = _vm.state.copyWith(players: newPlayers);
  }
}