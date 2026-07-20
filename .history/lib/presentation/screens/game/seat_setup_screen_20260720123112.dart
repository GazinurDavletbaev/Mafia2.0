// lib/presentation/screens/seat_setup_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../lobby_screen.dart';

class SeatSetupScreen extends ConsumerStatefulWidget {
  final GameData initialData;
  final Function(GameData) onNamesChanged;

  const SeatSetupScreen({
    super.key,
    required this.initialData,
    required this.onNamesChanged,
  });

  @override
  ConsumerState<SeatSetupScreen> createState() => _SeatSetupScreenState();
}

class _SeatSetupScreenState extends ConsumerState<SeatSetupScreen> {
  late List<TextEditingController> _nameControllers;
  late List<Map<String, dynamic>?> _selectedPlayers; // ✅ userId и данные игрока

  @override
  void initState() {
    super.initState();
    // Инициализируем контроллеры с именами из initialData
    _nameControllers = List.generate(10, (index) {
      return TextEditingController(
        text: widget.initialData.playerNames.length > index
            ? widget.initialData.playerNames[index]
            : '',
      );
    });
  }

  @override
  void dispose() {
    for (var controller in _nameControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  void _notifyChanges() {
    final names = _nameControllers.map((c) => c.text.trim()).toList();

    // Обновляем gameState с новыми именами
    inal updatedPlayers =
        widget.initialData.gameState.players.asMap().entries.map((entry) {
      final index = entry.key;
      final player = entry.value;
      final name = names.length > index ? names[index] : player.name;
      final userId = playerIds.length > index ? playerIds[index] : null;
      
      // ✅ Сохраняем userId в player (добавь поле userId в PlayerModel)
      return player.copyWith(
        name: name,
        userId: userId,
      );
    }).toList();

    final updatedGameState = widget.initialData.gameState.copyWith(
      players: updatedPlayers,
    );

    widget.onNamesChanged(
      GameData(
        tournamentName: widget.initialData.tournamentName,
        stageName: widget.initialData.stageName,
        tableNumber: widget.initialData.tableNumber,
        gameNumber: widget.initialData.gameNumber,
        date: widget.initialData.date,
        judgeName: widget.initialData.judgeName,
        playerNames: names,
        gameState: updatedGameState,
        gameHistory: widget.initialData.gameHistory,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final leftSeats = [5, 4, 3, 2, 1];
    final rightSeats = [6, 7, 8, 9, 10];

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
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
                    onChanged: (_) => _notifyChanges(),
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
}
