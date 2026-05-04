import 'package:mafia_help/data/local/models/player_model.dart';

enum GameResult {
  redWin,
  blackWin,
}

class GameEndHelper {
  // Проверяет, окончена ли игра, и возвращает результат
  static GameResult? check(List<PlayerModel> players) {
    // Подсчёт живых игроков
    final alivePlayers = players.where((p) => p.isAlive).toList();
    
    // Минимум 3 живых игрока, иначе игра заканчивается
    if (alivePlayers.length < 3) {
      // Определяем победителя
      final hasAliveRed = alivePlayers.any((p) => p.team == 'red');
      final hasAliveBlack = alivePlayers.any((p) => p.team == 'black');
      
      if (!hasAliveBlack) return GameResult.redWin;
      return GameResult.blackWin;
    }
    
    // Проверка на 0 чёрных
    final aliveBlackCount = alivePlayers.where((p) => p.team == 'black').length;
    if (aliveBlackCount == 0) {
      return GameResult.redWin;
    }
    
    // Во всех остальных случаях игра не окончена или победили чёрные
    // (включая 1 красный + 1 чёрный, 2 красных + 1 чёрный и т.д.)
    // Чёрные побеждают, если красных не осталось или игра не может продолжаться
    final aliveRedCount = alivePlayers.where((p) => p.team == 'red').length;
    if (aliveRedCount == 0) {
      return GameResult.blackWin;
    }
    
    // Игра продолжается
    return null;
  }
}