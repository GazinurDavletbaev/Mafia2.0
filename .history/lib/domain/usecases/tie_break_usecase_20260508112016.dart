import 'package:mafia_help/domain/repositories/game_repository.dart';
import 'package:mafia_help/presentation/state/game_state.dart';

import '../../data/local/models/sub_phase.dart';

class TieBreakUsecase {
  final GameRepository _repository;

  TieBreakUsecase({required GameRepository repository})
      : _repository = repository;

  /// Переход к следующему кандидату
  Future<GameState> nextCandidate() async {
    final state = await _repository.getCurrentGameState();
    
    final nextIndex = state.currentTieIndex + 1;
    
    if (nextIndex >= state.tiedSeats.length) {
      // Все кандидаты выступили → возвращаемся к переголосованию
      return state.copyWith(
        currentSubPhase: SubPhase.revote,
        tiedSeats: [],
        currentTieIndex: 0,
        currentSpeakerSeat: null,
        votes: {},
      );
    }
    
    // Следующий кандидат
    return state.copyWith(
      currentTieIndex: nextIndex,
      currentSpeakerSeat: state.tiedSeats[nextIndex],
    );
  }

  /// Завершить перестрелку досрочно
  Future<GameState> finishTieBreak() async {
    final state = await _repository.getCurrentGameState();
    
    return state.copyWith(
      currentSubPhase: SubPhase.revote,
      tiedSeats: [],
      currentTieIndex: 0,
      currentSpeakerSeat: null,
      votes: {},
    );
  }
}