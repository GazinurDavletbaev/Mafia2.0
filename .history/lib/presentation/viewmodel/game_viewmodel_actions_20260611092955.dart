import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mafia_help/application/providers/providers.dart';
import '../../core/logger/app_logger.dart';
import '../../data/local/models/phase.dart';
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

    // Проверяем, умер ли игрок после добавления фола
    final oldPlayer =
        _vm.state.players.firstWhere((p) => p.seatNumber == seatNumber);
    final newPlayer = newPlayers.firstWhere((p) => p.seatNumber == seatNumber);
    final hasDied = oldPlayer.isAlive && !newPlayer.isAlive;

    GameState newState = _vm.state.copyWith(
      players: newPlayers,
      isBestMove: hasDied ? true : _vm.state.isBestMove,
    );

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

    // Выводим текущее состояние игроков
    print('=== BEFORE KILL ===');
    for (var p in _vm.state.players) {
      print(
        'seat ${p.seatNumber}: role=${p.role}, team=${p.team}, isAlive=${p.isAlive}',
      );
    }

    final usecase = _ref.read(killPlayerUsecaseProvider);
    final (newPlayers, winner) = usecase.execute(_vm.state.players, seatNumber);

    // Выводим результат
    print('=== AFTER KILL ===');
    for (var p in newPlayers) {
      print(
        'seat ${p.seatNumber}: role=${p.role}, team=${p.team}, isAlive=${p.isAlive}',
      );
    }
    print('winner = $winner');

    GameState newState = _vm.state.copyWith(
      players: newPlayers,
      isBestMove:
          true, // ← судья удалил игрока (свайп вправо или долгое нажатие)
    );

    if (winner != null) {
      print(
        'GAME ENDED! Setting isGameEnded=true, winner=${winner ? "red" : "black"}',
      );
      newState = newState.copyWith(
        isGameEnded: true,
        winner: winner ? 'red' : 'black',
      );
    }

    _vm.state = newState;
  }

  Future<void> _revivePlayer(int seatNumber) async {
    AppLogger.d('_revivePlayer: seat=$seatNumber');
    final usecase = _ref.read(revivePlayerUsecaseProvider);
    final newPlayers = usecase.execute(_vm.state.players, seatNumber);

    _vm.state = _vm.state.copyWith(players: newPlayers);
  }

  Future<void> _nominatePlayer(int seatNumber) async {
    AppLogger.d('_nominatePlayer: seat=$seatNumber');
    final usecase = _ref.read(nominatePlayerUsecaseProvider);
    final (newPlayers, newNominatedSeats) = usecase.execute(
      _vm.state.players,
      _vm.state.nominatedSeats,
      seatNumber,
    );

    _vm.state = _vm.state.copyWith(
      players: newPlayers,
      nominatedSeats: newNominatedSeats,
    );
  }

  Future<void> _removeNomination(int seatNumber) async {
    AppLogger.d('_removeNomination: seat=$seatNumber');
    final usecase = _ref.read(removeNominationUsecaseProvider);
    final newNominatedSeats = usecase.execute(
      _vm.state.nominatedSeats,
      seatNumber,
    );

    _vm.state = _vm.state.copyWith(nominatedSeats: newNominatedSeats);
  }

  Future<void> onNominatePlayer(int seatNumber) async {
    if (_vm.state.currentPhase == Phase.night) return;
    await _nominatePlayer(seatNumber);
  }

  Future<void> onRemoveNomination(int seatNumber) async {
    await _removeNomination(seatNumber);
  }

  Future<void> onKillPlayer(int seatNumber) async {
    await _killPlayer(seatNumber);
  }

  Future<void> onRevivePlayer(int seatNumber) async {
    await _revivePlayer(seatNumber);
  }
}
