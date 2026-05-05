import 'package:flutter/material.dart';
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
import 'package:mafia_help/presentation/state/game_state.dart';
import 'package:mafia_help/data/local/models/phase.dart';
import 'package:mafia_help/data/local/models/player_model.dart';

import '../../core/logger/app_logger.dart';
import '../../data/local/models/phase_config.dart';

final gameViewModelFamily =
    StateNotifierProvider.family<GameViewModel, GameState, String>((
      ref,
      gameId,
    ) {
      return GameViewModel(ref, gameId);
    });

class GameViewModel extends StateNotifier<GameState> {
  final Ref _ref;
  final String gameId;

  GameViewModel(this._ref, this.gameId) : super(GameState.initial()) {
    _loadSavedGame();
  }

  // Геттеры для доступа к полям состояния
  List<PlayerModel> get players => state.players;
  int get currentDay => state.currentDay;
  Phase get currentPhase => state.currentPhase;
  int get currentSubPhaseIndex => state.currentSubPhaseIndex;
  int? get currentSpeakerSeat => state.currentSpeakerSeat;

  Future<void> _loadSavedGame() async {
      AppLogger.d('_loadSavedGame START');

    final repository = _ref.read(gameRepositoryProvider);
    final saved = await repository.loadCurrentGameState();
    if (saved != null) {
      state = saved;
    }
  }

  Future<void> _saveGame() async {
    final repository = _ref.read(gameRepositoryProvider);
    await repository.saveCurrentGameState();
  }

  Future<void> onPlayerTap(int seatNumber) async {
    // В фазе раздачи ролей — показываем роль
    AppLogger.d('onPlayerTap: seat=$seatNumber, currentSubPhase=${state.currentSubPhase}');

    if (state.currentSubPhase == SubPhase.roleDistribution) {
      AppLogger.d('roleDistribution detected, toggling role card');

      toggleRoleCard(seatNumber);
      return;
    }
    AppLogger.d('Adding foul');

    // В остальных фазах — добавляем фол
    final usecase = _ref.read(addFoulUsecaseProvider);
    await usecase(seatNumber);
    await _saveGame();
    await _checkGameEnd();
  }

  void toggleRoleCard(int seatNumber) {
    AppLogger.d('toggleRoleCard: seat=$seatNumber, current showing=${state.showingRoleForSeat}');

    if (state.showingRoleForSeat == seatNumber) {
      state = state.copyWith(showingRoleForSeat: null);
    } else {
      state = state.copyWith(showingRoleForSeat: seatNumber);
    }
    AppLogger.d('new showingRoleForSeat=${state.showingRoleForSeat}');

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
    await _saveGame();
    await _checkGameEnd();
  }

  Future<void> _killPlayer(int seatNumber) async {
    final usecase = _ref.read(killPlayerUsecaseProvider);
    await usecase(
      seatNumber: seatNumber,
      phase: _currentPhaseString(),
      killType: 'manual',
    );
  }

  Future<void> _revivePlayer(int seatNumber) async {
    final usecase = _ref.read(revivePlayerUsecaseProvider);
    await usecase(seatNumber);
  }

  Future<void> _nominatePlayer(int seatNumber) async {
    final usecase = _ref.read(nominatePlayerUsecaseProvider);
    await usecase(seatNumber);
  }

  Future<void> _removeNomination(int seatNumber) async {
    final usecase = _ref.read(removeNominationUsecaseProvider);
    await usecase(seatNumber);
  }

  Future<void> onPhaseBack() async {
    final usecase = _ref.read(changePhaseUsecaseProvider);
    await usecase(goForward: false);
    await _saveGame();
  }

  Future<void> onPhaseForward() async {
    final usecase = _ref.read(changePhaseUsecaseProvider);
    await usecase(goForward: true);
    await _saveGame();
  }

  Future<void> onEndGame(GameResult result) async {
    final usecase = _ref.read(endGameUsecaseProvider);
    await usecase(result);
    await _saveCompletedGame();
  }

  Future<void> onResetGame() async {
    final usecase = _ref.read(resetGameUsecaseProvider);
    await usecase();
    await _saveGame();
  }

  Future<void> _checkGameEnd() async {
    final usecase = _ref.read(checkGameEndUsecaseProvider);
    final result = await usecase();
    if (result != null) {
      _showGameEndDialog(result);
    }
  }

  Future<void> addVote(int seat, int votes) async {
    final currentVotes = Map<int, int>.from(state.votes);
    currentVotes[seat] = votes;
    state = state.copyWith(votes: currentVotes);
    await _saveGame();
  }

  void _showGameEndDialog(GameResult result) {
    // TODO: реализовать показ диалога через контекст
  }

  Future<void> _saveCompletedGame() async {
    final repository = _ref.read(gameRepositoryProvider);
    await repository.saveCompletedGame(state);
    await repository.clearCurrentGameState();
  }

  String _currentPhaseString() {
    switch (state.currentPhase) {
      case Phase.night:
        return 'night';
      case Phase.day:
        return 'day';
      case Phase.voting:
        return 'voting';
    }
  }
}
