import 'package:mafia_help/presentation/state/game_state.dart';
import '../../core/logger/app_logger.dart';

class RemoveNominationUsecase {
  RemoveNominationUsecase();

  Future<GameState> call(GameState currentState, int seatNumber) async {
    AppLogger.d('RemoveNominationUsecase: seat=$seatNumber');
    
    final updatedNominations = currentState.nominatedSeats
        .where((seat) => seat != seatNumber)
        .toList();
    
    return currentState.copyWith(nominatedSeats: updatedNominations);
  }
}