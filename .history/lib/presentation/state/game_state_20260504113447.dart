import 'package:mafia_help/data/local/models/best_move.dart';
import 'package:mafia_help/data/local/models/game_log.dart';
import 'package:mafia_help/data/local/models/game.dart';
import 'package:mafia_help/data/local/models/kill.dart';
import 'package:mafia_help/data/local/models/phase.dart';
import 'package:mafia_help/data/local/models/player.dart';
import 'package:mafia_help/data/local/models/vote.dart';
import 'package:mafia_help/data/local/models/player_model.dart'; // если нужен PlayerModel

class GameState {
  // Основные данные игры
  final GameModel? game;
  final List<PlayerModel> players;
  
  // Фазы
  final Phase currentPhase;
  final int currentSubPhaseIndex;
  final int currentDay;
  
  // Игровой процесс
  final int? currentSpeakerSeat;
  final List<int> nominatedSeats;      // Кандидаты на голосование
  final Map<int, int> votes;            // Голоса: seatNumber -> voteCount
  
  // Лучший ход (временный, для калькулятора)
  final List<int> partialBestMove;
  
  // Состояние игры
  final bool isGameEnded;
  final String? winner; // 'red' или 'black'
  final int currentRound;
  
  // Накопленные данные для сохранения в историю
  final List<KillModel> pendingKills;
  final List<BestMoveModel> pendingBestMoves;
  final List<VoteModel> pendingVotes;
  final List<GameLogModel> pendingLogs;

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

  // ========== Геттеры ==========
  
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

  // ========== Методы обновления (иммутабельные) ==========
  
  GameState copyWith({
    GameModel? game,
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
    List<KillModel>? pendingKills,
    List<BestMoveModel>? pendingBestMoves,
    List<VoteModel>? pendingVotes,
    List<GameLogModel>? pendingLogs,
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

  // ========== Добавление pending данных ==========
  
  GameState addPendingKill(int seatNumber, String phase, String killType) {
    final kill = KillModel(
      id: DateTime.now().millisecondsSinceEpoch,
      gameId: game?.id ?? 0,
      seatNumber: seatNumber,
      phase: phase,
      killType: killType,
    );
    return copyWith(pendingKills: [...pendingKills, kill]);
  }

  GameState addPendingBestMove(List<int> threeSeats) {
    final bestMove = BestMoveModel(
      id: DateTime.now().millisecondsSinceEpoch,
      gameId: game?.id ?? 0,
      killedSeat: threeSeats[0], // Условно, нужно получить реального убитого
      suspect1: threeSeats[0],
      suspect2: threeSeats[1],
      suspect3: threeSeats[2],
    );
    return copyWith(pendingBestMoves: [...pendingBestMoves, bestMove]);
  }

  GameState addPendingVote(VoteModel vote) {
    return copyWith(pendingVotes: [...pendingVotes, vote]);
  }

  GameState addPendingLog(GameLogModel log) {
    return copyWith(pendingLogs: [...pendingLogs, log]);
  }

  // ========== Сериализация для Hive ==========
  
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
      game: json['game'] != null ? GameModel.fromJson(json['game']) : null,
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
      pendingKills: (json['pendingKills'] as List).map((k) => KillModel.fromJson(k)).toList(),
      pendingBestMoves: (json['pendingBestMoves'] as List).map((b) => BestMoveModel.fromJson(b)).toList(),
      pendingVotes: (json['pendingVotes'] as List).map((v) => VoteModel.fromJson(v)).toList(),
      pendingLogs: (json['pendingLogs'] as List).map((l) => GameLogModel.fromJson(l)).toList(),
    );
  }

  // ========== Конвертация в модели для сохранения завершённой игры ==========
  
  GameModel toGameModel() {
    return game ?? GameModel(
      id: DateTime.now().millisecondsSinceEpoch,
      clubId: '',
      judgeUserId: '',
      date: DateTime.now(),
      winner: winner ?? '',
      status: 'completed',
    );
  }

  List<PlayerModel> toPlayerModels() {
    return players;
  }

  List<KillModel> toKillModels() {
    return pendingKills;
  }

  List<VoteModel> toVoteModels() {
    return pendingVotes;
  }

  List<BestMoveModel> toBestMoveModels() {
    return pendingBestMoves;
  }

  List<GameLogModel> toGameLogModels() {
    return pendingLogs;
  }
}