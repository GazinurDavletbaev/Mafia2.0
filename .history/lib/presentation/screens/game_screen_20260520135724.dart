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
import '../widgets/bottom_controls.dart';
import '../widgets/player_timer_type.dart';
import '../../data/local/models/sub_phase.dart';

class GameScreen extends ConsumerStatefulWidget {
  final String gameId;

  const GameScreen({super.key, required this.gameId});

  @override
  ConsumerState<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends ConsumerState<GameScreen> {
  late GameViewModel _vm;

  @override
  void initState() {
    super.initState();
    _vm = ref.read(gameViewModelFamily(widget.gameId).notifier);
  }

  @override
  void didUpdateWidget(covariant GameScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
  }

  PlayerTimerType _getTimerType(GameState state) {
    final subPhase = state.currentSubPhase;
    final currentSpeaker = state.currentSpeakerSeat;

    if (subPhase == SubPhase.speeches && currentSpeaker != null) {
      return PlayerTimerType.seconds60;
    }

    if (subPhase == SubPhase.tieBreak) {
      return PlayerTimerType.seconds30;
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

  @override
  Widget build(BuildContext context) {
    final gameState = ref.watch(gameViewModelFamily(widget.gameId));

    AppLogger.d(
      'BUILD gameScreen: currentSpeakerSeat=${gameState.currentSpeakerSeat}',
    );

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
    
    // Определяем, нужно ли показывать калькулятор
    final showCalculator = gameState.isVotingActive ||
        gameState.currentSubPhase == SubPhase.mafiaShoot ||
        gameState.currentSubPhase == SubPhase.donCheck ||
        gameState.currentSubPhase == SubPhase.sheriffCheck;

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
        body: Padding(
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
              if (gameState.nominatedSeats.isNotEmpty)
                CandidatesBar(
                  seats: gameState.nominatedSeats,
                  onTap: (seat) {},
                ),
              Expanded(
                child: PlayerGrid(
                  players: gameState.players,
                  currentSpeaker: gameState.currentSpeakerSeat,
                  timerType: timerType,
                  onTap: _vm.onPlayerTap,
                  onLongPress: (seat) => PieMenuDialog.show(context, seat, _vm),
                  currentSubPhase: gameState.currentSubPhase,
                  isVotingActive: gameState.isVotingActive,
                  voteController: gameState.voteController,
                ),
              ),
              const SizedBox(height: 20),
              SizeBox(BottomControls(
                onBack: () => _vm.onPhaseBack(),
                onForward: () => _vm.onPhaseForward(),
                showCalculator: showCalculator,
                onCalculatorTap: (value) {
                  if (gameState.isVotingActive) {
                    _vm.submitVote(value);
                  } else {
                    // Для ночных действий
                    _vm.submitNightAction(value);
                  }
                },
              ),
            ],
          ),
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