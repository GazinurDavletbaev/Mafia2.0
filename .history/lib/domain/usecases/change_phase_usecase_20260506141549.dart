import 'package:mafia_help/domain/repositories/game_repository.dart';
import 'package:mafia_help/presentation/state/game_state.dart';
import 'package:mafia_help/domain/helpers/phase_transition_helper.dart';

class ChangePhaseUsecase {
  final GameRepository _repository;
  final PhaseTransitionHelper _helper;

  ChangePhaseUsecase({
    required GameRepository repository,
  }) : _repository = repository,
       _helper = PhaseTransitionHelper();

  Future<GameState> call({required bool goForward}) async {
    final state = await _repository.getCurrentGameState();
    
    final newState = goForward
        ? _helper.nextPhase(state)
        : _helper.previousPhase(state);
    
    await _repository.saveCurrentGameState(newState);
    
    return newState;
  }
}