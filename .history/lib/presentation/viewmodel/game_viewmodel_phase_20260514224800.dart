import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mafia_help/application/providers/providers.dart';
import 'package:mafia_help/data/local/models/phase.dart';
import '../../application/providers/rules_providers.dart';
import '../../core/logger/app_logger.dart';
import '../../data/local/models/sub_phase.dart';
import 'game_viewmodel.dart';

class PhaseActions {
  final GameViewModel _vm;
  final Ref _ref;

  PhaseActions(this._vm, this._ref);

  Future<void> onPhaseBack() async {
    final phaseHistory = _vm.state.phaseHistory;
    if (phaseHistory.isEmpty) return;

    final newPhaseHistory = List<SubPhase>.from(phaseHistory)..removeLast();
    final previousPhase = newPhaseHistory.isNotEmpty
        ? newPhaseHistory.last
        : null;
    if (previousPhase == null) return;

    final newState = _vm.state.copyWith(
      phaseHistory: newPhaseHistory,
      currentSubPhase: previousPhase,
    );

    _vm.state = newState;
  }

  Future<void> onPhaseForward() async {
    AppLogger.d('PhaseActions.onPhaseForward() called');

    final phaseHistory = _vm.state.phaseHistory;
    final isNight0Completed = _vm.state.currentDay > 0;

    // Определяем следующую фазу
    SubPhase? nextPhase;
    List<SubPhase> newPhaseHistory;

    if (phaseHistory.isEmpty) {
      // Начало игры
      if (isNight0Completed) {
        nextPhase = SubPhase.speeches;
      } else {
        nextPhase = SubPhase.roleDistribution;
      }
      newPhaseHistory = [nextPhase];
    } else {
      final currentPhase = phaseHistory.last;

      // Ночь 0
      if (_isNight0Phase(currentPhase)) {
        final next = _getNextInOrder(currentPhase, _night0Order);
        if (next != null) {
          nextPhase = next;
          newPhaseHistory = List.from(phaseHistory)..add(nextPhase);
        } else {
          // Конец ночи 0 → день 0
          nextPhase = SubPhase.speeches;
          newPhaseHistory = List.from(phaseHistory)..add(nextPhase);
        }
      }
      // День
      else if (_isDayPhase(currentPhase)) {
        final next = _getNextInOrder(currentPhase, _dayOrder);
        if (next != null) {
          nextPhase = next;
          newPhaseHistory = List.from(phaseHistory)..add(nextPhase);
        } else {
          // Конец дня → ночь
          nextPhase = SubPhase.mafiaShoot;
          newPhaseHistory = List.from(phaseHistory)..add(nextPhase);
        }
      }
      // Ночь 1+
      else if (_isNightPhase(currentPhase)) {
        final next = _getNextInOrder(currentPhase, _nightOrder);
        if (next != null) {
          nextPhase = next;
          newPhaseHistory = List.from(phaseHistory)..add(nextPhase);
        } else {
          // Конец ночи → день
          nextPhase = SubPhase.speeches;
          newPhaseHistory = List.from(phaseHistory)..add(nextPhase);
        }
      } else {
        return;
      }
    }

    if (nextPhase == null) return;

    final phaseRules = _ref.read(phaseRulesProvider);
    final shouldIncrement = phaseRules.shouldIncrementDay(nextPhase);
    final newDay = shouldIncrement
        ? _vm.state.currentDay + 1
        : _vm.state.currentDay;

    final isNight =
        nextPhase == SubPhase.roleDistribution ||
        nextPhase == SubPhase.contract ||
        nextPhase == SubPhase.sheriffLook ||
        nextPhase == SubPhase.freeSeating ||
        nextPhase == SubPhase.mafiaShoot ||
        nextPhase == SubPhase.donCheck ||
        nextPhase == SubPhase.sheriffCheck;
    final newState = _vm.state.copyWith(
      phaseHistory: newPhaseHistory,
      currentSubPhase: nextPhase,
      currentDay: newDay,
      currentPhase: isNight ? Phase.night : Phase.day,
      currentSpeakerSeat: _vm.state.speechHistory.isNotEmpty
          ? _vm.state.speechHistory.last
          : null,
    );

    _vm.state = newState;
    AppLogger.d(
      'after: currentSubPhase = ${newState.currentSubPhase}, day = $newDay',
    );
  }

  String currentPhaseString() {
    switch (_vm.state.currentPhase) {
      case Phase.night:
        return 'night';
      case Phase.day:
        return 'day';
    }
  }

  // Вспомогательные методы
  bool _isNight0Phase(SubPhase phase) {
    return _night0Order.contains(phase);
  }

  bool _isDayPhase(SubPhase phase) {
    return _dayOrder.contains(phase);
  }

  bool _isNightPhase(SubPhase phase) {
    return _nightOrder.contains(phase);
  }

  SubPhase? _getNextInOrder(SubPhase current, List<SubPhase> order) {
    final index = order.indexOf(current);
    if (index >= 0 && index + 1 < order.length) {
      return order[index + 1];
    }
    return null;
  }

  static const List<SubPhase> _night0Order = [
    SubPhase.roleDistribution,
    SubPhase.contract,
    SubPhase.sheriffLook,
    SubPhase.freeSeating,
  ];

  static const List<SubPhase> _nightOrder = [
    SubPhase.mafiaShoot,
    SubPhase.donCheck,
    SubPhase.sheriffCheck,
  ];

  static const List<SubPhase> _dayOrder = [
    SubPhase.speeches,
    SubPhase.voting,
    SubPhase.revote,
    SubPhase.tieBreak,
    SubPhase.eliminationVote,
    SubPhase.finalWord,
  ];
}
