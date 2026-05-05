import 'package:flutter/material.dart';
import '../viewmodel/game_viewmodel.dart';

class ResetGameDialog {
  static void show(BuildContext context, GameViewModel vm) {
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
              vm.onResetGame();
            },
            child: const Text('Сбросить'),
          ),
        ],
      ),
    );
  }
}