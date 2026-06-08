import 'package:flutter_test/flutter_test.dart';
import 'package:mafia_help/data/local/models/sub_phase.dart';
import 'package:mafia_help/domain/rules/phase_rules.dart';
import 'package:mafia_help/presentation/state/game_state.dart';
import 'package:mafia_help/presentation/state/game_state_initializer.dart';

void main() {
  late PhaseRules phaseRules;

  setUp(() {
    phaseRules = PhaseRules();
  });

  group('Ночь 0 → День 0', () {
    test('roleDistribution → contract', () async {
      final state = GameState.initial().copyWith(
        currentSubPhase: SubPhase.roleDistribution,
      );
      final next = await phaseRules.calculateNextState(state);
      expect(next.currentSubPhase, SubPhase.contract);
    });

    test('contract → sheriffLook', () async {
      final state = GameState.initial().copyWith(
        currentSubPhase: SubPhase.contract,
      );
      final next = await phaseRules.calculateNextState(state);
      expect(next.currentSubPhase, SubPhase.sheriffLook);
    });

    test('sheriffLook → freeSeating', () async {
      final state = GameState.initial().copyWith(
        currentSubPhase: SubPhase.sheriffLook,
      );
      final next = await phaseRules.calculateNextState(state);
      expect(next.currentSubPhase, SubPhase.freeSeating);
    });

    test('freeSeating → speeches', () async {
      final state = GameState.initial().copyWith(
        currentSubPhase: SubPhase.freeSeating,
      );
      final next = await phaseRules.calculateNextState(state);
      expect(next.currentSubPhase, SubPhase.speeches);
    });
  });

  group('Ночь 1+', () {
    test('mafiaShoot → donCheck', () async {
      final state = GameState.initial().copyWith(
        currentDay: 1,
        currentSubPhase: SubPhase.mafiaShoot,
      );
      final next = await phaseRules.calculateNextState(state);
      expect(next.currentSubPhase, SubPhase.donCheck);
    });

    test('donCheck → sheriffCheck', () async {
      final state = GameState.initial().copyWith(
        currentDay: 1,
        currentSubPhase: SubPhase.donCheck,
      );
      final next = await phaseRules.calculateNextState(state);
      expect(next.currentSubPhase, SubPhase.sheriffCheck);
    });
  });

  group('eliminationVote', () {
    test('не хватило голосов → mafiaShoot', () async {
      var state = GameState.initial();
      final players = GameStateInitializer.assignRoles(state.players);
      state = state.copyWith(
        players: players,
        currentDay: 1,
        currentSubPhase: SubPhase.eliminationVote,
        eliminationVotes: 0,
        tiedSeats: [1, 2],
      );
      final next = await phaseRules.calculateNextState(state);
      expect(next.currentSubPhase, SubPhase.mafiaShoot);
    });

    test('хватило голосов → finalWord', () async {
      var state = GameState.initial();
      final players = GameStateInitializer.assignRoles(state.players);
      state = state.copyWith(
        players: players,
        currentDay: 1,
        currentSubPhase: SubPhase.eliminationVote,
        eliminationVotes: 10,
        tiedSeats: [1, 2],
      );
      final next = await phaseRules.calculateNextState(state);
      expect(next.currentSubPhase, SubPhase.finalWord);
    });
  });
}
