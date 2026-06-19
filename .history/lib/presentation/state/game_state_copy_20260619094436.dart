// lib/presentation/state/game_state_copywith.dart

import 'package:mafia_help/data/local/models/phase.dart';
import 'package:mafia_help/data/local/models/player_model.dart';
import 'package:mafia_help/presentation/widgets/player_timer_type.dart';
import '../../data/local/models/game.dart';
import '../../data/local/models/sub_phase.dart';
import '../../domain/helpers/vote_controller.dart';
import 'game_state.dart';

extension GameStateCopyWith on GameState {
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
    );
  }
}
