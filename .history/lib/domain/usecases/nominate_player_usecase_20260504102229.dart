import 'package:mafia_help/application/providers/game_state_provider.dart';
import 'package:mafia_help/domain/repositories/game_repository.dart';

class NominatePlayerUsecase {
  final GameRepository _repository;
  final GameStateNotifier _notifier;

  NominatePlayerUsecase({
    required GameRepository repository,
    required GameStateNotifier notifier,
  }) : _repository = repository,
       _notifier = notifier;

  Future<void> call(int seatNumber) async {
    // 1. Получить текущий список кандидатов
    final currentNominations = await _repository.getCurrentNominations();
    
    // 2. Бизнес-логика: максимум 3, без дубликатов
    if (currentNominations.contains(seatNumber)) return;
    if (currentNominations.length >= 3) return;
    
    // 3. Сохранить в репозиторий
    final newNominations = [...currentNominations, seatNumber];
    await _repository.setNominations(newNominations);
    
    // 4. Обновить UI состояние
    _notifier.updateNominationsInState(newNominations);
  }
}