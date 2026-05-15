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

  GameViewModel(this._ref, this.gameId) : super(GameState.initial()) {
    _loadSavedGame();
    _history.push(state);
  }

  // ========== Делегирование ==========
  late final GameViewModelState _stateActions = GameViewModelState(this, _ref);
  late final PersistenceActions _persistence = PersistenceActions(this, _ref);
  late final PhaseActions _phase = PhaseActions(this, _ref);
  late final SpeechesActions _speeches = SpeechesActions(this, _ref);
  late final PlayerActions _player = PlayerActions(this, _ref);
  late final VotingActions _voting = VotingActions(this, _ref);
  late final ResetActions _reset = ResetActions(this, _ref);
  late final TimerActions _timer = TimerActions(this, _ref);
  late final VoteCalculatorActions _voteCalc = VoteCalculatorActions(
    this,
    _ref,
  );

  Future<void> _loadSavedGame() => _stateActions.loadSavedGame();

  Future<void> onPhaseBack() async {
    if (!_history.canPop) return;
    final previousState = _history.pop();
    state = previousState;
    AppLogger.d(
      'onPhaseBack: restored previous state, subPhase = ${state.currentSubPhase}',
    );
    AppLogger.d(
      'history length = ${_history.length}, canPop = ${_history.canPop}',
    );
  }

  Future<void> onPhaseForward() async {
    final newState = await _phase.calculateNextState(state);
    state = newState;
    AppLogger.d('onPhaseForward: new state = ${state.currentSubPhase}');
  }
  // lib/presentation/viewmodel/game_viewmodel.dart

  void pushCurrentStateToHistory() {
    _history.push(state);
    AppLogger.d(
      'pushCurrentStateToHistory: saved state with speaker ${state.currentSpeakerSeat}',
    );
  }

  Future<void> nextSpeaker() => _speeches.nextSpeaker();
  Future<void> setCurrentSpeaker(int? seatNumber) =>
      _speeches.setCurrentSpeaker(seatNumber);

  Future<void> onPlayerTap(int seatNumber) => _player.onPlayerTap(seatNumber);
  Future<void> onPlayerLongPress(int seatNumber, int actionType) =>
      _player.onPlayerLongPress(seatNumber, actionType);
  void toggleRoleCard(int seatNumber) => _player.toggleRoleCard(seatNumber);
  void closeRoleCard() => _player.closeRoleCard();

  Future<void> onVote(int seat, int votes) => _voting.onVote(seat, votes);
  Future<void> onRevote() => _voting.onRevote();
  Future<void> onNextTieCandidate() => _voting.onNextTieCandidate();
  Future<void> onFinishTieBreak() => _voting.onFinishTieBreak();
  Future<void> onEliminationVote(int votes) => _voting.onEliminationVote(votes);
  Future<void> onCheckEliminationResult() => _voting.onCheckEliminationResult();

  Future<void> onResetGame() => _reset.onResetGame();
  Future<void> dealRoles() => _reset.dealRoles();

  Future<void> onTimerComplete() => _timer.onTimerComplete();

  void startVoting(List<int> candidates) => _voteCalc.startVoting(candidates);
  void submitVote(int votes) => _voteCalc.submitVote(votes);
  void hideVoteCalculator() => _voteCalc.hideVoteCalculator();
  void showVoteCalculator() => _voteCalc.showVoteCalculator();
  VoteController? getVoteController() => _voteCalc.getVoteController();

  String currentPhaseString() => _phase.currentPhaseString();

  void updateState(GameState newState) {
    state = newState;
  }
}
