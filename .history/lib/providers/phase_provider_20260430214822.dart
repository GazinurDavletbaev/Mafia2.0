import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mafia_help/state/game_state.dart';
import 'package:mafia_help/services/phase_controller.dart';

// Провайдер для текущего индекса подфазы (хранится в GameState)
final currentSubPhaseIndexProvider = StateProvider<int>((ref) => 0);

// Провайдер для GameState (будет расширен позже)
final gameStateProvider = StateProvider<GameState>((ref) => GameState.initial());

// Метод для перехода к следующей подфазе (обновляет GameState и PhaseController)
void goToNextSubPhase(WidgetRef ref) {
  final phaseController = ref.read(phaseControllerProvider.notifier);
  final gameState = ref.read(gameStateProvider);
  
  final currentIndex = ref.read(currentSubPhaseIndexProvider);
  final subPhases = ref.read(phaseControllerProvider).subPhases;
  
  if (currentIndex + 1 < subPhases.length) {
    // Остаёмся в той же основной фазе
    ref.read(currentSubPhaseIndexProvider.notifier).state = currentIndex + 1;
  } else {
    // Переключаем основную фазу
    phaseController.nextSubPhase(gameState);
    ref.read(currentSubPhaseIndexProvider.notifier).state = 0; // сбрасываем индекс
  }
}

void goToPreviousSubPhase(WidgetRef ref) {
  final currentIndex = ref.read(currentSubPhaseIndexProvider);
  
  if (currentIndex - 1 >= 0) {
    ref.read(currentSubPhaseIndexProvider.notifier).state = currentIndex - 1;
  } else {
    // TODO: вернуться к предыдущей основной фазе (сложнее, хранить историю)
  }
}

// Вспомогательный геттер для текущей подфазы
SubPhase getCurrentSubPhase(WidgetRef ref) {
  final phaseConfig = ref.read(phaseControllerProvider);
  final subPhaseIndex = ref.read(currentSubPhaseIndexProvider);
  return phaseConfig.subPhases[subPhaseIndex];
}