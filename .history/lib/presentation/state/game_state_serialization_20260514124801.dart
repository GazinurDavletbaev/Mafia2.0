import 'package:mafia_help/data/local/models/best_move.dart';
import 'package:mafia_help/data/local/models/game_log.dart';
import 'package:mafia_help/data/local/models/game.dart';
import 'package:mafia_help/data/local/models/kill.dart';
import 'package:mafia_help/data/local/models/phase.dart';
import 'package:mafia_help/data/local/models/player_model.dart';
import 'package:mafia_help/data/local/models/vote.dart';
import 'package:mafia_help/data/local/models/sub_phase.dart';
import 'package:mafia_help/domain/entities/phase_stack.dart';
import 'package:mafia_help/domain/entities/speech_stack.dart';
import 'package:mafia_help/domain/entities/vote_stack.dart';
import 'game_state.dart';

extension GameStateSerialization on GameState {
  Map<String, dynamic> toJson() {
    return {
      'game': game?.toJson(),
      'players': players.map((p) => p.toJson()).toList(),
      'currentPhase': currentPhase.index,
      'currentSubPhase': currentSubPhase.index,
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
      'showingRoleForSeat': showingRoleForSeat,
      'hasKillInLastNight': hasKillInLastNight,
      'eliminationVotes': eliminationVotes,
      'tiedSeats': tiedSeats,
      'currentTieIndex': currentTieIndex,
      'dayStarterSeat': dayStarterSeat,
      'voteController': null,
      'isVotingActive': isVotingActive,
      'phaseStack': phaseStack.history,
      'speechStack': speechStack.history,
      'voteStack': voteStack.history,
    };
  }

  static GameState fromJson(Map<String, dynamic> json) {
    final playersList = json['players'] as List<dynamic>;
    final players = playersList.map((p) {
      final map = Map<String, dynamic>.from(p as Map<dynamic, dynamic>);
      return PlayerModel.fromJson(map);
    }).toList();

    final pendingKillsList = json['pendingKills'] as List<dynamic>? ?? [];
    final pendingKills = pendingKillsList.map((k) {
      final map = Map<String, dynamic>.from(k as Map<dynamic, dynamic>);
      return Kill.fromJson(map);
    }).toList();

    final pendingBestMovesList = json['pendingBestMoves'] as List<dynamic>? ?? [];
    final pendingBestMoves = pendingBestMovesList.map((b) {
      final map = Map<String, dynamic>.from(b as Map<dynamic, dynamic>);
      return BestMove.fromJson(map);
    }).toList();

    final pendingVotesList = json['pendingVotes'] as List<dynamic>? ?? [];
    final pendingVotes = pendingVotesList.map((v) {
      final map = Map<String, dynamic>.from(v as Map<dynamic, dynamic>);
      return Vote.fromJson(map);
    }).toList();

    final pendingLogsList = json['pendingLogs'] as List<dynamic>? ?? [];
    final pendingLogs = pendingLogsList.map((l) {
      final map = Map<String, dynamic>.from(l as Map<dynamic, dynamic>);
      return GameLog.fromJson(map);
    }).toList();

    final phaseStackHistory = json['phaseStack'] as List<dynamic>? ?? [];
final phaseStack = PhaseStack();
for (final phase in phaseStackHistory) {
  if (phase is SubPhase) {
    phaseStack.push(phase);
  } else if (phase is int) {
    // Если сохранился как индекс enum
    phaseStack.push(SubPhase.values[phase]);
  }
}

    final speechStackHistory = json['speechStack'] as List<dynamic>? ?? [];
    final speechStack = SpeechStack();
    speechStack.history.addAll(speechStackHistory.cast<int>());

    final voteStackHistory = json['voteStack'] as List<dynamic>? ?? [];
    final voteStack = VoteStack();
    for (final votes in voteStackHistory) {
      voteStack.push(votes as Map<int, int>);
    }

    return GameState(
      game: json['game'] != null 
          ? Game.fromJson(Map<String, dynamic>.from(json['game'] as Map<dynamic, dynamic>))
          : null,
      players: players,
      currentPhase: Phase.values[json['currentPhase']],
      currentSubPhase: SubPhase.values[json['currentSubPhase']],
      currentSubPhaseIndex: json['currentSubPhaseIndex'],
      currentDay: json['currentDay'],
      currentSpeakerSeat: json['currentSpeakerSeat'],
      nominatedSeats: List<int>.from(json['nominatedSeats']),
      votes: Map<int, int>.from(json['votes']),
      partialBestMove: List<int>.from(json['partialBestMove']),
      isGameEnded: json['isGameEnded'],
      winner: json['winner'],
      currentRound: json['currentRound'],
      pendingKills: pendingKills,
      pendingBestMoves: pendingBestMoves,
      pendingVotes: pendingVotes,
      pendingLogs: pendingLogs,
      showingRoleForSeat: json['showingRoleForSeat'],
      hasKillInLastNight: json['hasKillInLastNight'] ?? false,
      eliminationVotes: json['eliminationVotes'] ?? 0,
      tiedSeats: List<int>.from(json['tiedSeats'] ?? []),
      currentTieIndex: json['currentTieIndex'] ?? 0,
      dayStarterSeat: json['dayStarterSeat'],
      voteController: null,
      isVotingActive: json['isVotingActive'] ?? false,
      phaseStack: phaseStack,
      speechStack: speechStack,
      voteStack: voteStack,
    );
  }
}