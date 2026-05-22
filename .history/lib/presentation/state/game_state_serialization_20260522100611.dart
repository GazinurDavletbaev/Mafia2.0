// lib/presentation/state/game_state_serialization.dart

import 'package:mafia_help/data/local/models/phase.dart';
import 'package:mafia_help/data/local/models/player_model.dart';
import 'package:mafia_help/data/local/models/sub_phase.dart';
import '../../data/local/models/game.dart';
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
      'showingRoleForSeat': showingRoleForSeat,
      'hasKillInLastNight': hasKillInLastNight,
      'eliminationVotes': eliminationVotes,
      'tiedSeats': tiedSeats,
      'currentTieIndex': currentTieIndex,
      'dayStarterSeat': dayStarterSeat,
      'voteController': null,
      'isVotingActive': isVotingActive,
      'nightActions': nightActions,
      'phaseHistory': phaseHistory.map((p) => p.index).toList(),
      'speechHistory': speechHistory,
      'voteHistory': voteHistory,
    };
  }

  static GameState fromJson(Map<String, dynamic> json) {
    final playersList = json['players'] as List<dynamic>;
    final players = playersList.map((p) {
      final map = Map<String, dynamic>.from(p as Map<dynamic, dynamic>);
      return PlayerModel.fromJson(map);
    }).toList();

    final phaseHistory = (json['phaseHistory'] as List<dynamic>?)
            ?.map((p) => SubPhase.values[p as int])
            .toList() ?? [];

    final speechHistory = (json['speechHistory'] as List<dynamic>?)?.cast<int>() ?? [];

    final voteHistory = (json['voteHistory'] as List<dynamic>?)
            ?.map((v) => Map<int, int>.from(v as Map<dynamic, dynamic>))
            .toList() ??
        [];

    return GameState(
      game: json['game'] != null
          ? Game.fromJson(
              Map<String, dynamic>.from(json['game'] as Map<dynamic, dynamic>),
            )
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
      showingRoleForSeat: json['showingRoleForSeat'],
      HasBe: json['hasKillInLastNight'] ?? false,
      eliminationVotes: json['eliminationVotes'] ?? 0,
      tiedSeats: List<int>.from(json['tiedSeats'] ?? []),
      currentTieIndex: json['currentTieIndex'] ?? 0,
      dayStarterSeat: json['dayStarterSeat'],
      voteController: null,
      isVotingActive: json['isVotingActive'] ?? false,
      nightActions: List<int>.from(json['nightActions'] ?? []),
      phaseHistory: phaseHistory,
      speechHistory: speechHistory,
      voteHistory: voteHistory,
    );
  }
}