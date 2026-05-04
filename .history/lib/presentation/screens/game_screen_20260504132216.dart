import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pie_menu/pie_menu.dart';
import '../../domain/helpers/game_end_helper.dart';
import '../viewmodel/game_viewmodel.dart';
import '../widgets/player_grid.dart';
import '../widgets/phase_header.dart';
import '../widgets/phase_button.dart';

class GameScreen extends ConsumerWidget {
  final String gameId;
  
  const GameScreen({super.key, required this.gameId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return PieCanvas(
      child: _GameContent(gameId: gameId),
    );
  }
}

class _GameContent extends ConsumerWidget {
  final String gameId;
  
  const _GameContent({required this.gameId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final GameViewModel vm = ref.watch(gameViewModelF(gameId));
    final players = vm.players;

    return Scaffold(
      appBar: AppBar(
        title: Text('День ${vm.currentDay}'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () => _showSettingsMenu(context, ref, vm),
          ),
        ],
      ),
      body: Column(
        children: [
          PhaseHeader(
            phase: vm.currentPhase,
            subPhaseIndex: vm.currentSubPhaseIndex,
          ),
          Expanded(
            child: PlayerGrid(
              players: players,
              currentSpeaker: vm.currentSpeakerSeat,
              onTap: vm.onPlayerTap,
              onLongPress: (seat) => vm.onPlayerLongPress(seat, context),
            ),
          ),
          PhaseButton(
            onBack: vm.onPhaseBack,
            onForward: vm.onPhaseForward,
          ),
        ],
      ),
    );
  }

  void _showSettingsMenu(BuildContext context, WidgetRef ref, GameViewModel vm) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: const Icon(Icons.stop_circle, color: Colors.red),
            title: const Text('Завершить игру'),
            onTap: () {
              Navigator.pop(context);
              _showEndGameDialog(context, vm);
            },
          ),
          ListTile(
            leading: const Icon(Icons.refresh),
            title: const Text('Сбросить игру'),
            onTap: () {
              Navigator.pop(context);
              _confirmResetGame(context, vm);
            },
          ),
        ],
      ),
    );
  }

  void _showEndGameDialog(BuildContext context, GameViewModel vm) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Кто победил?'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              vm.onEndGame(GameResult.redWin);
            },
            child: const Text('Красные'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              vm.onEndGame(GameResult.blackWin);
            },
            child: const Text('Чёрные'),
          ),
        ],
      ),
    );
  }

  void _confirmResetGame(BuildContext context, GameViewModel vm) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Сбросить игру?'),
        content: const Text('Все данные будут потеряны'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Отмена'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              vm.onResetGame();
            },
            child: const Text('Сбросить'),
          ),
        ],
      ),
    );
  }
}