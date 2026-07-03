// lib/presentation/screens/lobby_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'club_screen.dart';
import 'game_screen.dart';
import 'game_settings_screen.dart';
import 'seat_setup_screen.dart';
import 'game_protocol_screen.dart';
import 'saved_protocols_screen.dart';
import 'settings_screen.dart';
import '../../domain/rules/game_history.dart';
import '../state/game_state.dart';
import '../viewmodel/game_viewmodel.dart';

class GameData {
  String tournamentName;
  String stageName;
  int tableNumber;
  int gameNumber;
  DateTime date;
  String judgeName;
  List<String> playerNames;
  GameState gameState;
  GameHistory gameHistory;

  GameData({
    this.tournamentName = 'РЕЙТИНГ',
    this.stageName = '',
    this.tableNumber = 1,
    this.gameNumber = 1,
    DateTime? date,
    this.judgeName = '',
    this.playerNames = const [],
    GameState? gameState,
    GameHistory? gameHistory,
  })  : date = date ?? DateTime.now(),
        gameState = gameState ?? GameState.initial(),
        gameHistory = gameHistory ?? GameHistory();
}

class LobbyScreen extends ConsumerStatefulWidget {
  const LobbyScreen({super.key});

  @override
  ConsumerState<LobbyScreen> createState() => _LobbyScreenState();
}

class _LobbyScreenState extends ConsumerState<LobbyScreen> {
  int _selectedIndex = 0;

  GameData _gameData = GameData();

  void _updateGameData(GameData newData) {
    setState(() {
      _gameData = newData;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    // ✅ Подписываемся на изменения gameViewModel
    ref.listen<GameState>(gameViewModelProvider, (previous, next) {
      // Если мы на вкладке "Игра" или "Протокол" — обновляем данные
      if (_selectedIndex == 3 || _selectedIndex == 4) {
        final vm = ref.read(gameViewModelProvider.notifier);
        _updateGameData(
          GameData(
            tournamentName: _gameData.tournamentName,
            stageName: _gameData.stageName,
            tableNumber: _gameData.tableNumber,
            gameNumber: _gameData.gameNumber,
            date: _gameData.date,
            judgeName: _gameData.judgeName,
            playerNames: _gameData.playerNames,
            gameState: next,
            gameHistory: vm.getHistory(),
          ),
        );
      }
    });

    final List<Widget> _pages = [
      const ClubScreen(),
      GameSettingsScreen(
        initialData: _gameData,
        onSettingsChanged: _updateGameData,
      ),
      SeatSetupScreen(
        initialData: _gameData,
        onNamesChanged: _updateGameData,
      ),
      GameScreen(
        initialData: _gameData,
        onGameStateChanged: _updateGameData,
        onSwitchToTab: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
      ),
      GameProtocolScreen(
        gameHistory: _gameData.gameHistory,
        gameState: _gameData.gameState,
      ),
    ];

    return SafeArea(
      child: Scaffold(
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
              label: 'Клуб',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.add_circle_outline),
              label: 'Судья',
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
              label: 'Протокол',
            ),
          ],
        ),
      ),
    );
  }
  void _onNewGame() {
  // ✅ Сохраняем имя судьи
  final judgeName = _gameData.judgeName;
  
  // ✅ Создаём новый GameData с сохранённым судьёй
  final newGameData = GameData(
    judgeName: judgeName,  // ← сохраняем судью
  );
  
  _updateGameData(newGameData);
  
  // ✅ Показываем сообщение
  ScaffoldMessenger.of(context).showSnackBar(
    const SnackBar(
      content: Text('🔄 Новая игра создана!'),
      backgroundColor: Colors.green,
      duration: Duration(seconds: 2),
    ),
  );
}
}
