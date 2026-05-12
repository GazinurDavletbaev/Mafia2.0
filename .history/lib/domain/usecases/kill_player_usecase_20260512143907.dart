import 'package:mafia_help/presentation/state/game_state.dart';
import 'package:mafia_help/data/local/models/kill.dart';
import 'package:mafia_help/domain/helpers/game_end_helper.dart';
import '../../core/logger/app_logger.dart';

class KillPlayerUsecase {
  final GameEndHelper _gameEndHelper = GameEndHelper();

  KillPlayerUsecase();

  Future<GameState> call(
    GameState currentState, {
    required int seatNumber,
    required String phase,
    required String killType,
  }) async {
    AppLogger.d('KillPlayerUsecase: seat=$seatNumber, phase=$phase');
    
    final targetPlayer = currentState.players.firstWhere(
      (p) => p.seatNumber == seatNumber,
      orElse: () => throw Exception('Player not found'),
    );
    
    if (!targetPlayer.isAlive) {
      return currentState;
    }
    
    final updatedPlayers = currentState.players.map((player) {
      if (player.seatNumber == seatNumber) {
        return player.copyWith(isAlive: false);
      }
      return player;
    }).toList();
    
    final updatedKills = List<Kill>.from(currentState.pendingKills);
    updatedKills.add(Kill(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      gameId: currentState.game?.id ?? '',
      phaseId: currentState.currentDay,
      playerSeatNumber: seatNumber,
      type: killType,
    ));
    
    GameState newState = currentState.copyWith(
      players: updatedPlayers,
      pendingKills: updatedKills,
    );
    
    if (phase == 'mafiaShoot') {
      newState = newState.copyWith(hasKillInLastNight: true);
    }
    
    final result = _gameEndHelper.checkWinner(newState);
    if (result != null) {
      newState = newState.copyWith(
        isGameEnded: true,
        winner: result == GameResult.redWin ? 'red' : 'black',
      );
    }
    
    return newState;
  }
}