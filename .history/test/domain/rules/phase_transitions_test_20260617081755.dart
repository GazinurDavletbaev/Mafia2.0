// test/domain/rules/phase_transitions_test.dart

import 'package:flutter_test/flutter_test.dart';
import 'package:mafia_help/data/local/models/phase.dart';
import 'package:mafia_help/data/local/models/player_model.dart';
import 'package:mafia_help/data/local/models/sub_phase.dart';
import 'package:mafia_help/domain/rules/phase_rules.dart';
import 'package:mafia_help/presentation/state/game_state.dart';

GameState createTestState({
  SubPhase currentSubPhase = SubPhase.roleDistribution,
  int currentDay = 0,
  List<int> nominatedSeats = const [],
  List<int> nightActions = const [],
  int eliminationVotes = 0,
  int? currentSpeakerSeat,
  Map<int, int> votes = const {},
  List<int> tiedSeats = const [],
  int? dayStarterSeat,
}) {
  final players = List.generate(10, (i) {
    final seat = i + 1;
    String role = 'citizen';
    if (seat == 1) role = 'don';
    if (seat == 2) role = 'mafia';
    if (seat == 3) role = 'sheriff';

    return PlayerModel(
      id: 'p$seat',
      seatNumber: seat,
      name: 'Player $seat',
      team: role == 'don' || role == 'mafia' ? 'black' : 'red',
      role: role,
      isAlive: true,
      fouls: 0,
      isSpeaking: false,
      gameId: 'test',
      hasSkippedSpeech: false,
    );
  });

  return GameState(
    game: null,
    players: players,
    currentPhase: Phase.night,
    currentSubPhase: currentSubPhase,
    currentSubPhaseIndex: 0,
    currentDay: currentDay,
    currentSpeakerSeat: currentSpeakerSeat,
    nominatedSeats: nominatedSeats,
    votes: votes,
    partialBestMove: [],
    isGameEnded: false,
    winner: null,
    currentRound: 1,
    showingRoleForSeat: null,
    hasKillInLastNight: false,
    eliminationVotes: eliminationVotes,
    tiedSeats: tiedSeats,
    currentTieIndex: 0,
    dayStarterSeat: dayStarterSeat,
    voteController: null,
    isVotingActive: false,
    nightActions: nightActions,
    phaseHistory: [currentSubPhase],
    speechHistory: const [1, 2, 3, 4, 5, 6, 7, 8, 9, 10],
    voteHistory: [],
    isBestMove: true,
  );
}

void main() {
  group('PhaseRules.calculateNextState', () {
    late PhaseRules rules;

    setUp(() {
      rules = PhaseRules();
    });

    group('Night 0 transitions', () {
      test('roleDistribution → contract', () async {
        final state =
            createTestState(currentSubPhase: SubPhase.roleDistribution);
        final next = await rules.calculateNextState(state);

        expect(next.currentSubPhase, SubPhase.contract);
        expect(next.currentDay, 0);
        expect(next.currentPhase, Phase.night);
      });

      test('contract → sheriffLook', () async {
        final state = createTestState(currentSubPhase: SubPhase.contract);
        final next = await rules.calculateNextState(state);

        expect(next.currentSubPhase, SubPhase.sheriffLook);
        // sheriffLook — говорящий шериф (seat 3)
        expect(next.currentSpeakerSeat, 3);
      });

      test('sheriffLook → freeSeating', () async {
        final state = createTestState(currentSubPhase: SubPhase.sheriffLook);
        final next = await rules.calculateNextState(state);

        expect(next.currentSubPhase, SubPhase.freeSeating);
        // freeSeating не требует speaker'а
        expect(next.currentSpeakerSeat, isNull);
      });

      test('freeSeating → speeches (день 0)', () async {
        final state = createTestState(
          currentSubPhase: SubPhase.freeSeating,
          currentDay: 0,
        );
        final next = await rules.calculateNextState(state);

        expect(next.currentSubPhase, SubPhase.speeches);
        expect(next.currentDay, 0);
        expect(next.currentPhase, Phase.day);
        expect(next.currentSpeakerSeat, isNotNull);
      });
    });

    group('Night 1+ transitions', () {
      test('mafiaShoot → donCheck', () async {
        final state = createTestState(
          currentSubPhase: SubPhase.mafiaShoot,
          currentDay: 1,
        );
        final next = await rules.calculateNextState(state);

        expect(next.currentSubPhase, SubPhase.donCheck);
        expect(next.currentDay, 1);
        expect(next.currentSpeakerSeat, 1);
      });

      test('donCheck → sheriffCheck', () async {
        final state = createTestState(
          currentSubPhase: SubPhase.donCheck,
          currentDay: 1,
        );
        final next = await rules.calculateNextState(state);

        expect(next.currentSubPhase, SubPhase.sheriffCheck);
        expect(next.currentSpeakerSeat, 3);
      });

      test('sheriffCheck → bestMove (день 1, было убийство)', () async {
        final state = createTestState(
          currentSubPhase: SubPhase.sheriffCheck,
          currentDay: 1,
          nightActions: [5, 2, 4],
        );
        final next = await rules.calculateNextState(state);

        expect(next.currentSubPhase, SubPhase.bestMove);
        expect(next.currentDay, 1);
        expect(next.currentPhase, Phase.day);
        expect(next.currentSpeakerSeat, 5);
      });

      test('sheriffCheck → finalWordKill (день 2+, было убийство)', () async {
        final state = createTestState(
          currentSubPhase: SubPhase.sheriffCheck,
          currentDay: 2,
          nightActions: [5, 2, 4],
        );
        final next = await rules.calculateNextState(state);

        expect(next.currentSubPhase, SubPhase.finalWordKill);
        expect(next.currentDay, 2);
        expect(next.currentSpeakerSeat, 5);
      });

      test('sheriffCheck → speeches (промах)', () async {
        final state = createTestState(
          currentSubPhase: SubPhase.sheriffCheck,
          currentDay: 1,
          nightActions: [0, 2, 4],
        );
        final next = await rules.calculateNextState(state);

        expect(next.currentSubPhase, SubPhase.speeches);
        expect(next.currentDay, 1);
        expect(next.currentPhase, Phase.day);
      });
    });

    group('eliminationVote transitions', () {
      test('eliminationVote with votes >= majority → finalWord', () async {
        final state = createTestState(
          currentSubPhase: SubPhase.eliminationVote,
          eliminationVotes: 6,
        );
        final next = await rules.calculateNextState(state);

        expect(next.currentSubPhase, SubPhase.finalWord);
      });

      test('eliminationVote with votes < majority → mafiaShoot', () async {
        final state = createTestState(
          currentSubPhase: SubPhase.eliminationVote,
          eliminationVotes: 4,
          currentDay: 1,
        );
        final next = await rules.calculateNextState(state);

        expect(next.currentSubPhase, SubPhase.mafiaShoot);
        expect(next.currentDay, 2);
      });

      test('eliminationVote with votes = exactly half (50%) → mafiaShoot',
          () async {
        final state = createTestState(
          currentSubPhase: SubPhase.eliminationVote,
          eliminationVotes: 5,
          currentDay: 1,
        );
        final next = await rules.calculateNextState(state);

        expect(next.currentSubPhase, SubPhase.mafiaShoot);
        expect(next.currentDay, 2);
      });
    });

    group('_getNextInOrder tests', () {
      test('bestMove → finalWordKill', () async {
        final state = createTestState(currentSubPhase: SubPhase.bestMove);
        final next = await rules.calculateNextState(state);

        expect(next.currentSubPhase, SubPhase.finalWordKill);
      });

      test('finalWordKill → speeches', () async {
        final state = createTestState(currentSubPhase: SubPhase.finalWordKill);
        final next = await rules.calculateNextState(state);

        expect(next.currentSubPhase, SubPhase.speeches);
      });

      test('voting → revote (если ничья)', () async {
        // voting сам по себе не переходит, но если вызвать calculateNextState
        // на voting, то должен вернуть revote (следующий в _dayOrder)
        final state = createTestState(currentSubPhase: SubPhase.voting);
        final next = await rules.calculateNextState(state);

        expect(next.currentSubPhase, SubPhase.revote);
      });

      test('revote → tieBreak', () async {
        final state = createTestState(currentSubPhase: SubPhase.revote);
        final next = await rules.calculateNextState(state);

        expect(next.currentSubPhase, SubPhase.tieBreak);
      });

      test('tieBreak → eliminationVote', () async {
        final state = createTestState(currentSubPhase: SubPhase.tieBreak);
        final next = await rules.calculateNextState(state);

        expect(next.currentSubPhase, SubPhase.eliminationVote);
      });
    });
  });
}
