import 'package:mafia_help/presentation/state/game_state.dart';
import 'package:mafia_help/domain/helpers/game_end_helper.dart';
import '../../core/logger/app_logger.dart';

class RevivePlayerUsecase {
  final GameEndHelper _gameEndHelper = GameEndHelper();

  RevivePlayerUsecase();

  Future<GameState> call(GameState currentState, int seatNumber) async {
    AppLogger.d('RevivePlayerUsecase: seat=$seatNumber');
    
    final updatedPlayers = currentState.players.map((player) {
      if (player.seatNumber == seatNumber && !player.isAlive) {
        return player.copyWith(isAlive: true);
      }
      return player;
    }).toList();
    
    GameState newState = currentState.copyWith(players: updatedPlayers);
    
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