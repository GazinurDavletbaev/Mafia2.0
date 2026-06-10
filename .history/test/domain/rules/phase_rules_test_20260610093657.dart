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

  GameState _withRoles(GameState state) {
    final playersWithRoles = GameStateInitializer.assignRoles(state.players);
    return state.copyWith(players: playersWithRoles);
  }

  group('Ночь 0 → День 0', () {
    test('roleDistribution → contract', () async {
      final state = _withRoles(GameState.initial().copyWith(
        currentSubPhase: SubPhase.roleDistribution,
      ));
      final next = await phaseRules.calculateNextState(state);
      expect(next.currentSubPhase, SubPhase.contract);
    });

    test('contract → sheriffLook', () async {
      final state = _withRoles(GameState.initial().copyWith(
        currentSubPhase: SubPhase.contract,
      ));
      final next = await phaseRules.calculateNextState(state);
      expect(next.currentSubPhase, SubPhase.sheriffLook);
    });

    test('sheriffLook → freeSeating', () async {
      final state = _withRoles(GameState.initial().copyWith(
        currentSubPhase: SubPhase.sheriffLook,
      ));
      final next = await phaseRules.calculateNextState(state);
      expect(next.currentSubPhase, SubPhase.freeSeating);
    });

    test('freeSeating → speeches', () async {
      final state = _withRoles(GameState.initial().copyWith(
        currentSubPhase: SubPhase.freeSeating,
      ));
      final next = await phaseRules.calculateNextState(state);
      expect(next.currentSubPhase, SubPhase.speeches);
    });
  });

  group('Ночь 1+', () {
    test('mafiaShoot → donCheck', () async {
      final state = _withRoles(GameState.initial().copyWith(
        currentDay: 1,
        currentSubPhase: SubPhase.mafiaShoot,
      ));
      final next = await phaseRules.calculateNextState(state);
      expect(next.currentSubPhase, SubPhase.donCheck);
    });

    test('donCheck → sheriffCheck', () async {
      final state = _withRoles(GameState.initial().copyWith(
        currentDay: 1,
        currentSubPhase: SubPhase.donCheck,
      ));
      final next = await phaseRules.calculateNextState(state);
      expect(next.currentSubPhase, SubPhase.sheriffCheck);
    });
  });

  group('Из sheriffCheck', () {
    test('день 1, было убийство → bestMove', () async {
      // Создаём состояние с ночными действиями: [жертва, donCheck, sheriffCheck]
      final state = _withRoles(GameState.initial().copyWith(
        currentDay: 1,
        currentSubPhase: SubPhase.sheriffCheck,
        nightActions: [5, 2, 4], // 5 - убитый
      ));
      final next = await phaseRules.calculateNextState(state);

      expect(next.currentSubPhase, SubPhase.bestMove);
      expect(next.currentDay, 1);
    });

    test('день 2+, было убийство → finalWordKill', () async {
      final state = _withRoles(GameState.initial().copyWith(
        currentDay: 2,
        currentSubPhase: SubPhase.sheriffCheck,
        nightActions: [5, 2, 4],
      ));
      final next = await phaseRules.calculateNextState(state);

      expect(next.currentSubPhase, SubPhase.finalWordKill);
      expect(next.currentDay, 2);
    });

    test('промах (убийства нет) → speeches', () async {
      final state = _withRoles(GameState.initial().copyWith(
        currentDay: 1,
        currentSubPhase: SubPhase.sheriffCheck,
        nightActions: [0, 2, 4], // 0 или null = промах
      ));
      final next = await phaseRules.calculateNextState(state);

      expect(next.currentSubPhase, SubPhase.speeches);
      expect(next.currentDay, 1);
    });
  });

  group('eliminationVote', () {
    test('не хватило голосов → mafiaShoot', () async {
      var state = GameState.initial();
      final players = GameStateInitializer.assignRoles(state.players);
      state = _withRoles(state.copyWith(
        currentDay: 1,
        currentSubPhase: SubPhase.eliminationVote,
        eliminationVotes: 0,
        tiedSeats: [1, 2],
      ));
      final next = await phaseRules.calculateNextState(state);
      expect(next.currentSubPhase, SubPhase.mafiaShoot);
    });

    test('хватило голосов → finalWord', () async {
      var state = GameState.initial();
      final players = GameStateInitializer.assignRoles(state.players);
      state = _withRoles(state.copyWith(
        currentDay: 1,
        currentSubPhase: SubPhase.eliminationVote,
        eliminationVotes: 10,
        tiedSeats: [1, 2],
      ));
      final next = await phaseRules.calculateNextState(state);
      expect(next.currentSubPhase, SubPhase.finalWord);
    });
  });
  // добавить в существующий phase_rules_test.dart

  group('bestMove и finalWordKill', () {
    test('bestMove → finalWordKill', () async {
      final state = _withRoles(GameState.initial().copyWith(
        currentDay: 1,
        currentSubPhase: SubPhase.bestMove,
        partialBestMove: [1, 2, 3],
      ));
      final next = await phaseRules.calculateNextState(state);

      expect(next.currentSubPhase, SubPhase.finalWordKill);
    });

    test('finalWordKill → speeches (после убийства)', () async {
      final state = _withRoles(GameState.initial().copyWith(
        currentDay: 1,
        currentSubPhase: SubPhase.finalWordKill,
        currentSpeakerSeat: 5,
      ));
      final next = await phaseRules.calculateNextState(state);

      expect(next.currentSubPhase, SubPhase.speeches);
    });
  });

  group('finalWord после голосования', () {
    test('finalWord → mafiaShoot (если один игрок)', () async {
      final state = _withRoles(GameState.initial().copyWith(
        currentDay: 1,
        currentSubPhase: SubPhase.finalWord,
        currentSpeakerSeat: 5,
        tiedSeats: [], // один игрок
      ));
      final next = await phaseRules.calculateNextState(state);

      expect(next.currentSubPhase, SubPhase.mafiaShoot);
      expect(next.currentDay, 2);
    });
  });
}
