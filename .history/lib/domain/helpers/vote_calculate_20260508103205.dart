import 'package:mafia_help/presentation/state/game_state.dart';

class VoteCalculator {
  /// Проверка, равный ли счёт голосов
  static bool isTie(GameState state) {
    final voteValues = state.votes.values.toList();
    if (voteValues.isEmpty) return false;
    final maxVotes = voteValues.reduce((a, b) => a > b ? a : b);
    final countWithMax = voteValues.where((v) => v == maxVotes).length;
    return countWithMax > 1;
  }

  /// Проверка, есть ли победитель (один кандидат набрал больше всех)
  static bool hasWinner(GameState state) {
    final voteValues = state.votes.values.toList();
    if (voteValues.isEmpty) return false;
    final maxVotes = voteValues.reduce((a, b) => a > b ? a : b);
    final countWithMax = voteValues.where((v) => v == maxVotes).length;
    return countWithMax == 1;
  }

  /// Проверка, что за подъём проголосовало больше половины
  static bool isEliminationPassed(GameState state) {
    final aliveCount = state.players.where((p) => p.isAlive).length;
    return state.eliminationVotes > (aliveCount / 2);
  }
}