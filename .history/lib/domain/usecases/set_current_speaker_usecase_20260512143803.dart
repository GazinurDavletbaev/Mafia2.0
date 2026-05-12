import 'package:mafia_help/presentation/state/game_state.dart';
import '../../core/logger/app_logger.dart';

class SetCurrentSpeakerUsecase {
  SetCurrentSpeakerUsecase();

  Future<GameState> call(GameState currentState, int? seatNumber) async {
    AppLogger.d('SetCurrentSpeakerUsecase: seat=$seatNumber');
    return currentState.copyWith(currentSpeakerSeat: seatNumber);
  }
}