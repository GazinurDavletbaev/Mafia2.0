import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pie_menu/pie_menu.dart';
import '../../domain/helpers/game_end_helper.dart';
import '../state/game_state.dart';
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
    _vm = ref.read(gameViewModelFamily(widget.gameId).notifier);
  }

  @override
  Widget build(BuildContext context) {
    final gameState = ref.watch(gameViewModelFamily(widget.gameId));

    return PieCanvas(
      child: Scaffold(
        backgroundColor: Colors.black87,
        appBar: AppBar(
          backgroundColor: Colors.grey.shade900,
          title: const Text('Mafia_Help'),
          elevation: 0,
          actions: [
            IconButton(
              icon: const Icon(Icons.settings),
              onPressed: () => _showSettingsMenu(context),
            ),
          ],
        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              // Верхняя панель с названием подфазы
              Container(
                height: 40,
                color: Colors.grey.shade900,
                child: Center(
                  child: Text(
                    _getSubPhaseTitle(gameState),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              // Список кандидатов
              if (gameState.nominatedSeats.isNotEmpty) ...[
                _buildCandidatesList(gameState),
                const SizedBox(height: 10),
              ],
              // Сетка игроков
              Expanded(
                child: PlayerGrid(
                  players: gameState.players,
                  currentSpeaker: gameState.currentSpeakerSeat,
                  onTap: _vm.onPlayerTap,
                  onLongPress: (seat) => _showPieMenu(seat, context),
                ),
              ),
              const SizedBox(height: 20),
              // Кнопка смены фаз
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

  Widget _buildCandidatesList(GameState gameState) {
    return SizedBox(
      height: 60,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: gameState.nominatedSeats.length,
        itemBuilder: (context, index) {
          final seat = gameState.nominatedSeats[index];
          return GestureDetector(
            onTap: () => _showVoteDialog(seat),
            child: Container(
              width: 60,
              margin: const EdgeInsets.only(right: 8),
              decoration: BoxDecoration(
                color: Colors.orange,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Center(
                child: Text(
                  '$seat',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  void _showVoteDialog(int seat) {
    // TODO: показать калькулятор для ввода голосов
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Голоса за место $seat'),
        content: const Text('TODO: добавить калькулятор'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Закрыть'),
          ),
        ],
      ),
    );
  }

  void _showPieMenu(int seat, BuildContext context) async {
    final result = await showDialog<int>(
      context: context,
      builder: (_) => _PieMenuDialog(seatNumber: seat),
    );
    if (result != null) {
      _vm.onPlayerLongPress(seat, result);
    }
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

  String _getSubPhaseTitle(GameState state) {
    // TODO: вернуть русское название текущей подфазы
    return '${state.currentPhase.name} / ${state.currentSubPhase.name}';
  }
}

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
