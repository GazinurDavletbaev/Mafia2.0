import 'package:flutter_test/flutter_test.dart';
import 'package:mafia_help/domain/rules/player_rules.dart';
import 'package:mafia_help/data/local/models/player_model.dart';

void main() {
  group('PlayerRules', () {
    late PlayerRules rules;
    late PlayerModel player;

    setUp(() {
      rules = PlayerRules();
      player = PlayerModel(
        id: '1',
        seatNumber: 1,
        name: 'Test',
        team: 'red',
        role: 'citizen',
        isAlive: true,
        fouls: 0,
        isSpeaking: false,
        gameId: 'test',
      );
    });

    test('0 → 1', () {
      final result = rules.addFoul(player);
      expect(result.fouls, 1);
      expect(result.isAlive, true);
    });

    test('1 → 2', () {
      final playerWithFouls = player.copyWith(fouls: 1);
      final result = rules.addFoul(playerWithFouls);
      expect(result.fouls, 2);
      expect(result.isAlive, true);
    });

    test('2 → 3', () {
      final playerWithFouls = player.copyWith(fouls: 2);
      final result = rules.addFoul(playerWithFouls);
      expect(result.fouls, 3);
      expect(result.isAlive, true);
    });

    test('3 → 4 (смерть)', () {
      final playerWithFouls = player.copyWith(fouls: 3);
      final result = rules.addFoul(playerWithFouls);
      expect(result.fouls, 4);
      expect(result.isAlive, false);
    });

    test('Мёртвый с 4 фолами → воскрешение до 0', () {
      final deadPlayer = player.copyWith(fouls: 4, isAlive: false);
      final result = rules.addFoul(deadPlayer);
      expect(result.fouls, 0);
      expect(result.isAlive, true);
    });

    test('Живой с 5 фолами → сброс до 0', () {
      final alivePlayer = player.copyWith(fouls: 5, isAlive: true);
      final result = rules.addFoul(alivePlayer);
      expect(result.fouls, 0);
      expect(result.isAlive, true);
    });
  });
}
