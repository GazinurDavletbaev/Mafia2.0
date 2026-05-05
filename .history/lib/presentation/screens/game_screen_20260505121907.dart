import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pie_menu/pie_menu.dart';
import '../../core/logger/app_logger.dart';
import '../state/game_state.dart';
import '../viewmodel/game_viewmodel.dart';
import '../widgets/player_grid.dart';
import '../widgets/phase_header.dart';
import '../widgets/phase_button.dart';
import '../widgets/candidates_bar.dart';
import '../widgets/settings_menu.dart';
import '../widgets/pie_menu_dialog.dart';
import '../widgets/role_card.dart';

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
  Widget build(BuildContext context) {
    final gameState = ref.watch(gameViewModelFamily(widget.gameId));

    // Если показываем карточку роли
    if (gameState.showingRoleForSeat != null) {
      AppLogger.d('Showing role card for seat ${gameState.showingRoleForSeat}');

      final player = gameState.getPlayerBySeat(gameState.showingRoleForSeat!);
      
      if (player != null && player.role != 'unknown') {
        return Stack(
          children: [
            _buildMainScaffold(gameState),
            RoleCard(
              role: _getRoleImageName(player.role),
              onClose: () => _vm.toggleRoleCard(gameState.showingRoleForSeat!),
            ),
          ],
        );
      }
    }

    return _buildMainScaffold(gameState);
  }

  Widget _buildMainScaffold(GameState gameState) {
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
                subPhaseIndex: gameState.currentSubPhaseIndex,
              ),
              const SizedBox(height: 20),
              if (gameState.nominatedSeats.isNotEmpty)
                CandidatesBar(
                  seats: gameState.nominatedSeats,
                  onTap: (seat) => _vm.addVote(seat, 0),
                ),
              Expanded(
                child: PlayerGrid(
                  players: gameState.players,
                  currentSpeaker: gameState.currentSpeakerSeat,
                  onTap: _vm.onPlayerTap,
                  onLongPress: (seat) => PieMenuDialog.show(context, seat, _vm),
                ),
              ),
              const SizedBox(height: 20),
              PhaseButton(
                onBack: _vm.onPhaseBack,
                onForward: _vm.onPhaseForward,
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _getRoleImageName(String role) {
    switch (role) {
      case 'citizen': return 'citizen';
      case 'sheriff': return 'sheriff';
      case 'mafia': return 'mafia';
      case 'don': return 'don';
      default: return 'citizen';
    }
  }
}