import 'package:mafia_help/core/logger/app_logger.dart';
import 'package:mafia_help/data/local/models/phase.dart';
import 'package:mafia_help/data/local/models/player_model.dart';
import 'package:mafia_help/data/local/models/sub_phase.dart';
import 'game_state.dart';

class GameStateInitializer {
  static GameState initial() {
    AppLogger.d('GameState.initial() called');

    const names = [
      'Алексей', 'Дмитрий', 'Максим', 'Иван', 'Сергей',
      'Анна', 'Елена', 'Мария', 'Татьяна', 'Ольга'
    ];
    
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
      );
    });

    AppLogger.d('Setting currentSubPhase = SubPhase.roleDistribution');
    final playersWithRoles = _assignRoles(players);

    return GameState(
      game: null,
      players: playersWithRoles,
      currentPhase: Phase.night,
      currentSubPhase: SubPhase.roleDistribution,
      currentSubPhaseIndex: 0,
      currentDay: 1,
      currentSpeakerSeat: null,
      nominatedSeats: [],
      votes: {},
      partialBestMove: [],
      isGameEnded: false,
      winner: null,
      currentRound: 1,
      pendingKills: [],
      pendingBestMoves: [],
      pendingVotes: [],
      pendingLogs: [],
      showingRoleForSeat: null,
    );
  }

  static List<PlayerModel> _assignRoles(List<PlayerModel> players) {
    const roles = ['don', 'mafia', 'mafia', 'sheriff', 'citizen', 'citizen', 'citizen', 'citizen', 'citizen', 'citizen'];
    final shuffled = List.of(roles)..shuffle();
    
    final result = List<PlayerModel>.from(players);
    for (int i = 0; i < result.length; i++) {
      result[i] = result[i].copyWith(role: shuffled[i]);
    }
    return result;
  }
}