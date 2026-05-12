import 'package:mafia_help/domain/repositories/game_repository.dart';
import 'package:mafia_help/presentation/state/game_state.dart';
import 'package:mafia_help/data/local/models/vote.dart';

import '../../presentation/state/game_state_copy.dart';

class AddVoteUsecase {
  final GameRepository _repository;

  AddVoteUsecase({required GameRepository repository})
      : _repository = repository;

  Future<GameState> call({
    required int targetSeatNumber,
    required int votesCount,
  }) async {
    final state = await _repository.getCurrentGameState();
    
    final updatedVotes = List<Vote>.from(state.pendingVotes);
    updatedVotes.add(Vote(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      gameId: state.game?.id ?? '',
      round: state.currentRound,
      targetSeatNumber: targetSeatNumber,
      votesCount: votesCount,
    ));
    
    final newState = state.copyWith(
      pendingVotes: updatedVotes,
    );
    
    await _repository.saveCurrentGameState(newState);
    return newState;
  }
}