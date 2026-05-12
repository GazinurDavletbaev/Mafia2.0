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

  Future<GameState> call({required bool goForward}) async {
    final state = await _repository.getCurrentGameState();
    
    GameState newState = goForward
        ? _helper.nextPhase(state)
        : _helper.previousPhase(state);
    
    // Проверка конца игры после смены фазы
    final result = _gameEndHelper.checkWinner(newState);
    if (result != null) {
      newState = newState.copyWith(
        isGameEnded: true,
        winner: result == GameResult.redWin ? 'red' : 'black',
      );
      AppLogger.d('ChangePhaseUsecase: игра закончена после смены фазы');
    }
    
    await _repository.saveCurrentGameState(newState);
    
    return newState;
  }
}