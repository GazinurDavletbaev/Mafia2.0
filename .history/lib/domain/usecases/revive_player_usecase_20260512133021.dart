import 'package:mafia_help/domain/repositories/game_repository.dart';
import 'package:mafia_help/presentation/state/game_state.dart';
import 'package:mafia_help/domain/helpers/game_end_helper.dart';
import '../../core/logger/app_logger.dart';

class RevivePlayerUsecase {
  final GameRepository _repository;
  final GameEndHelper _gameEndHelper = GameEndHelper();

  RevivePlayerUsecase({required GameRepository repository})
      : _repository = repository;

  Future<GameState> call(int seatNumber) async {
    AppLogger.d('RevivePlayerUsecase: START seat=$seatNumber');
    
    final state = await _repository.getCurrentGameState();
    
    final updatedPlayers = state.players.map((player) {
      if (player.seatNumber == seatNumber && !player.isAlive) {
        AppLogger.d('RevivePlayerUsecase: воскрешаем игрока ${player.seatNumber}');
        return player.copyWith(isAlive: true);
      }
      return player;
    }).toList();
    
    GameState newState = state.copyWith(players: updatedPlayers);
    
    final result = _gameEndHelper.checkWinner(newState);
    if (result != null) {
      newState = newState.copyWith(
        isGameEnded: true,
        winner: result == GameResult.redWin ? 'red' : 'black',
      );
      AppLogger.d('RevivePlayerUsecase: игра закончена');
    }
    
    await _repository.saveCurrentGameState(newState);
    return newState;
  }
}