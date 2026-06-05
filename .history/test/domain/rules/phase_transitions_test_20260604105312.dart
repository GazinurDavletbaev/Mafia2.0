import 'package:flutter_test/flutter_test.dart';
import 'package:mafia_help/data/local/models/phase.dart';
import 'package:mafia_help/data/local/models/sub_phase.dart';
import 'package:mafia_help/domain/rules/phase_rules.dart';
import 'package:mafia_help/presentation/state/game_state.dart';

void main() {
  test('mafiaShoot → должна быть donCheck, а не voting', () async {
    final rules = PhaseRules();
    
    final state = GameState.initial().copyWith(
      currentDay: 1,
      currentPhase: Phase.night,
      currentSubPhase: SubPhase.mafiaShoot,
      phaseHistory: [SubPhase.mafiaShoot],
      nightActions: [5],
    );
    
    final nextState = await rules.calculateNextState(state);
    
    expect(nextState.currentSubPhase, SubPhase.donCheck,
        reason: 'После mafiaShoot должна быть donCheck, а не ${nextState.currentSubPhase}');
  });
}