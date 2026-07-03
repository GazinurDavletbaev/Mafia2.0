// lib/presentation/screens/lobby_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'club_screen.dart';
import 'game_settings_screen.dart';
import 'seat_setup_screen.dart';
import 'saved_protocols_screen.dart';
import 'settings_screen.dart';

class LobbyScreen extends ConsumerStatefulWidget {
  const LobbyScreen({super.key});

  @override
  ConsumerState<LobbyScreen> createState() => _LobbyScreenState();
}

class _LobbyScreenState extends ConsumerState<LobbyScreen> {
  int _selectedIndex = 0;

  // Данные из GameSettingsScreen
  int _tableNumber = 1;
  int _gameNumber = 1;
  DateTime _date = DateTime.now();
  String _judgeName = '';
  String _tournamentName = 'РЕЙТИНГ';
  String _stageName = '';

  // Контроллеры для ввода имён
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

    final List<Widget> _pages = [
      const ClubScreen(),
      const GameSettingsScreen(),
      _buildSeatSetupScreen(),
      const Center(
        child: Text(
          'Рейтинг',
          style: TextStyle(color: Colors.white, fontSize: 24),
        ),
      ),
      const Center(
        child: Text(
          'Игра',
          style: TextStyle(color: Colors.white, fontSize: 24),
        ),
      ),
    ];

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: _pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        backgroundColor: isDark ? Colors.grey.shade900 : Colors.white,
        selectedItemColor: Colors.orange,
        unselectedItemColor: isDark ? Colors.grey : Colors.grey.shade600,
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Профиль',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.add_circle_outline),
            label: 'Новая игра',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.people),
            label: 'Игроки',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.emoji_events),
            label: 'Рейтинг',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.gamepad),
            label: 'Игра',
          ),
        ],
      ),
    );
  }

  Widget _buildSeatSetupScreen() {
    final leftSeats = [5, 4, 3, 2, 1];
    final rightSeats = [6, 7, 8, 9, 10];

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.grey.shade800,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Text('Стол $_tableNumber',
                    style: const TextStyle(color: Colors.white)),
                Text('Игра $_gameNumber',
                    style: const TextStyle(color: Colors.white)),
                Text('Судья: $_judgeName',
                    style: const TextStyle(color: Colors.white)),
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
                  onPressed: () {
                    setState(() {
                      _selectedIndex = 1; // переключаемся на "Новая игра"
                    });
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.grey.shade800,
                    foregroundColor: Colors.white,
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
    );
  }

  Widget _buildColumn(List<int> seats, {required bool isLeft}) {
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
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      hintText: 'Игрок $seat',
                      hintStyle: TextStyle(color: Colors.grey.shade600),
                      filled: true,
                      fillColor: Colors.grey.shade800,
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

    // Переход в игру
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => GameScreen(
          playerNames: names,
          tableNumber: _tableNumber,
          gameNumber: _gameNumber,
          date: _date,
          judgeName: _judgeName,
          tournamentName: _tournamentName,
          stageName: _stageName,
        ),
      ),
    );
  }
}