import 'package:mafia_help/domain/repositories/game_repository.dart';
import 'package:mafia_help/presentation/state/game_state.dart';
import '../../core/logger/app_logger.dart';

class NominatePlayerUsecase {
  final GameRepository _repository;

  NominatePlayerUsecase({required GameRepository repository})
      : _repository = repository;

  Future<GameState> call(int seatNumber) async {
    final state = await _repository.getCurrentGameState();
    
    AppLogger.d('NominatePlayerUsecase: BEFORE - currentSpeaker=${state.currentSpeakerSeat}');
    
    if (state.nominatedSeats.contains(seatNumber)) {
      return state;
    }
    
    final updatedNominations = List<int>.from(state.nominatedSeats)..add(seatNumber);
    
    final newState = state.copyWith(
      nominatedSeats: updatedNominations,
      currentSpeakerSeat: state.currentSpeakerSeat,
    );
    
    AppLogger.d('NominatePlayerUsecase: AFTER - currentSpeaker=${newState.currentSpeakerSeat}');
    
    await _repository.saveCurrentGameState(newState);
    
    return newState;
  }
}