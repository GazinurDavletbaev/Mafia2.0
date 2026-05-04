import 'package:mafia_help/application/providers/game_state_provider.dart';
import 'package:mafia_help/domain/repositories/game_repository.dart';

class CommitBestMoveUsecase {
  final GameRepository _repository;
  final GameStateNotifier _notifier;

  CommitBestMoveUsecase({
    required GameRepository repository,
    required GameStateNotifier notifier,
  }) : _repository = repository,
       _notifier = notifier;

  Future<void> call() async {
    // 1. Получить временный список
    final digits = await _repository.getPartialBestMove();
    
    // 2. Проверка: должно быть ровно 3 цифры
    if (digits.length != 3) return;
    
    // 3. Сохранить в BestMove
    await _repository.saveBestMove(digits);
    
    // 4. Очистить временный список
    await _repository.clearPartialBestMove();
    
    // 5. Обновить UI состояние
    _notifier.updatePartialBestMoveInState([]);
  }
}