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

  static const List<SubPhase> nightPhases = [
    SubPhase.roleDistribution,
    SubPhase.contract,
    SubPhase.sheriffLook,
    SubPhase.freeSeating,
    SubPhase.mafiaShoot,
    SubPhase.donCheck,
    SubPhase.sheriffCheck,
  ];

  Future<void> onPhaseBack() async {
    AppLogger.d('PhaseActions.onPhaseBack() called');

    // Если мы в речах, сначала пытаемся переключить на предыдущего говорящего
    if (_vm.state.currentSubPhase == SubPhase.speeches) {
      final speechHistory = _vm.state.speechHistory;
      if (speechHistory.length >= 2) {
        final newSpeechHistory = List<int>.from(speechHistory)..removeLast();
        final prevSpeaker = newSpeechHistory.last;
        _vm.state = _vm.state.copyWith(
          currentSpeakerSeat: prevSpeaker,
          speechHistory: newSpeechHistory,
        );
        AppLogger.d('onPhaseBack: switched to previous speaker $prevSpeaker');
        return;
      }
      // Нет предыдущего говорящего → удаляем фазу speeches
    }

    // Стандартный откат фазы
    final phaseHistory = _vm.state.phaseHistory;
    if (phaseHistory.length <= 1) return;

    final newPhaseHistory = List<SubPhase>.from(phaseHistory)..removeLast();
    final previousPhase = newPhaseHistory.last;

    // Пересчитываем день по количеству mafiaShoot в истории
    final newDay = newPhaseHistory
        .where((p) => p == SubPhase.mafiaShoot)
        .length;

    final newState = _vm.state.copyWith(
      phaseHistory: newPhaseHistory,
      currentSubPhase: previousPhase,
      currentDay: newDay,
      currentPhase: nightPhases.contains(previousPhase)
          ? Phase.night
          : Phase.day,
      speechHistory: [], // очищаем историю речей при выходе из дня
      currentSpeakerSeat: null,
    );

    _vm.state = newState;
    AppLogger.d(
      'onPhaseBack: rolled back phase to $previousPhase, day = $newDay',
    );
  }

  Future<void> onPhaseForward() async {
    AppLogger.d('PhaseActions.onPhaseForward() called');

    final phaseHistory = _vm.state.phaseHistory;
    final isNight0Completed = _vm.state.currentDay > 0;

    if (phaseHistory.isEmpty)
      return; // на всякий случай, но теперь не должно быть

    SubPhase? nextPhase;
    List<SubPhase> newPhaseHistory;

    final currentPhase = phaseHistory.last;

    // Ночь 0
    if (_night0Order.contains(currentPhase)) {
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
    else if (_dayOrder.contains(currentPhase)) {
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
    else if (_nightOrder.contains(currentPhase)) {
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

    if (nextPhase == null) return;

    // Инициализация речей при переходе на speeches
    if (nextPhase == SubPhase.speeches) {
      final allAlive =
          _vm.state.players
              .where((p) => p.isAlive)
              .map((p) => p.seatNumber)
              .toList()
            ..sort();

      if (allAlive.isNotEmpty) {
        final firstSpeaker = allAlive.first;
        _vm.state = _vm.state.copyWith(
          currentSpeakerSeat: firstSpeaker,
          dayStarterSeat: firstSpeaker,
          speechHistory: [firstSpeaker],
        );
      }
    }

    // Увеличиваем день только при переходе finalWord → mafiaShoot
    final shouldIncrement =
        _vm.state.currentSubPhase == SubPhase.finalWord &&
        nextPhase == SubPhase.mafiaShoot;
    final newDay = shouldIncrement
        ? _vm.state.currentDay + 1
        : _vm.state.currentDay;

    final newState = _vm.state.copyWith(
      phaseHistory: newPhaseHistory,
      currentSubPhase: nextPhase,
      currentDay: newDay,
      currentPhase: nightPhases.contains(nextPhase) ? Phase.night : Phase.day,
      currentSpeakerSeat: _vm.state.speechHistory.isNotEmpty
          ? _vm.state.speechHistory.last
          : null,
    );

    _vm.state = newState;
    AppLogger.d('onPhaseForward: nextPhase = $nextPhase, day = $newDay');
    AppLogger.d(
      'phaseHistory = ${newPhaseHistory.map((p) => p.name).toList()}',
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
