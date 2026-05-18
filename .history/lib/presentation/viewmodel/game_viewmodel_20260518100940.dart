import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mafia_help/application/providers/providers.dart';
import 'package:mafia_help/data/local/models/sub_phase.dart';
import '../../core/logger/app_logger.dart';
import '../../domain/helpers/vote_controller.dart';
import '../../domain/rules/game_history.dart';
import '../state/game_state.dart';
import 'game_viewmodel_state.dart';
import 'game_viewmodel_persistence.dart';
import 'game_viewmodel_phase.dart';
import 'game_viewmodel_speeches.dart';
import 'game_viewmodel_actions.dart';
import 'game_viewmodel_voting.dart';
import 'game_viewmodel_reset.dart';
import 'game_viewmodel_timer.dart';
import 'game_viewmodel_vote_calc.dart';

final gameViewModelFamily =
    StateNotifierProvider.family<GameViewModel, GameState, String>(
      (ref, gameId) => GameViewModel(ref, gameId),
    );

class GameViewModel extends StateNotifier<GameState> {
  final Ref _ref;
  final String gameId;
  final GameHistory _history = GameHistory();
  
  // Новый флаг для логики Back
  bool _shouldSkipNextBack = false;  // пропустить следующий Back

  GameViewModel(this._ref, this.gameId) : super(GameState.initial()) {
    _loadSavedGame();
    _history.push(state);
  }

  // ... остальные методы ...

  Future<void> onPhaseBack() async {
    // Логика пропуска первого Back после Forward
    if (_shouldSkipNextBack) {
      _shouldSkipNextBack = false;
      AppLogger.d('onPhaseBack: skipped first back after forward');
      return;
    }

    if (_history.length <= 1) {
      return;
    }

    _history.pop();
    final previousState = _history.last;
    state = previousState;
    final phaseNames = _history.states
        .map((s) => s.currentSubPhase.name)
        .toList();
    AppLogger.d('history phases: $phaseNames');
  }

  Future<void> onPhaseForward() async {
    // При каждом Forward устанавливаем флаг
    _shouldSkipNextBack = true;
    
    switch (state.currentSubPhase) {
      case SubPhase.speeches:
        await _speeches.nextSpeaker();
        break;
      case SubPhase.voting:
      case SubPhase.revote:
      case SubPhase.tieBreak:
      case SubPhase.eliminationVote:
      case SubPhase.finalWord:
      case SubPhase.bestMove:
        final newState = await _phase.calculateNextState(state);
        state = newState;
        break;
      case SubPhase.roleDistribution:
        final phaseNames = _history.states
            .map((s) => s.currentSubPhase.name)
            .toList();
        AppLogger.d('history phases: $phaseNames');
        final newState = await _phase.calculateNextState(state);
        state = newState;
        break;
      default:
        _history.push(state);
        final phaseNames = _history.states
            .map((s) => s.currentSubPhase.name)
            .toList();
        AppLogger.d('history phases: $phaseNames');
        final newState = await _phase.calculateNextState(state);
        state = newState;
        break;
    }
  }
  
  // ... остальные методы ...
}