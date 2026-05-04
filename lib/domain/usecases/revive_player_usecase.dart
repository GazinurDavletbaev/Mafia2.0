import 'package:mafia_help/application/providers/game_state_provider.dart';
import 'package:mafia_help/domain/repositories/game_repository.dart';

class RevivePlayerUsecase {
  final GameRepository _repository;
  final GameStateNotifier _notifier;

  RevivePlayerUsecase({
    required GameRepository repository,
    required GameStateNotifier notifier,
  }) : _repository = repository,
       _notifier = notifier;

  Future<void> call(int seatNumber) async {
    // 1. Получить текущего игрока
    final player = await _repository.getPlayerBySeat(seatNumber);
    if (player == null) return;

    // 2. Если игрок уже жив - ничего не делаем
    if (player.isAlive) return;

    // 3. Сохранить в репозиторий (воскресить и сбросить фолы)
    await _repository.setPlayerAlive(seatNumber, true);
    await _repository.updatePlayerFouls(seatNumber, 0);

    // 4. Обновить UI состояние
    _notifier.updateAliveInState(seatNumber, true);
    _notifier.updateFoulsInState(seatNumber, 0);
  }
}