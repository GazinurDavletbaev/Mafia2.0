import 'package:flutter/material.dart';

class GameNewButton extends StatelessWidget {
  final VoidCallback onNewGame;
  final String? label;
  final bool isFullWidth;

  const GameNewButton({
    super.key,
    required this.onNewGame,
    this.label = 'НОВАЯ ИГРА',
    this.isFullWidth = true,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return SizedBox(
      width: isFullWidth ? double.infinity : null,
      child: ElevatedButton(
        onPressed: () => _showNewGameDialog(context),
        style: ElevatedButton.styleFrom(
          backgroundColor: isDark ? Colors.grey.shade800 : Colors.grey.shade200,
          foregroundColor: isDark ? Colors.white : Colors.black87,
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: Text(
          label!,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  void _showNewGameDialog(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: isDark ? Colors.grey.shade900 : Colors.white,
        title: Text(
          'Новая игра?',
          style: TextStyle(
            color: isDark ? Colors.white : Colors.black87,
          ),
        ),
        content: Text(
          'Все несохранённые данные будут потеряны.\nИмя судьи будет сохранено.',
          style: TextStyle(
            color: isDark ? Colors.white70 : Colors.black54,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Отмена',
              style: TextStyle(
                color: isDark ? Colors.grey : Colors.grey.shade600,
              ),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              onNewGame();
            },
            child: const Text(
              'Создать',
              style: TextStyle(color: Colors.orange),
            ),
          ),
        ],
      ),
    );
  }
}