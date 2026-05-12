import 'package:mafia_help/domain/repositories/game_repository.dart';
import 'package:mafia_help/presentation/state/game_state.dart';

class NominatePlayerUsecase {
  final GameRepository _repository;

  NominatePlayerUsecase({required GameRepository repository})
      : _repository = repository;

  Future<GameState> call(int seatNumber) async {
    final state = await _repository.getCurrentGameState();
    
    if (state.nominatedSeats.contains(seatNumber)) {
      return state;
    }
    
    final updatedNominations = List<int>.from(state.nominatedSeats)..add(seatNumber);
    
    // Явно сохраняем currentSpeakerSeat, чтобы он не сбросился
    final newState = state.copyWith(
      nominatedSeats: updatedNominations,
      currentSpeakerSeat: state.currentSpeakerSeat,
    );
    
    await _repository.saveCurrentGameState(newState);
    
    return newState;
  }
}