import 'package:hive_ce/hive.dart';
import 'package:mafia_help/data/local/models/best_move.dart';
import 'package:mafia_help/data/local/models/game_log.dart';
import 'package:mafia_help/data/local/models/game.dart';
import 'package:mafia_help/data/local/models/kill.dart';
import 'package:mafia_help/data/local/models/player_model.dart';
import 'package:mafia_help/data/local/models/vote.dart';
import 'package:mafia_help/presentation/state/game_state.dart';

class GameLocalSource {
  static const String _gamesBoxName = 'completed_games';
  static const String _playersBoxName = 'players';
  static const String _killsBoxName = 'kills';
  static const String _votesBoxName = 'votes';
  static const String _bestMovesBoxName = 'best_moves';
  static const String _gameLogsBoxName = 'game_logs';
  static const String _settingsBoxName = 'settings';
  
  static const String _currentGameStateKey = 'current_game_state';
  static const String _currentGameIdKey = 'current_game_id';

  late Box<Game> _gamesBox;
  late Box<PlayerModel> _playersBox;
  late Box<Kill> _killsBox;
  late Box<Vote> _votesBox;
  late Box<BestMove> _bestMovesBox;
  late Box<GameLog> _gameLogsBox;
  late Box _settingsBox;

  Future<void> init() async {
    _gamesBox = await Hive.openBox<Game>(_gamesBoxName);
    _playersBox = await Hive.openBox<PlayerModel>(_playersBoxName);
    _killsBox = await Hive.openBox<Kill>(_killsBoxName);
    _votesBox = await Hive.openBox<Vote>(_votesBoxName);
    _bestMovesBox = await Hive.openBox<BestMove>(_bestMovesBoxName);
    _gameLogsBox = await Hive.openBox<GameLog>(_gameLogsBoxName);
    _settingsBox = await Hive.openBox(_settingsBoxName);
  }

  
  Future<GameState?> loadCurrentGameState() async {
  final json = _settingsBox.get(_currentGameStateKey);
  if (json == null) return null;
  
  // Приводим к правильному типу
  final Map<String, dynamic> typedJson = Map<String, dynamic>.from(json);
  return GameState.fromJson(typedJson);
}

  Future<void> clearCurrentGameState() async {
    await _settingsBox.delete(_currentGameStateKey);
    await _settingsBox.delete(_currentGameIdKey);
  }

  Future<void> saveCompletedGame({
    required Game game,
    required List<PlayerModel> players,
    required List<Kill> kills,
    required List<Vote> votes,
    required List<BestMove> bestMoves,
    required List<GameLog> logs,
  }) async {
    await _gamesBox.put(game.id, game);
    
    for (final player in players) {
      await _playersBox.put(player.id, player);
    }
    
    for (final kill in kills) {
      await _killsBox.put(kill.id, kill);
    }
    
    for (final vote in votes) {
      await _votesBox.put(vote.id, vote);
    }
    
    for (final bestMove in bestMoves) {
      await _bestMovesBox.put(bestMove.id, bestMove);
    }
    
    for (final log in logs) {
      await _gameLogsBox.put(log.id, log);
    }
    
    await _settingsBox.put(_currentGameIdKey, game.id);
  }

  Future<List<Game>> getAllCompletedGames() async {
    return _gamesBox.values.toList();
  }

  Future<Game?> getCompletedGame(String id) async {
    return _gamesBox.get(id);
  }

  Future<List<PlayerModel>> getPlayersForCompletedGame(String gameId) async {
    return _playersBox.values.where((p) => p.gameId == gameId).toList();
  }

  Future<List<Kill>> getKillsForCompletedGame(String gameId) async {
    return _killsBox.values.where((k) => k.gameId == gameId).toList();
  }

  Future<List<Vote>> getVotesForCompletedGame(String gameId) async {
    return _votesBox.values.where((v) => v.gameId == gameId).toList();
  }

  Future<List<BestMove>> getBestMovesForCompletedGame(String gameId) async {
    return _bestMovesBox.values.where((b) => b.gameId == gameId).toList();
  }

  Future<List<GameLog>> getLogsForCompletedGame(String gameId) async {
    return _gameLogsBox.values.where((l) => l.gameId == gameId).toList();
  }
}