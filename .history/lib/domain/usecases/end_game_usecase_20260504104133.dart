import 'package:mafia_help/application/providers/game_state_provider.dart';
import 'package:mafia_help/domain/helpers/game_end_helper.dart';
import 'package:mafia_help/domain/repositories/game_repository.dart';

class EndGameUsecase {
  final GameRepository _repository;
  final GameStateNotifier _notifier;

  EndGameUsecase({
    required GameRepository repository,
    required GameStateNotifier notifier,
  }) : _repository = repository,
       _notifier = notifier;

  Future<void> call(GameResult result) async {
    // 1. Сохранить результат игры
    await _repository.setGameEnded(true);
    await _repository.setWinner(result);
    
    // 2. Обновить UI состояние (заблокировать действия)
    _notifier.setGameEnded(true);
    _notifier.setWinner(result);
  }
}