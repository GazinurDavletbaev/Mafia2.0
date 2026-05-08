import 'package:mafia_help/domain/repositories/game_repository.dart';
import 'package:mafia_help/presentation/state/game_state.dart';
import 'package:mafia_help/data/local/models/kill.dart';

class KillPlayerUsecase {
  final GameRepository _repository;

  KillPlayerUsecase({required GameRepository repository})
      : _repository = repository;

  Future<GameState> call({
    required int seatNumber,
    required String phase,
    required String killType,
  }) async {
    final state = await _repository.getCurrentGameState();
    
    // Проверяем, жив ли игрок
    final targetPlayer = state.players.firstWhere(
      (p) => p.seatNumber == seatNumber,
      orElse: () => throw Exception('Player not found'),
    );
    
    if (!targetPlayer.isAlive) {
      return state; // уже мёртв, ничего не делаем
    }
    
    // Убиваем игрока
    final updatedPlayers = state.players.map((player) {
      if (player.seatNumber == seatNumber) {
        return player.copyWith(isAlive: false);
      }
      return player;
    }).toList();
    
    // Добавляем запись об убийстве
    final updatedKills = List<Kill>.from(state.pendingKills);
    updatedKills.add(Kill(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      gameId: state.game?.id ?? '',
      phaseId: state.currentDay,
      playerSeatNumber: seatNumber,
      type: killType,
    ));
    
    // Обновляем состояние
    GameState newState = state.copyWith(
      players: updatedPlayers,
      pendingKills: updatedKills,
    );
    
    // Если это убийство от мафии (mafiaShoot) — устанавливаем флаг
    if (phase == 'mafiaShoot') {
      newState = newState.copyWith(hasKillInLastNight: true);
    }
    
    await _repository.saveCurrentGameState(newState);
    return newState;
  }
}