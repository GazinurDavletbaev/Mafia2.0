import 'package:mafia_help/domain/repositories/game_repository.dart';
import 'package:mafia_help/presentation/state/game_state.dart';

class DealRolesUsecase {
  final GameRepository _repository;

  DealRolesUsecase({required GameRepository repository})
      : _repository = repository;

  Future<GameState> call() async {
    final state = await _repository.getCurrentGameState();
    
    // Роли для 10 игроков: 1 don, 2 mafia, 1 sheriff, 6 citizen
    final List<String> roles = [
      'don', 'mafia', 'mafia', 'sheriff',
      'citizen', 'citizen', 'citizen', 'citizen', 'citizen', 'citizen'
    ]..shuffle();
    
    final updatedPlayers = state.players.asMap().entries.map((entry) {
      final index = entry.key;
      final player = entry.value;
      return player.copyWith(role: roles[index]);
    }).toList();
    
    final newState = state.copyWith(players: updatedPlayers);
    await _repository.saveCurrentGameState(newState);
    
    return newState;
  }
}