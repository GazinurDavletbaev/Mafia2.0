import 'package:flutter_test/flutter_test.dart';
import 'package:mafia_help/domain/rules/voting_rules.dart';

void main() {
  group('VotingRules', () {
    late VotingRules rules;

    setUp(() {
      rules = VotingRules();
    });

    group('findLeaders', () {
      test('возвращает лидеров с максимальными голосами', () {
        final votes = {1: 5, 2: 3, 3: 5, 4: 2};
        final leaders = rules.findLeaders(votes);
        expect(leaders, [1, 3]);
      });

      test('возвращает одного лидера', () {
        final votes = {1: 7, 2: 3, 3: 2};
        final leaders = rules.findLeaders(votes);
        expect(leaders, [1]);
      });

      test('пустой словарь → пустой список', () {
        final leaders = rules.findLeaders({});
        expect(leaders, []);
      });
    });

    group('needsVoting', () {
      test('день 0, 1 кандидат → false', () {
        final result = rules.needsVoting(
          dayNumber: 0,
          nominatedSeats: [5],
        );
        expect(result, false);
      });

      test('день 0, 2+ кандидата → true', () {
        final result = rules.needsVoting(
          dayNumber: 0,
          nominatedSeats: [1, 2],
        );
        expect(result, true);
      });

      test('день 1+, 1 кандидат → true', () {
        final result = rules.needsVoting(
          dayNumber: 1,
          nominatedSeats: [5],
        );
        expect(result, true);
      });
    });

    group('shouldSkipToNight', () {
      test('день 0, 1 кандидат → true', () {
        final result = rules.shouldSkipToNight(0, [5]);
        expect(result, true);
      });

      test('день 0, 2 кандидата → false', () {
        final result = rules.shouldSkipToNight(0, [1, 2]);
        expect(result, false);
      });

      test('день 1, 1 кандидат → false', () {
        final result = rules.shouldSkipToNight(1, [5]);
        expect(result, false);
      });
    });

    group('needsTieBreak', () {
      test('количество уменьшилось → true', () {
        final result = rules.needsTieBreak(
          currentLeaders: [1, 2],
          previousLeaders: [1, 2, 3],
          tieBreakDone: false,
        );
        expect(result, true);
      });

      test('не изменилось и перестрелки не было → true', () {
        final result = rules.needsTieBreak(
          currentLeaders: [1, 2],
          previousLeaders: [1, 2],
          tieBreakDone: false,
        );
        expect(result, true);
      });

      test('не изменилось и перестрелка была → false', () {
        final result = rules.needsTieBreak(
          currentLeaders: [1, 2],
          previousLeaders: [1, 2],
          tieBreakDone: true,
        );
        expect(result, false);
      });
    });

    group('needsEliminationVote', () {
      test('не изменилось и перестрелка была → true', () {
        final result = rules.needsEliminationVote(
          currentLeaders: [1, 2],
          previousLeaders: [1, 2],
          tieBreakDone: true,
        );
        expect(result, true);
      });

      test('не изменилось и перестрелки не было → false', () {
        final result = rules.needsEliminationVote(
          currentLeaders: [1, 2],
          previousLeaders: [1, 2],
          tieBreakDone: false,
        );
        expect(result, false);
      });

      test('изменилось → false', () {
        final result = rules.needsEliminationVote(
          currentLeaders: [1],
          previousLeaders: [1, 2],
          tieBreakDone: true,
        );
        expect(result, false);
      });
    });

    group('isEliminated', () {
      test('голосов больше половины → true', () {
        expect(rules.isEliminated(6, 10), true); // 6 > 5
      });

      test('голосов ровно половина → false', () {
        expect(rules.isEliminated(5, 10), false);
      });

      test('голосов меньше половины → false', () {
        expect(rules.isEliminated(4, 10), false);
      });
    });
  });
}
