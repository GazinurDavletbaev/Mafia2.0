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
    
    // 2. Получить количество живых игроков
    final alivePlayers = await _repository.getAlivePlayers();
    final maxNominations = alivePlayers.length;
    
    // 3. Бизнес-логика: без дубликатов, максимум = количество живых
    if (currentNominations.contains(seatNumber)) return;
    if (currentNominations.length >= maxNominations) return;
    
    // 4. Сохранить в репозиторий
    final newNominations = [...currentNominations, seatNumber];
    await _repository.setNominations(newNominations);
    
    // 5. Обновить UI состояние
    _notifier.updateNominationsInState(newNominations);
  }
}