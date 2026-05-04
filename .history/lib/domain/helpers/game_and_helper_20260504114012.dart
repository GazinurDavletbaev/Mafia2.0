import 'package:mafia_help/data/local/models/player.dart';

enum GameResult {
  redWin,
  blackWin,
}

class GameEndHelper {
  static GameResult? check(List<Player> players) {
    final alivePlayers = players.where((p) => p.isAlive).toList();
    
    // Минимум 3 живых игрока
    if (alivePlayers.length < 3) {
      final hasAliveRed = alivePlayers.any((p) => p.team == 'red');
      final hasAliveBlack = alivePlayers.any((p) => p.team == 'black');
      
      if (!hasAliveBlack) return GameResult.redWin;
      if (!hasAliveRed) return GameResult.blackWin;
      return GameResult.blackWin;
    }
    
    // Проверка на 0 чёрных
    final aliveBlackCount = alivePlayers.where((p) => p.team == 'black').length;
    if (aliveBlackCount == 0) {
      return GameResult.redWin;
    }
    
    // Проверка на 0 красных
    final aliveRedCount = alivePlayers.where((p) => p.team == 'red').length;
    if (aliveRedCount == 0) {
      return GameResult.blackWin;
    }
    
    return null;
  }
}