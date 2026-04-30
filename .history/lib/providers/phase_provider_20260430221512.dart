import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mafia_help/state/game_state.dart';
import 'package:mafia_help/services/phase_controller.dart';
import 'package:mafia_help/providers/game_provider.dart';  // ← импорт gameStateProvider оттуда

// Провайдер для текущего индекса подфазы
final currentSubPhaseIndexProvider = StateProvider<int>((ref) => 0);

// НЕ ОПРЕДЕЛЯЙ gameStateProvider ЗДЕСЬ!

// Метод для перехода к следующей подфазе
void goToNextSubPhase(WidgetRef ref) {
  final phaseController = ref.read(phaseControllerProvider.notifier);
  final gameState = ref.read(gameStateProvider);  // ← из game_provider.dart
  
  final currentIndex = ref.read(currentSubPhaseIndexProvider);
  final subPhases = ref.read(phaseControllerProvider).subPhases;
  
  if (currentIndex + 1 < subPhases.length) {
    ref.read(currentSubPhaseIndexProvider.notifier).state = currentIndex + 1;
  } else {
    phaseController.nextSubPhase(gameState);
    ref.read(currentSubPhaseIndexProvider.notifier).state = 0;
  }
}

void goToPreviousSubPhase(WidgetRef ref) {
  final currentIndex = ref.read(currentSubPhaseIndexProvider);
  
  if (currentIndex - 1 >= 0) {
    ref.read(currentSubPhaseIndexProvider.notifier).state = currentIndex - 1;
  }
}

SubPhase getCurrentSubPhase(WidgetRef ref) {
  final phaseConfig = ref.read(phaseControllerProvider);
  final subPhaseIndex = ref.read(currentSubPhaseIndexProvider);
  return phaseConfig.subPhases[subPhaseIndex];
}