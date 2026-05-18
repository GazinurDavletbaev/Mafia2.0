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