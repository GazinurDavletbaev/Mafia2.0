import 'package:mafia_help/domain/repositories/game_repository.dart';
import 'package:mafia_help/presentation/state/game_state.dart';

class VotingUsecase {
  final GameRepository _repository;

  VotingUsecase({required GameRepository repository})
      : _repository = repository;

  Future<GameState> call({
    required int targetSeat,
    required int votesCount,
  }) async {
    final state = await _repository.getCurrentGameState();
    
    final updatedVotes = Map<int, int>.from(state.votes);
    updatedVotes[targetSeat] = votesCount;
    
    final newState = state.copyWith(votes: updatedVotes);
    await _repository.saveCurrentGameState(newState);
    
    return newState;
  }
}