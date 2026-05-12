import 'package:mafia_help/domain/repositories/game_repository.dart';
import 'package:mafia_help/presentation/state/game_state.dart';
import 'package:mafia_help/domain/helpers/game_end_helper.dart';
import '../../core/logger/app_logger.dart';

class AddFoulUsecase {
  final GameRepository _repository;

  AddFoulUsecase({required GameRepository repository})
      : _repository = repository;

  Future<GameState> call(int seatNumber) async {
    AppLogger.d('AddFoulUsecase: START seat=$seatNumber');
    
    final state = await _repository.getCurrentGameState();
    
    final updatedPlayers = state.players.map((player) {
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
    
    GameState newState = state.copyWith(players: updatedPlayers);
    
    final result = GameEndHelper.checkWinner(newState);
    if (result != null) {
      newState = newState.copyWith(
        isGameEnded: true,
        winner: result == GameResult.redWin ? 'red' : 'black',
      );
      AppLogger.d('AddFoulUsecase: игра закончена');
    }
    
    await _repository.saveCurrentGameState(newState);
    return newState;
  }
}