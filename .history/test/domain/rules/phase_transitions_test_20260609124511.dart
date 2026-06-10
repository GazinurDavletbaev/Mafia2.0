// test/phase_rules_transitions_test.dart

import 'package:flutter_test/flutter_test.dart';
import 'package:mafia_help/data/local/models/phase.dart';
import 'package:mafia_help/data/local/models/player_model.dart';
import 'package:mafia_help/data/local/models/sub_phase.dart';
import 'package:mafia_help/domain/rules/phase_rules.dart';
import 'package:mafia_help/presentation/state/game_state.dart';

// Хелпер для создания тестового GameState
GameState createTestState({
  SubPhase currentSubPhase = SubPhase.roleDistribution,
  int currentDay = 0,
  List<int> nominatedSeats = const [],
  List<int> nightActions = const [],
  int eliminationVotes = 0,
  bool hasKillInLastNight = false,
  int? currentSpeakerSeat,
  Map<int, int> votes = const {},
  List<int> tiedSeats = const [],
  int? dayStarterSeat,
}) {
  // Базовые игроки (10 живых)
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
    hasKillInLastNight: hasKillInLastNight,
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
        // Дон должен быть текущим говорящим
        expect(next.currentSpeakerSeat, 1); // don на seat 1
      });

      test('sheriffLook → freeSeating', () async {
        final state = createTestState(currentSubPhase: SubPhase.sheriffLook);
        final next = await rules.calculateNextState(state);

        expect(next.currentSubPhase, SubPhase.freeSeating);
        expect(next.currentSpeakerSeat, 3); // sheriff на seat 3
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
        // Должен быть первый говорящий
        expect(next.currentSpeakerSeat, isNotNull);
      });
    });

    group('Day 0 transitions (speeches → next)', () {
      test('speeches day 0, no candidates → mafiaShoot', () async {
        final state = createTestState(
          currentSubPhase: SubPhase.speeches,
          currentDay: 0,
          nominatedSeats: [],
        );
        final next = await rules.calculateNextState(state);

        expect(next.currentSubPhase, SubPhase.mafiaShoot);
        expect(next.currentDay, 1);
        expect(next.currentPhase, Phase.night);
        // Должны очиститься nominatedSeats и votes
        expect(next.nominatedSeats, isEmpty);
        expect(next.votes, isEmpty);
      });

      test('speeches day 0, 1 candidate → mafiaShoot (день 0 нет finalWord)',
          () async {
        final state = createTestState(
          currentSubPhase: SubPhase.speeches,
          currentDay: 0,
          nominatedSeats: [5],
        );
        final next = await rules.calculateNextState(state);

        expect(next.currentSubPhase, SubPhase.mafiaShoot);
        expect(next.currentDay, 1);
      });

      test('speeches day 0, 2+ candidates → voting', () async {
        final state = createTestState(
          currentSubPhase: SubPhase.speeches,
          currentDay: 0,
          nominatedSeats: [5, 7],
        );
        final next = await rules.calculateNextState(state);

        expect(next.currentSubPhase, SubPhase.voting);
        expect(next.currentDay, 0);
        expect(next.currentPhase, Phase.day);
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
        expect(next.currentSpeakerSeat, 1); // don
      });

      test('donCheck → sheriffCheck', () async {
        final state = createTestState(
          currentSubPhase: SubPhase.donCheck,
          currentDay: 1,
        );
        final next = await rules.calculateNextState(state);

        expect(next.currentSubPhase, SubPhase.sheriffCheck);
        expect(next.currentSpeakerSeat, 3); // sheriff
      });

      test('sheriffCheck → bestMove (день 1, было убийство)', () async {
        final state = createTestState(
          currentSubPhase: SubPhase.sheriffCheck,
          currentDay: 1,
          nightActions: [5, 2, 4], // kill, donCheck, sheriffCheck
        );
        final next = await rules.calculateNextState(state);

        expect(next.currentSubPhase, SubPhase.bestMove);
        expect(next.currentDay, 1);
        expect(next.currentPhase, Phase.day);
        expect(next.currentSpeakerSeat, 5); // убитый
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
          nightActions: [0, 2, 4], // промах (0)
        );
        final next = await rules.calculateNextState(state);

        expect(next.currentSubPhase, SubPhase.speeches);
        expect(next.currentDay, 1);
        expect(next.currentPhase, Phase.day);
      });
    });

    group('Day 1+ transitions (speeches → next)', () {
      test('speeches day 1, no candidates → mafiaShoot', () async {
        final state = createTestState(
          currentSubPhase: SubPhase.speeches,
          currentDay: 1,
          nominatedSeats: [],
        );
        final next = await rules.calculateNextState(state);

        expect(next.currentSubPhase, SubPhase.mafiaShoot);
        expect(next.currentDay, 2);
      });

      test('speeches day 1, 1 candidate → finalWord', () async {
        final state = createTestState(
          currentSubPhase: SubPhase.speeches,
          currentDay: 1,
          nominatedSeats: [5],
        );
        final next = await rules.calculateNextState(state);

        expect(next.currentSubPhase, SubPhase.finalWord);
        expect(next.currentDay, 1);
      });

      test('speeches day 1, 2+ candidates → voting', () async {
        final state = createTestState(
          currentSubPhase: SubPhase.speeches,
          currentDay: 1,
          nominatedSeats: [5, 7],
        );
        final next = await rules.calculateNextState(state);

        expect(next.currentSubPhase, SubPhase.voting);
        expect(next.currentDay, 1);
      });
    });

    group('eliminationVote transitions', () {
      test('eliminationVote with votes >= majority → finalWord', () async {
        final state = createTestState(
          currentSubPhase: SubPhase.eliminationVote,
          eliminationVotes: 6, // > 5 (половина от 10)
        );
        final next = await rules.calculateNextState(state);

        expect(next.currentSubPhase, SubPhase.finalWord);
      });

      test('eliminationVote with votes < majority → mafiaShoot', () async {
        final state = createTestState(
          currentSubPhase: SubPhase.eliminationVote,
          eliminationVotes: 4, // < 6
        );
        final next = await rules.calculateNextState(state);

        expect(next.currentSubPhase, SubPhase.mafiaShoot);
        expect(next.currentDay, 1);
      });
    });
  });
}
