import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
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
import 'package:mafia_help/data/local/models/phase_model.dart';


final gameViewModelProvider = StateNotifierProvider.family<GameViewModel, GameState, String>((ref, gameId) {
  return GameViewModel(ref, gameId);
});

class GameViewModel extends StateNotifier<GameState> {
  final Ref _ref;
  final String gameId;

  GameViewModel(this._ref, this.gameId) : super(GameState.initial()) {
    _loadSavedGame();
  }

  // ========== Инициализация ==========
  
  Future<void> _loadSavedGame() async {
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

  // ========== Действия судьи ==========
  
  Future<void> onPlayerTap(int seatNumber) async {
    final usecase = _ref.read(addFoulUsecaseProvider);
    await usecase(seatNumber);
    await _saveGame();
    await _checkGameEnd();
  }

  Future<void> onPlayerLongPress(int seatNumber, BuildContext context) async {
    final result = await showDialog<int>(
      context: context,
      builder: (_) => _PieMenuDialog(seatNumber: seatNumber),
    );
    
    if (result == null) return;
    
    switch (result) {
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

  // ========== Проверка окончания игры ==========
  
  Future<void> _checkGameEnd() async {
    final usecase = _ref.read(checkGameEndUsecaseProvider);
    final result = await usecase();
    if (result != null && _ref.context.mounted) {
      _showGameEndDialog(result);
    }
  }

  void _showGameEndDialog(GameResult result) {
    showDialog(
      context: _ref.context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Text(result == GameResult.redWin ? 'Красные победили!' : 'Чёрные победили!'),
        actions: [
          TextButton(
            onPressed: () {
              context.pop();
              context.pop();
            },
            child: const Text('Выйти'),
          ),
          TextButton(
            onPressed: () {
              context.pop();
              onResetGame();
            },
            child: const Text('Новая игра'),
          ),
        ],
      ),
    );
  }

  // ========== Завершение игры и сохранение ==========
  
  Future<void> _saveCompletedGame() async {
    final repository = _ref.read(gameRepositoryProvider);
    await repository.saveCompletedGame(state);
    await repository.clearCurrentGameState();
  }

  // ========== Хелперы ==========
  
  String _currentPhaseString() {
    switch (state.currentPhase) {
      case Phase.night: return 'night';
      case Phase.day: return 'day';
      case Phase.voting: return 'voting';
    }
  }
}

// ========== Диалог меню ==========
class _PieMenuDialog extends StatelessWidget {
  final int seatNumber;
  const _PieMenuDialog({required this.seatNumber});

  @override
  Widget build(BuildContext context) {
    return SimpleDialog(
      title: Text('Игрок место $seatNumber'),
      children: [
        SimpleDialogOption(
          child: const Text('💀 Убить'),
          onPressed: () => Navigator.pop(context, 0),
        ),
        SimpleDialogOption(
          child: const Text('❤️ Оживить'),
          onPressed: () => Navigator.pop(context, 1),
        ),
        SimpleDialogOption(
          child: const Text('📢 Выставить'),
          onPressed: () => Navigator.pop(context, 2),
        ),
        SimpleDialogOption(
          child: const Text('❌ Снять'),
          onPressed: () => Navigator.pop(context, 3),
        ),
      ],
    );
  }
}