import 'package:mafia_help/presentation/state/game_state.dart';

class GameRuleChecker {
  static bool hasKillInLastNight(GameState state) {
    return state.hasKillInLastNight;
  }

  static int getCandidatesCount(GameState state) {
    return state.nominatedSeats.length;
  }

  static bool hasValidCandidatesForVoting(GameState state) {
    return getCandidatesCount(state) >= 2;
  }
}