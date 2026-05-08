import 'package:mafia_help/data/local/models/best_move.dart';
import 'package:mafia_help/data/local/models/game_log.dart';
import 'package:mafia_help/data/local/models/game.dart';
import 'package:mafia_help/data/local/models/kill.dart';
import 'package:mafia_help/data/local/models/phase.dart';
import 'package:mafia_help/data/local/models/player_model.dart';
import 'package:mafia_help/data/local/models/vote.dart';
import '../../data/local/models/sub_phase.dart';
import 'game_state_initializer.dart';
import 'game_state_serialization.dart';

class GameState {
  final Game? game;
  final List<PlayerModel> players;
  final Phase currentPhase;
  final SubPhase currentSubPhase;
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
  final int? showingRoleForSeat;
  final bool hasKillInLastNight;
  final int eliminationVotes;final List<int> tiedSeats;
  final int currentTieIndex;
  

  const GameState({
    required this.game,
    required this.players,
    required this.currentPhase,
    required this.currentSubPhase,
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
    this.showingRoleForSeat,
    this.hasKillInLastNight = false,
    this.eliminationVotes = 0,
  });

  factory GameState.initial() {
    return GameStateInitializer.initial();
  }

  static GameState fromJson(Map<String, dynamic> json) {
    return GameStateSerialization.fromJson(json);
  }
  
  GameState copyWith({
    Game? game,
    List<PlayerModel>? players,
    Phase? currentPhase,
    SubPhase? currentSubPhase,
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
    int? showingRoleForSeat,
    bool? hasKillInLastNight,
    int? eliminationVotes,
  }) {
    return GameState(
      game: game ?? this.game,
      players: players ?? this.players,
      currentPhase: currentPhase ?? this.currentPhase,
      currentSubPhase: currentSubPhase ?? this.currentSubPhase,
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
      showingRoleForSeat: showingRoleForSeat, // ✅ БЕЗ ?? чтобы можно было сбросить в null
      hasKillInLastNight: hasKillInLastNight ?? this.hasKillInLastNight,
      eliminationVotes: eliminationVotes ?? this.eliminationVotes,
    );
  }

  PlayerModel? getPlayerBySeat(int seatNumber) {
    try {
      return players.firstWhere((p) => p.seatNumber == seatNumber);
    } catch (e) {
      return null;
    }
  }
}