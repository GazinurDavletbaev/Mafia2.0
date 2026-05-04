import 'package:mafia_help/application/providers/game_state_provider.dart';
import 'package:mafia_help/domain/repositories/game_repository.dart';

class RemoveNominationUsecase {
  final GameRepository _repository;
  final GameStateNotifier _notifier;

  RemoveNominationUsecase({
    required GameRepository repository,
    required GameStateNotifier notifier,
  }) : _repository = repository,
       _notifier = notifier;

  Future<void> call(int seatNumber) async {
    // 1. Получить текущий список кандидатов
    final currentNominations = await _repository.getCurrentNominations();
    
    // 2. Если кандидата нет в списке — ничего не делаем
    if (!currentNominations.contains(seatNumber)) return;
    
    // 3. Удалить из списка
    final newNominations = currentNominations.where((s) => s != seatNumber).toList();
    
    // 4. Сохранить в репозиторий
    await _repository.setNominations(newNominations);
    
    // 5. Обновить UI состояние
    _notifier.updateNominationsInState(newNominations);
  }
}