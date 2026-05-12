import 'package:mafia_help/presentation/state/game_state.dart';
import 'package:mafia_help/domain/helpers/vote_calculator.dart';
import '../../data/local/models/phase.dart';
import '../../data/local/models/sub_phase.dart';
import '../../core/logger/app_logger.dart';

class RevoteUsecase {
  RevoteUsecase();

  Future<GameState> call(GameState currentState) async {
    AppLogger.d('RevoteUsecase called');
    
    // Проверяем равный счёт → перестрелка
    if (VoteCalculator.isTie(currentState)) {
      final tiedSeats = VoteCalculator.getTiedSeats(currentState);
      return currentState.copyWith(
        currentSubPhase: SubPhase.tieBreak,
        tiedSeats: tiedSeats,
        currentTieIndex: 0,
        currentSpeakerSeat: tiedSeats.isNotEmpty ? tiedSeats[0] : null,
        votes: {},
      );
    }
    
    // Есть победитель → заключительная минута
    if (VoteCalculator.hasWinner(currentState)) {
      final winnerSeat = VoteCalculator.getWinnerSeat(currentState);
      return currentState.copyWith(
        currentSubPhase: SubPhase.finalWord,
        currentSpeakerSeat: winnerSeat,
        votes: {},
      );
    }
    
    // Никого не выбрали → ночь
    return _goToNight(currentState);
  }

  GameState _goToNight(GameState state) {
    return state.copyWith(
      currentPhase: Phase.night,
      currentSubPhase: SubPhase.mafiaShoot,
      currentSubPhaseIndex: 0,
      currentDay: state.currentDay + 1,
      nominatedSeats: [],
      votes: {},
      eliminationVotes: 0,
    );
  }
}