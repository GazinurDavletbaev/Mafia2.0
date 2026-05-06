import 'package:mafia_help/data/local/models/game.dart';
import 'package:mafia_help/presentation/state/game_state.dart';

abstract class GameRepository {
  // Всегда возвращает GameState (никогда null)
  Future<GameState> getCurrentGameState();
  
  Future<void> saveCurrentGameState(GameState state);
  Future<void> clearCurrentGameState();
  Future<void> saveCompletedGame(GameState finalState);
  Future<List<Game>> getAllCompletedGames();
}