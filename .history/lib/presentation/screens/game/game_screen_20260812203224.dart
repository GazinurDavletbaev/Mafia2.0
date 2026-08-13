import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mafia_help/presentation/screens/lobby/lobby_data.dart';
import 'package:mafia_help/presentation/widgets/tip_manager.dart';
import 'package:mdi_plus/mdi_plus.dart';
import 'package:pie_menu/pie_menu.dart';
import '../../state/game_state.dart';
import '../../viewmodel/game_viewmodel.dart';
import '../../widgets/phase_header.dart';
import '../../widgets/player_grid.dart';
import '../../widgets/pie_menu_dialog.dart';
import '../../widgets/role_card.dart';
import '../../widgets/player_timer_type.dart';
import '../../widgets/floating_calculator.dart';

class GameScreen extends ConsumerStatefulWidget {
  final GameData initialData;
  final Function(GameData) onGameStateChanged;
  final Function(int) onSwitchToTab;

  const GameScreen({
    super.key,
    required this.initialData,
    required this.onGameStateChanged,
    required this.onSwitchToTab,
  });

  @override
  ConsumerState<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends ConsumerState<GameScreen> {
  late GameViewModel _vm;
  bool _dialogShown = false;

  @override
  void initState() {
    super.initState();
    _vm = ref.read(gameViewModelProvider.notifier);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      print('=== GAME SCREEN INIT ===');
      print('playerNames: ${widget.initialData.playerNames}');
      print(
          'gameState.players: ${widget.initialData.gameState.players.map((p) => p.name)}');

      final players = widget.initialData.gameState.players;
      final namesFromData = widget.initialData.playerNames;
      final avatars = players.map((p) => p.avatarUrl).toList(); // ✅

      print('📦 avatars: $avatars'); // ✅ ДОБАВЬ

      final hasNames = namesFromData.any((name) => name.isNotEmpty);

      if (hasNames) {
        _vm.initializeGame(
          playerNames: namesFromData,
          avatars: avatars, // ✅
          tableNumber: widget.initialData.tableNumber,
          gameNumber: widget.initialData.gameNumber,
          gameDate: widget.initialData.date,
          judgeName: widget.initialData.judgeName,
          tournamentName: widget.initialData.tournamentName,
          stageName: widget.initialData.stageName,
        );
        _notifyGameStateChanged();
      } else {
        final playerNamesFromState = players.map((p) => p.name).toList();
        final hasStateNames =
            playerNamesFromState.any((name) => name.isNotEmpty);
        if (hasStateNames) {
          widget.onGameStateChanged(
            GameData(
              tournamentName: widget.initialData.tournamentName,
              stageName: widget.initialData.stageName,
              tableNumber: widget.initialData.tableNumber,
              gameNumber: widget.initialData.gameNumber,
              date: widget.initialData.date,
              judgeName: widget.initialData.judgeName,
              playerNames: playerNamesFromState,
              gameState: widget.initialData.gameState,
              gameHistory: widget.initialData.gameHistory,
            ),
          );
          _vm.initializeGame(
            playerNames: playerNamesFromState,
            avatars: avatars, // ✅ ДОБАВИТЬ
            tableNumber: widget.initialData.tableNumber,
            gameNumber: widget.initialData.gameNumber,
            gameDate: widget.initialData.date,
            judgeName: widget.initialData.judgeName,
            tournamentName: widget.initialData.tournamentName,
            stageName: widget.initialData.stageName,
          );
          _notifyGameStateChanged();
        }
      }
    });
  }

  @override
  void didUpdateWidget(covariant GameScreen oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (_vm.state.isGameEnded && !_dialogShown) {
      _dialogShown = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _showVictoryDialog(_vm.state.winner!);
      });
    }
  }

  void _notifyGameStateChanged() {
    widget.onGameStateChanged(
      GameData(
        tournamentName: widget.initialData.tournamentName,
        stageName: widget.initialData.stageName,
        tableNumber: widget.initialData.tableNumber,
        gameNumber: widget.initialData.gameNumber,
        date: widget.initialData.date,
        judgeName: widget.initialData.judgeName,
        playerNames: widget.initialData.playerNames,
        gameState: _vm.state,
        gameHistory: _vm.getHistory(),
      ),
    );
  }

  void _showVictoryDialog(String winner) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final bool isRedWon = winner == 'red';

    final icon = isRedWon ? Mdi.accountGroup : Mdi.redhat;

    final iconColor = isRedWon ? Colors.red : Colors.black;

    final titleText = isRedWon ? 'ПОБЕДА КРАСНЫХ' : 'ПОБЕДА ЧЁРНЫХ';

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: isDark ? Colors.grey.shade900 : Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Column(
          children: [
            Icon(
              icon,
              size: 80,
              color: iconColor,
            ),
            const SizedBox(height: 12),
            Text(
              titleText,
              style: TextStyle(
                color: isDark ? Colors.white : Colors.black87,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
        actions: [
          Row(
            children: [
              // 🔥 КНОПКА ОТМЕНА
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  _dialogShown = false;
                  _vm.onPhaseBack();
                  _notifyGameStateChanged();
                },
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Mdi.undo,
                      size: 18,
                      color: isDark ? Colors.grey : Colors.grey.shade600,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'ОТМЕНА',
                      style: TextStyle(
                        color: isDark ? Colors.grey : Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),
              // 🔥 КНОПКА ПРОТОКОЛ
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  _dialogShown = false;
                  _notifyGameStateChanged();
                  widget.onSwitchToTab(3);
                },
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Mdi.fileDocument,
                      size: 18,
                      color: Colors.orange,
                    ),
                    const SizedBox(width: 8),
                    const Text(
                      'ПРОТОКОЛ',
                      style: TextStyle(color: Colors.orange),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final gameState = _vm.state;

    if (gameState.isGameEnded && !_dialogShown) {
      _dialogShown = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _showVictoryDialog(gameState.winner!);
        _notifyGameStateChanged();
      });
    }

    if (gameState.showingRoleForSeat != null) {
      final player = gameState.getPlayerBySeat(gameState.showingRoleForSeat!);
      if (player != null && player.role != 'unknown') {
        return RoleCard(
          role: _getRoleImageName(player.role),
          seatNumber: player.seatNumber,
          onClose: () => _vm.closeRoleCard(),
        );
      }
    }

    return _buildMainScaffold(gameState);
  }

  Widget _buildMainScaffold(GameState gameState) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final timerType = gameState.currentSpeakerTimer ?? PlayerTimerType.none;
if (gameState.currentSubPhase == SubPhase.seatSetup) {
  // 🔥 ПОКАЗЫВАЕМ ВИДЖЕТ РАССАДКИ
  return _buildSeatSetupWidget();
}
    return PieCanvas(
      child: Scaffold(
        backgroundColor: theme.scaffoldBackgroundColor,
        body: Stack(
          children: [
            // 🔥 ОСНОВНОЙ КОНТЕНТ
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  Expanded(
                    child: PlayerGrid(
                      players: gameState.players,
                      currentSpeaker: gameState.currentSpeakerSeat,
                      timerType: timerType,
                      onTap: _vm.onPlayerTap,
                      onLongPress: (seat) =>
                          PieMenuDialog.show(context, seat, _vm),
                      currentSubPhase: gameState.currentSubPhase,
                      isVotingActive: gameState.isVotingActive,
                      voteController: gameState.voteController,
                      partialBestMove: gameState.partialBestMove,
                      tiedSeats: gameState.tiedSeats,
                      nominatedSeats: gameState.nominatedSeats,
                      nightActions: gameState.nightActions ?? [],
                      currentDay: gameState.currentDay,
                      phase: gameState.currentPhase,
                      eliminationVotes: gameState.eliminationVotes,
                      onSwipeUp: _vm.onSwipeUp,
                      onSwipeDown: _vm.onSwipeDown,
                      onSwipeLeft: _vm.onSwipeLeft,
                      onSwipeRight: _vm.onSwipeRight,
                    ),
                  ),
                  const SizedBox(height: 20),
                  const SizedBox.shrink(),
                ],
              ),
            ),
            // 🔥 УВЕДОМЛЕНИЕ (PhaseHeader) ПОВЕРХ
            Positioned(
              top: 10,
              left: 0,
              right: 0,
              child: PhaseHeader(
                phase: gameState.currentPhase,
                subPhase: gameState.currentSubPhase,
                currentDay: gameState.currentDay,
                currentSpeaker: gameState.currentSpeakerSeat,
              ),
            ),
            FloatingCalculator(),
          ],
        ),
      ),
    );
  }

  String _getRoleImageName(String role) {
    switch (role) {
      case 'citizen':
        return 'citizen';
      case 'sheriff':
        return 'sheriff';
      case 'mafia':
        return 'mafia';
      case 'don':
        return 'don';
      default:
        return 'citizen';
    }
  }
}
