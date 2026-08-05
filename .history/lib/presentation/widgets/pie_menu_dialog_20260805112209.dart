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
      barrierColor: Colors.black.withOpacity(0.3),
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
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.transparent,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              decoration: BoxDecoration(
                color: isDark
                    ? Colors.grey.shade800.withOpacity(0.85)
                    : Colors.white.withOpacity(0.85),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 20,
                    spreadRadius: 5,
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildMenuItem(
                    icon: Mdi.accountRemove,
                    iconColor: Colors.red,
                    label: 'Удалить',
                    onTap: () => Navigator.pop(context, 0),
                    isDark: isDark,
                  ),
                  const Divider(height: 1, thickness: 0.5),
                  _buildMenuItem(
                    icon: Mdi.accountPlus,
                    iconColor: Colors.green,
                    label: 'Вернуть за стол',
                    onTap: () => Navigator.pop(context, 1),
                    isDark: isDark,
                  ),
                  const Divider(height: 1, thickness: 0.5),
                  _buildMenuItem(
                    icon: Mdi.accountArrowUp,
                    iconColor: primaryColor,
                    label: 'Выставить',
                    onTap: () => Navigator.pop(context, 2),
                    isDark: isDark,
                  ),
                  const Divider(height: 1, thickness: 0.5),
                  _buildMenuItem(
                    icon: Mdi.accountArrowDown,
                    iconColor: Colors.orange,
                    label: 'Снять',
                    onTap: () => Navigator.pop(context, 3),
                    isDark: isDark,
                  ),
                  const Divider(height: 1, thickness: 0.5),
                  _buildMenuItem(
                    icon: Mdi.alertCircle,
                    iconColor: Colors.orange,
                    label: 'Тех. фол',
                    onTap: () => Navigator.pop(context, 4),
                    isDark: isDark,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required Color iconColor,
    required String label,
    required VoidCallback onTap,
    required bool isDark,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          width: 220,
          child: Row(
            children: [
              Icon(
                icon,
                color: iconColor,
                size: 24,
              ),
              const SizedBox(width: 14),
              Text(
                label,
                style: TextStyle(
                  color: isDark ? Colors.white : Colors.black87,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}