import 'package:mafia_help/data/local/models/phase.dart';
import 'package:mafia_help/data/local/models/player_model.dart';
import 'package:mafia_help/data/local/models/sub_phase.dart';
import 'package:mafia_help/presentation/widgets/player_timer_type.dart';
import '../../data/local/models/game.dart';
import 'game_state.dart';
import 'vote_day.dart';

extension GameStateSerialization on GameState {
  Map<String, dynamic> toJson() {
    // Сериализуем voteHistory: Map<int, VoteDay> → Map<String, dynamic>
    final voteHistoryJson = <String, dynamic>{};
    voteHistory.forEach((day, voteDay) {
      voteHistoryJson[day.toString()] = voteDay.toJson();
    });

    return {
      'game': game?.toJson(),
      'players': players.map((p) => p.toJson()).toList(),
      'currentPhase': currentPhase.index,
      'currentSubPhase': currentSubPhase.index,
      'currentSubPhaseIndex': currentSubPhaseIndex,
      'currentDay': currentDay,
      'currentSpeakerSeat': currentSpeakerSeat,
      'nominatedSeats': nominatedSeats,
      'removedPlayers': players.map((p) => p.toJson()).toList(),
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
      'voteHistory': voteHistoryJson, // ← новый формат
      'isBestMove': isBestMove,
      'isVotingDay': isVotingDay,
      'currentSpeakerTimer': currentSpeakerTimer?.index,
      'tableNumber': tableNumber,
      'gameNumber': gameNumber,
      'gameDate': gameDate?.toIso8601String(),
      'judgeName': judgeName,
      'tournamentName': tournamentName,
      'stageName': stageName,
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
            .toList() ??
        [];

    final speechHistory =
        (json['speechHistory'] as List<dynamic>?)?.cast<int>() ?? [];

    // Десериализуем voteHistory: Map<String, dynamic> → Map<int, VoteDay>
    final voteHistory = <int, VoteDay>{};
    final voteHistoryJson = json['voteHistory'] as Map<String, dynamic>? ?? {};
    voteHistoryJson.forEach((dayStr, dayData) {
      final day = int.parse(dayStr);
      voteHistory[day] = VoteDay.fromJson(dayData as Map<String, dynamic>);
    });

    // Читаем currentSpeakerTimer из JSON
    PlayerTimerType? currentSpeakerTimer;
    if (json['currentSpeakerTimer'] != null) {
      currentSpeakerTimer = PlayerTimerType.values[json['currentSpeakerTimer']];
    }

    // Читаем gameDate из JSON
    DateTime? gameDate;
    if (json['gameDate'] != null) {
      gameDate = DateTime.parse(json['gameDate']);
    }

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
      hasKillInLastNight: json['hasKillInLastNight'] ?? false,
      eliminationVotes: json['eliminationVotes'] ?? 0,
      tiedSeats: List<int>.from(json['tiedSeats'] ?? []),
      currentTieIndex: json['currentTieIndex'] ?? 0,
      dayStarterSeat: json['dayStarterSeat'],
      voteController: null,
      isVotingActive: json['isVotingActive'] ?? false,
      nightActions: List<int>.from(json['nightActions'] ?? []),
      phaseHistory: phaseHistory,
      speechHistory: speechHistory,
      voteHistory: voteHistory, // ← новый формат
      isBestMove: json['isBestMove'] ?? false,
      isVotingDay: json['isVotingDay'] ?? true,
      currentSpeakerTimer: currentSpeakerTimer,
      tableNumber: json['tableNumber'],
      gameNumber: json['gameNumber'],
      gameDate: gameDate,
      judgeName: json['judgeName'],
      tournamentName: json['tournamentName'],
      stageName: json['stageName'],
    );
  }
}
