import 'package:mafia_help/domain/repositories/game_repository.dart';
import 'package:mafia_help/presentation/state/game_state.dart';

class AddVoteUsecase {
  final GameRepository _repository;

  AddVoteUsecase({required GameRepository repository})
      : _repository = repository;

  Future<GameState> call(int seatNumber, int votes) async {
    final state = await _repository.getCurrentGameState();
    
    final updatedVotes = Map<int, int>.from(state.votes);
    updatedVotes[seatNumber] = votes;
    
    final newState = state.copyWith(votes: updatedVotes);
    await _repository.saveCurrentGameState(newState);
    
    return newState;
  }
}