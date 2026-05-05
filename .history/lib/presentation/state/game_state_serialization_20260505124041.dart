import 'package:mafia_help/data/local/models/best_move.dart';
import 'package:mafia_help/data/local/models/game_log.dart';
import 'package:mafia_help/data/local/models/game.dart';
import 'package:mafia_help/data/local/models/kill.dart';
import 'package:mafia_help/data/local/models/phase.dart';
import 'package:mafia_help/data/local/models/player_model.dart';
import 'package:mafia_help/data/local/models/vote.dart';
import 'package:mafia_help/data/local/models/sub_phase.dart';
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
    };
  }

  static GameState fromJson(Map<String, dynamic> json) {
    final playersList = json['players'] as List;
    final players = playersList.map((p) {
      if (p is Map<String, dynamic>) {
        return PlayerModel.fromJson(p);
      } else {
        return PlayerModel.fromJson(Map<String, dynamic>.from(p));
      }
    }).toList();

    return GameState(
      game: json['game'] != null ? Game.fromJson(json['game']) : null,
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
      pendingKills: (json['pendingKills'] as List).map((k) => Kill.fromJson(k)).toList(),
      pendingBestMoves: (json['pendingBestMoves'] as List).map((b) => BestMove.fromJson(b)).toList(),
      pendingVotes: (json['pendingVotes'] as List).map((v) => Vote.fromJson(v)).toList(),
      pendingLogs: (json['pendingLogs'] as List).map((l) => GameLog.fromJson(l)).toList(),
      showingRoleForSeat: json['showingRoleForSeat'],
    );
  }
}