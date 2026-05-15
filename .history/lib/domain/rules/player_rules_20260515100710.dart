import '../../data/local/models/player_model.dart';

class PlayerRules {
  /// Добавить фол. Возвращает нового игрока.
  PlayerModel addFoul(PlayerModel player) {
    // Если игрок мёртв и у него 4 фола → воскрешение
    if (!player.isAlive && player.fouls == 4) {
      return player.copyWith(fouls: 0, isAlive: true);
    }

    if (!player.isAlive) return player;

    final newFouls = player.fouls + 1;

    if (newFouls == 4) {
      return player.copyWith(fouls: newFouls, isAlive: false);
    }

    if (newFouls == 5) {
      return player.copyWith(fouls: 0, isAlive: true);
    }

    return player.copyWith(fouls: newFouls);
  }

  /// Убить игрока
  PlayerModel kill(PlayerModel player) {
    if (!player.isAlive) return player;
    return player.copyWith(isAlive: false);
  }

  /// Воскресить игрока
  PlayerModel revive(PlayerModel player) {
    if (player.isAlive) return player;
    return player.copyWith(isAlive: true);
  }
}
