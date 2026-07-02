import 'package:flutter/material.dart';
import '../viewmodel/game_viewmodel.dart';
import 'reset_game_dialog.dart';

class SettingsMenu {
  static void show(BuildContext context, GameViewModel vm) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    showModalBottomSheet(
      context: context,
      backgroundColor: isDark ? Colors.grey.shade900 : Colors.white,
      builder: (context) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: const Icon(Icons.stop_circle, color: Colors.red),
            title: Text(
              'Завершить игру',
              style: TextStyle(
                color: isDark ? Colors.white : Colors.black87,
              ),
            ),
            onTap: () {
              Navigator.pop(context);
            },
          ),
          ListTile(
            leading: Icon(
              Icons.refresh,
              color: isDark ? Colors.white : Colors.black87,
            ),
            title: Text(
              'Сбросить игру',
              style: TextStyle(
                color: isDark ? Colors.white : Colors.black87,
              ),
            ),
            onTap: () {
              Navigator.pop(context);
              ResetGameDialog.show(context, vm);
            },
          ),
        ],
      ),
    );
  }
}
