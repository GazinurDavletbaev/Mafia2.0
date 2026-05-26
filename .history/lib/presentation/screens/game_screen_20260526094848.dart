import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pie_menu/pie_menu.dart';
import '../../core/logger/app_logger.dart';
import '../state/game_state.dart';
import '../state/game_state_extentions.dart';
import '../viewmodel/game_viewmodel.dart';
import '../widgets/player_grid.dart';
import '../widgets/phase_header.dart';
import '../widgets/candidates_bar.dart';
import '../widgets/settings_menu.dart';
import '../widgets/pie_menu_dialog.dart';
import '../widgets/role_card.dart';
import '../widgets/player_timer_type.dart';
import '../widgets/floating_calculator.dart';
import '../../data/local/models/sub_phase.dart';
import 'game_protocol_screen.dart';

class GameScreen extends ConsumerStatefulWidget {
  final String gameId;

  const GameScreen({super.key, required this.gameId});

  @override
  ConsumerState<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends ConsumerState<GameScreen> {
  late GameViewModel _vm;
  bool _dialogShown = false; // ← добавить

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

  PlayerTimerType _getTimerType(GameState state) {
    final subPhase = state.currentSubPhase;
    final currentSpeaker = state.currentSpeakerSeat;

    if (subPhase == SubPhase.speeches && currentSpeaker != null) {
      return PlayerTimerType.seconds60;
    }
    if (subPhase == SubPhase.finalWordKill && currentSpeaker != null) {
      return PlayerTimerType.seconds60;
    }
    if (subPhase == SubPhase.tieBreak && currentSpeaker != null) {
      return PlayerTimerType.seconds30; // 30 секунд на кандидата
    }

    if (subPhase == SubPhase.finalWord && currentSpeaker != null) {
      return PlayerTimerType.seconds60;
    }

    if (subPhase == SubPhase.bestMove && currentSpeaker != null) {
      return PlayerTimerType.seconds20;
    }

    if (subPhase == SubPhase.sheriffLook || subPhase == SubPhase.sheriffCheck) {
      final sheriff = state.players.firstWhere(
        (p) => p.role == 'sheriff',
        orElse: () => throw Exception('Sheriff not found'),
      );
      if (currentSpeaker == sheriff.seatNumber) {
        return subPhase == SubPhase.sheriffLook
            ? PlayerTimerType.seconds20
            : PlayerTimerType.seconds10;
      }
    }

    if (subPhase == SubPhase.donCheck) {
      final don = state.players.firstWhere(
        (p) => p.role == 'don',
        orElse: () => throw Exception('Don not found'),
      );
      if (currentSpeaker == don.seatNumber) {
        return PlayerTimerType.seconds10;
      }
    }

    if (subPhase == SubPhase.contract) {
      final don = state.players.firstWhere(
        (p) => p.role == 'don',
        orElse: () => throw Exception('Don not found'),
      );
      if (currentSpeaker == don.seatNumber) {
        return PlayerTimerType.seconds60;
      }
    }

    return PlayerTimerType.none;
  }

  // В GameScreen, когда isGameEnded == true, показываем диалог
  void _showVictoryDialog(String winner) {
    final winnerText = winner == 'red'
        ? '🔴 ПОБЕДА КРАСНЫХ'
        : '⚫ ПОБЕДА ЧЁРНЫХ';

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

    print(
      'BUILD gameScreen: subPhase=${gameState.currentSubPhase}, day=${gameState.currentDay}',
    );

    if (gameState.isGameEnded && !_dialogShown) {
      _dialogShown = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _showVictoryDialog(gameState.winner!);
      });
    }

    if (gameState.showingRoleForSeat != null) {
      AppLogger.d('Showing role card for seat ${gameState.showingRoleForSeat}');
      final player = gameState.getPlayerBySeat(gameState.showingRoleForSeat!);
      AppLogger.d('Player role: ${player?.role}');
      if (player != null && player.role != 'unknown') {
        return RoleCard(
          role: _getRoleImageName(player.role),
          onClose: () => _vm.closeRoleCard(),
        );
      }
    }

    return _buildMainScaffold(gameState);
  }

  Widget _buildMainScaffold(GameState gameState) {
    final timerType = _getTimerType(gameState);

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
                    nominatedSeats: gameState.nominatedSeats, // ← добавить
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
                      partialBestMove: gameState.partialBestMove, // ← добавить
                      tiedSeats: gameState.tiedSeats,
                      nominatedSeats: [],
                    ),
                  ),
                  const SizedBox(height: 20),
                  const SizedBox.shrink(), // Место для BottomControls удалено
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
