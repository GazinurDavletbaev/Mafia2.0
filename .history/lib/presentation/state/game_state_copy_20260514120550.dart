import 'package:mafia_help/data/local/models/best_move.dart';
import 'package:mafia_help/data/local/models/game_log.dart';
import 'package:mafia_help/data/local/models/game.dart';
import 'package:mafia_help/data/local/models/kill.dart';
import 'package:mafia_help/data/local/models/phase.dart';
import 'package:mafia_help/data/local/models/player_model.dart';
import 'package:mafia_help/data/local/models/vote.dart';
import 'package:mafia_help/domain/entities/phase_stack.dart';
import 'package:mafia_help/domain/entities/speech_stack.dart';
import 'package:mafia_help/domain/entities/vote_stack.dart';
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
    List<Kill>? pendingKills,
    List<BestMove>? pendingBestMoves,
    List<Vote>? pendingVotes,
    List<GameLog>? pendingLogs,
    int? showingRoleForSeat,
    bool? hasKillInLastNight,
    int? eliminationVotes,
    List<int>? tiedSeats,
    int? currentTieIndex,
    int? dayStarterSeat,
    VoteController? voteController,
    bool? isVotingActive,
    PhaseStack? phaseStack,
    SpeechStack? speechStack,
    VoteStack? voteStack,
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
      showingRoleForSeat: showingRoleForSeat,
      hasKillInLastNight: hasKillInLastNight ?? this.hasKillInLastNight,
      eliminationVotes: eliminationVotes ?? this.eliminationVotes,
      tiedSeats: tiedSeats ?? this.tiedSeats,
      currentTieIndex: currentTieIndex ?? this.currentTieIndex,
      dayStarterSeat: dayStarterSeat ?? this.dayStarterSeat,
      voteController: voteController ?? this.voteController,
      isVotingActive: isVotingActive ?? this.isVotingActive,
      phaseStack: phaseStack ?? this.phaseStack,
      speechStack: speechStack ?? this.speechStack,
      voteStack: voteStack ?? this.voteStack,
    );
  }
}