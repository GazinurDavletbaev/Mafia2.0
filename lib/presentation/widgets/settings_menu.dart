import 'package:flutter/material.dart';
import '../viewmodel/game_viewmodel.dart';
import 'end_game_dialog.dart';
import 'reset_game_dialog.dart';

class SettingsMenu {
  static void show(BuildContext context, GameViewModel vm) {
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
              EndGameDialog.show(context, vm);
            },
          ),
          ListTile(
            leading: const Icon(Icons.refresh),
            title: const Text('Сбросить игру'),
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