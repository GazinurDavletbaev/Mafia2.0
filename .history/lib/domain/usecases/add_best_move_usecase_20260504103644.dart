import 'package:mafia_help/application/providers/game_state_provider.dart';
import 'package:mafia_help/domain/repositories/game_repository.dart';

class AddBestMoveDigitUsecase {
  final GameRepository _repository;
  final GameStateNotifier _notifier;

  AddBestMoveDigitUsecase({
    required GameRepository repository,
    required GameStateNotifier notifier,
  }) : _repository = repository,
       _notifier = notifier;

  Future<void> call(int digit) async {
    // 1. Получить текущий временный список
    final currentDigits = await _repository.getPartialBestMove();
    
    // 2. Проверка: не больше 3 цифр
    if (currentDigits.length >= 3) return;
    
    // 3. Добавить цифру
    final newDigits = [...currentDigits, digit];
    
    // 4. Сохранить в репозиторий
    await _repository.setPartialBestMove(newDigits);
    
    // 5. Обновить UI состояние
    _notifier.updatePartialBestMoveInState(newDigits);
  }
}