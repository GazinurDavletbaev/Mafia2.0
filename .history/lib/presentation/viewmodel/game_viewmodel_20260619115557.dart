import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mafia_help/application/providers/providers.dart';
import 'package:mafia_help/data/local/models/player_model.dart';
import 'package:mafia_help/data/local/models/sub_phase.dart';
import '../../core/logger/app_logger.dart';
import '../../data/local/models/phase.dart';
import '../../domain/helpers/vote_controller.dart';
import '../../domain/rules/game_history.dart';
import '../../domain/rules/phase_rules.dart';
import '../state/game_state.dart';
import 'game_viewmodel_state.dart';
import 'game_viewmodel_speeches.dart';
import 'game_viewmodel_actions.dart';
import 'game_viewmodel_reset.dart';
import 'game_viewmodel_vote_calc.dart';

final gameViewModelProvider =
    StateNotifierProvider<GameViewModel, GameState>((ref) {
  return GameViewModel(ref);
});

class GameViewModel extends StateNotifier<GameState> {
  final Ref _ref;
  final GameHistory _history = GameHistory();

  bool _skipNextBack = false;

  GameViewModel(this._ref) : super(GameState.initial()) {
    _loadSavedGame().then((_) {
      if (state.players.first.role == 'unknown') {
        dealRoles();
      }
      _history.push(state);
    });
  }

  late final GameViewModelState _stateActions = GameViewModelState(this, _ref);
  late final PhaseRules _phaseRules = PhaseRules();
  late final SpeechesActions _speeches = SpeechesActions(this, _ref);
  late final PlayerActions _player = PlayerActions(this, _ref);
  late final ResetActions _reset = ResetActions(this, _ref);
  late final VoteCalculatorActions _voteCalc =
      VoteCalculatorActions(this, _ref);

  Future<void> _loadSavedGame() => _stateActions.loadSavedGame();

  void initializeGame({
    required List<String> playerNames,
    int? tableNumber,
    int? gameNumber,
    DateTime? gameDate,
    String? judgeName,
  }) {
    final newPlayers = List<PlayerModel>.from(state.players);
    for (int i = 0; i < playerNames.length && i < newPlayers.length; i++) {
      newPlayers[i] = newPlayers[i].copyWith(name: playerNames[i]);
    }
    state = state.copyWith(
      players: newPlayers,
      tableNumber: tableNumber,
      gameNumber: gameNumber,
      gameDate: gameDate,
      judgeName: judgeName,
    );
    dealRoles();
  }

  Future<void> onPhaseBack() async {
    if (_skipNextBack) {
      _skipNextBack = false;
      final previousState = _history.last;
      state = previousState;
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
    AppLogger.d(
      'BACK: players = ${state.players.map((p) => '${p.seatNumber}:${p.role}').toList()}',
    );
  }

  Future<void> onPhaseForward() async {
    _skipNextBack = true;
    switch (state.currentSubPhase) {
      case SubPhase.roleDistribution:
        _history.push(state);
        state = await _phaseRules.calculateNextState(state);
        break;
      case SubPhase.contract:
      case SubPhase.mafiaShoot:
      case SubPhase.donCheck:
      case SubPhase.sheriffLook:
      case SubPhase.sheriffCheck:
        _history.push(state);
        state = await _phaseRules.calculateNextState(state);
        break;
      case SubPhase.tieBreak:
        await _speeches.nextSpeakerForTieBreak();
        _history.push(state);
        break;
      case SubPhase.speeches:
        _history.push(state);
        await _speeches.nextSpeaker();
        break;
      case SubPhase.voting:
        if (!state.isVotingDay) {
          _history.push(state);
          final aliveCount = state.players.where((p) => p.isAlive).length;
          state = state.copyWith(
            currentPhase: Phase.night,
            currentSubPhase: SubPhase.mafiaShoot,
            currentDay: state.currentDay + 1,
            currentSpeakerSeat: -1,
            nominatedSeats: [],
            votes: {},
            isVotingActive: false,
            voteController: null,
            isBestMove: aliveCount >= 9,
            isVotingDay: true,
            currentSpeakerTimer: null,
          );
          break;
        }
        AppLogger.d(
            'Voting phase started, candidates: ${state.nominatedSeats}');
        state = state.copyWith(
          isVotingActive: true,
          voteController: VoteController(state.nominatedSeats),
        );
        break;
      case SubPhase.revote:
        final candidates =
            state.tiedSeats.isNotEmpty ? state.tiedSeats : state.nominatedSeats;
        AppLogger.d('Revote phase started, candidates: $candidates');
        state = state.copyWith(
          isVotingActive: true,
          nominatedSeats: candidates,
          voteController: VoteController(candidates),
        );
        break;
      case SubPhase.eliminationVote:
        _history.push(state);
        state = await _phaseRules.calculateNextState(state);
        break;
      case SubPhase.finalWordKill:
        _history.push(state);
        final playerToKill = state.currentSpeakerSeat;
        if (playerToKill != null) {
          final usecase = _ref.read(killPlayerUsecaseProvider);
          final (newPlayers, winner) =
              usecase.execute(state.players, playerToKill);
          state = state.copyWith(players: newPlayers);
          if (winner != null) {
            state = state.copyWith(
                isGameEnded: true, winner: winner ? 'red' : 'black');
          }
        }
        state = await _phaseRules.calculateNextState(state);
        break;
      case SubPhase.finalWord:
        _history.push(state);
        final playerToKill = state.currentSpeakerSeat;
        if (playerToKill == null) break;

        final usecase = _ref.read(killPlayerUsecaseProvider);
        final (newPlayers, winner) =
            usecase.execute(state.players, playerToKill);

        final remainingTied =
            state.tiedSeats.where((seat) => seat != playerToKill).toList();

        if (remainingTied.isNotEmpty) {
          state = state.copyWith(
            players: newPlayers,
            currentSpeakerSeat: remainingTied.first,
            tiedSeats: remainingTied,
          );
          if (winner != null) {
            state = state.copyWith(
                isGameEnded: true, winner: winner ? 'red' : 'black');
          }
        } else {
          final newPhaseHistory = List<SubPhase>.from(state.phaseHistory)
            ..add(SubPhase.mafiaShoot);
          state = state.copyWith(
            players: newPlayers,
            currentPhase: Phase.night,
            currentSubPhase: SubPhase.mafiaShoot,
            currentDay: state.currentDay + 1,
            nominatedSeats: [],
            votes: {},
            tiedSeats: [],
            currentSpeakerSeat: -1,
            phaseHistory: newPhaseHistory,
            speechHistory: [],
            currentSpeakerTimer: null,
          );
          if (winner != null) {
            state = state.copyWith(
                isGameEnded: true, winner: winner ? 'red' : 'black');
          }
        }
        break;
      case SubPhase.bestMove:
        _history.push(state);
        state = await _phaseRules.calculateNextState(state);
        break;
      default:
        _history.push(state);
        state = await _phaseRules.calculateNextState(state);
        break;
    }
  }

  Future<void> nextSpeaker() => _speeches.nextSpeaker();
  Future<void> setCurrentSpeaker(int? seatNumber) =>
      _speeches.setCurrentSpeaker(seatNumber);

  Future<void> onPlayerTap(int seatNumber) => _player.onPlayerTap(seatNumber);
  Future<void> onPlayerLongPress(int seatNumber, int actionType) =>
      _player.onPlayerLongPress(seatNumber, actionType);
  Future<void> onSwipeUp(int seatNumber) =>
      _player.onNominatePlayer(seatNumber);
  Future<void> onSwipeDown(int seatNumber) =>
      _player.onRemoveNomination(seatNumber);
  Future<void> onSwipeLeft(int seatNumber) =>
      _player.onRevivePlayer(seatNumber);
  Future<void> onSwipeRight(int seatNumber) => _player.onKillPlayer(seatNumber);
  void toggleRoleCard(int seatNumber) => _player.toggleRoleCard(seatNumber);
  void closeRoleCard() => _player.closeRoleCard();

  Future<void> onResetGame() => _reset.onResetGame();
  Future<void> dealRoles() => _reset.dealRoles();

  void submitVote(int votes) => _voteCalc.submitVote(votes);
  void hideVoteCalculator() => _voteCalc.hideVoteCalculator();
  void showVoteCalculator() => _voteCalc.showVoteCalculator();
  VoteController? getVoteController() => _voteCalc.getVoteController();
  GameHistory getHistory() => _history;

  void submitNightAction(int value) {
    final subPhase = state.currentSubPhase;
    final currentActions = state.nightActions ?? [];
    final newActions = [...currentActions, value];
    state = state.copyWith(nightActions: newActions);

    if (subPhase == SubPhase.mafiaShoot) {
      if (value != 0) {
        state = state.copyWith(hasKillInLastNight: true);
      }
      AppLogger.d('Mafia shoot: цель $newActions');
    } else if (subPhase == SubPhase.donCheck && value != 0) {
      _showRoleCardForPlayer(value);
      AppLogger.d('Don check: игрок $value');
    } else if (subPhase == SubPhase.sheriffCheck && value != 0) {
      _showRoleCardForPlayer(value);
      AppLogger.d('Sheriff check: игрок $value');
    }
  }

  void _showRoleCardForPlayer(int seatNumber) {
    final player = state.players.firstWhere((p) => p.seatNumber == seatNumber);
    if (player.role == 'unknown') return;

    state = state.copyWith(showingRoleForSeat: seatNumber);

    Future.delayed(const Duration(seconds: 2), () {
      if (state.showingRoleForSeat == seatNumber) {
        state = state.copyWith(showingRoleForSeat: null);
      }
    });
  }

  void submitBestMoveNumber(int value) {
    if (state.currentSubPhase != SubPhase.bestMove) return;
    if (state.partialBestMove.contains(value)) return;
    if (state.partialBestMove.length >= 3) return;

    final newPartial = List<int>.from(state.partialBestMove)..add(value);
    _history.push(state);
    state = state.copyWith(partialBestMove: newPartial);
    AppLogger.d('Best move partial: $newPartial');
  }

  String currentPhaseString() {
    switch (state.currentPhase) {
      case Phase.night:
        return 'night';
      case Phase.day:
        return 'day';
    }
  }

  void updateState(GameState newState) {
    state = newState;
  }
}
