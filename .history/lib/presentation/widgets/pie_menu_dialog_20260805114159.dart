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
      barrierColor: Colors.transparent,
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

    return Center(
      child: Container(
        width: 200,
        decoration: BoxDecoration(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // 🔥 КНОПКА 1: УДАЛИТЬ
            _buildMenuItem(
              context: context,
              icon: Mdi.accountRemove,
              iconColor: Colors.red,
              label: 'Удалить',
              value: 0,
              isDark: isDark,
            ),
            const SizedBox(height: 5), // 🔥 ОТСТУП МЕЖДУ КНОПКАМИ

            // 🔥 КНОПКА 2: ВЕРНУТЬ ЗА СТОЛ
            _buildMenuItem(
              context: context,
              icon: Mdi.accountPlus,
              iconColor: Colors.green,
              label: 'Вернуть за стол',
              value: 1,
              isDark: isDark,
            ),
            const SizedBox(height: 5),

            // 🔥 КНОПКА 3: ВЫСТАВИТЬ
            _buildMenuItem(
              context: context,
              icon: Mdi.accountArrowUp,
              iconColor: Colors.blue.withOpacity(0.7),
              label: 'Выставить',
              value: 2,
              isDark: isDark,
            ),
            const SizedBox(height: 5),

            // 🔥 КНОПКА 4: СНЯТЬ
            _buildMenuItem(
              context: context,
              icon: Mdi.accountArrowDown,
              iconColor: Colors.green.withOpacity(0.7),
              label: 'Снять',
              value: 3,
              isDark: isDark,
            ),
            const SizedBox(height: 5),

            // 🔥 КНОПКА 5: ТЕХ. ФОЛ
            _buildMenuItem(
              context: context,
              icon: Mdi.alertCircle,
              iconColor: Colors.black,
              label: 'Тех. фол',
              value: 4,
              isDark: isDark,
            ),
            const SizedBox(height: 5),

            _buildMenuItem(
              context: context,
              icon: Mdi.closeOctagon,
              iconColor: const Color.fromARGB(255, 196, 13, 0),
              label: 'ППК',
              value: 4,
              isDark: isDark,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuItem({
    required BuildContext context,
    required IconData icon,
    required Color iconColor,
    required String label,
    required int value,
    required bool isDark,
  }) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: isDark ? Colors.grey.shade800.withOpacity(0.7) : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark ? Colors.grey.shade700 : Colors.grey.shade300,
          width: 1,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => Navigator.pop(context, value),
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: Row(
              children: [
                Icon(
                  icon,
                  color: iconColor,
                  size: 22,
                ),
                const SizedBox(width: 14),
                Text(
                  label,
                  style: TextStyle(
                    color: isDark ? Colors.white : Colors.black87,
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
