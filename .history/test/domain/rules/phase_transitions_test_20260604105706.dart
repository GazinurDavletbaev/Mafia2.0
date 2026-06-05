import 'package:flutter_test/flutter_test.dart';
import 'package:mafia_help/data/local/models/phase.dart';
import 'package:mafia_help/data/local/models/sub_phase.dart';
import 'package:mafia_help/domain/rules/phase_rules.dart';
import 'package:mafia_help/presentation/state/game_state.dart';
import 'package:mafia_help/presentation/state/game_state_initializer.dart';

void main() {
  test('БАГ: после eliminationVote с недостатком голосов -> ночь -> после стрельбы должна быть donCheck, а не voting', () async {
    final rules = PhaseRules();
    
    // 1. Создаём состояние: eliminationVote, голосов НЕ хватило
    var state = GameState.initial();
    final playersWithRoles = GameStateInitializer.assignRoles(state.players);
    state = state.copyWith(
      players: playersWithRoles,
      currentDay: 1,
      currentPhase: Phase.day,
      currentSubPhase: SubPhase.eliminationVote,
      tiedSeats: [1, 2, 3],
      eliminationVotes: 0,  // НЕ хватило
    );
    
    // 2. Нажимаем "вперёд" -> переход в ночь
    state = await rules.calculateNextState(state);
    expect(state.currentSubPhase, SubPhase.mafiaShoot,
        reason: 'После eliminationVote должна быть ночь');
    
    // 3. В ночи: стрельба
    // Добавляем действие стрельбы (мафия стреляет в 5)
    final nightActions = [...state.nightActions, 5];
    state = state.copyWith(
      nightActions: nightActions,
      currentSubPhase: SubPhase.mafiaShoot,  // остаёмся в стрельбе
    );
    
    // 4. Нажимаем "вперёд" в стрельбе
    state = await rules.calculateNextState(state);
    
    // 5. ПРОВЕРКА: должна быть donCheck, а не voting
    expect(state.currentSubPhase, SubPhase.donCheck,
        reason: 'После стрельбы должна быть donCheck, а не ${state.currentSubPhase}');
  });
}