import 'package:mafia_help/domain/repositories/game_repository.dart';
import 'package:mafia_help/presentation/state/game_state.dart';

class RemoveNominationUsecase {
  final GameRepository _repository;

  RemoveNominationUsecase({required GameRepository repository})
      : _repository = repository;

  Future<GameState> call(int seatNumber) async {
    final state = await _repository.getCurrentGameState();
    
    final updatedNominations = state.nominatedSeats
        .where((seat) => seat != seatNumber)
        .toList();
    
    final newState = state.copyWith(nominatedSeats: updatedNominations);
    await _repository.saveCurrentGameState(newState);
    
    return newState;
  }
}