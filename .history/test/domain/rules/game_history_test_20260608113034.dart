import 'package:flutter_test/flutter_test.dart';
import 'package:mafia_help/domain/rules/game_history.dart';
import 'package:mafia_help/presentation/state/game_state.dart';

void main() {
  group('GameHistory', () {
    late GameHistory history;
    late GameState state1;
    late GameState state2;

    setUp(() {
      history = GameHistory();
      state1 = GameState.initial();
      state2 = GameState.initial().copyWith(currentDay: 1);
    });

    test('push() добавляет состояние', () {
      history.push(state1);
      expect(history.length, 1);
      expect(history.current, state1);
    });

    test('pop() возвращает предыдущее состояние', () {
      history.push(state1);
      history.push(state2);
      expect(history.length, 2);

      final previous = history.pop();
      expect(history.length, 1);
      expect(previous, state1);
    });

    test('pop() не удаляет последнее состояние', () {
      history.push(state1);
      history.pop();
      expect(history.length, 1);
      expect(history.current, state1);
    });

    test('canPop возвращает true если больше 1 состояния', () {
      history.push(state1);
      expect(history.canPop, false);

      history.push(state2);
      expect(history.canPop, true);
    });

    test('clear() очищает историю', () {
      history.push(state1);
      history.push(state2);
      history.clear();
      expect(history.length, 0);
    });
  });
}
