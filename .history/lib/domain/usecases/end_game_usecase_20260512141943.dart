import 'package:mafia_help/domain/repositories/game_repository.dart';
import 'package:mafia_help/domain/helpers/game_end_helper.dart';
import 'package:mafia_help/presentation/state/game_state.dart';
import '../../core/logger/app_logger.dart';

class EndGameUsecase {
  final GameRepository _repository;

  EndGameUsecase({required GameRepository repository})
      : _repository = repository;

  Future<GameState> call(GameResult result) async {
    AppLogger.d('EndGameUsecase: result=$result');
    
    final state = await _repository.getCurrentGameState();
    
    final winner = result == GameResult.redWin ? 'red' : 'black';
    
    final newState = state.copyWith(
      isGameEnded: true,
      winner: winner,
    );
    
    await _repository.saveCompletedGame(newState);
    await _repository.clearCurrentGameState();
    
    return newState;
  }
}