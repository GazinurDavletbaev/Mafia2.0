import 'package:flutter/material.dart';
import 'package:mdi_plus/mdi_plus.dart';
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
    final primaryColor = theme.primaryColor;

    return SimpleDialog(
      backgroundColor: isDark ? Colors.grey.shade900 : Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      children: [
        // 🔥 УДАЛИТЬ (вместо убить)
        SimpleDialogOption(
          onPressed: () => Navigator.pop(context, 0),
          child: Row(
            children: [
              Icon(
                Mdi.accountRemove,
                color: Colors.red,
                size: 24,
              ),
              const SizedBox(width: 12),
              Text(
                'Удалить',
                style: TextStyle(
                  color: isDark ? Colors.white : Colors.black87,
                  fontSize: 16,
                ),
              ),
            ],
          ),
        ),
        const Divider(height: 1),

        // 🔥 ВЕРНУТЬ ЗА СТОЛ (вместо оживить)
        SimpleDialogOption(
          onPressed: () => Navigator.pop(context, 1),
          child: Row(
            children: [
              Icon(
                Mdi.accountPlus,
                color: Colors.green,
                size: 24,
              ),
              const SizedBox(width: 12),
              Text(
                'Вернуть за стол',
                style: TextStyle(
                  color: isDark ? Colors.white : Colors.black87,
                  fontSize: 16,
                ),
              ),
            ],
          ),
        ),
        const Divider(height: 1),

        // 🔥 ВЫСТАВИТЬ
        SimpleDialogOption(
          onPressed: () => Navigator.pop(context, 2),
          child: Row(
            children: [
              Icon(
                Mdi.accountArrowUp,
                color: primaryColor,
                size: 24,
              ),
              const SizedBox(width: 12),
              Text(
                'Выставить',
                style: TextStyle(
                  color: isDark ? Colors.white : Colors.black87,
                  fontSize: 16,
                ),
              ),
            ],
          ),
        ),
        const Divider(height: 1),

        // 🔥 СНЯТЬ
        SimpleDialogOption(
          onPressed: () => Navigator.pop(context, 3),
          child: Row(
            children: [
              Icon(
                Mdi.accountArrowDown,
                color: Colors.orange,
                size: 24,
              ),
              const SizedBox(width: 12),
              Text(
                'Снять',
                style: TextStyle(
                  color: isDark ? Colors.white : Colors.black87,
                  fontSize: 16,
                ),
              ),
            ],
          ),
        ),
        const Divider(height: 1),

        // 🔥 ТЕХНИЧЕСКИЙ ФОЛ
        SimpleDialogOption(
          onPressed: () => Navigator.pop(context, 4),
          child: Row(
            children: [
              Icon(
                Mdi.alertCircle,
                color: Colors.,
                size: 24,
              ),
              const SizedBox(width: 12),
              Text(
                'Тех. фол',
                style: TextStyle(
                  color: isDark ? Colors.white : Colors.black87,
                  fontSize: 16,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
