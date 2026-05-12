import 'package:mafia_help/presentation/state/game_state.dart';
import '../../core/logger/app_logger.dart';

class NominatePlayerUsecase {
  NominatePlayerUsecase();

  Future<GameState> call(GameState currentState, int seatNumber) async {
    AppLogger.d('NominatePlayerUsecase: seat=$seatNumber');
    
    if (currentState.nominatedSeats.contains(seatNumber)) {
      return currentState;
    }
    
    final updatedNominations = List<int>.from(currentState.nominatedSeats)..add(seatNumber);
    
    final newState = currentState.copyWith(
      nominatedSeats: updatedNominations,
    );
    
    return newState;
  }
}