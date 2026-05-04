import 'package:mafia_help/data/local/models/player_model.dart';

enum GameResult {
  redWin,
  blackWin,
}

class GameEndHelper {
  static GameResult? check(List<PlayerModel> players) {
    final alivePlayers = players.where((p) => p.isAlive).toList();
    
    if (alivePlayers.length < 3) {
      final hasAliveRed = alivePlayers.any((p) => p.team == 'red');
      final hasAliveBlack = alivePlayers.any((p) => p.team == 'black');
      
      if (!hasAliveBlack) return GameResult.redWin;
      if (!hasAliveRed) return GameResult.blackWin;
      return GameResult.blackWin;
    }
    
    final aliveBlackCount = alivePlayers.where((p) => p.team == 'black').length;
    if (aliveBlackCount == 0) {
      return GameResult.redWin;
    }
    
    final aliveRedCount = alivePlayers.where((p) => p.team == 'red').length;
    if (aliveRedCount == 0) {
      return GameResult.blackWin;
    }
    
    return null;
  }
}