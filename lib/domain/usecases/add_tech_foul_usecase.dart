// lib/domain/usecases/add_tech_foul_usecase.dart

import '../rules/player_rules.dart';
import '../rules/win_rules.dart';
import '../../data/local/models/player_model.dart';

class AddTechFoulUsecase {
  final PlayerRules _playerRules;
  final WinRules _winRules;
  static const int TECH_FOUL_LIMIT = 2; // 🔥 ПОСЛЕ 2 ТЕХ. ФОЛОВ — УДАЛЕНИЕ
  
  AddTechFoulUsecase({
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
    
    final player = players[playerIndex];
    final newTechFouls = player.techFouls + 1;
    final isAlive = player.isAlive;
    
    // 🔥 ЕСЛИ ТЕХ. ФОЛОВ СТАЛО 2 И ИГРОК ЖИВ — УДАЛЯЕМ
    final shouldDie = isAlive && newTechFouls >= TECH_FOUL_LIMIT;
    
    final newPlayers = List<PlayerModel>.from(players);
    
    if (shouldDie) {
      // Убиваем игрока
      newPlayers[playerIndex] = player.copyWith(
        techFouls: newTechFouls,
        isAlive: false,
      );
      
      // Проверяем победу
      final blackAlive = newPlayers.where((p) => p.isAlive && p.team == 'black').length;
      final redAlive = newPlayers.where((p) => p.isAlive && p.team == 'red').length;
      final totalAlive = newPlayers.where((p) => p.isAlive).length;
      
      final winner = _winRules.check(
        blackAlive: blackAlive,
        redAlive: redAlive,
        totalAlive: totalAlive,
      );
      
      return (newPlayers, winner);
    } else {
      // Просто добавляем тех. фол
      newPlayers[playerIndex] = player.copyWith(
        techFouls: newTechFouls,
      );
      return (newPlayers, null);
    }
  }
}