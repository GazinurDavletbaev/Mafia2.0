import 'package:mafia_help/presentation/state/game_state.dart';
import '../../data/local/models/sub_phase.dart';
import '../../core/logger/app_logger.dart';

class TieBreakUsecase {
  TieBreakUsecase();

  /// Переход к следующему кандидату
  Future<GameState> nextCandidate(GameState currentState) async {
    AppLogger.d('TieBreakUsecase.nextCandidate called');
    
    final nextIndex = currentState.currentTieIndex + 1;
    
    if (nextIndex >= currentState.tiedSeats.length) {
      // Все кандидаты выступили → возвращаемся к переголосованию
      return currentState.copyWith(
        currentSubPhase: SubPhase.revote,
        tiedSeats: [],
        currentTieIndex: 0,
        currentSpeakerSeat: null,
        votes: {},
      );
    }
    
    // Следующий кандидат
    return currentState.copyWith(
      currentTieIndex: nextIndex,
      currentSpeakerSeat: currentState.tiedSeats[nextIndex],
    );
  }

  /// Завершить перестрелку досрочно
  Future<GameState> finishTieBreak(GameState currentState) async {
  AppLogger.d('TieBreakUsecase.finishTieBreak called');
  return currentState.copyWith(
    currentSubPhase: SubPhase.revote,
    tiedSeats: [],
    currentTieIndex: 0,
    currentSpeakerSeat: null,
    votes: {},
  );
  
}