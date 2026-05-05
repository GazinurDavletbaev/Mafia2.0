import 'package:mafia_help/data/local/models/best_move.dart';
import 'package:mafia_help/data/local/models/game_log.dart';
import 'package:mafia_help/data/local/models/game.dart';
import 'package:mafia_help/data/local/models/kill.dart';
import 'package:mafia_help/data/local/models/phase.dart';
import 'package:mafia_help/data/local/models/player_model.dart';
import 'package:mafia_help/data/local/models/vote.dart';
import '../../data/local/models/sub_phase.dart';
import 'package:mafia_help/presentation/stategame_state_initializer.dart';

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
  });

  factory GameState.initial() {
    return _GameStateInitializer.initial();
  }
}