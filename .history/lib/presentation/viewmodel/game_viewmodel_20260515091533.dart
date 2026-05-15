import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mafia_help/application/providers/providers.dart';
import 'package:mafia_help/data/local/models/sub_phase.dart';
import '../../core/logger/app_logger.dart';
import '../../domain/helpers/vote_controller.dart';
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

final gameViewModelFamily = StateNotifierProvider.family<GameViewModel, GameState, String>(
  (ref, gameId) => GameViewModel(ref, gameId),
);

class GameViewModel extends StateNotifier<GameState> {
  final Ref ref;
  final String gameId;

  // Экшены
  late final GameViewModelState stateActions;
  late final PersistenceActions persistence;
  late final PhaseActions phase;
  late final SpeechesActions speeches;
  late final PlayerActions player;
  late final VotingActions voting;
  late final ResetActions reset;
  late final TimerActions timer;
  late final VoteCalculatorActions voteCalc;

  GameViewModel(this.ref, this.gameId) : super(GameState.initial()) {
    stateActions = GameViewModelState(this, ref);
    persistence = PersistenceActions(this, ref);
    phase = PhaseActions(this, ref);
    speeches = SpeechesActions(this, ref);
    player = PlayerActions(this, ref);
    voting = VotingActions(this, ref);
    reset = ResetActions(this, ref);
    timer = TimerActions(this, ref);
    voteCalc = VoteCalculatorActions(this, ref);
    
    _loadSavedGame();
  }

  Future<void> _loadSavedGame() => stateActions.loadSavedGame();
  
  void updateState(GameState newState) {
    state = newState;
  }
}