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