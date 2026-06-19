import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mafia_help/data/local/models/player_model.dart';
import 'package:pie_menu/pie_menu.dart';
import '../../core/logger/app_logger.dart';
import '../state/game_state.dart';
import '../viewmodel/game_viewmodel.dart';
import '../widgets/phase_header.dart';
import '../widgets/player_grid.dart';
import '../widgets/settings_menu.dart';
import '../widgets/pie_menu_dialog.dart';
import '../widgets/role_card.dart';
import '../widgets/player_timer_type.dart';
import '../widgets/floating_calculator.dart';
import '../../data/local/models/sub_phase.dart';
import 'game_protocol_screen.dart';

class GameScreen extends ConsumerStatefulWidget {
  final String gameId;
  final List<String?>? playerNames;
  final bool isTestGame;
  final int? tableNumber;
  final int? gameNumber;
  final DateTime? date;
  final String? judgeName;

  const GameScreen({
    super.key,
    required this.gameId,
    this.playerNames,
    this.isTestGame = true,
    this.tableNumber,
    this.gameNumber,
    this.date,
    this.judgeName,
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
    _vm = ref.read(gameViewModelFamily(widget.gameId).notifier);
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

  void _showVictoryDialog(String winner) {
    final winnerText =
        winner == 'red' ? '🔴 ПОБЕДА КРАСНЫХ' : '⚫ ПОБЕДА ЧЁРНЫХ';

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.grey.shade900,
        title: Text(
          winnerText,
          style: const TextStyle(color: Colors.white, fontSize: 24),
          textAlign: TextAlign.center,
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _dialogShown = false;
              _vm.onPhaseBack();
            },
            child: const Text(
              '◀️ ОТМЕНА',
              style: TextStyle(color: Colors.grey),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _dialogShown = false;
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => GameProtocolScreen(
                    gameHistory: _vm.getHistory(),
                    gameState: _vm.state,
                  ),
                ),
              );
            },
            child: const Text(
              '📋 ПРОТОКОЛ ИГРЫ',
              style: TextStyle(color: Colors.orange),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final gameState = ref.watch(gameViewModelFamily(widget.gameId));

    if (gameState.isGameEnded && !_dialogShown) {
      _dialogShown = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _showVictoryDialog(gameState.winner!);
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
    // Используем таймер из состояния
    final timerType = gameState.currentSpeakerTimer ?? PlayerTimerType.none;
    print('=== BUILD MAIN SCAFFOLD ===');
    print('currentSpeakerTimer = ${gameState.currentSpeakerTimer}');
    print('currentSpeakerSeat = ${gameState.currentSpeakerSeat}');
    return PieCanvas(
      child: Scaffold(
        backgroundColor: Colors.black87,
        appBar: AppBar(
          backgroundColor: Colors.grey.shade900,
          title: const Text('Mafia Help'),
          elevation: 0,
          actions: [
            IconButton(
              icon: const Icon(Icons.settings),
              onPressed: () => SettingsMenu.show(context, _vm),
            ),
          ],
        ),
        body: Stack(
          children: [
            // Основной контент
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  PhaseHeader(
                    phase: gameState.currentPhase,
                    subPhase: gameState.currentSubPhase,
                    currentDay: gameState.currentDay,
                    currentSpeaker: gameState.currentSpeakerSeat,
                  ),
                  const SizedBox(height: 20),
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
            // Плавающий калькулятор
            FloatingCalculator(gameId: widget.gameId),
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
