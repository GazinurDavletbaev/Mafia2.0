import 'package:mafia_help/presentation/state/game_state.dart';
import '../../core/logger/app_logger.dart';

class DealRolesUsecase {
  DealRolesUsecase();

  Future<GameState> call(GameState currentState) async {
    AppLogger.d('DealRolesUsecase called');
    
    const roles = ['don', 'mafia', 'mafia', 'sheriff', 'citizen', 'citizen', 'citizen', 'citizen', 'citizen', 'citizen'];
    final shuffled = List.of(roles)..shuffle();
    
    final updatedPlayers = currentState.players.asMap().entries.map((entry) {
      final index = entry.key;
      final player = entry.value;
      return player.copyWith(role: shuffled[index]);
    }).toList();
    
    return currentState.copyWith(players: updatedPlayers);
  }
}