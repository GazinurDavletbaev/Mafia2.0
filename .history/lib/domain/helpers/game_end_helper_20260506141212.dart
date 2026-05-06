import 'package:mafia_help/presentation/state/game_state.dart';

enum GameResult { redWin, blackWin }

class GameEndHelper {
  GameResult? checkWinner(GameState state) {
    if (state.isGameEnded) return null;
    
    final alivePlayers = state.players.where((p) => p.isAlive).toList();
    final totalAlive = alivePlayers.length;
    
    if (totalAlive < 3) {
      return GameResult.blackWin;
    }
    
    final blackCount = alivePlayers.where((p) => 
      p.role == 'mafia' || p.role == 'don'
    ).length;
    
    final redCount = alivePlayers.length - blackCount;
    
    if (blackCount == 0) {
      return GameResult.redWin;
    }
    
    if (redCount <= blackCount) {
      return GameResult.blackWin;
    }
    
    return null;
  }
}