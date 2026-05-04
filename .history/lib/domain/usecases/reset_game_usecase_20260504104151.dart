import 'package:mafia_help/application/providers/game_state_provider.dart';
import 'package:mafia_help/domain/repositories/game_repository.dart';

class ResetGameUsecase {
  final GameRepository _repository;
  final GameStateNotifier _notifier;

  ResetGameUsecase({
    required GameRepository repository,
    required GameStateNotifier notifier,
  }) : _repository = repository,
       _notifier = notifier;

  Future<void> call() async {
    // 1. Очистить все данные игры в репозитории
    await _repository.clearAllGameData();
    
    // 2. Сбросить UI состояние
    _notifier.resetState();
  }
}