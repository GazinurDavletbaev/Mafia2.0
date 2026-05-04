import 'package:mafia_help/application/providers/game_state_provider.dart';
import 'package:mafia_help/domain/repositories/game_repository.dart';

class PopBestMoveDigitUsecase {
  final GameRepository _repository;
  final GameStateNotifier _notifier;

  PopBestMoveDigitUsecase({
    required GameRepository repository,
    required GameStateNotifier notifier,
  }) : _repository = repository,
       _notifier = notifier;

  Future<void> call() async {
    // 1. Получить текущий временный список
    final currentDigits = await _repository.getPartialBestMove();
    
    // 2. Если список пуст — ничего не делаем
    if (currentDigits.isEmpty) return;
    
    // 3. Удалить последний элемент
    final newDigits = List<int>.from(currentDigits);
    newDigits.removeLast();
    
    // 4. Сохранить в репозиторий
    await _repository.setPartialBestMove(newDigits);
    
    // 5. Обновить UI состояние
    _notifier.updatePartialBestMoveInState(newDigits);
  }
}