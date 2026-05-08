import 'package:mafia_help/presentation/state/game_state.dart';

class VoteCalculator {
  /// Проверка, равный ли счёт голосов
  static bool isTie(GameState state) {
    final values = state.votes.values.toList();
    if (values.isEmpty) return false;
    final max = values.reduce((a, b) => a > b ? a : b);
    return values.where((v) => v == max).length > 1;
  }

  /// Проверка, есть ли победитель (один кандидат набрал больше всех)
  static bool hasWinner(GameState state) {
    final values = state.votes.values.toList();
    if (values.isEmpty) return false;
    final max = values.reduce((a, b) => a > b ? a : b);
    return values.where((v) => v == max).length == 1;
  }

  /// Получить место победителя
  static int getWinnerSeat(GameState state) {
    final maxVotes = state.votes.values.reduce((a, b) => a > b ? a : b);
    return state.votes.entries.firstWhere(
      (e) => e.value == maxVotes,
      orElse: () => const MapEntry(0, 0),
    ).key;
  }

  /// Получить список мест с равными голосами (для перестрелки)
  static List<int> getTiedSeats(GameState state) {
    final values = state.votes.values.toList();
    if (values.isEmpty) return [];
    final max = values.reduce((a, b) => a > b ? a : b);
    return state.votes.entries
        .where((e) => e.value == max)
        .map((e) => e.key)
        .toList();
  }

  /// Проверка, что за подъём проголосовало больше половины живых игроков
  static bool isEliminationPassed(GameState state) {
    final aliveCount = state.players.where((p) => p.isAlive).length;
    return state.eliminationVotes > (aliveCount / 2);
  }
}