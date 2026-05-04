import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pie_menu/pie_menu.dart';
import '../../domain/helpers/game_end_helper.dart';
import '../viewmodel/game_viewmodel.dart';
import '../widgets/player_grid.dart';
import '../widgets/phase_header.dart';
import '../widgets/phase_button.dart';

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
    // Получаем notifier (ViewModel) через .notifier
    _vm = ref.read(gameViewModelFamily(widget.gameId).notifier);
  }

  @override
  Widget build(BuildContext context) {
    // Слушаем состояние через .watch
    final gameState = ref.watch(gameViewModelFamily(widget.gameId));
    
    return PieCanvas(
      child: Scaffold(
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
            PhaseHeader(
              phase: gameState.currentPhase,
              subPhaseIndex: gameState.currentSubPhaseIndex,
            ),
            Expanded(
              child: PlayerGrid(
                players: gameState.players,
                currentSpeaker: gameState.currentSpeakerSeat,
                onTap: _vm.onPlayerTap,
                onLongPress: (seat) => _vm.onPlayerLongPress(seat, context),
              ),
            ),
            PhaseButton(
              onBack: _vm.onPhaseBack,
              onForward: _vm.onPhaseForward,
            ),
          ],
        ),
      ),
    );
  }

  void _showSettingsMenu(BuildContext context) {
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
              _showEndGameDialog(context);
            },
          ),
          ListTile(
            leading: const Icon(Icons.refresh),
            title: const Text('Сбросить игру'),
            onTap: () {
              Navigator.pop(context);
              _confirmResetGame(context);
            },
          ),
        ],
      ),
    );
  }

  void _showEndGameDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Кто победил?'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _vm.onEndGame(GameResult.redWin);
            },
            child: const Text('Красные'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _vm.onEndGame(GameResult.blackWin);
            },
            child: const Text('Чёрные'),
          ),
        ],
      ),
    );
  }

  void _confirmResetGame(BuildContext context) {
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
              _vm.onResetGame();
            },
            child: const Text('Сбросить'),
          ),
        ],
      ),
    );
  }
}
EOF