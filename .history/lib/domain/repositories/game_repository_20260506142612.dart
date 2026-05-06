import 'package:mafia_help/data/local/models/game.dart';
import 'package:mafia_help/presentation/state/game_state.dart';

abstract class GameRepository {
  // Загрузка текущего состояния игры
  Future<GameState?> loadCurrentGameState();
  
  Future<GameState?> getCurrentGameState();

  // Сохранение текущего состояния игры
  Future<void> saveCurrentGameState(GameState state);
  
  // Очистка текущего состояния игры
  Future<void> clearCurrentGameState();
  
  // Сохранение завершённой игры в историю
  Future<void> saveCompletedGame(GameState finalState);
  
  // Получение всех завершённых игр
  Future<List<Game>> getAllCompletedGames();
}
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