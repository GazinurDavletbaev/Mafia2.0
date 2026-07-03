// lib/presentation/screens/lobby_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
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

  // Флаг, что игра началась
  bool _gameStarted = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final List<Widget> _pages = [
      _buildProfileTab(),
      GameSettingsScreen(
        onSettingsSaved: (table, game, date, judge, tournament, stage) {
          setState(() {
            _tableNumber = table;
            _gameNumber = game;
            _date = date;
            _judgeName = judge;
            _tournamentName = tournament;
            _stageName = stage;
            _selectedIndex = 2; // переключаемся на вкладку "Игроки"
          });
        },
      ),
      SeatSetupScreen(
        tableNumber: _tableNumber,
        gameNumber: _gameNumber,
        date: _date,
        judgeName: _judgeName,
        tournamentName: _tournamentName,
        stageName: _stageName,
        onStartGame: (names) {
          setState(() {
            _gameStarted = true;
          });
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
        },
      ),
      const Center(
        child: Text(
          'Игра',
          style: TextStyle(color: Colors.white, fontSize: 24),
        ),
      ),
      const Center(
        child: Text(
          'Рейтинг',
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
            icon: Icon(Icons.gamepad),
            label: 'Игра',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.emoji_events),
            label: 'Рейтинг',
          ),
        ],
      ),
    );
  }

  Widget _buildProfileTab() {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset(
            'assets/mafia_logo.png',
            width: 120,
            height: 120,
            fit: BoxFit.contain,
          ),
          const SizedBox(height: 16),
          Text(
            'Mafia Help',
            style: TextStyle(
              color: isDark ? Colors.white : Colors.black87,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Версия 1.7.4',
            style: TextStyle(
              color: isDark ? Colors.grey : Colors.grey.shade600,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
}