// lib/presentation/state/game_state_initializer.dart

import 'package:mafia_help/core/logger/app_logger.dart';
import 'package:mafia_help/data/local/models/phase.dart';
import 'package:mafia_help/data/local/models/player_model.dart';
import 'package:mafia_help/data/local/models/sub_phase.dart';
import 'game_state.dart';

class GameStateInitializer {
  static GameState initial({List<String?>? playerNames}) {
    // Если имена не переданы, используем пустые строки
    final defaultNames = ['', '', '', '', '', '', '', '', '', ''];

    final names = List.generate(10, (index) {
      if (playerNames != null &&
          index < playerNames.length &&
          playerNames[index] != null &&
          playerNames[index]!.isNotEmpty) {
        return playerNames[index]!;
      }
      return defaultNames[index];
    });

    final players = List.generate(10, (index) {
      final seat = index + 1;
      return PlayerModel(
        id: 'player_$seat',
        seatNumber: seat,
        name: names[index],
        team: 'unknown',
        role: 'unknown',
        isAlive: true,
        fouls: 0,
        isSpeaking: false,
        gameId: '',
        hasSkippedSpeech: false,
        gotThirdFoulDuringSpeech: false,
      );
    });

    AppLogger.d('Setting currentSubPhase = SubPhase.roleDistribution');

    return GameState(
      game: null,
      players: players,
      currentPhase: Phase.night,
      currentSubPhase: SubPhase.roleDistribution,
      currentSubPhaseIndex: 0,
      currentDay: 0,
      currentSpeakerSeat: null,
      nominatedSeats: [],
      votes: {},
      partialBestMove: [],
      isGameEnded: false,
      winner: null,
      currentRound: 1,
      showingRoleForSeat: null,
      hasKillInLastNight: false,
      eliminationVotes: 0,
      tiedSeats: const [],
      currentTieIndex: 0,
      dayStarterSeat: null,
      voteController: null,
      isVotingActive: false,
      nightActions: const [],
      phaseHistory: [SubPhase.roleDistribution],
      speechHistory: [1, 2, 3, 4, 5, 6, 7, 8, 9, 10],
      voteHistory: [],
      isBestMove: true,
      isVotingDay: true,
      currentSpeakerTimer: null,
      tableNumber: null,
      gameNumber: null,
      gameDate: null,
      judgeName: null,
    );
  }

  // Метод для раздачи ролей (вызывается отдельно при старте игры)
  static List<PlayerModel> assignRoles(List<PlayerModel> players) {
    const roles = [
      'don',
      'mafia',
      'mafia',
      'sheriff',
      'citizen',
      'citizen',
      'citizen',
      'citizen',
      'citizen',
      'citizen',
    ];
    final shuffled = List.of(roles)..shuffle();

    final result = List<PlayerModel>.from(players);
    for (int i = 0; i < result.length; i++) {
      final role = shuffled[i];
      final team = _getTeamByRole(role);
      result[i] = result[i].copyWith(role: role, team: team);
    }
    return result;
  }

  static String _getTeamByRole(String role) {
    switch (role) {
      case 'don':
      case 'mafia':
        return 'black';
      case 'sheriff':
      case 'citizen':
        return 'red';
      default:
        return 'unknown';
    }
  }
}
