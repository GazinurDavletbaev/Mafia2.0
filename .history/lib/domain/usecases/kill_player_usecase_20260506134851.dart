import 'package:mafia_help/domain/repositories/game_repository.dart';
import 'package:mafia_help/presentation/state/game_state.dart';

class KillPlayerUsecase {
  final GameRepository _repository;

  KillPlayerUsecase({required GameRepository repository})
      : _repository = repository;

  Future<GameState> call({
    required int seatNumber,
    required String phase,
    required String killType,
  }) async {
    // 1. Загружаем текущее состояние
    final state = await _repository.getCurrentGameState();
    
    // 2. Находим игрока и убиваем (если жив)
    final updatedPlayers = state.players.map((player) {
      if (player.seatNumber == seatNumber && player.isAlive) {
        return player.copyWith(isAlive: false);
      }
      return player;
    }).toList();
    
    // 3. Добавляем запись об убийстве (если нужно в истории)
    final updatedKills = List<Map<String, dynamic>>.from(state.kills);
    updatedKills.add({
      'seatNumber': seatNumber,
      'phase': phase,
      'killType': killType,
      'day': state.currentDay,
    });
    
    // 4. Создаём новое состояние
    final newState = state.copyWith(
      players: updatedPlayers,
      kills: updatedKills,
    );
    
    // 5. Сохраняем в Hive
    await _repository.saveCurrentGameState(newState);
    
    // 6. Возвращаем новое состояние
    return newState;
  }
}