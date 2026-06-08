
import 'package:flutter_test/flutter_test.dart';
import 'package:mafia_help/domain/rules/win_rules.dart';

void main() {
  group('WinRules', () {
    test('Красные побеждают, когда нет чёрных', () {
      final rules = WinRules();
      final result = rules.check(
        blackAlive: 0,
        redAlive: 3,
        totalAlive: 3,
      );
      expect(result, true);
    });

    test('Чёрные побеждают, когда красных меньше или равно', () {
      final rules = WinRules();
      final result = rules.check(
        blackAlive: 2,
        redAlive: 2,
        totalAlive: 4,
      );
      expect(result, false);
    });

    test('Чёрные побеждают, когда живых меньше 3', () {
      final rules = WinRules();
      final result = rules.check(
        blackAlive: 1,
        redAlive: 1,
        totalAlive: 2,
      );
      expect(result, false);
    });

    test('Игра продолжается, если условия не выполнены', () {
      final rules = WinRules();
      final result = rules.check(
        blackAlive: 2,
        redAlive: 3,
        totalAlive: 5,
      );
      expect(result, null);
    });
  });
}
