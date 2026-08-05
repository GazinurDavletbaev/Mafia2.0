// lib/domain/usecases/ppk_usecase.dart

import '../../data/local/models/player_model.dart';

class PpkUsecase {
  (List<PlayerModel>, String? winner) execute(
    List<PlayerModel> players,
    int seatNumber,
  ) {
    final playerIndex = players.indexWhere((p) => p.seatNumber == seatNumber);
    if (playerIndex == -1) return (players, null);

    final player = players[playerIndex];
    
    // 🔥 Определяем, кто победил
    String? winner;
    
    if (player.team == 'red') {
      // Если красный (мирный или шериф) устроил ППК → победа чёрных
      winner = 'black';
    } else if (player.team == 'black') {
      // Если чёрный (дон или мафия) устроил ППК → победа красных
      winner = 'red';
    }
    
    // Все игроки остаются на своих местах, игра просто завершается
    return (players, winner);
  }
}