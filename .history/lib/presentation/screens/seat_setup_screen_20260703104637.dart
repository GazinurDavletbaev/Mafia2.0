import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'game_screen.dart';

class SeatSetupScreen extends ConsumerStatefulWidget {
  final int tableNumber;
  final int gameNumber;
  final DateTime date;
  final String judgeName;
  final String tournamentName;
  final String stageName;
  final Function(List<String>)? onStartGame;

  const SeatSetupScreen({
    super.key,
    required this.tableNumber,
    required this.gameNumber,
    required this.date,
    required this.judgeName,
    required this.tournamentName,
    required this.stageName,
    this.onStartGame,
  });

  @override
  ConsumerState<SeatSetupScreen> createState() => _SeatSetupScreenState();
}

class _SeatSetupScreenState extends ConsumerState<SeatSetupScreen> {
  final List<TextEditingController> _nameControllers =
      List.generate(10, (_) => TextEditingController());

  @override
  void dispose() {
    for (var controller in _nameControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final leftSeats = [5, 4, 3, 2, 1];
    final rightSeats = [6, 7, 8, 9, 10];

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('Расс адка игроков'),
        backgroundColor: theme.appBarTheme.backgroundColor,
        foregroundColor: theme.appBarTheme.foregroundColor,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isDark ? Colors.grey.shade800 : Colors.grey.shade200,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Text(
                    'Стол ${widget.tableNumber}',
                    style: TextStyle(
                      color: isDark ? Colors.white : Colors.black87,
                    ),
                  ),
                  Text(
                    'Игра ${widget.gameNumber}',
                    style: TextStyle(
                      color: isDark ? Colors.white : Colors.black87,
                    ),
                  ),
                  Text(
                    'Судья: ${widget.judgeName}',
                    style: TextStyle(
                      color: isDark ? Colors.white : Colors.black87,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: Row(
                children: [
                  Expanded(
                    child: _buildColumn(leftSeats, isLeft: true),
                  ),
                  const SizedBox(width: 20),
                  Expanded(
                    child: _buildColumn(rightSeats, isLeft: false),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor:
                          isDark ? Colors.grey.shade800 : Colors.grey.shade200,
                      foregroundColor: isDark ? Colors.white : Colors.black87,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    child: const Text('⬅️ НАЗАД'),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _startGame,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange,
                      foregroundColor: Colors.black,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    child: const Text(
                      '▶️ СТАРТ',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildColumn(List<int> seats, {required bool isLeft}) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Column(
      children: seats.map((seat) {
        final index = seat - 1;
        return Expanded(
          child: Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(
              children: [
                Container(
                  width: 30,
                  height: 30,
                  decoration: const BoxDecoration(
                    color: Colors.grey,
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      '$seat',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: TextField(
                    controller: _nameControllers[index],
                    style: TextStyle(
                      color: theme.textTheme.bodyLarge?.color ?? Colors.white,
                    ),
                    decoration: InputDecoration(
                      hintText: 'Игрок $seat',
                      hintStyle: TextStyle(
                        color: isDark
                            ? Colors.grey.shade600
                            : Colors.grey.shade400,
                      ),
                      filled: true,
                      fillColor:
                          isDark ? Colors.grey.shade800 : Colors.grey.shade200,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 8),
                    ),
                    textAlign: isLeft ? TextAlign.left : TextAlign.right,
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  void _startGame() {
    final names = _nameControllers.map((c) => c.text.trim()).toList();

    if (names.any((name) => name.isEmpty)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Заполните имена всех игроков!'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (widget.onStartGame != null) {
      widget.onStartGame!(names);
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => GameScreen(
            playerNames: names,
            tableNumber: widget.tableNumber,
            gameNumber: widget.gameNumber,
            date: widget.date,
            judgeName: widget.judgeName,
            tournamentName: widget.tournamentName,
            stageName: widget.stageName,
          ),
        ),
      );
    }
  }
}