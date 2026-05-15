// lib/presentation/viewmodel/game_viewmodel_phase.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mafia_help/application/providers/providers.dart';
import 'package:mafia_help/data/local/models/phase.dart';
import '../../application/providers/rules_providers.dart';
import '../../core/logger/app_logger.dart';
import '../../data/local/models/sub_phase.dart';
import '../state/game_state.dart';
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

  Future<GameState> calculateNextState(GameState currentState) async {
    final phaseHistory = currentState.phaseHistory;
    final currentPhase = phaseHistory.isNotEmpty ? phaseHistory.last : null;

    SubPhase? nextPhase;

    if (phaseHistory.isEmpty) {
      // Начало игры
      nextPhase = SubPhase.roleDistribution;
    } else {
      // Ночь 0
      if (_night0Order.contains(currentPhase)) {
        final next = _getNextInOrder(currentPhase!, _night0Order);
        if (next != null) {
          nextPhase = next;
        } else {
          nextPhase = SubPhase.speeches;
        }
      }
      // День
      else if (_dayOrder.contains(currentPhase)) {
        final next = _getNextInOrder(currentPhase!, _dayOrder);
        if (next != null) {
          nextPhase = next;
        } else {
          nextPhase = SubPhase.mafiaShoot;
        }
      }
      // Ночь 1+
      else if (_nightOrder.contains(currentPhase)) {
        final next = _getNextInOrder(currentPhase!, _nightOrder);
        if (next != null) {
          nextPhase = next;
        } else {
          nextPhase = SubPhase.speeches;
        }
      }
    }

    if (nextPhase == null) return currentState;

    // Просто обновляем currentSubPhase, остальное не трогаем
    return currentState.copyWith(currentSubPhase: nextPhase);
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
