// lib/presentation/screens/lobby_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'club_screen.dart';
import 'game_settings_screen.dart';
import 'saved_protocols_screen.dart';
import 'settings_screen.dart';

class LobbyScreen extends ConsumerStatefulWidget {
  const LobbyScreen({super.key});

  @override
  ConsumerState<LobbyScreen> createState() => _LobbyScreenState();
}

class _LobbyScreenState extends ConsumerState<LobbyScreen> {
  int _selectedIndex = 0;

  final List<Widget> _pages = [
    const ClubScreen(),
    const GameSettingsScreen(),
    const Center(
      child: re
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

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
            icon: Icon(Icons.gamepad),
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

  static Widget _buildProfileTab(BuildContext context) {
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
