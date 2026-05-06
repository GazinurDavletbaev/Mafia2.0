import 'package:mafia_help/domain/repositories/game_repository.dart';
import 'package:mafia_help/domain/helpers/game_end_helper.dart';
import 'package:mafia_help/presentation/state/game_state.dart';

class EndGameUsecase {
  final GameRepository _repository;

  EndGameUsecase({required GameRepository repository})
      : _repository = repository;

  Future<GameState> call(GameResult result) async {
    final state = await _repository.getCurrentGameState();
    
    final winner = result == GameResult.redWin ? 'red' : 'black';
    
    final newState = state.copyWith(
      isGameEnded: true,
      winner: winner,
    );
    
    await _repository.saveCurrentGameState(newState);
    
    return newState;
  }
}