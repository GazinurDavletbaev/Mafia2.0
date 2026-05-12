import 'package:mafia_help/presentation/state/game_state.dart';
import 'package:mafia_help/domain/helpers/game_end_helper.dart';
import '../../data/local/models/phase.dart';
import '../../data/local/models/sub_phase.dart';
import '../../core/logger/app_logger.dart';

class EliminationVoteUsecase {
  EliminationVoteUsecase();

  /// Записать голоса за подъём
  Future<GameState> addVotes(GameState currentState, int votesFor) async {
    AppLogger.d('EliminationVoteUsecase.addVotes: votes=$votesFor');
    
    return currentState.copyWith(
      eliminationVotes: votesFor,
    );
  }
  
  /// Проверить результат голосования
  Future<GameState> checkResult(GameState currentState) async {
    AppLogger.d('EliminationVoteUsecase.checkResult called');
    
    final aliveCount = currentState.players.where((p) => p.isAlive).length;
    final passed = currentState.eliminationVotes > (aliveCount / 2);
    
    if (passed) {
      // Выбывший говорит заключительную минуту
      return currentState.copyWith(
        currentSubPhase: SubPhase.finalWord,
      );
    } else {
      // Переход в ночь
      return currentState.copyWith(
        currentPhase: Phase.night,
        currentSubPhase: SubPhase.mafiaShoot,
        currentSubPhaseIndex: 0,
        currentDay: currentState.currentDay + 1,
        nominatedSeats: [],
        votes: {},
        eliminationVotes: 0,
        tiedSeats: [],
        currentTieIndex: 0,
      );
    }
  }
}