// test/presentation/widgets/player_grid_test.dart

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mafia_help/data/local/models/player_model.dart';
import 'package:mafia_help/data/local/models/sub_phase.dart';
import 'package:mafia_help/domain/helpers/vote_controller.dart';
import 'package:mafia_help/presentation/widgets/player_grid.dart';
import 'package:mafia_help/presentation/widgets/player_timer_type.dart';

void main() {
  group('PlayerGrid отображение кандидатов', () {
    late List<PlayerModel> players;

    setUp(() {
      players = List.generate(10, (i) {
        final seat = i + 1;
        return PlayerModel(
          id: 'p$seat',
          seatNumber: seat,
          name: 'Player $seat',
          team: 'red',
          role: 'citizen',
          isAlive: true,
          fouls: 0,
          isSpeaking: false,
          gameId: 'test',
          hasSkippedSpeech: false,
        );
      });
    });

    // Находим центральную колонку (второй ребёнок в Row)
    Finder getCenterColumn(WidgetTester tester) {
      final row = find.byType(Row).first;
      final rowElement = tester.element(row);
      final rowWidget = rowElement.widget as Row;
      final centerWidget = rowWidget.children[1];
      return find.byWidget(centerWidget);
    }

    testWidgets('voting — отображает nominatedSeats', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PlayerGrid(
              players: players,
              currentSpeaker: null,
              timerType: PlayerTimerType.none,
              currentSubPhase: SubPhase.voting,
              onTap: (_) {},
              onLongPress: (_) {},
              isVotingActive: true,
              voteController: VoteController([2, 5, 7]),
              partialBestMove: [],
              tiedSeats: [],
              nominatedSeats: [2, 5, 7],
              nightActions: [],
              currentDay: 1,
              eliminationVotes: 0,
              onSwipeUp: (_) {},
              onSwipeDown: (_) {},
              onSwipeLeft: (_) {},
              onSwipeRight: (_) {},
            ),
          ),
        ),
      );

      final centerColumn = getCenterColumn(tester);

      expect(
        find.descendant(of: centerColumn, matching: find.text('2')),
        findsOneWidget,
      );
      expect(
        find.descendant(of: centerColumn, matching: find.text('5')),
        findsOneWidget,
      );
      expect(
        find.descendant(of: centerColumn, matching: find.text('7')),
        findsOneWidget,
      );
    });

    testWidgets('speeches — отображает выставленных кандидатов',
        (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PlayerGrid(
              players: players,
              currentSpeaker: null,
              timerType: PlayerTimerType.none,
              currentSubPhase: SubPhase.speeches,
              onTap: (_) {},
              onLongPress: (_) {},
              isVotingActive: false,
              voteController: null,
              partialBestMove: [],
              tiedSeats: [],
              nominatedSeats: [2, 5, 7],
              nightActions: [],
              currentDay: 1,
              eliminationVotes: 0,
              onSwipeUp: (_) {},
              onSwipeDown: (_) {},
              onSwipeLeft: (_) {},
              onSwipeRight: (_) {},
            ),
          ),
        ),
      );

      final centerColumn = getCenterColumn(tester);

      expect(
        find.descendant(of: centerColumn, matching: find.text('2')),
        findsOneWidget,
      );
      expect(
        find.descendant(of: centerColumn, matching: find.text('5')),
        findsOneWidget,
      );
      expect(
        find.descendant(of: centerColumn, matching: find.text('7')),
        findsOneWidget,
      );
    });

    testWidgets('tieBreak — отображает tiedSeats', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PlayerGrid(
              players: players,
              currentSpeaker: 5,
              timerType: PlayerTimerType.none,
              currentSubPhase: SubPhase.tieBreak,
              onTap: (_) {},
              onLongPress: (_) {},
              isVotingActive: false,
              voteController: null,
              partialBestMove: [],
              tiedSeats: [5, 7],
              nominatedSeats: [],
              nightActions: [],
              currentDay: 1,
              eliminationVotes: 0,
              onSwipeUp: (_) {},
              onSwipeDown: (_) {},
              onSwipeLeft: (_) {},
              onSwipeRight: (_) {},
            ),
          ),
        ),
      );

      final centerColumn = getCenterColumn(tester);

      expect(
        find.descendant(of: centerColumn, matching: find.text('5')),
        findsOneWidget,
      );
      expect(
        find.descendant(of: centerColumn, matching: find.text('7')),
        findsOneWidget,
      );
    });

    testWidgets('bestMove — отображает partialBestMove', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PlayerGrid(
              players: players,
              currentSpeaker: null,
              timerType: PlayerTimerType.none,
              currentSubPhase: SubPhase.bestMove,
              onTap: (_) {},
              onLongPress: (_) {},
              isVotingActive: false,
              voteController: null,
              partialBestMove: [1, 3, 5],
              tiedSeats: [],
              nominatedSeats: [],
              nightActions: [],
              currentDay: 1,
              eliminationVotes: 0,
              onSwipeUp: (_) {},
              onSwipeDown: (_) {},
              onSwipeLeft: (_) {},
              onSwipeRight: (_) {},
            ),
          ),
        ),
      );

      final centerColumn = getCenterColumn(tester);

      expect(
        find.descendant(of: centerColumn, matching: find.text('1')),
        findsOneWidget,
      );
      expect(
        find.descendant(of: centerColumn, matching: find.text('3')),
        findsOneWidget,
      );
      expect(
        find.descendant(of: centerColumn, matching: find.text('5')),
        findsOneWidget,
      );
    });

    testWidgets('eliminationVote — отображает tiedSeats и голоса',
        (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PlayerGrid(
              players: players,
              currentSpeaker: null,
              timerType: PlayerTimerType.none,
              currentSubPhase: SubPhase.eliminationVote,
              onTap: (_) {},
              onLongPress: (_) {},
              isVotingActive: false,
              voteController: null,
              partialBestMove: [],
              tiedSeats: [5, 7],
              nominatedSeats: [],
              nightActions: [],
              currentDay: 1,
              eliminationVotes: 6,
              onSwipeUp: (_) {},
              onSwipeDown: (_) {},
              onSwipeLeft: (_) {},
              onSwipeRight: (_) {},
            ),
          ),
        ),
      );

      final centerColumn = getCenterColumn(tester);

      expect(
        find.descendant(of: centerColumn, matching: find.text('5')),
        findsOneWidget,
      );
      expect(
        find.descendant(of: centerColumn, matching: find.text('7')),
        findsOneWidget,
      );
      expect(
        find.descendant(of: centerColumn, matching: find.text('6')),
        findsOneWidget,
      );
    });
  });
}
