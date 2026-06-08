import 'package:flutter_test/flutter_test.dart';
import 'package:mafia_help/domain/rules/speech_rules.dart';

void main() {
  group('SpeechRules', () {
    late SpeechRules rules;

    setUp(() {
      rules = SpeechRules();
    });

    group('buildSpeechQueue', () {
      test('без lastSpeaker возвращает отсортированный список', () {
        final queue = rules.buildSpeechQueue(
          aliveSeats: [5, 2, 8, 1],
          lastSpeakerOfPreviousDay: null,
        );
        expect(queue, [1, 2, 5, 8]);
      });

      test('c lastSpeaker начинает со следующего', () {
        final queue = rules.buildSpeechQueue(
          aliveSeats: [1, 2, 3, 4, 5],
          lastSpeakerOfPreviousDay: 3,
        );
        expect(queue, [4, 5, 1, 2, 3]);
      });

      test('lastSpeaker не в списке игнорируется', () {
        final queue = rules.buildSpeechQueue(
          aliveSeats: [1, 2, 3, 4, 5],
          lastSpeakerOfPreviousDay: 10,
        );
        expect(queue, [1, 2, 3, 4, 5]);
      });
    });

    group('findNextSpeaker', () {
      test('находит следующего живого по порядку', () {
        final next = rules.findNextSpeaker(
          currentSpeaker: 3,
          aliveSeats: [1, 2, 3, 4, 5],
          speechHistory: [1, 2, 3],
        );
        expect(next, 4);
      });

      test('зацикливается в начало', () {
        final next = rules.findNextSpeaker(
          currentSpeaker: 5,
          aliveSeats: [1, 2, 3, 4, 5],
          speechHistory: [1, 2, 3, 4, 5],
        );
        expect(next, null);
      });

      test('пропускает мёртвых', () {
        final next = rules.findNextSpeaker(
          currentSpeaker: 2,
          aliveSeats: [1, 3, 5, 7, 9],
          speechHistory: [1],
        );
        expect(next, 3);
      });

      test('возвращает null если все живые уже говорили', () {
        final next = rules.findNextSpeaker(
          currentSpeaker: 5,
          aliveSeats: [1, 3, 5],
          speechHistory: [1, 3, 5],
        );
        expect(next, null);
      });
    });
  });
}
