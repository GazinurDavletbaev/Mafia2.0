import 'package:mafia_help/presentation/state/game_state.dart';
import '../../core/logger/app_logger.dart';

class SetCurrentSpeakerUsecase {
  SetCurrentSpeakerUsecase();

  Future<GameState> call(GameState currentState, int? seatNumber) async {
    AppLogger.d('SetCurrentSpeakerUsecase: seat=$seatNumber');
    final newState = currentState.copyWith(currentSpeakerSeat: seatNumber);
    return newState;
  }
}