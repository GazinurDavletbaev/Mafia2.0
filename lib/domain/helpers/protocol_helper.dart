// lib/domain/helpers/protocol_helper.dart
import 'package:mafia_help/data/local/models/player_model.dart';
import 'package:mafia_help/domain/constants/protocol_constants.dart';
import 'package:mafia_help/presentation/state/game_state.dart';

class ProtocolHelper {
  // 🔥 РАСЧЁТ ОЧКОВ ИГРОКА
  static int calculatePoints(PlayerModel player, String? winner) {
    final isRedWon = winner == 'red';
    return (isRedWon && player.team == 'red') ||
           (!isRedWon && player.team == 'black')
        ? 1
        : 0;
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
}