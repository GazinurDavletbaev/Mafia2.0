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
    
    final updatedPlayers = state.players.map((player) {
      if (player.seatNumber == seatNumber && player.isAlive) {
        return player.copyWith(isAlive: false);
      }
      return player;
    }).toList();
    
    final updatedKills = List<Kill>.from(state.pendingKills);
    updatedKills.add(Kill(
      id: DateTime.now().millisecondsSinceEpoch, // или generateId()
      seatNumber: seatNumber,
      phase: phase,
      killType: killType,
      day: state.currentDay,
    ));
    
    final newState = state.copyWith(
      players: updatedPlayers,
      pendingKills: updatedKills,
    );
    
    await _repository.saveCurrentGameState(newState);
    return newState;
  }
}