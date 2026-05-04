import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mafia_help/data/local/models/phase_config.dart';
import 'package:mafia_help/state/game_state.dart';

class PhaseController extends StateNotifier<PhaseConfig> {
  PhaseController() : super(PhaseConfig.firstNight());

  // Текущая подфаза
  SubPhase get currentSubPhase => state.subPhases[state.isFirstNight ? 0 : 0]; // будет обновляться через индекс в GameState

  // Переход к следующей подфазе
  void nextSubPhase(GameState gameState) {
    final currentIndex = gameState.currentSubPhaseIndex;
    final subPhases = state.subPhases;
    
    if (currentIndex + 1 < subPhases.length) {
      // Остаёмся в той же основной фазе, переходим к следующей подфазе
      return;
    } else {
      // Основная фаза закончилась, переключаемся на следующую основную фазу
      _switchToNextMainPhase(gameState);
    }
  }

  // Переход к предыдущей подфазе
  void previousSubPhase(GameState gameState) {
    final currentIndex = gameState.currentSubPhaseIndex;
    
    if (currentIndex - 1 >= 0) {
      // Возврат к предыдущей подфазе в той же основной фазе
      return;
    } else {
      // Нужно вернуться к предыдущей основной фазе
      _switchToPreviousMainPhase(gameState);
    }
  }

  // Определяем следующую основную фазу на основе текущей
  void _switchToNextMainPhase(GameState gameState) {
    if (state.mainPhase == MainPhase.night) {
      // Ночь закончилась → начинается день
      final hasKill = _checkIfKillHappened(gameState);
      _setDayPhase(hasKill);
    } else if (state.mainPhase == MainPhase.day) {
      // День закончился → начинается ночь
      _setNightPhase();
    }
  }

  void _switchToPreviousMainPhase(GameState gameState) {
    if (state.mainPhase == MainPhase.night) {
      // ночь → предыдущий день
      // TODO: вернуться к предыдущему дню (сложнее, хранить историю)
    } else if (state.mainPhase == MainPhase.day) {
      // день → предыдущая ночь
      _setNightPhase();
    }
  }

  void _setDayPhase(bool hasKill) {
    state = PhaseConfig.day(hasKillFromPreviousNight: hasKill);
  }

  void _setNightPhase() {
    // Если первая ночь уже прошла, используем regularNight
    // Для простоты: проверяем, была ли уже раздача ролей
    final bool isFirstNight = (state.isFirstNight && state.subPhases.contains(SubPhase.roleDistribution));
    if (isFirstNight) {
      state = PhaseConfig.regularNight();
    } else {
      state = PhaseConfig.regularNight();
    }
  }

  bool _checkIfKillHappened(GameState gameState) {
    // Проверяем, есть ли убитый игрок в текущей ночи
    // В реальном коде будет проверка по логу убийств
    return false; // заглушка
  }

  // Обновление состояния (для случаев, когда судья вручную меняет что-то)
  void updateConfig(PhaseConfig newConfig) {
    state = newConfig;
  }
}

// Провайдер для PhaseController
final phaseControllerProvider = StateNotifierProvider<PhaseController, PhaseConfig>((ref) {
  return PhaseController();
});