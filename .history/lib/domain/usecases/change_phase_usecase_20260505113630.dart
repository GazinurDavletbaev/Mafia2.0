import 'package:mafia_help/application/providers/game_state_provider.dart';
import 'package:mafia_help/domain/helpers/phase_transition_helper.dart';
import 'package:mafia_help/domain/repositories/game_repository.dart';
import 'package:mafia_help/domain/usecases/deal_roles_usecase.dart';
import 'package:mafia_help/application/providers/usecase_providers.dart';
import 'package:riverpod/riverpod.dart';

class ChangePhaseUsecase {
  final GameRepository _repository;
  final GameStateNotifier _notifier;
  final Ref _ref;

  ChangePhaseUsecase({
    required GameRepository repository,
    required GameStateNotifier notifier,
    required Ref ref,
  }) : _repository = repository,
       _notifier = notifier,
       _ref = ref;

  Future<void> call({required bool goForward}) async {
    // 1. Получить текущее состояние
    final currentPhase = await _repository.getCurrentPhase();
    final currentSubPhase = await _repository.getCurrentSubPhase();
    final currentSubPhaseIndex = await _repository.getCurrentSubPhaseIndex();
    final currentDay = await _repository.getCurrentDay();
    
    // 2. Вычислить новое состояние через Helper
    final newState = PhaseTransitionHelper.next(
      currentPhase: currentPhase,
      currentSubPhase: currentSubPhase,
      currentSubPhaseIndex: currentSubPhaseIndex,
      currentDay: currentDay,
      goForward: goForward,
    );
    
    // 3. Если перешли в фазу раздачи ролей — раздать роли
    if (newState.subPhase == SubPhase.roleDistribution) {
      final dealRoles = _ref.read(dealRolesUsecaseProvider);
      await dealRoles();
    }
    
    // 4. Сохранить в репозиторий
    await _repository.setCurrentPhase(newState.phase);
    await _repository.setCurrentSubPhase(newState.subPhase);
    await _repository.setCurrentSubPhaseIndex(newState.subPhaseIndex);
    await _repository.setCurrentDay(newState.day);
    
    // 5. Обновить UI состояние
    _notifier.setPhase(newState.phase);
    _notifier.setSubPhase(newState.subPhase);
    _notifier.setSubPhaseIndex(newState.subPhaseIndex);
    _notifier.setDay(newState.day);
  }
}