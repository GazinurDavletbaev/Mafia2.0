// lib/domain/usecases/deal_roles_usecase.dart

import '../../data/local/models/player_model.dart';

class DealRolesUsecase {
  DealRolesUsecase();
  
  List<PlayerModel> execute({
    required List<PlayerModel> players,
    required List<String> roles, // ['mafia', 'mafia', 'don', 'sheriff', 'citizen', ...]
  }) {
    final shuffledRoles = List<String>.from(roles)..shuffle();
    
    final newPlayers = <PlayerModel>[];
    
    for (int i = 0; i < players.length; i++) {
      final role = shuffledRoles[i];
      final team = (role == 'mafia' || role == 'don') ? 'black' : 'red';
      
      newPlayers.add(players[i].copyWith(
        role: role,
        team: team,
        isAlive: true,
        fouls: 0,
      ));
    }
    
    return newPlayers;
  }
}