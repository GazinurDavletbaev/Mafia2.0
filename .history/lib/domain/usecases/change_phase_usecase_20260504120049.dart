import 'package:mafia_help/application/providers/game_state_provider.dart';
import 'package:mafia_help/data/local/models/phase.dart';

import 'package:mafia_help/domain/helpers/phase_transition_helper.dart';
import 'package:mafia_help/domain/repositories/game_repository.dart';

class ChangePhaseUsecase {
  final GameRepository _repository;
  final GameStateNotifier _notifier;

  ChangePhaseUsecase({
    required GameRepository repository,
    required GameStateNotifier notifier,
  }) : _repository = repository,
       _notifier = notifier;

  Future<void> call({required bool goForward}) async {
    // 1. Получить текущее состояние
    final currentPhase = await _repository.getCurrentPhase();
    final currentSubPhaseIndex = await _repository.getCurrentSubPhaseIndex();
    final currentDay = await _repository.getCurrentDay();
    
    // 2. Вычислить новое состояние через Helper
    final newState = PhaseTransitionHelper.next(
      currentPhase: currentPhase,
      currentSubPhaseIndex: currentSubPhaseIndex,
      currentDay: currentDay,
      goForward: goForward,
    );
    
    // 3. Сохранить в репозиторий
    await _repository.setCurrentPhase(newState.phase);
    await _repository.setCurrentSubPhaseIndex(newState.subPhaseIndex);
    await _repository.setCurrentDay(newState.day);
    
    // 4. Обновить UI состояние
    _notifier.setSubPhaseIndex(newState.subPhaseIndex);
    _notifier.setDay(newState.day);
    // Можно также обновить фазу в GameState, если нужно
  }
}