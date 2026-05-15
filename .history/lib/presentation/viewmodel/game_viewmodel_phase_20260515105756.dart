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

  // Здесь будет вся логика вычисления следующего состояния
  Future<GameState> calculateNextState(GameState currentState) async {
    // TODO: собрать все Usecase'ы для перехода к следующей фазе
    // Пока возвращаем текущее состояние (заглушка)
    AppLogger.d('calculateNextState called');
    return currentState;
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