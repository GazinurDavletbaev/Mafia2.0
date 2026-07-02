import 'package:flutter/material.dart';
import '../viewmodel/game_viewmodel.dart';

class PieMenuDialog {
  static Future<void> show(
    BuildContext context,
    int seat,
    GameViewModel vm,
  ) async {
    final result = await showDialog<int>(
      context: context,
      builder: (_) => _PieMenuContent(seatNumber: seat),
    );
    if (result != null) {
      vm.onPlayerLongPress(seat, result);
    }
  }
}

class _PieMenuContent extends StatelessWidget {
  final int seatNumber;
  const _PieMenuContent({required this.seatNumber});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return SimpleDialog(
      backgroundColor: isDark ? Colors.grey.shade900 : Colors.white,
      title: Text(
        'Игрок место $seatNumber',
        style: TextStyle(
          color: isDark ? Colors.white : Colors.black87,
        ),
      ),
      children: [
        SimpleDialogOption(
          child: Text(
            '💀 Убить',
            style: TextStyle(
              color: isDark ? Colors.white : Colors.black87,
            ),
          ),
          onPressed: () => Navigator.pop(context, 0),
        ),
        SimpleDialogOption(
          child: Text(
            '❤️ Оживить',
            style: TextStyle(
              color: isDark ? Colors.white : Colors.black87,
            ),
          ),
          onPressed: () => Navigator.pop(context, 1),
        ),
        SimpleDialogOption(
          child: Text(
            '📢 Выставить',
            style: TextStyle(
              color: isDark ? Colors.white : Colors.black87,
            ),
          ),
          onPressed: () => Navigator.pop(context, 2),
        ),
        SimpleDialogOption(
          child: Text(
            '❌ Снять',
            style: TextStyle(
              color: isDark ? Colors.white : Colors.black87,
            ),
          ),
          onPressed: () => Navigator.pop(context, 3),
        ),
      ],
    );
  }
}
