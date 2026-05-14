import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mafia_help/application/providers/providers.dart';
import 'package:mafia_help/data/local/models/phase.dart';
import '../../core/logger/app_logger.dart';
import '../../data/local/models/sub_phase.dart';
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

    AppLogger.d(
      'before: phaseStack.current = ${phaseStack.current?.toString() ?? 'null'}',
    );
    AppLogger.d('isNight0Completed = $isNight0Completed');

    final (newStack, nextPhase) = changePhaseUsecase.nextPhase(
      stack: phaseStack,
      isNight0Completed: isNight0Completed,
    );

    AppLogger.d('nextPhase = $nextPhase');

    if (nextPhase != null) {
      final newState = _vm.state.copyWith(
        phaseStack: newStack,
        currentSubPhase: nextPhase,
      );
      _vm.state = newState;
      AppLogger.d(
        'after: newState.currentSubPhase = ${newState.currentSubPhase}',
      );
    } else {
  AppLogger.d('nextPhase is null, no change');
  
  // Ночь 0 закончилась → день 0
  if (_vm.state.currentDay == 0 && _vm.state.currentPhase == Phase.night) {
    final dayPhase = SubPhase.speeches;
    final newStack = phaseStack..push(dayPhase);
    final newState = _vm.state.copyWith(
      phaseStack: newStack,
      currentSubPhase: dayPhase,
      currentPhase: Phase.day,
      currentDay: 0,
    );
    _vm.state = newState;
    AppLogger.d('transition to day 0: $dayPhase');
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
