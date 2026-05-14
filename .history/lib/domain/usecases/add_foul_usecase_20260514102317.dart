// lib/domain/usecases/add_foul_usecase.dart

import '../rules/player_rules.dart';
import '../rules/win_rules.dart';
import '../../data/local/models/player_model.dart';

class AddFoulUsecase {
  final PlayerRules _playerRules;
  final WinRules _winRules;
  
  AddFoulUsecase({
    required PlayerRules playerRules,
    required WinRules winRules,
  }) : _playerRules = playerRules,
       _winRules = winRules;
  
  (List<PlayerModel>, bool? winner) execute(
    List<PlayerModel> players,
    int seatNumber,
  ) {
    final playerIndex = players.indexWhere((p) => p.seatNumber == seatNumber);
    if (playerIndex == -1) return (players, null);
    
    final oldIsAlive = players[playerIndex].isAlive;
    final newPlayer = _playerRules.addFoul(players[playerIndex]);
    final died = oldIsAlive && !newPlayer.isAlive;
    
    final newPlayers = List<PlayerModel>.from(players);
    newPlayers[playerIndex] = newPlayer;
    
    if (died) {
      final blackAlive = newPlayers.where((p) => p.isAlive && p.team == 'black').length;
      final redAlive = newPlayers.where((p) => p.isAlive && p.team == 'red').length;
      final totalAlive = newPlayers.where((p) => p.isAlive).length;
      
      final winner = _winRules.check(
        blackAlive: blackAlive,
        redAlive: redAlive,
        totalAlive: totalAlive,
      );
      
      return (newPlayers, winner);
    }
    
    return (newPlayers, null);
  }
}