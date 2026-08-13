// lib/domain/helpers/protocol_helper.dart
import 'package:mafia_help/data/local/models/player_model.dart';
import 'package:mafia_help/domain/constants/protocol_constants.dart';
import 'package:mafia_help/presentation/state/game_state.dart';

class ProtocolHelper {
  // 🔥 РАСЧЁТ ОЧКОВ ИГРОКА
  static int calculatePoints(PlayerModel player, String? winner) {
    final isRedWon = winner == 'red';
    final team = player.team;
    return (isRedWon && team == 'red') || (!isRedWon && team == 'black') ? 1 : 0;
  }

  // 🔥 РАСЧЁТ БОНУСА ИГРОКА
  static double calculateBonus({
    required PlayerModel player,
    required GameState gameState,
    required List<double> bonusPoints,
    required Map<int, String> removedRuleMap,
  }) {
    final isRemoved = gameState.removedPlayers.any((rp) => rp.seatNumber == player.seatNumber);
    final hasPpk = gameState.ppkPlayerSeat == player.seatNumber;

    if (hasPpk) return -1.0;
    if (isRemoved) return -0.5;
    return bonusPoints[player.seatNumber - 1] ?? 0.0;
  }

  // 🔥 ПРОВЕРКА: УДАЛЁН ЛИ ИГРОК
  static bool isRemoved(PlayerModel player, GameState gameState) {
    return gameState.removedPlayers.any((rp) => rp.seatNumber == player.seatNumber);
  }

  // 🔥 ПРОВЕРКА: ЕСТЬ ЛИ ППК
  static bool hasPpk(PlayerModel player, GameState gameState) {
    return gameState.ppkPlayerSeat == player.seatNumber;
  }

  // 🔥 КОРОТКОЕ НАЗВАНИЕ РОЛИ
  static String getRoleShort(String role) {
    return ProtocolConstants.roleShortNames[role] ?? '?';
  }

  // 🔥 ФОРМАТИРОВАНИЕ БОНУСА
  static String formatBonus(double value) {
    if (value == 0) return '0';
    if (value == -1) return '-1';
    if (value == -0.5) return '-0.5';
    return value.toStringAsFixed(1);
  }

  // 🔥 ПОЛУЧИТЬ СТАТУС ИГРОКА
  static String getPlayerStatus(PlayerModel player, GameState gameState) {
    if (gameState.ppkPlayerSeat == player.seatNumber) {
      return ProtocolConstants.statusPpk;
    }
    if (gameState.removedPlayers.any((rp) => rp.seatNumber == player.seatNumber)) {
      return ProtocolConstants.statusRemoved;
    }
    return ProtocolConstants.statusActive;
  }
}