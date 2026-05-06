import 'package:mafia_help/domain/repositories/game_repository.dart';
import 'package:mafia_help/presentation/state/game_state.dart';

class RevivePlayerUsecase {
  final GameRepository _repository;

  RevivePlayerUsecase({required GameRepository repository})
      : _repository = repository;

  Future<GameState> call(int seatNumber) async {
    final state = await _repository.getCurrentGameState();
    
    final updatedPlayers = state.players.map((player) {
      if (player.seatNumber == seatNumber && !player.isAlive) {
        return player.copyWith(isAlive: true);
      }
      return player;
    }).toList();
    
    final newState = state.copyWith(players: updatedPlayers);
    await _repository.saveCurrentGameState(newState);
    
    return newState;
  }
}