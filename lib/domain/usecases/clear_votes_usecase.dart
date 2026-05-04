import 'package:mafia_help/application/providers/game_state_provider.dart';
import 'package:mafia_help/domain/repositories/game_repository.dart';

class ClearVotesUsecase {
  final GameRepository _repository;
  final GameStateNotifier _notifier;

  ClearVotesUsecase({
    required GameRepository repository,
    required GameStateNotifier notifier,
  }) : _repository = repository,
       _notifier = notifier;

  Future<void> call() async {
    // 1. Очистить в репозитории
    await _repository.clearVotes();
    
    // 2. Обновить UI состояние
    _notifier.updateVotesInState({});
  }
}