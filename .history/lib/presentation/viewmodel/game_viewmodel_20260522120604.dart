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
import 'game_viewmodel_reset.dart';
import 'game_viewmodel_vote_calc.dart';

final gameViewModelFamily =
    StateNotifierProvider.family<GameViewModel, GameState, String>(
      (ref, gameId) => GameViewModel(ref, gameId),
    );

class GameViewModel extends StateNotifier<GameState> {
  final Ref _ref;
  final String gameId;
  final GameHistory _history = GameHistory();

  // Флаг для пропуска первого Back после Forward
  bool _skipNextBack = false;

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
  late final ResetActions _reset = ResetActions(this, _ref);
  late final VoteCalculatorActions _voteCalc = VoteCalculatorActions(
    this,
    _ref,
  );

  Future<void> _loadSavedGame() => _stateActions.loadSavedGame();

  Future<void> onPhaseBack() async {
    // Пропускаем первый Back после Forward
    print(_skipNextBack);
    if (_skipNextBack) {
      _skipNextBack = false;
      final previousState = _history.last;
      state = previousState;
      final phaseNames = _history.states
          .map((s) => s.currentSubPhase.name)
          .toList();
      AppLogger.d(
        'SKIP BACK: players = ${state.players.map((p) => '${p.seatNumber}:${p.role}').toList()}',
      );
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
    AppLogger.d(
      'BACK: players = ${state.players.map((p) => '${p.seatNumber}:${p.role}').toList()}',
    );
  }

  Future<void> onPhaseForward() async {
    
    // При каждом Forward включаем флаг пропуска следующего Back
    _skipNextBack = true;
    print(state.currentSubPhase);
    switch (state.currentSubPhase) {
      case SubPhase.roleDistribution:
        _history.push(state);
        state = await _phase.calculateNextState(state);
        break;
      case SubPhase.contract:
      case SubPhase.mafiaShoot:
      case SubPhase.donCheck:
      case SubPhase.sheriffLook:
      case SubPhase.sheriffCheck:
        _history.push(state);
        state = await _phase.calculateNextState(state);
        break;
      case SubPhase.tieBreak:
      case SubPhase.speeches:
        await _speeches.nextSpeaker();
        _history.push(state);
        break;
      case SubPhase.voting:
      case SubPhase.revote:
        AppLogger.d(
          'Voting phase started, candidates: ${state.nominatedSeats}',
        );
        state = state.copyWith(
          isVotingActive: true,
          voteController: VoteController(state.nominatedSeats),
        );
        break;
      case SubPhase.eliminationVote:
        _history.push(state);
        state = await _phase.calculateNextState(state);
        break;
      case SubPhase.finalWordKill:
        print("finalwordkill onphaseforward");
        _history.push(state);
        state = state.copyWith(hasKillInLastNight: false);
        final playerToKill = state.currentSpeakerSeat;
        if (playerToKill != null) {
          final usecase = _ref.read(killPlayerUsecaseProvider);
          final (newPlayers, winner) = usecase.execute(
            state.players,
            playerToKill,
          );
          state = state.copyWith(players: newPlayers);
          if (winner != null) {
            state = state.copyWith(
              isGameEnded: true,
              winner: winner ? 'red' : 'black',
            );
          }
        }
        state = await _phase.calculateNextState(state);
        break;
      case SubPhase.finalWord:
        _history.push(state);
        final playerToKill = state.currentSpeakerSeat;
        if (playerToKill != null) {
          final usecase = _ref.read(killPlayerUsecaseProvider);
          final (newPlayers, winner) = usecase.execute(
            state.players,
            playerToKill,
          );
          state = state.copyWith(players: newPlayers);
          if (winner != null) {
            state = state.copyWith(
              isGameEnded: true,
              winner: winner ? 'red' : 'black',
            );
          }
        }
        state = await _phase.calculateNextState(state);
        break;
      case SubPhase.bestMove:
        print("bestmove gameviewmodel onfhaseforward");
        _history.push(state);
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

  Future<void> nextSpeaker() => _speeches.nextSpeaker();
  Future<void> setCurrentSpeaker(int? seatNumber) =>
      _speeches.setCurrentSpeaker(seatNumber);

  Future<void> onPlayerTap(int seatNumber) => _player.onPlayerTap(seatNumber);
  Future<void> onPlayerLongPress(int seatNumber, int actionType) =>
      _player.onPlayerLongPress(seatNumber, actionType);
  void toggleRoleCard(int seatNumber) => _player.toggleRoleCard(seatNumber);
  void closeRoleCard() => _player.closeRoleCard();

  Future<void> onResetGame() => _reset.onResetGame();
  Future<void> dealRoles() => _reset.dealRoles();

  void startVoting(List<int> candidates) => _voteCalc.startVoting(candidates);
  void submitVote(int votes) => _voteCalc.submitVote(votes);
  void hideVoteCalculator() => _voteCalc.hideVoteCalculator();
  void showVoteCalculator() => _voteCalc.showVoteCalculator();
  VoteController? getVoteController() => _voteCalc.getVoteController();

  void submitNightAction(int value) {
    final subPhase = state.currentSubPhase;

    // Добавляем действие в историю ночных действий
    final currentActions = state.nightActions ?? [];
    final newActions = [...currentActions, value];
    state = state.copyWith(nightActions: newActions);

    if (subPhase == SubPhase.mafiaShoot) {
      if (value != 0) {
        state = state.copyWith(hasKillInLastNight: true);
      }
      AppLogger.d('Mafia shoot: цель $newActions');
    } else if (subPhase == SubPhase.donCheck) {
      AppLogger.d('Don check: игрок $newActions');
    } else if (subPhase == SubPhase.sheriffCheck) {
      AppLogger.d('Sheriff check: игрок $newActions');
    }

    // Переход к следующей фазе
    onPhaseForward();
  }

  void submitBestMoveNumber(int value) {
    if (state.currentSubPhase != SubPhase.bestMove) return;

    // Не добавляем повторно уже выбранного игрока
    if (state.partialBestMove.contains(value)) return;
    if (state.partialBestMove.length >= 3) return;

    final newPartial = List<int>.from(state.partialBestMove)..add(value);
    _history.push(state);

    state = state.copyWith(partialBestMove: newPartial);
    AppLogger.d('Best move partial: $newPartial');

    // Перехода нет, судья сам нажмёт "вперёд"
  }

  String currentPhaseString() => _phase.currentPhaseString();

  void updateState(GameState newState) {
    state = newState;
  }
}
