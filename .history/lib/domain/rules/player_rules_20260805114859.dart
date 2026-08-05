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

  /// Добавить технический фол. После 2 тех. фолов — удаление.
  PlayerModel addTechFoul(PlayerModel player) {
    // Если игрок мёртв — ничего не делаем
    if (!player.isAlive) return player;

    final newTechFouls = player.techFouls + 1;

    // После 2 тех. фолов — удаление
    if (newTechFouls >= 2) {
      return player.copyWith(
        techFouls: newTechFouls,
        isAlive: false,
      );
    }

    return player.copyWith(techFouls: newTechFouls);
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