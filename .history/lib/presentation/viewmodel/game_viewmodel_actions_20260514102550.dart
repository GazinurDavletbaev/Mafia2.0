import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mafia_help/application/providers/providers.dart';
import '../../core/logger/app_logger.dart';
import '../../data/local/models/sub_phase.dart';
import '../state/game_state.dart';
import 'game_viewmodel.dart';

class PlayerActions {
  final GameViewModel _vm;
  final Ref _ref;

  PlayerActions(this._vm, this._ref);

  Future<void> onPlayerTap(int seatNumber) async {
    AppLogger.d('onPlayerTap: seat=$seatNumber');

    if (_vm.state.currentSubPhase == SubPhase.roleDistribution) {
      toggleRoleCard(seatNumber);
      return;
    }

    final usecase = _ref.read(addFoulUsecaseProvider);
    final (newPlayers, winner) = usecase.execute(_vm.state.players, seatNumber);

    GameState newState = _vm.state.copyWith(players: newPlayers);

    if (winner != null) {
      newState = newState.copyWith(
        isGameEnded: true,
        winner: winner ? 'red' : 'black',
      );
    }

    _vm.state = newState;
  }

  void toggleRoleCard(int seatNumber) {
    if (_vm.state.showingRoleForSeat == seatNumber) {
      _vm.state = _vm.state.copyWith(showingRoleForSeat: null);
    } else {
      _vm.state = _vm.state.copyWith(showingRoleForSeat: seatNumber);
    }
  }

  void closeRoleCard() {
    _vm.state = _vm.state.copyWith(showingRoleForSeat: null);
  }

  Future<void> onPlayerLongPress(int seatNumber, int actionType) async {
    AppLogger.d('onPlayerLongPress: seat=$seatNumber, actionType=$actionType');
    switch (actionType) {
      case 0:
        await _killPlayer(seatNumber);
        break;
      case 1:
        await _revivePlayer(seatNumber);
        break;
      case 2:
        await _nominatePlayer(seatNumber);
        break;
      case 3:
        await _removeNomination(seatNumber);
        break;
      default:
        AppLogger.d('  unknown actionType: $actionType');
    }
  }

  Future<void> _killPlayer(int seatNumber) async {
    AppLogger.d('_killPlayer: seat=$seatNumber');
    final usecase = _ref.read(killPlayerUsecaseProvider);
    final newState = await usecase(
      _vm.state,
      seatNumber: seatNumber,
      phase: _vm.currentPhaseString(),
      killType: 'manual',
    );
    _vm.state = newState;
  }

  Future<void> _revivePlayer(int seatNumber) async {
    AppLogger.d('_revivePlayer: seat=$seatNumber');
    final usecase = _ref.read(revivePlayerUsecaseProvider);
    final newState = await usecase(_vm.state, seatNumber);
    _vm.state = newState;
  }

  Future<void> _nominatePlayer(int seatNumber) async {
    AppLogger.d('_nominatePlayer: seat=$seatNumber');
    final usecase = _ref.read(nominatePlayerUsecaseProvider);
    final newState = await usecase(_vm.state, seatNumber);
    _vm.state = newState;
  }

  Future<void> _removeNomination(int seatNumber) async {
    AppLogger.d('_removeNomination: seat=$seatNumber');
    final usecase = _ref.read(removeNominationUsecaseProvider);
    final newState = await usecase(_vm.state, seatNumber);
    _vm.state = newState;
  }
}
