import 'package:mafia_help/data/local/models/player_model.dart';
import '../../data/local/models/game.dart';
import 'game_state.dart';

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

extension GameStateConverters on GameState {
  Game toGameModel() {
    return game ?? Game(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      clubId: '',
      judgeId: '',
      date: DateTime.now(),
      winningTeam: winner ?? '',
      status: 'completed',
    );
  }

  List<PlayerModel> toPlayerModels() => players;
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
}