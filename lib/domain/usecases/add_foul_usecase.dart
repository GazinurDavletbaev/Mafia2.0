import 'package:mafia_help/application/providers/game_state_provider.dart';
import 'package:mafia_help/domain/repositories/game_repository.dart';

class AddFoulUsecase {
  final GameRepository _repository;
  final GameStateNotifier _notifier;

  AddFoulUsecase({
    required GameRepository repository,
    required GameStateNotifier notifier,
  }) : _repository = repository,
       _notifier = notifier;

  Future<void> call(int seatNumber) async {
    // 1. Получить текущего игрока
    final player = await _repository.getPlayerBySeat(seatNumber);
    if (player == null) return;

    // 2. Бизнес-логика: циклическое изменение фолов
    int newFouls = player.fouls + 1;
    bool isDead = player.isAlive;
    
    if (newFouls > 4) {
      // 5-й фол → сброс в 0 и воскрешение
      newFouls = 0;
      if (!isDead) {
        // Если игрок был жив, воскрешать не нужно (он и так жив)
        // Но по логике "при 5 → 0 и воскресает" - если был мёртв, воскресает
        isDead = false;
      }
    } else if (newFouls == 4) {
      // 4 фола → игрок умирает
      isDead = false;
    } else {
      // 0-3 фола → игрок жив
      isDead = true;
    }

    // 3. Сохранить в репозиторий (Hive)
    await _repository.updatePlayerFouls(seatNumber, newFouls);
    if (newFouls == 4 && player.isAlive) {
      // Игрок умирает от 4 фолов
      await _repository.setPlayerAlive(seatNumber, false);
    } else if (newFouls == 0 && !player.isAlive) {
      // Игрок воскресает при сбросе с 4→0
      await _repository.setPlayerAlive(seatNumber, true);
    }

    // 4. Обновить UI состояние
    _notifier.updateFoulsInState(seatNumber, newFouls);
    if (newFouls == 4 && player.isAlive) {
      _notifier.updateAliveInState(seatNumber, false);
    } else if (newFouls == 0 && !player.isAlive) {
      _notifier.updateAliveInState(seatNumber, true);
    }
  }
}