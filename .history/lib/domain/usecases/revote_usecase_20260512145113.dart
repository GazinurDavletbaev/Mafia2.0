import 'package:mafia_help/domain/repositories/game_repository.dart';
import 'package:mafia_help/presentation/state/game_state.dart';
import 'package:mafia_help/domain/helpers/vote_calculator.dart';

import '../../data/local/models/phase.dart';
import '../../data/local/models/sub_phase.dart';

class RevoteUsecase {


  RevoteUsecase();

  Future<GameState> call() async {
    final state = await _repository.getCurrentGameState();
    
    // Проверяем равный счёт → перестрелка
    if (VoteCalculator.isTie(state)) {
      final tiedSeats = VoteCalculator.getTiedSeats(state);
      return state.copyWith(
        currentSubPhase: SubPhase.tieBreak,
        tiedSeats: tiedSeats,
        currentTieIndex: 0,
        currentSpeakerSeat: tiedSeats.isNotEmpty ? tiedSeats[0] : null,
        votes: {},
      );
    }
    
    // Есть победитель → заключительная минута
    if (VoteCalculator.hasWinner(state)) {
      final winnerSeat = VoteCalculator.getWinnerSeat(state);
      return state.copyWith(
        currentSubPhase: SubPhase.finalWord,
        currentSpeakerSeat: winnerSeat,
        votes: {},
      );
    }
    
    // Никого не выбрали → ночь
    return _goToNight(state);
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