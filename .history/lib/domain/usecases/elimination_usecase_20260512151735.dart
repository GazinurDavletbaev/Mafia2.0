import 'package:mafia_help/domain/repositories/game_repository.dart';
import 'package:mafia_help/presentation/state/game_state.dart';

import '../../data/local/models/phase.dart';
import '../../data/local/models/sub_phase.dart';

class EliminationVoteUsecase {
  final GameRepository _repository;

  EliminationVoteUsecase({required GameRepository repository})
      : _repository = repository;

  /// Записать голоса за подъём
  Future<GameState> addVotes(int votesFor, int votes) async {
    final state = await _repository.getCurrentGameState();
    
    final newState = state.copyWith(
      eliminationVotes: votesFor,
    );
    
    await _repository.saveCurrentGameState(newState);
    return newState;
  }
  
  /// Проверить результат голосования
  Future<GameState> checkResult() async {
    final state = await _repository.getCurrentGameState();
    
    final aliveCount = state.players.where((p) => p.isAlive).length;
    final passed = state.eliminationVotes > (aliveCount / 2);
    
    if (passed) {
      // Выбывший говорит заключительную минуту
      return state.copyWith(
        currentSubPhase: SubPhase.finalWord,
      );
    } else {
      // Переход в ночь
      return state.copyWith(
        currentPhase: Phase.night,
        currentSubPhase: SubPhase.mafiaShoot,
        currentSubPhaseIndex: 0,
        currentDay: state.currentDay + 1,
        nominatedSeats: [],
        votes: {},
        eliminationVotes: 0,
        tiedSeats: [],
        currentTieIndex: 0,
      );
    }
  }
}