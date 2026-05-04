import 'package:mafia_help/data/local/models/best_move_model.dart';
import 'package:mafia_help/data/local/models/game_model.dart';
import 'package:mafia_help/data/local/models/kill_model.dart';
import 'package:mafia_help/data/local/models/phase_model.dart';
import 'package:mafia_help/data/local/models/player_model.dart';
import 'package:mafia_help/data/local/models/vote_model.dart';
import 'package:mafia_help/domain/helpers/game_end_helper.dart';
import 'package:mafia_help/domain/repositories/game_repository.dart';
import 'package:mafia_help/services/storage_service.dart';

class GameRepositoryImpl implements GameRepository {
  final StorageService _storage;

  GameRepositoryImpl({required StorageService storage}) : _storage = storage;

  // ========== Game ==========
  @override
  Future<GameModel?> getCurrentGame() async {
    return _storage.getCurrentGame();
  }

  @override
  Future<void> saveGame(GameModel game) async {
    await _storage.saveGame(game);
  }

  @override
  Future<void> setGameEnded(bool ended) async {
    final game = await _storage.getCurrentGame();
    if (game != null) {
      final updatedGame = game.copyWith(isEnded: ended);
      await _storage.saveGame(updatedGame);
    }
  }

  @override
  Future<void> setWinner(GameResult result) async {
    final game = await _storage.getCurrentGame();
    if (game != null) {
      final winner = result == GameResult.redWin ? 'red' : 'black';
      final updatedGame = game.copyWith(winner: winner, isEnded: true);
      await _storage.saveGame(updatedGame);
    }
  }
}

  // ========== Players ==========
  @override
  Future<PlayerModel?> getPlayerBySeat(int seatNumber) async {
    final players = await _storage.getPlayersForCurrentGame();
    try {
      return players.firstWhere((p) => p.seatNumber == seatNumber);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<List<PlayerModel>> getAllPlayers() async {
    return _storage.getPlayersForCurrentGame();
  }

  @override
  Future<List<PlayerModel>> getAlivePlayers() async {
    final players = await _storage.getPlayersForCurrentGame();
    return players.where((p) => p.isAlive).toList();
  }

  @override
  Future<void> updatePlayerFouls(int seatNumber, int fouls) async {
    final player = await getPlayerBySeat(seatNumber);
    if (player != null) {
      final updatedPlayer = player.copyWith(fouls: fouls);
      await _storage.updatePlayer(updatedPlayer);
    }
  }

  @override
  Future<void> setPlayerAlive(int seatNumber, bool isAlive) async {
    final player = await getPlayerBySeat(seatNumber);
    if (player != null) {
      final updatedPlayer = player.copyWith(isAlive: isAlive);
      await _storage.updatePlayer(updatedPlayer);
    }
  }

  @override
  Future<void> updatePlayer(PlayerModel player) async {
    await _storage.updatePlayer(player);
  }

    // ========== Nominations (для голосования) ==========
  @override
  Future<List<int>> getCurrentNominations() async {
    return _storage.getCurrentNominations();
  }

  @override
  Future<void> setNominations(List<int> seats) async {
    await _storage.setCurrentNominations(seats);
  }

  // ========== Votes ==========
  @override
  Future<void> addVote({
    required int round,
    required int targetSeat,
    required int voteCount,
  }) async {
    final vote = VoteModel(
      id: DateTime.now().millisecondsSinceEpoch,
      gameId: await _getCurrentGameId(),
      round: round,
      targetSeat: targetSeat,
      voteCount: voteCount,
    );
    await _storage.addVote(vote);
  }

  @override
  Future<void> clearVotes() async {
    final gameId = await _getCurrentGameId();
    await _storage.clearVotesForGame(gameId);
  }

  @override
  Future<Map<int, int>> getCurrentVotes() async {
    final gameId = await _getCurrentGameId();
    final round = await _storage.getCurrentRound();
    final votes = await _storage.getVotesForGameAndRound(gameId, round);
    return Map.fromEntries(votes.map((v) => MapEntry(v.targetSeat, v.voteCount)));
  }

  Future<int> _getCurrentGameId() async {
    final game = await _storage.getCurrentGame();
    return game?.id ?? 0;
  }