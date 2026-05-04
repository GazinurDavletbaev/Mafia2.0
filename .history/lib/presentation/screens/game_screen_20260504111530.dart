import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mafia_help/presentation/viewmodels/game_viewmodel.dart';
import 'package:mafia_help/presentation/widgets/player_grid.dart';
import 'package:mafia_help/presentation/widgets/phase_header.dart';
import 'package:mafia_help/presentation/widgets/phase_button.dart';

class GameScreen extends ConsumerWidget {
  const GameScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final vm = ref.watch(gameViewModelProvider);
    final players = vm.players;

    return Scaffold(
      appBar: AppBar(
        title: Text('День ${vm.currentDay}'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () => _showSettingsMenu(context, ref),
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
              onTap: (seat) => vm.onPlayerTap(seat),
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

  void _showSettingsMenu(BuildContext context, WidgetRef ref) {
    final vm = ref.read(gameViewModelProvider.notifier);
    
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