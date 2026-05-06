import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mafia_help/application/providers/providers.dart';
import 'package:mafia_help/domain/helpers/game_end_helper.dart';
import 'package:mafia_help/domain/usecases/add_foul_usecase.dart';
import 'package:mafia_help/domain/usecases/change_phase_usecase.dart';
import 'package:mafia_help/domain/usecases/check_game_end_usecase.dart';
import 'package:mafia_help/domain/usecases/kill_player_usecase.dart';
import 'package:mafia_help/domain/usecases/revive_player_usecase.dart';
import 'package:mafia_help/domain/usecases/nominate_player_usecase.dart';
import 'package:mafia_help/domain/usecases/remove_nomination_usecase.dart';
import 'package:mafia_help/domain/usecases/end_game_usecase.dart';
import 'package:mafia_help/domain/usecases/reset_game_usecase.dart';
import 'package:mafia_help/domain/usecases/add_vote_usecase.dart';
import 'package:mafia_help/domain/usecases/clear_votes_usecase.dart';
import 'package:mafia_help/domain/usecases/set_current_speaker_usecase.dart';
import 'package:mafia_help/domain/usecases/deal_roles_usecase.dart';
import 'package:mafia_help/data/local/models/phase.dart';
import 'package:mafia_help/data/local/models/player_model.dart';
import '../../core/logger/app_logger.dart';
import '../../data/local/models/sub_phase.dart';
import '../state/game_state.dart';
import '../state/game_state_copy.dart';

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

  // ========== Загрузка и сохранение ==========
  
  Future<void> _loadSavedGame() async {
  AppLogger.d('_loadSavedGame START');
  final repository = _ref.read(gameRepositoryProvider);
  final saved = await repository.getCurrentGameState(); // ✅ исправлено
  state = saved;
  AppLogger.d('_loadSavedGame END: subPhase=${state.currentSubPhase}');
}

  Future<void> saveGame() async {
    AppLogger.d('saveGame: saving current state');
    final repository = _ref.read(gameRepositoryProvider);
    await repository.saveCurrentGameState(state);  // ✅ передаём state
  }

  // ========== Действия с игроками ==========

  Future<void> onPlayerTap(int seatNumber) async {
    AppLogger.d('onPlayerTap: seat=$seatNumber, currentSubPhase=${state.currentSubPhase}');

    if (state.currentSubPhase == SubPhase.roleDistribution) {
      AppLogger.d('roleDistribution detected, toggling role card');
      toggleRoleCard(seatNumber);
      return;
    }
    
    AppLogger.d('Adding foul');
    final usecase = _ref.read(addFoulUsecaseProvider);
    final newState = await usecase(seatNumber);
    state = newState;
    await _checkGameEnd();
  }

  void toggleRoleCard(int seatNumber) {
    if (state.showingRoleForSeat == seatNumber) {
      state = state.copyWith(showingRoleForSeat: null);
    } else {
      state = state.copyWith(showingRoleForSeat: seatNumber);
    }
  }

  Future<void> onPlayerLongPress(int seatNumber, int actionType) async {
    switch (actionType) {
      case 0:
        await _killPlayer(seatNumber);
        break;
      case 1:
        await _revivePlayer(seatNumber);
        break;
      case 2:
        await _nominatePlayer(seatNumber);
        break;
      case 3:
        await _removeNomination(seatNumber);
        break;
    }
    await _checkGameEnd();
  }

  Future<void> _killPlayer(int seatNumber) async {
    final usecase = _ref.read(killPlayerUsecaseProvider);
    final newState = await usecase(
      seatNumber: seatNumber,
      phase: _currentPhaseString(),
      killType: 'manual',
    );
    state = newState;
  }

  Future<void> _revivePlayer(int seatNumber) async {
    final usecase = _ref.read(revivePlayerUsecaseProvider);
    final newState = await usecase(seatNumber);
    state = newState;
  }

  Future<void> _nominatePlayer(int seatNumber) async {
    final usecase = _ref.read(nominatePlayerUsecaseProvider);
    final newState = await usecase(seatNumber);
    state = newState;
  }

  Future<void> _removeNomination(int seatNumber) async {
    final usecase = _ref.read(removeNominationUsecaseProvider);
    final newState = await usecase(seatNumber);
    state = newState;
  }

  // ========== Фазы ==========

  Future<void> onPhaseBack() async {
    final usecase = _ref.read(changePhaseUsecaseProvider);
    final newState = await usecase(goForward: false);
    state = newState;
  }

  Future<void> onPhaseForward() async {
    AppLogger.d('onPhaseForward called BEFORE: subPhase=${state.currentSubPhase}');
    final usecase = _ref.read(changePhaseUsecaseProvider);
    final newState = await usecase(goForward: true);
    state = newState;
    AppLogger.d('onPhaseForward AFTER: subPhase=${state.currentSubPhase}');
  }

  // ========== Голосование ==========

  Future<void> addVote(int seat, int votes) async {
    final usecase = _ref.read(addVoteUsecaseProvider);
    final newState = await usecase(
      targetSeatNumber: seat,
      votesCount: votes,
    );
  state = newState;
}

  Future<void> clearVotes() async {
    final usecase = _ref.read(clearVotesUsecaseProvider);
    final newState = await usecase();
    state = newState;
  }

  // ========== Речи ==========

  Future<void> setCurrentSpeaker(int? seatNumber) async {
    final usecase = _ref.read(setCurrentSpeakerUsecaseProvider);
    final newState = await usecase(seatNumber);
    state = newState;
  }

  Future<void> dealRoles() async {
    final usecase = _ref.read(dealRolesUsecaseProvider);
    final newState = await usecase();
    state = newState;
  }

  // ========== Завершение и сброс игры ==========

  Future<void> onEndGame(GameResult result) async {
    final usecase = _ref.read(endGameUsecaseProvider);
    final newState = await usecase(result);
    if (newState != null) {
      state = newState;
    }
    await _saveCompletedGame();
  }

  Future<void> onResetGame() async {
    final usecase = _ref.read(resetGameUsecaseProvider);
    final newState = await usecase();
    state = newState;
  }

  Future<void> _checkGameEnd() async {
    final usecase = _ref.read(checkGameEndUsecaseProvider);
    final result = await usecase();
    if (result != null) {
      _showGameEndDialog(result);
    }
  }

  void _showGameEndDialog(GameResult result) {
    // TODO: реализовать показ диалога через контекст
  }

  Future<void> _saveCompletedGame() async {
    final repository = _ref.read(gameRepositoryProvider);
    await repository.saveCompletedGame(state);
    await repository.clearCurrentGameState();
  }

  // ========== Вспомогательные методы ==========

  String _currentPhaseString() {
    switch (state.currentPhase) {
      case Phase.night: return 'night';
      case Phase.day: return 'day';
      case Phase.voting: return 'voting';
    }
  }
}