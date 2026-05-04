import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mafia_help/application/providers/providers.dart';
import 'package:mafia_help/data/local/models/phase_model.dart';
import 'package:mafia_help/presentation/widgets/player_card.dart';
import 'package:mafia_help/presentation/widgets/phase_button.dart';
import 'package:mafia_help/presentation/widgets/candidate_list.dart';
import 'package:mafia_help/presentation/widgets/number_pad.dart';
import 'package:mafia_help/presentation/widgets/circular_timer.dart';

class GameScreen extends ConsumerStatefulWidget {
  const GameScreen({super.key});

  @override
  ConsumerState<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends ConsumerState<GameScreen> {
  @override
  void initState() {
    super.initState();
    _loadSavedGame();
  }

  void _loadSavedGame() async {
    final repository = ref.read(gameRepositoryProvider);
    final savedState = await repository.loadCurrentGameState();
    if (savedState != null) {
      ref.read(gameStateProvider.notifier).setGameState(savedState);
    }
  }

  @override
  Widget build(BuildContext context) {
    final gameState = ref.watch(gameStateProvider);
    final timerState = ref.watch(timerProvider);
    final players = gameState.players;

    return Scaffold(
      appBar: AppBar(
        title: Text('День ${gameState.currentDay}'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () => _showSettingsMenu(context),
          ),
        ],
      ),
      body: Column(
        children: [
          // Текущая фаза
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.grey.shade900,
            child: Center(
              child: Column(
                children: [
                  Text(
                    _getPhaseTitle(gameState),
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  if (_shouldShowTimer(gameState))
                    CircularTimer(
                      seconds: timerState.remainingSeconds,
                      isRunning: timerState.isRunning,
                      onStart: () => ref.read(timerProvider.notifier).start(),
                      onPause: () => ref.read(timerProvider.notifier).pause(),
                      onStop: () => ref.read(timerProvider.notifier).stop(),
                    ),
                ],
              ),
            ),
          ),
          
          // Сетка игроков (5x2)
          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.all(16),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 5,
                childAspectRatio: 0.8,
                crossAxisSpacing: 8,
                mainAxisSpacing: 8,
              ),
              itemCount: players.length,
              itemBuilder: (context, index) {
                final player = players[index];
                return PlayerCard(
                  player: player,
                  isSpeaking: gameState.currentSpeakerSeat == player.seatNumber,
                  onTap: () => _onPlayerTap(player.seatNumber),
                  onLongPress: () => _showPieMenu(player.seatNumber),
                );
              },
            ),
          ),
          
          // Кандидаты на голосование
          if (_shouldShowCandidates(gameState))
            CandidateList(
              candidates: gameState.nominatedSeats,
              players: players,
              onRemove: (seat) => _removeNomination(seat),
            ),
          
          // Калькулятор голосов или лучшего хода
          if (_shouldShowNumberPad(gameState))
            NumberPad(
              onDigitPressed: (digit) => _onDigitPressed(digit),
              onDeletePressed: () => _onDeletePressed(),
              onSubmitPressed: () => _onSubmitPressed(),
            ),
          
          // Кнопка смены фазы
          PhaseButton(
            currentPhase: gameState.currentPhase,
            currentSubPhaseIndex: gameState.currentSubPhaseIndex,
            onBack: () => _changePhase(goForward: false),
            onForward: () => _changePhase(goForward: true),
          ),
        ],
      ),
    );
  }

  // ========== UI хелперы ==========
  
  String _getPhaseTitle(GameState state) {
    switch (state.currentPhase) {
      case Phase.night:
        return state.currentSubPhaseIndex == 0 ? '🌙 Ночь — Договорка' : '🌙 Ночь — Шериф осматривает';
      case Phase.day:
        final subPhases = ['🗣️ Речи', '🗳️ Голосование', '🔄 Переголосование', '⬆️ Подъём', '⏱️ Заключительная минута'];
        return subPhases[state.currentSubPhaseIndex];
      case Phase.voting:
        return '🗳️ Голосование за подъём';
    }
  }

  bool _shouldShowTimer(GameState state) {
    // Таймер показываем во время речей, заключительной минуты, договорки
    if (state.currentPhase == Phase.day) {
      return state.currentSubPhaseIndex == 0 || state.currentSubPhaseIndex == 4;
    }
    if (state.currentPhase == Phase.night && state.currentSubPhaseIndex == 0) {
      return true; // договорка
    }
    return false;
  }

  bool _shouldShowCandidates(GameState state) {
    // Показываем кандидатов во время голосования
    return state.currentPhase == Phase.day && 
           (state.currentSubPhaseIndex == 1 || state.currentSubPhaseIndex == 2);
  }

  bool _shouldShowNumberPad(GameState state) {
    // Показываем калькулятор во время голосования или лучшего хода
    if (state.currentPhase == Phase.day && 
        (state.currentSubPhaseIndex == 1 || state.currentSubPhaseIndex == 2)) {
      return true;
    }
    // Для лучшего хода (отдельный режим, можно добавить кнопку)
    return false;
  }

  // ========== Действия ==========
  
  void _onPlayerTap(int seatNumber) async {
    final addFoul = ref.read(addFoulUsecaseProvider);
    await addFoul(seatNumber);
    _saveGameState();
  }

  void _showPieMenu(int seatNumber) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Wrap(
        children: [
          ListTile(
            leading: const Icon(Icons.skull, color: Colors.red),
            title: const Text('Убить'),
            onTap: () {
              Navigator.pop(context);
              _killPlayer(seatNumber);
            },
          ),
          ListTile(
            leading: const Icon(Icons.favorite, color: Colors.green),
            title: const Text('Оживить'),
            onTap: () {
              Navigator.pop(context);
              _revivePlayer(seatNumber);
            },
          ),
          ListTile(
            leading: const Icon(Icons.person_add),
            title: const Text('Выставить на голосование'),
            onTap: () {
              Navigator.pop(context);
              _nominatePlayer(seatNumber);
            },
          ),
          ListTile(
            leading: const Icon(Icons.person_remove),
            title: const Text('Снять с голосования'),
            onTap: () {
              Navigator.pop(context);
              _removeNomination(seatNumber);
            },
          ),
        ],
      ),
    );
  }

  Future<void> _killPlayer(int seatNumber) async {
    final kill = ref.read(killPlayerUsecaseProvider);
    await kill(
      seatNumber: seatNumber,
      phase: _getCurrentPhaseString(),
      killType: 'manual',
    );
    _checkGameEnd();
    _saveGameState();
  }

  Future<void> _revivePlayer(int seatNumber) async {
    final revive = ref.read(revivePlayerUsecaseProvider);
    await revive(seatNumber);
    _saveGameState();
  }

  Future<void> _nominatePlayer(int seatNumber) async {
    final nominate = ref.read(nominatePlayerUsecaseProvider);
    await nominate(seatNumber);
    _saveGameState();
  }

  Future<void> _removeNomination(int seatNumber) async {
    final remove = ref.read(removeNominationUsecaseProvider);
    await remove(seatNumber);
    _saveGameState();
  }

  void _onDigitPressed(int digit) {
    final gameState = ref.read(gameStateProvider);
    final currentPhase = gameState.currentPhase;
    final subPhaseIndex = gameState.currentSubPhaseIndex;
    
    // Если в режиме голосования
    if (currentPhase == Phase.day && (subPhaseIndex == 1 || subPhaseIndex == 2)) {
      // Нужно знать выбранного кандидата
      // Для упрощения: показываем диалог выбора кандидата
      _showVoteDialog(digit);
    } else {
      // Режим лучшего хода
      final addDigit = ref.read(addBestMoveUsecaseProvider);
      addDigit(digit);
    }
    _saveGameState();
  }

  void _showVoteDialog(int voteCount) {
    final gameState = ref.read(gameStateProvider);
    final candidates = gameState.nominatedSeats;
    
    if (candidates.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Нет выставленных кандидатов')),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Кому отдать голоса?'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: candidates.map((seat) {
            final player = gameState.getPlayerBySeat(seat);
            return ListTile(
              title: Text('Место $seat — ${player?.customName ?? 'Игрок $seat'}'),
              onTap: () {
                Navigator.pop(context);
                _addVote(seat, voteCount);
              },
            );
          }).toList(),
        ),
      ),
    );
  }

  Future<void> _addVote(int targetSeat, int voteCount) async {
    final addVote = ref.read(addVoteUsecaseProvider);
    final gameState = ref.read(gameStateProvider);
    await addVote(
      round: gameState.currentRound,
      targetSeat: targetSeat,
      voteCount: voteCount,
    );
    _saveGameState();
  }

  void _onDeletePressed() {
    final pop = ref.read(popBestMoveUsecaseProvider);
    pop();
    _saveGameState();
  }

  void _onSubmitPressed() {
    final gameState = ref.read(gameStateProvider);
    final currentPhase = gameState.currentPhase;
    final subPhaseIndex = gameState.currentSubPhaseIndex;
    
    if (currentPhase == Phase.day && (subPhaseIndex == 1 || subPhaseIndex == 2)) {
      // Очищаем голоса после подсчёта
      final clearVotes = ref.read(clearVotesUsecaseProvider);
      clearVotes();
    } else {
      // Сохраняем лучший ход
      final commit = ref.read(commitBestMoveUsecaseProvider);
      commit();
    }
    _saveGameState();
  }

  Future<void> _changePhase({required bool goForward}) async {
    final changePhase = ref.read(changePhaseUsecaseProvider);
    await changePhase(goForward: goForward);
    
    // Сбрасываем таймер при смене фазы
    final timerNotifier = ref.read(timerProvider.notifier);
    timerNotifier.setSeconds(60);
    timerNotifier.stop();
    
    _checkGameEnd();
    _saveGameState();
  }

  Future<void> _checkGameEnd() async {
    final checkEnd = ref.read(checkGameEndUsecaseProvider);
    final result = await checkEnd();
    
    if (result != null && mounted) {
      final endGame = ref.read(endGameUsecaseProvider);
      await endGame(result);
      
      _showGameEndDialog(result);
    }
    _saveGameState();
  }

  void _showGameEndDialog(GameResult result) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Text(result == GameResult.redWin ? '🏆 Победа красных!' : '🏆 Победа чёрных!'),
        content: const Text('Игра завершена.'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context); // Возврат на экран клуба
            },
            child: const Text('Выйти'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _resetGame();
            },
            child: const Text('Новая игра'),
          ),
        ],
      ),
    );
  }

  Future<void> _resetGame() async {
    final reset = ref.read(resetGameUsecaseProvider);
    await reset();
    final timerNotifier = ref.read(timerProvider.notifier);
    timerNotifier.reset();
    _saveGameState();
  }

  void _showSettingsMenu(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Wrap(
        children: [
          ListTile(
            leading: const Icon(Icons.stop_circle, color: Colors.red),
            title: const Text('Завершить игру досрочно'),
            onTap: () {
              Navigator.pop(context);
              _confirmEndGame();
            },
          ),
          ListTile(
            leading: const Icon(Icons.refresh),
            title: const Text('Сбросить игру'),
            onTap: () {
              Navigator.pop(context);
              _confirmResetGame();
            },
          ),
        ],
      ),
    );
  }

  void _confirmEndGame() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Завершить игру?'),
        content: const Text('Игра будет сохранена в истории.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Отмена'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _endGameManually();
            },
            child: const Text('Завершить'),
          ),
        ],
      ),
    );
  }

  Future<void> _endGameManually() async {
    // Определяем победителя (нужен выбор)
    final result = GameResult.redWin; // или черные — нужен диалог выбора
    final endGame = ref.read(endGameUsecaseProvider);
    await endGame(result);
    _saveGameAndExit(result);
  }

  void _confirmResetGame() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Сбросить игру?'),
        content: const Text('Все данные текущей игры будут потеряны.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Отмена'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _resetGame();
            },
            child: const Text('Сбросить'),
          ),
        ],
      ),
    );
  }

  String _getCurrentPhaseString() {
    final gameState = ref.read(gameStateProvider);
    switch (gameState.currentPhase) {
      case Phase.night:
        return 'night';
      case Phase.day:
        return 'day';
      case Phase.voting:
        return 'voting';
    }
  }

  Future<void> _saveGameState() async {
    final repository = ref.read(gameRepositoryProvider);
    await repository.saveCurrentGameState();
  }

  Future<void> _saveGameAndExit(GameResult result) async {
    final repository = ref.read(gameRepositoryProvider);
    final gameState = ref.read(gameStateProvider);
    
    // Сохраняем завершённую игру в историю
    await repository.saveCompletedGame(gameState);
    
    // Очищаем текущую игру
    await repository.clearCurrentGameState();
    
    if (mounted) {
      Navigator.pop(context);
    }
  }
}