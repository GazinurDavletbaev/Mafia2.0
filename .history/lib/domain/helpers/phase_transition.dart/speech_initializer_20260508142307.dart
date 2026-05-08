import 'package:mafia_help/presentation/state/game_state.dart';
import '../../../core/logger/app_logger.dart';
import '../../../data/local/models/phase.dart';

class SpeechInitializer {
  static GameState initialize(GameState state) {
    AppLogger.d(
      'SpeechInitializer: day=${state.currentDay}, lastStarter=${state.dayStarterSeat}',
    );

    int startSeat;
    if (state.currentDay == 1) {
      startSeat = 1;
    } else {
      final previousStarter = state.dayStarterSeat ?? 1;
      startSeat = previousStarter + 1;
      if (startSeat > 10) startSeat = 1;
    }

    // Ищем первого живого
    int? firstAliveSeat;
    for (int i = 0; i < 10; i++) {
      final seat = ((startSeat - 1 + i) % 10) + 1;
      final player = state.players.firstWhere((p) => p.seatNumber == seat);
      if (player.isAlive) {
        firstAliveSeat = seat;
        break;
      }
    }

    return state.copyWith(
      currentPhase: Phase.day,
      currentSubPhase: SubPhase.speeches,
      currentSubPhaseIndex: 0,
      dayStarterSeat: firstAliveSeat,
      currentSpeakerSeat: firstAliveSeat,
    );
  }
}