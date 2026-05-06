import 'package:mafia_help/domain/repositories/game_repository.dart';
import 'package:mafia_help/presentation/state/game_state.dart';
import 'package:mafia_help/domain/helpers/phase_transition_helper.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ChangePhaseUsecase {
  final GameRepository _repository;
  final Ref _ref;

  ChangePhaseUsecase({
    required GameRepository repository,
    required Ref ref,
  }) : _repository = repository,
       _ref = ref;

  Future<GameState> call({required bool goForward}) async {
    final state = await _repository.getCurrentGameState();
    
    final PhaseTransitionHelper helper = PhaseTransitionHelper(_ref);
    
    final newState = goForward
        ? helper.nextPhase(state)
        : helper.previousPhase(state);
    
    await _repository.saveCurrentGameState(newState);
    
    return newState;
  }
}