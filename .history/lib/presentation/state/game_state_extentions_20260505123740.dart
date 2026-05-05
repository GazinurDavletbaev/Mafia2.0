import 'package:mafia_help/data/local/models/player_model.dart';
import '../../data/local/models/best_move.dart';
import '../../data/local/models/game_log.dart';
import '../../data/local/models/kill.dart';
import '../../data/local/models/vote.dart';
import 'game_state.dart';
import 'game_state_copy.dart';

extension GameStateGetters on GameState {
  PlayerModel? getPlayerBySeat(int seatNumber) {
    try {
      return players.firstWhere((p) => p.seatNumber == seatNumber);
    } catch (_) {
      return null;
    }
  }

  List<PlayerModel> getAlivePlayers() => players.where((p) => p.isAlive).toList();
  List<PlayerModel> getDeadPlayers() => players.where((p) => !p.isAlive).toList();
  List<PlayerModel> get alivePlayers => getAlivePlayers();
  List<PlayerModel> get redAlivePlayers => alivePlayers.where((p) => p.team == 'red').toList();
  List<PlayerModel> get blackAlivePlayers => alivePlayers.where((p) => p.team == 'black').toList();
  int get totalAlive => alivePlayers.length;
  int get redAlive => redAlivePlayers.length;
  int get blackAlive => blackAlivePlayers.length;
}

extension GameStateMutation on GameState {
  GameState updatePlayer(PlayerModel updatedPlayer) {
    final newPlayers = List<PlayerModel>.from(players);
    final index = newPlayers.indexWhere((p) => p.seatNumber == updatedPlayer.seatNumber);
    if (index != -1) {
      newPlayers[index] = updatedPlayer;
    }
    return copyWith(players: newPlayers);
  }

  GameState updateFouls(int seatNumber, int fouls) {
    final player = getPlayerBySeat(seatNumber);
    if (player == null) return this;
    return updatePlayer(player.copyWith(fouls: fouls));
  }

  GameState setPlayerAlive(int seatNumber, bool isAlive) {
    final player = getPlayerBySeat(seatNumber);
    if (player == null) return this;
    return updatePlayer(player.copyWith(isAlive: isAlive));
  }

  GameState addPendingKill(int seatNumber, String phase, String killType) {
    final kill = Kill(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      gameId: game?.id.toString() ?? '',
      playerSeatNumber: seatNumber,
      type: killType,
      phaseId: 0,
    );
    return copyWith(pendingKills: [...pendingKills, kill]);
  }

  GameState addPendingBestMove(List<int> threeSeats) {
    final bestMove = BestMove(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      gameId: game?.id.toString() ?? '',
      killedSeatNumber: threeSeats[0],
      suspectSeat1: threeSeats[0],
      suspectSeat2: threeSeats[1],
      suspectSeat3: threeSeats[2],
    );
    return copyWith(pendingBestMoves: [...pendingBestMoves, bestMove]);
  }

  GameState addPendingVote(Vote vote) {
    return copyWith(pendingVotes: [...pendingVotes, vote]);
  }

  GameState addPendingLog(GameLog log) {
    return copyWith(pendingLogs: [...pendingLogs, log]);
  }
}