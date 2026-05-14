// lib/domain/usecases/revive_player_usecase.dart

import '../rules/player_rules.dart';
import '../../data/local/models/player_model.dart';

class RevivePlayerUsecase {
  final PlayerRules _playerRules;
  
  RevivePlayerUsecase({
    required PlayerRules playerRules,
  }) : _playerRules = playerRules;
  
  List<PlayerModel> execute(
    List<PlayerModel> players,
    int seatNumber,
  ) {
    final playerIndex = players.indexWhere((p) => p.seatNumber == seatNumber);
    if (playerIndex == -1) return players;
    
    final newPlayer = _playerRules.revive(players[playerIndex]);
    
    final newPlayers = List<PlayerModel>.from(players);
    newPlayers[playerIndex] = newPlayer;
    
    return newPlayers;
  }
}