import 'package:flutter_test/flutter_test.dart';
import 'package:mafia_help/data/local/models/phase.dart';
import 'package:mafia_help/data/local/models/sub_phase.dart';
import 'package:mafia_help/presentation/state/game_state.dart';
import 'package:mafia_help/presentation/viewmodel/game_viewmodel.dart';
import 'package:mafia_help/presentation/viewmodel/game_viewmodel_phase.dart';

void main() {
  test('mafiaShoot → должна быть donCheck, а не voting', () async {
    // Создаём заглушку GameViewModel (не используется в calculateNextState)
    final dummyViewModel = GameViewModel(null as dynamic, 'test');
    
    final phaseActions = PhaseActions(dummyViewModel, null as dynamic);
    
    final state = GameState.initial().copyWith(
      currentDay: 1,
      currentPhase: Phase.night,
      currentSubPhase: SubPhase.mafiaShoot,
      phaseHistory: [SubPhase.mafiaShoot],
      nightActions: [5],
    );
    
    final nextState = await phaseActions.calculateNextState(state);
    
    expect(nextState.currentSubPhase, SubPhase.donCheck,
        reason: 'После mafiaShoot должна быть donCheck, а не ${nextState.currentSubPhase}');
  });
}