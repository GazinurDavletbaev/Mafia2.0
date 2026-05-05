import 'package:flutter/material.dart';
import '../../domain/helpers/game_end_helper.dart';
import '../viewmodel/game_viewmodel.dart';

class EndGameDialog {
  static void show(BuildContext context, GameViewModel vm) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Кто победил?'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              vm.onEndGame(GameResult.redWin);
            },
            child: const Text('Красные'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              vm.onEndGame(GameResult.blackWin);
            },
            child: const Text('Чёрные'),
          ),
        ],
      ),
    );
  }
}