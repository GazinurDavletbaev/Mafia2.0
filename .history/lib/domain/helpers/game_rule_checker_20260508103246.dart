import 'package:mafia_help/presentation/state/game_state.dart';

class GameRuleChecker {
  /// Было ли убийство в последнюю ночь (мафия стреляла и попала)
  static bool hasKillInLastNight(GameState state) {
    return state.hasKillInLastNight;
  }

  /// Количество выставленных кандидатов
  static int getCandidatesCount(GameState state) {
    return state.nominatedSeats.length;
  }

  /// Есть ли кандидаты для голосования (1 или 0 — голосование не проводится)
  static bool hasValidCandidatesForVoting(GameState state) {
    final count = getCandidatesCount(state);
    return count >= 2;
  }
}