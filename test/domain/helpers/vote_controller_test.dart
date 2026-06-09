import 'package:flutter_test/flutter_test.dart';
import 'package:mafia_help/domain/helpers/vote_controller.dart';

void main() {
  group('VoteController.determineResult', () {
    test('один победитель с большинством → winner', () {
      final votes = {1: 6, 2: 3, 3: 1};
      final result = VoteController.determineResult(
        votes,
        10,
        isRevote: false,
        previousTiedCount: 0,
      );

      expect(result.type, VoteResultType.winner);
      expect(result.winnerSeat, 1);
      expect(result.seats, [1]);
    });

    test('ничья, перестрелка (2 кандидата) → tieBreak', () {
      final votes = {1: 5, 2: 5, 3: 0};
      final result = VoteController.determineResult(
        votes,
        10,
        isRevote: false,
        previousTiedCount: 0,
      );

      expect(result.type, VoteResultType.tieBreak);
      expect(result.seats, [1, 2]);
    });

    test('ничья, перестрелка (3 кандидата) → tieBreak', () {
      final votes = {1: 4, 2: 4, 3: 4, 4: 0};
      final result = VoteController.determineResult(
        votes,
        12,
        isRevote: false,
        previousTiedCount: 0,
      );

      expect(result.type, VoteResultType.tieBreak);
      expect(result.seats, [1, 2, 3]);
    });

    test('переголосование, количество лидеров уменьшилось → tieBreak', () {
      final votes = {1: 5, 2: 5, 3: 0};
      final result = VoteController.determineResult(
        votes,
        10,
        isRevote: true,
        previousTiedCount: 3,
      );

      expect(result.type, VoteResultType.tieBreak);
      expect(result.seats, [1, 2]);
    });

    test('переголосование, количество лидеров не изменилось → eliminationVote',
        () {
      final votes = {1: 4, 2: 4, 3: 2};
      final result = VoteController.determineResult(
        votes,
        10,
        isRevote: true,
        previousTiedCount: 2,
      );

      expect(result.type, VoteResultType.eliminationVote);
      expect(result.seats, [1, 2]);
    });

    test('нет кандидатов → noCandidates', () {
      final votes = <int, int>{};
      final result = VoteController.determineResult(
        votes,
        10,
        isRevote: false,
        previousTiedCount: 0,
      );

      expect(result.type, VoteResultType.noCandidates);
    });
  });
}
