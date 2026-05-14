import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mafia_help/application/providers/providers.dart';
import 'package:mafia_help/data/local/models/phase.dart';
import '../../core/logger/app_logger.dart';
import 'game_viewmodel.dart';

class PhaseActions {
  final GameViewModel _vm;
  final Ref _ref;

  PhaseActions(this._vm, this._ref);

  Future<void> onPhaseBack() async {
    AppLogger.d('PhaseActions.onPhaseBack() called');

    final changePhaseUsecase = _ref.read(changePhaseUsecaseProvider);
    final phaseStack = _vm.state.phaseStack;

    final newStack = changePhaseUsecase.previousPhase(phaseStack);
    final newState = _vm.state.copyWith(phaseStack: newStack);

    _vm.state = newState;
  }

  Future<void> onPhaseForward() async {
  AppLogger.d('PhaseActions.onPhaseForward() called');
  
  final changePhaseUsecase = _ref.read(changePhaseUsecaseProvider);
  final phaseStack = _vm.state.phaseStack;
  final isNight0Completed = _vm.state.currentDay > 0;
  
  final (newStack, nextPhase) = changePhaseUsecase.nextPhase(
    stack: phaseStack,
    isNight0Completed: isNight0Completed,
  );
  
  if (nextPhase != null) {
    final newState = _vm.state.copyWith(
      phaseStack: newStack,
      currentSubPhase: nextPhase,
    );
    _vm.state = newState;
  } else {
    // Нет следующей фазы → переключаем блок (ночь → день или день → ночь)
    if (_vm.state.currentPhase == Phase.night && _vm.state.currentDay == 0) {
      // Ночь 0 закончилась → день 0
      final dayPhase = DayPhase.speeches;
      newStack.push(dayPhase);
      _vm.state = _vm.state.copyWith(
        phaseStack: newStack,
        currentSubPhase: dayPhase,
        currentPhase: Phase.day,
      );
    } else if (_vm.state.currentPhase == Phase.day) {
      // День закончился → ночь
      final nightPhase = NightPhase.mafiaShoot;
      newStack.push(nightPhase);
      _vm.state = _vm.state.copyWith(
        phaseStack: newStack,
        currentSubPhase: nightPhase,
        currentPhase: Phase.night,
        currentDay: _vm.state.currentDay + 1,
      );
    } else if (_vm.state.currentPhase == Phase.night && _vm.state.currentDay > 0) {
      // Обычная ночь закончилась → день
      final dayPhase = DayPhase.speeches;
      newStack.push(dayPhase);
      _vm.state = _vm.state.copyWith(
        phaseStack: newStack,
        currentSubPhase: dayPhase,
        currentPhase: Phase.day,
      );
    }
  }
}

  String currentPhaseString() {
    switch (_vm.state.currentPhase) {
      case Phase.night:
        return 'night';
      case Phase.day:
        return 'day';
    }
  }
}
