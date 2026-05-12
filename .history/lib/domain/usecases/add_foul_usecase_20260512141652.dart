import 'package:mafia_help/presentation/state/game_state.dart';
import 'package:mafia_help/domain/helpers/game_end_helper.dart';
import '../../core/logger/app_logger.dart';

class AddFoulUsecase {
  final GameEndHelper _gameEndHelper = GameEndHelper();

  AddFoulUsecase();

  Future<GameState> call(GameState currentState, int seatNumber) async {
    AppLogger.d('AddFoulUsecase: seat=$seatNumber');
    
    final updatedPlayers = currentState.players.map((player) {
      if (player.seatNumber == seatNumber) {
        int newFouls = player.fouls + 1;
        bool newIsAlive = player.isAlive;
        
        if (newFouls > 4) {
          newFouls = 0;
          newIsAlive = true;
        } else if (newFouls == 4) {
          newIsAlive = false;
        }
        
        return player.copyWith(
          fouls: newFouls,
          isAlive: newIsAlive,
        );
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
      AppLogger.d('AddFoulUsecase: игра закончена');
    }
    
    return newState;
  }
}