import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mafia_help/application/providers/providers.dart';
import 'package:mafia_help/data/local/models/phase.dart';
import 'package:mafia_help/data/local/models/player_model.dart';
import 'package:mafia_help/data/local/models/sub_phase.dart';
import '../../core/logger/app_logger.dart';
import '../state/game_state.dart';
import 'game_viewmodel_persistence.dart';
import 'game_viewmodel_gameplay.dart';
import 'game_viewmodel_end.dart';

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
  Future<void> onVote(int seat, int votes) => _gameplay.onVote(seat, votes);
  Future<void> onRevote() => _gameplay.onRevote();
  Future<void> onNextTieCandidate() => _gameplay.onNextTieCandidate();
  Future<void> onFinishTieBreak() => _gameplay.onFinishTieBreak();
  Future<void> onEliminationVote(int votes) => _gameplay.onEliminationVote(votes);
  Future<void> onCheckEliminationResult() => _gameplay.onCheckEliminationResult();
  Future<void> onResetGame() => _gameplay.onResetGame();

  // ========== Делегирование end ==========
  late final EndGameActions _end = EndGameActions(this, _ref);

  Future<void> onEndGame(GameResult result) => _end.onEndGame(result);
  Future<void> _checkGameEnd() => _end.checkGameEnd();

  // ========== Делегирование persistence ==========
  late final PersistenceActions _persistence = PersistenceActions(this, _ref);

  Future<void> saveGame() => _persistence.saveGame();
  Future<void> _loadSavedGame() => _persistence.loadSavedGame();
  Future<void> _saveCompletedGame() => _persistence.saveCompletedGame();
}