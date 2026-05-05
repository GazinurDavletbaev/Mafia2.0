import 'package:flutter/material.dart';
import '../viewmodel/game_viewmodel.dart';

class VoteDialog {
  static Future<void> show(
    BuildContext context,
    int seat,
    GameViewModel vm,
  ) async {
    int votes = 0;

    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Голоса за место $seat'),
        content: StatefulBuilder(
          builder: (context, setState) {
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '$votes',
                  style: const TextStyle(fontSize: 40, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildVoteButton('+', () => setState(() => votes++)),
                    const SizedBox(width: 20),
                    _buildVoteButton('-', () => setState(() => votes > 0 ? votes-- : null)),
                  ],
                ),
              ],
            );
          },
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Отмена'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              vm.addVote(seat, votes);
            },
            child: const Text('Сохранить'),
          ),
        ],
      ),
    );
  }

  static Widget _buildVoteButton(String text, VoidCallback onPressed) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        minimumSize: const Size(60, 60),
        shape: const CircleBorder(),
      ),
      child: Text(text, style: const TextStyle(fontSize: 30)),
    );
  }
}