import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mafia_help/application/providers/game_provider.dart';
import 'package:mafia_help/presentation/screens/lobby/lobby_data.dart';
import 'package:mafia_help/presentation/viewmodel/game_viewmodel.dart';

class GameNewButton extends ConsumerStatefulWidget {
  final VoidCallback? onNewGame;
  final String? label;
  final bool isFullWidth;

  const GameNewButton({
    super.key,
    this.onNewGame,
    this.label = 'НОВАЯ ИГРА',
    this.isFullWidth = true,
  });

  @override
  ConsumerState<GameNewButton> createState() => _GameNewButtonState();
}

class _GameNewButtonState extends ConsumerState<GameNewButton> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return SizedBox(
      width: widget.isFullWidth ? double.infinity : null,
      child: ElevatedButton(
        onPressed: _showNewGameDialog,
        style: ElevatedButton.styleFrom(
          backgroundColor: isDark ? Colors.grey.shade800 : Colors.grey.shade200,
          foregroundColor: isDark ? Colors.white : Colors.black87,
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: Center(
          child: Text(
            widget.label!,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }

  void _showNewGameDialog() {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: isDark ? Colors.grey.shade900 : Colors.white,
        title: Center(
          child: Text(
            'Удалить?',
            style: TextStyle(
              color: isDark ? Colors.white : Colors.black87,
            ),
            textAlign: TextAlign.center,
          ),
        ),
        content: Center(
          child: Text(
            'Текущая игра будет удалена!\nМожно будет начать новую.',
            style: TextStyle(
              color: isDark ? Colors.white70 : Colors.black54,
            ),
            textAlign: TextAlign.center,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: SizedBox(
              width: double.infinity,
              child: Center(
                child: Text(
                  'Отмена',
                  style: TextStyle(
                    color: isDark ? Colors.grey : Colors.grey.shade600,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _onNewGame();
            },
            child: SizedBox(
              width: double.infinity,
              child: Center(
                child: const Text(
                  'Удалить',
                  style: TextStyle(color: Colors.orange),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _onNewGame() {
    print('🔄 Создаём новую игру...');

    ref.read(savedGameIdProvider.notifier).state = null;

    final vm = ref.read(gameViewModelProvider.notifier);
    vm.resetGame();

    if (widget.onNewGame != null) {
      widget.onNewGame!();
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('🔄 Можно начать новую игру!'),
        backgroundColor: Theme.of(context).primaryColor,
        duration: const Duration(seconds: 2),
      ),
    );
  }
}
