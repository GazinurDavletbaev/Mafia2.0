import 'package:mafia_help/domain/repositories/game_repository.dart';
import 'package:mafia_help/presentation/state/game_state.dart';
import 'package:mafia_help/domain/helpers/phase_transition.dart/phase_transition_helper.dart';
import 'package:mafia_help/domain/helpers/game_end_helper.dart';
import '../../core/logger/app_logger.dart';

class ChangePhaseUsecase {
  final GameRepository _repository;
  final PhaseTransitionHelper _helper;
  final GameEndHelper _gameEndHelper = GameEndHelper();

  ChangePhaseUsecase({
    required GameRepository repository,
  }) : _repository = repository,
       _helper = PhaseTransitionHelper();

  Future<GameState> call(GameState currentState, {required bool goForward}) async {
    AppLogger.d('ChangePhaseUsecase: goForward=$goForward');
    
    GameState newState = goForward
        ? _helper.nextPhase(currentState)
        : _helper.previousPhase(currentState);
    
    final result = _gameEndHelper.checkWinner(newState);
    if (result != null) {
      newState = newState.copyWith(
        isGameEnded: true,
        winner: result == GameResult.redWin ? 'red' : 'black',
      );
    }
    
    await _repository.saveCurrentGameState(newState);
    return newState;
  }
}