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
        );
      });
    });

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

      // Проверяем что кандидаты отображаются
      expect(find.text('2'), findsOneWidget);
      expect(find.text('5'), findsOneWidget);
      expect(find.text('7'), findsOneWidget);
    });

    testWidgets('speeches — НЕ отображает кандидатов', (tester) async {
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
              nominatedSeats: [2, 5, 7], // есть кандидаты
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

      // Кандидаты НЕ должны отображаться
      expect(find.text('2'), findsNothing);
      expect(find.text('5'), findsNothing);
      expect(find.text('7'), findsNothing);

      // Должна быть иконка микрофона
      expect(find.byIcon(Icons.mic), findsOneWidget);
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

      expect(find.text('5'), findsOneWidget);
      expect(find.text('7'), findsOneWidget);
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

      expect(find.text('1'), findsOneWidget);
      expect(find.text('3'), findsOneWidget);
      expect(find.text('5'), findsOneWidget);
      expect(find.byIcon(Icons.emoji_events), findsOneWidget);
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

      expect(find.text('5'), findsOneWidget);
      expect(find.text('7'), findsOneWidget);
      expect(find.text('6'), findsOneWidget); // голоса
    });
  });
}
