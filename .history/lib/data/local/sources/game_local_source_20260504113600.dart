import 'package:hive_ce/hive.dart';
import 'package:mafia_help/data/local/models/player_model.dart';
import 'package:mafia_help/presentation/state/game_state.dart';
import 'package:mafia_help/data/local/models/best_move.dart';
import 'package:mafia_help/data/local/models/game_log.dart';
import 'package:mafia_help/data/local/models/game.dart';
import 'package:mafia_help/data/local/models/kill.dart';
import 'package:mafia_help/data/local/models/phase.dart';
import 'package:mafia_help/data/local/models/player.dart';
import 'package:mafia_help/data/local/models/vote.dart';

class GameLocalSource {
  static const String _gamesBox = 'completed_games';
  static const String _playersBox = 'players';
  static const String _killsBox = 'kills';
  static const String _votesBox = 'votes';
  static const String _bestMovesBox = 'best_moves';
  static const String _gameLogsBox = 'game_logs';
  static const String _settingsBox = 'settings';
  
  static const String _currentGameStateKey = 'current_game_state';
  static const String _currentGameIdKey = 'current_game_id';

  late Box<GameModel> _gamesBox;
  late Box<PlayerModel> _playersBox;
  late Box<KillModel> _killsBox;
  late Box<VoteModel> _votesBox;
  late Box<BestMoveModel> _bestMovesBox;
  late Box<GameLogModel> _gameLogsBox;
  late Box _settingsBox;

  Future<void> init() async {
    _gamesBox = await Hive.openBox<GameModel>(_gamesBox);
    _playersBox = await Hive.openBox<PlayerModel>(_playersBox);
    _killsBox = await Hive.openBox<KillModel>(_killsBox);
    _votesBox = await Hive.openBox<VoteModel>(_votesBox);
    _bestMovesBox = await Hive.openBox<BestMoveModel>(_bestMovesBox);
    _gameLogsBox = await Hive.openBox<GameLogModel>(_gameLogsBox);
    _settingsBox = await Hive.openBox(_settingsBox);
  }

  // ========== Текущая игра (для восстановления при сворачивании) ==========
  
  Future<void> saveCurrentGameState(GameState state) async {
    await _settingsBox.put(_currentGameStateKey, state.toJson());
  }

  Future<GameState?> loadCurrentGameState() async {
    final json = _settingsBox.get(_currentGameStateKey);
    if (json == null) return null;
    return GameState.fromJson(json);
  }

  Future<void> clearCurrentGameState() async {
    await _settingsBox.delete(_currentGameStateKey);
    await _settingsBox.delete(_currentGameIdKey);
  }

  // ========== Завершённая игра (сохраняется в историю) ==========
  
  Future<void> saveCompletedGame({
    required GameModel game,
    required List<PlayerModel> players,
    required List<KillModel> kills,
    required List<VoteModel> votes,
    required List<BestMoveModel> bestMoves,
    required List<GameLogModel> logs,
  }) async {
    // Сохраняем игру
    await _gamesBox.put(game.id, game);
    
    // Сохраняем всех игроков
    for (final player in players) {
      await _playersBox.put(player.id, player);
    }
    
    // Сохраняем убийства
    for (final kill in kills) {
      await _killsBox.put(kill.id, kill);
    }
    
    // Сохраняем голоса
    for (final vote in votes) {
      await _votesBox.put(vote.id, vote);
    }
    
    // Сохраняем лучшие ходы
    for (final bestMove in bestMoves) {
      await _bestMovesBox.put(bestMove.id, bestMove);
    }
    
    // Сохраняем логи
    for (final log in logs) {
      await _gameLogsBox.put(log.id, log);
    }
    
    // Сохраняем ID текущей игры (чтобы знать, что это за игра)
    await _settingsBox.put(_currentGameIdKey, game.id);
  }

  // ========== История игр ==========
  
  Future<List<GameModel>> getAllCompletedGames() async {
    return _gamesBox.values.toList();
  }

  Future<GameModel?> getCompletedGame(int id) async {
    return _gamesBox.get(id);
  }

  Future<List<PlayerModel>> getPlayersForCompletedGame(int gameId) async {
    return _playersBox.values.where((p) => p.gameId == gameId).toList();
  }

  Future<List<KillModel>> getKillsForCompletedGame(int gameId) async {
    return _killsBox.values.where((k) => k.gameId == gameId).toList();
  }

  Future<List<VoteModel>> getVotesForCompletedGame(int gameId) async {
    return _votesBox.values.where((v) => v.gameId == gameId).toList();
  }

  Future<List<BestMoveModel>> getBestMovesForCompletedGame(int gameId) async {
    return _bestMovesBox.values.where((b) => b.gameId == gameId).toList();
  }

  Future<List<GameLogModel>> getLogsForCompletedGame(int gameId) async {
    return _gameLogsBox.values.where((l) => l.gameId == gameId).toList();
  }
}