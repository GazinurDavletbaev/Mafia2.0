// lib/presentation/state/game_state.dart
import 'package:mafia_help/data/local/models/phase.dart';
import 'package:mafia_help/data/local/models/player_model.dart';
import 'package:mafia_help/presentation/widgets/player_timer_type.dart';
import '../../data/local/models/game.dart';
import '../../data/local/models/sub_phase.dart';
import '../../domain/helpers/vote_controller.dart';
import 'game_state_initializer.dart';
import 'game_state_serialization.dart';
import 'vote_day.dart';


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
  final int? showingRoleForSeat;
  final bool hasKillInLastNight;
  final int eliminationVotes;
  final List<int> tiedSeats;
  final int currentTieIndex;
  final int? dayStarterSeat;
  final VoteController? voteController;
  final bool isVotingActive;
  final bool isBestMove;
  final bool isVotingDay;
  final PlayerTimerType? currentSpeakerTimer;
  final int? tableNumber;
  final int? gameNumber;
  final DateTime? gameDate;
  final String? judgeName;
  final String? tournamentName;
  final String? stageName;

  // Ночные действия: [kill, donCheck, sheriffCheck, kill, donCheck, sheriffCheck, ...]
  final List<int>? nightActions;

  // История вместо стеков
  final List<SubPhase> phaseHistory;
  final List<int> speechHistory;
  final Map<int, VoteDay> voteHistory;  // день → VoteDay

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
    this.showingRoleForSeat,
    this.hasKillInLastNight = false,
    this.eliminationVotes = 0,
    this.tiedSeats = const [],
    this.currentTieIndex = 0,
    this.dayStarterSeat,
    this.voteController,
    this.isVotingActive = false,
    this.nightActions = const [],
    required this.phaseHistory,
    required this.speechHistory,
    required this.voteHistory,
    required this.isBestMove,
    required this.isVotingDay,
    this.currentSpeakerTimer,
    this.tableNumber,
    this.gameNumber,
    this.gameDate,
    this.judgeName,
    this.tournamentName,
    this.stageName,
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
    int? showingRoleForSeat,
    bool? hasKillInLastNight,
    int? eliminationVotes,
    List<int>? tiedSeats,
    int? currentTieIndex,
    int? dayStarterSeat,
    VoteController? voteController,
    bool? isVotingActive,
    List<int>? nightActions,
    List<SubPhase>? phaseHistory,
    List<int>? speechHistory,
    List<Map<int, int>>? voteHistory,
    bool? isBestMove,
    bool? isVotingDay,
    PlayerTimerType? currentSpeakerTimer,
    int? tableNumber,
    int? gameNumber,
    DateTime? gameDate,
    String? judgeName,
    String? tournamentName,
    String? stageName,
  }) {
    return GameState(
      game: game ?? this.game,
      players: players ?? this.players,
      currentPhase: currentPhase ?? this.currentPhase,
      currentSubPhase: currentSubPhase ?? this.currentSubPhase,
      currentSubPhaseIndex: currentSubPhaseIndex ?? this.currentSubPhaseIndex,
      currentDay: currentDay ?? this.currentDay,
      currentSpeakerSeat: currentSpeakerSeat == -1
          ? null
          : (currentSpeakerSeat ?? this.currentSpeakerSeat),
      nominatedSeats: nominatedSeats ?? this.nominatedSeats,
      votes: votes ?? this.votes,
      partialBestMove: partialBestMove ?? this.partialBestMove,
      isGameEnded: isGameEnded ?? this.isGameEnded,
      winner: winner ?? this.winner,
      currentRound: currentRound ?? this.currentRound,
      showingRoleForSeat: showingRoleForSeat,
      hasKillInLastNight: hasKillInLastNight ?? this.hasKillInLastNight,
      eliminationVotes: eliminationVotes ?? this.eliminationVotes,
      tiedSeats: tiedSeats ?? this.tiedSeats,
      currentTieIndex: currentTieIndex ?? this.currentTieIndex,
      dayStarterSeat: dayStarterSeat ?? this.dayStarterSeat,
      voteController: voteController ?? this.voteController,
      isVotingActive: isVotingActive ?? this.isVotingActive,
      nightActions: nightActions ?? this.nightActions,
      phaseHistory: phaseHistory ?? this.phaseHistory,
      speechHistory: speechHistory ?? this.speechHistory,
      voteHistory: voteHistory ?? this.voteHistory,
      isBestMove: isBestMove ?? this.isBestMove,
      isVotingDay: isVotingDay ?? this.isVotingDay,
      currentSpeakerTimer: currentSpeakerTimer ?? this.currentSpeakerTimer,
      tableNumber: tableNumber ?? this.tableNumber,
      gameNumber: gameNumber ?? this.gameNumber,
      gameDate: gameDate ?? this.gameDate,
      judgeName: judgeName ?? this.judgeName,
      tournamentName: tournamentName ?? this.tournamentName,
      stageName: stageName ?? this.stageName,
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
