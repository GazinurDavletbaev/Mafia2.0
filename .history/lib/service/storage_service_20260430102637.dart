import 'package:hive_ce/hive.dart';
import 'package:mafia_help/models/game.dart';
import 'package:mafia_help/models/player.dart';
import 'package:mafia_help/models/kill.dart';
import 'package:mafia_help/models/vote.dart';
import 'package:mafia_help/models/violation.dart';
import 'package:mafia_help/models/best_move.dart';
import 'package:mafia_help/models/game_log.dart';

class StorageService {
  // Ссылки на коробки Hive
  late final Box<Game> _gamesBox;
  late final Box<Player> _playersBox;
  late final Box<Kill> _killsBox;
  late final Box<Vote> _votesBox;
  late final Box<Violation> _violationsBox;
  late final Box<BestMove> _bestMovesBox;
  late final Box<GameLog> _gameLogsBox;

  // Инициализация (вызывать один раз при старте)
  Future<void> init() async {
    _gamesBox = await Hive.openBox<Game>('games');
    _playersBox = await Hive.openBox<Player>('players');
    _killsBox = await Hive.openBox<Kill>('kills');
    _votesBox = await Hive.openBox<Vote>('votes');
    _violationsBox = await Hive.openBox<Violation>('violations');
    _bestMovesBox = await Hive.openBox<BestMove>('best_moves');
    _gameLogsBox = await Hive.openBox<GameLog>('game_logs');
  }

  // ============ Игры ============
  Future<void> saveGame(Game game) async {
    await _gamesBox.put(game.id, game);
  }

  Game? loadGame(String id) {
    return _gamesBox.get(id);
  }

  List<Game> loadAllGames() {
    return _gamesBox.values.toList();
  }

  List<Game> loadGamesByClub(String clubId) {
    return _gamesBox.values.where((game) => game.clubId == clubId).toList();
  }

  Game? loadUnfinishedGame() {
    try {
      return _gamesBox.values.firstWhere((game) => game.status == 'in_progress');
    } catch (e) {
      return null;
    }
  }

  // ============ Игроки за столом ============
  Future<void> savePlayer(Player player) async {
    await _playersBox.put(player.id, player);
  }

  Future<void> savePlayers(List<Player> players) async {
    for (final player in players) {
      await savePlayer(player);
    }
  }

  List<Player> loadPlayersByGame(String gameId) {
    return _playersBox.values.where((player) => player.gameId == gameId).toList();
  }

  Player? loadPlayerBySeat(String gameId, int seatNumber) {
    try {
      return _playersBox.values.firstWhere(
        (player) => player.gameId == gameId && player.seatNumber == seatNumber,
      );
    } catch (e) {
      return null;
    }
  }

  Future<void> updatePlayerAliveStatus(String playerId, bool isAlive) async {
    final player = _playersBox.get(playerId);
    if (player != null) {
      final updatedPlayer = Player(
        id: player.id,
        gameId: player.gameId,
        userId: player.userId,
        customName: player.customName,
        seatNumber: player.seatNumber,
        roleId: player.roleId,
        score: player.score,
        isAlive: isAlive,
      );
      await savePlayer(updatedPlayer);
    }
  }

  Future<void> updatePlayerScore(String playerId, int newScore) async {
    final player = _playersBox.get(playerId);
    if (player != null) {
      final updatedPlayer = Player(
        id: player.id,
        gameId: player.gameId,
        userId: player.userId,
        customName: player.customName,
        seatNumber: player.seatNumber,
        roleId: player.roleId,
        score: newScore,
        isAlive: player.isAlive,
      );
      await savePlayer(updatedPlayer);
    }
  }

  // ============ Убийства ============
  Future<void> saveKill(Kill kill) async {
    await _killsBox.put(kill.id, kill);
  }

  List<Kill> loadKillsByGame(String gameId) {
    return _killsBox.values.where((kill) => kill.gameId == gameId).toList();
  }

  // ============ Голосования ============
  Future<void> saveVote(Vote vote) async {
    await _votesBox.put(vote.id, vote);
  }

  List<Vote> loadVotesByGame(String gameId) {
    return _votesBox.values.where((vote) => vote.gameId == gameId).toList();
  }

  List<Vote> loadVotesByRound(String gameId, int round) {
    return _votesBox.values.where(
      (vote) => vote.gameId == gameId && vote.round == round,
    ).toList();
  }

  // ============ Нарушения ============
  Future<void> saveViolation(Violation violation) async {
    await _violationsBox.put(violation.id, violation);
  }

  List<Violation> loadViolationsByGame(String gameId) {
    return _violationsBox.values.where(
      (violation) => violation.gameId == gameId,
    ).toList();
  }

  int countViolationsForPlayer(String gameId, int seatNumber) {
    return _violationsBox.values.where(
      (violation) => violation.gameId == gameId && violation.playerSeatNumber == seatNumber,
    ).length;
  }

  // ============ Лучший ход ============
  Future<void> saveBestMove(BestMove bestMove) async {
    await _bestMovesBox.put(bestMove.id, bestMove);
  }

  BestMove? loadBestMoveForKill(String gameId, int killedSeatNumber) {
    try {
      return _bestMovesBox.values.firstWhere(
        (move) => move.gameId == gameId && move.killedSeatNumber == killedSeatNumber,
      );
    } catch (e) {
      return null;
    }
  }

  List<BestMove> loadBestMovesByGame(String gameId) {
    return _bestMovesBox.values.where((move) => move.gameId == gameId).toList();
  }

  // ============ Лог игры ============
  Future<void> saveGameLog(GameLog log) async {
    await _gameLogsBox.put(log.id, log);
  }

  List<GameLog> loadGameLogsByGame(String gameId) {
    return _gameLogsBox.values.where((log) => log.gameId == gameId).toList();
  }

  // ============ Утилиты ============
  Future<void> deleteGame(String gameId) async {
    // Удаляем все связанные данные
    final players = loadPlayersByGame(gameId);
    for (final player in players) {
      await _playersBox.delete(player.id);
    }

    final kills = loadKillsByGame(gameId);
    for (final kill in kills) {
      await _killsBox.delete(kill.id);
    }

    final votes = loadVotesByGame(gameId);
    for (final vote in votes) {
      await _votesBox.delete(vote.id);
    }

    final violations = loadViolationsByGame(gameId);
    for (final violation in violations) {
      await _violationsBox.delete(violation.id);
    }

    final bestMoves = loadBestMovesByGame(gameId);
    for (final bestMove in bestMoves) {
      await _bestMovesBox.delete(bestMove.id);
    }

    final logs = loadGameLogsByGame(gameId);
    for (final log in logs) {
      await _gameLogsBox.delete(log.id);
    }

    await _gamesBox.delete(gameId);
  }
}