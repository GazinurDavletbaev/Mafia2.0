import 'package:mafia_help/application/providers/game_state_provider.dart';
import 'package:mafia_help/domain/repositories/game_repository.dart';

class KillPlayerUsecase {
  final GameRepository _repository;
  final GameStateNotifier _notifier;

  KillPlayerUsecase({
    required GameRepository repository,
    required GameStateNotifier notifier,
  }) : _repository = repository,
       _notifier = notifier;

  Future<void> call({
    required int seatNumber,
    required String phase,
    required String killType,
  }) async {
    // 1. Получить текущего игрока
    final player = await _repository.getPlayerBySeat(seatNumber);
    if (player == null) return;

    // 2. Если игрок уже мёртв - ничего не делаем
    if (!player.isAlive) return;

    // 3. Сохранить в репозиторий
    await _repository.setPlayerAlive(seatNumber, false);
    await _repository.addKill(
      seatNumber: seatNumber,
      phase: phase,
      killType: killType,
    );

    // 4. Обновить UI состояние
    _notifier.updateAliveInState(seatNumber, false);
  }
}