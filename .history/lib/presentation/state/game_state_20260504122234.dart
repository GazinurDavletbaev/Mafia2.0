import 'package:mafia_help/data/local/models/best_move.dart';
import 'package:mafia_help/data/local/models/game_log.dart';
import 'package:mafia_help/data/local/models/game.dart';
import 'package:mafia_help/data/local/models/kill.dart';
import 'package:mafia_help/data/local/models/phase.dart';
import 'package:mafia_help/data/local/models/player_model.dart';
import 'package:mafia_help/data/local/models/vote.dart';
import 'package:mafia_help/data/local/models/phase.dart';

class GameState {
  final Game? game;
  final List<PlayerModel> players;
  final Phase currentPhase;
  final int currentSubPhaseIndex;
  final int currentDay;
  final int? currentSpeakerSeat;
  final List<int> nominatedSeats;
  final Map<int, int> votes;
  final List<int> partialBestMove;
  final bool isGameEnded;
  final String? winner;
  final int currentRound;
  final List<Kill> pendingKills;
  final List<BestMove> pendingBestMoves;
  final List<Vote> pendingVotes;
  final List<GameLog> pendingLogs;

  const GameState({
    required this.game,
    required this.players,
    required this.currentPhase,
    required this.currentSubPhaseIndex,
    required this.currentDay,
    this.currentSpeakerSeat,
    required this.nominatedSeats,
    required this.votes,
    required this.partialBestMove,
    required this.isGameEnded,
    this.winner,
    required this.currentRound,
    required this.pendingKills,
    required this.pendingBestMoves,
    required this.pendingVotes,
    required this.pendingLogs,
  });

  factory GameState.initial() {
    return GameState(
      game: null,
      players: [],
      currentPhase: Phase.night,
      currentSubPhaseIndex: 0,
      currentDay: 1,
      currentSpeakerSeat: null,
      nominatedSeats: [],
      votes: {},
      partialBestMove: [],
      isGameEnded: false,
      winner: null,
      currentRound: 1,
      pendingKills: [],
      pendingBestMoves: [],
      pendingVotes: [],
      pendingLogs: [],
    );
  }

  PlayerModel? getPlayerBySeat(int seatNumber) {
    try {
      return players.firstWhere((p) => p.seatNumber == seatNumber);
    } catch (_) {
      return null;
    }
  }

  List<PlayerModel> getAlivePlayers() {
    return players.where((p) => p.isAlive).toList();
  }

  List<PlayerModel> getDeadPlayers() {
    return players.where((p) => !p.isAlive).toList();
  }

  GameState copyWith({
    Game? game,
    List<PlayerModel>? players,
    Phase? currentPhase,
    int? currentSubPhaseIndex,
    int? currentDay,
    int? currentSpeakerSeat,
    List<int>? nominatedSeats,
    Map<int, int>? votes,
    List<int>? partialBestMove,
    bool? isGameEnded,
    String? winner,
    int? currentRound,
    List<Kill>? pendingKills,
    List<BestMove>? pendingBestMoves,
    List<Vote>? pendingVotes,
    List<GameLog>? pendingLogs,
  }) {
    return GameState(
      game: game ?? this.game,
      players: players ?? this.players,
      currentPhase: currentPhase ?? this.currentPhase,
      currentSubPhaseIndex: currentSubPhaseIndex ?? this.currentSubPhaseIndex,
      currentDay: currentDay ?? this.currentDay,
      currentSpeakerSeat: currentSpeakerSeat ?? this.currentSpeakerSeat,
      nominatedSeats: nominatedSeats ?? this.nominatedSeats,
      votes: votes ?? this.votes,
      partialBestMove: partialBestMove ?? this.partialBestMove,
      isGameEnded: isGameEnded ?? this.isGameEnded,
      winner: winner ?? this.winner,
      currentRound: currentRound ?? this.currentRound,
      pendingKills: pendingKills ?? this.pendingKills,
      pendingBestMoves: pendingBestMoves ?? this.pendingBestMoves,
      pendingVotes: pendingVotes ?? this.pendingVotes,
      pendingLogs: pendingLogs ?? this.pendingLogs,
    );
  }

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
    final updatedPlayer = player.copyWith(fouls: fouls);
    return updatePlayer(updatedPlayer);
  }

  GameState setPlayerAlive(int seatNumber, bool isAlive) {
    final player = getPlayerBySeat(seatNumber);
    if (player == null) return this;
    final updatedPlayer = player.copyWith(isAlive: isAlive);
    return updatePlayer(updatedPlayer);
  }

  GameState addPendingKill(int seatNumber, String phase, String killType) {
    final kill = Kill(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      gameId: game?.id.toString() ?? '',
      playerSeatNumber: seatNumber,     // ← было seatNumber, стало playerSeatNumber
      type: killType,                   // ← было killType, стало type
      phaseId: 0, // TODO: нужен phaseId
    );
    return copyWith(pendingKills: [...pendingKills, kill]);
  }

  GameState addPendingBestMove(List<int> threeSeats) {
    final bestMove = BestMove(
      id: DateTime.now().millisecondsSinceEpoch,
      gameId: game?.id ?? 0,
      killedSeat: threeSeats[0],
      suspect1: threeSeats[0],
      suspect2: threeSeats[1],
      suspect3: threeSeats[2],
    );
    return copyWith(pendingBestMoves: [...pendingBestMoves, bestMove]);
  }

  GameState addPendingVote(Vote vote) {
    return copyWith(pendingVotes: [...pendingVotes, vote]);
  }

  GameState addPendingLog(GameLog log) {
    return copyWith(pendingLogs: [...pendingLogs, log]);
  }

  Map<String, dynamic> toJson() {
    return {
      'game': game?.toJson(),
      'players': players.map((p) => p.toJson()).toList(),
      'currentPhase': currentPhase.index,
      'currentSubPhaseIndex': currentSubPhaseIndex,
      'currentDay': currentDay,
      'currentSpeakerSeat': currentSpeakerSeat,
      'nominatedSeats': nominatedSeats,
      'votes': votes,
      'partialBestMove': partialBestMove,
      'isGameEnded': isGameEnded,
      'winner': winner,
      'currentRound': currentRound,
      'pendingKills': pendingKills.map((k) => k.toJson()).toList(),
      'pendingBestMoves': pendingBestMoves.map((b) => b.toJson()).toList(),
      'pendingVotes': pendingVotes.map((v) => v.toJson()).toList(),
      'pendingLogs': pendingLogs.map((l) => l.toJson()).toList(),
    };
  }

  factory GameState.fromJson(Map<String, dynamic> json) {
    return GameState(
      game: json['game'] != null ? Game.fromJson(json['game']) : null,
      players: (json['players'] as List).map((p) => PlayerModel.fromJson(p)).toList(),
      currentPhase: Phase.values[json['currentPhase']],
      currentSubPhaseIndex: json['currentSubPhaseIndex'],
      currentDay: json['currentDay'],
      currentSpeakerSeat: json['currentSpeakerSeat'],
      nominatedSeats: List<int>.from(json['nominatedSeats']),
      votes: Map<int, int>.from(json['votes']),
      partialBestMove: List<int>.from(json['partialBestMove']),
      isGameEnded: json['isGameEnded'],
      winner: json['winner'],
      currentRound: json['currentRound'],
      pendingKills: (json['pendingKills'] as List).map((k) => Kill.fromJson(k)).toList(),
      pendingBestMoves: (json['pendingBestMoves'] as List).map((b) => BestMove.fromJson(b)).toList(),
      pendingVotes: (json['pendingVotes'] as List).map((v) => Vote.fromJson(v)).toList(),
      pendingLogs: (json['pendingLogs'] as List).map((l) => GameLog.fromJson(l)).toList(),
    );
  }

  Game toGameModel() {
    return game ?? Game(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      clubId: '',
      judgeId: '',        // ← было judgeUserId, стало judgeId
      date: DateTime.now(),
      winningTeam: winner ?? '',
      status: 'completed',
    );
  }

  List<PlayerModel> toPlayerModels() {
    return players;
  }

  List<Kill> toKillModels() {
    return pendingKills;
  }

  List<Vote> toVoteModels() {
    return pendingVotes;
  }

  List<BestMove> toBestMoveModels() {
    return pendingBestMoves;
  }

  List<GameLog> toGameLogModels() {
    return pendingLogs;
  }
}