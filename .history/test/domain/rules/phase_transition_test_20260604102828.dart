import 'package:flutter_test/flutter_test.dart';
import 'package:mafia_help/data/local/models/phase.dart';
import 'package:mafia_help/data/local/models/sub_phase.dart';
import 'package:mafia_help/presentation/state/game_state.dart';
import 'package:mafia_help/presentation/viewmodel/game_viewmodel_phase.dart';

void main() {
  test('mafiaShoot → должна быть donCheck, а не voting', () async {
    // 1. Создаём PhaseActions (calculateNextState не требует _vm и _ref)
    final phaseActions = PhaseActions(null, null);
    
    // 2. Создаём состояние: ночь 1, фаза mafiaShoot
    final state = GameState.initial().copyWith(
      currentDay: 1,
      currentPhase: Phase.night,
      currentSubPhase: SubPhase.mafiaShoot,
      phaseHistory: [SubPhase.mafiaShoot],
      nightActions: [5], // мафия уже выбрала цель
    );
    
    // 3. Вызываем calculateNextState
    final nextState = await phaseActions.calculateNextState(state);
    
    // 4. Проверяем: следующая фаза должна быть donCheck
    expect(nextState.currentSubPhase, SubPhase.donCheck,
        reason: 'После mafiaShoot должна быть donCheck, а не ${nextState.currentSubPhase}');
  });
}