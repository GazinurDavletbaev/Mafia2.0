import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mafia_help/application/providers/providers.dart';
import 'package:mafia_help/data/local/models/phase.dart';
import 'package:mafia_help/data/local/models/player_model.dart';
import 'package:mafia_help/data/local/models/sub_phase.dart';
import '../../core/logger/app_logger.dart';
import '../../domain/helpers/game_end_helper.dart';
import '../../domain/helpers/vote_controller.dart';
import '../state/game_state.dart';
import 'game_viewmodel_persistence.dart';
import 'game_viewmodel_gameplay.dart';

final gameViewModelFamily = StateNotifierProvider.family<GameViewModel, GameState, String>(
  (ref, gameId) => GameViewModel(ref, gameId),
);

class GameViewModel extends StateNotifier<GameState> {
  final Ref _ref;
  final String gameId;

  GameViewModel(this._ref, this.gameId) : super(GameState.initial()) {
    _loadSavedGame();
  }

  // Геттеры
  List<PlayerModel> get players => state.players;
  int get currentDay => state.currentDay;
  Phase get currentPhase => state.currentPhase;
  int get currentSubPhaseIndex => state.currentSubPhaseIndex;
  int? get currentSpeakerSeat => state.currentSpeakerSeat;

  // ========== Делегирование gameplay ==========
  late final GameplayActions _gameplay = GameplayActions(this, _ref);

  Future<void> onPhaseBack() => _gameplay.onPhaseBack();
  Future<void> onPhaseForward() => _gameplay.onPhaseForward();
  Future<void> nextSpeaker() => _gameplay.nextSpeaker();
  Future<void> previousSpeaker() => _gameplay.previousSpeaker();
  Future<void> setCurrentSpeaker(int? seatNumber) => _gameplay.setCurrentSpeaker(seatNumber);
  Future<void> dealRoles() => _gameplay.dealRoles();
  Future<void> onPlayerTap(int seatNumber) => _gameplay.onPlayerTap(seatNumber);
  Future<void> onPlayerLongPress(int seatNumber, int actionType) => _gameplay.onPlayerLongPress(seatNumber, actionType);
  void toggleRoleCard(int seatNumber) => _gameplay.toggleRoleCard(seatNumber);
  void closeRoleCard() => _gameplay.closeRoleCard();
  Future<void> addVote(int seat, int votes) => _gameplay.onVote(seat, votes);
  Future<void> onVote(int seat, int votes) => _gameplay.onVote(seat, votes);
  Future<void> onRevote() => _gameplay.onRevote();
  Future<void> onNextTieCandidate() => _gameplay.onNextTieCandidate();
  Future<void> onFinishTieBreak() => _gameplay.onFinishTieBreak();
  Future<void> onEliminationVote(int votes) => _gameplay.onEliminationVote(votes);
  Future<void> onCheckEliminationResult() => _gameplay.onCheckEliminationResult();
  Future<void> onResetGame() => _gameplay.onResetGame();



  // ========== Делегирование persistence ==========
  late final PersistenceActions _persistence = PersistenceActions(this, _ref);

  Future<void> saveGame() => _persistence.saveGame();
  Future<void> _loadSavedGame() => _persistence.loadSavedGame();

  // ========== Таймер ==========
  Future<void> onTimerComplete() async {
    final subPhase = state.currentSubPhase;
    final currentSpeaker = state.currentSpeakerSeat;

    AppLogger.d('onTimerComplete: subPhase=$subPhase, currentSpeaker=$currentSpeaker');

    if (subPhase == SubPhase.speeches && currentSpeaker != null) {
      await nextSpeaker();
    } else if (subPhase == SubPhase.tieBreak) {
      await onNextTieCandidate();
    } else if (subPhase == SubPhase.finalWord && currentSpeaker != null) {
      await onPhaseForward();
    } else if (subPhase == SubPhase.contract) {
      // Ничего не делаем
    } else if (subPhase == SubPhase.sheriffLook || subPhase == SubPhase.sheriffCheck || subPhase == SubPhase.donCheck) {
      await onPhaseForward();
    } else if (subPhase == SubPhase.bestMove && currentSpeaker != null) {
      await setCurrentSpeaker(currentSpeaker);
      await onPhaseForward();
    }
  }

  // ========== Голосование ==========

  void startVoting(List<int> candidates) {
    AppLogger.d('startVoting: candidates=$candidates');
    final controller = VoteController(candidates);
    state = state.copyWith(
      voteController: controller,
      isVotingActive: true,
    );
  }

  void submitVote(int votes) {
    final controller = state.voteController;
    if (controller == null) {
      AppLogger.d('submitVote: no active controller');
      return;
    }
    
    AppLogger.d('submitVote: seat=${controller.currentSeat}, votes=$votes');
    controller.setVotes(votes);
    state = state.copyWith(voteController: controller);
    
    if (controller.isComplete) {
      AppLogger.d('submitVote: all votes collected, finalizing');
      _finalizeVoting(controller.results);
    } else {
      controller.nextCandidate();
      state = state.copyWith(voteController: controller);
    }
  }

  void _finalizeVoting(Map<int, int> votes) {
    AppLogger.d('_finalizeVoting: votes=$votes');
    final aliveCount = state.players.where((p) => p.isAlive).length;
    final result = VoteController.determineResult(votes, aliveCount);
    
    AppLogger.d('_finalizeVoting: result=${result.type}');
    
    switch (result.type) {
      case VoteResultType.winner:
        state = state.copyWith(
          currentSubPhase: SubPhase.finalWord,
          currentSpeakerSeat: result.winnerSeat,
          voteController: null,
          isVotingActive: false,
        );
        break;
        
      case VoteResultType.tieBreak:
        state = state.copyWith(
          currentSubPhase: SubPhase.tieBreak,
          tiedSeats: result.seats,
          currentTieIndex: 0,
          currentSpeakerSeat: result.seats.isNotEmpty ? result.seats[0] : null,
          voteController: null,
          isVotingActive: false,
        );
        break;
        
      case VoteResultType.eliminationVote:
        state = state.copyWith(
          currentSubPhase: SubPhase.eliminationVote,
          tiedSeats: result.seats,
          voteController: null,
          isVotingActive: false,
        );
        break;
        
      case VoteResultType.noCandidates:
        final nextDay = state.currentDay + 1;
        state = state.copyWith(
          currentPhase: Phase.night,
          currentSubPhase: SubPhase.mafiaShoot,
          currentDay: nextDay,
          voteController: null,
          isVotingActive: false,
          nominatedSeats: [],
          votes: {},
        );
        break;
    }
  }

  void hideVoteCalculator() {
    final controller = state.voteController;
    if (controller != null) {
      controller.hide();
      state = state.copyWith(voteController: controller);
    }
  }

  void showVoteCalculator() {
    final controller = state.voteController;
    if (controller != null) {
      controller.show();
      state = state.copyWith(voteController: controller);
    }
  }

  VoteController? getVoteController() {
    return state.voteController;
  }

  // ========== Вспомогательные ==========
  String currentPhaseString() => _gameplay.currentPhaseString();
}