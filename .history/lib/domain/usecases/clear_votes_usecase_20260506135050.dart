import 'package:mafia_help/domain/repositories/game_repository.dart';
import 'package:mafia_help/presentation/state/game_state.dart';

class ClearVotesUsecase {
  final GameRepository _repository;

  ClearVotesUsecase({required GameRepository repository})
      : _repository = repository;

  Future<GameState> call() async {
    final state = await _repository.getCurrentGameState();
    
    final newState = state.copyWith(votes: {});
    await _repository.saveCurrentGameState(newState);
    
    return newState;
  }
}