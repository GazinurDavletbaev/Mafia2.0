// lib/presentation/screens/lobby_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:mafia_help/application/providers/notification_provider.dart';
import 'package:mafia_help/services/auth_service.dart';
import 'club_screen.dart';
import 'game_screen.dart';
import 'game_settings_screen.dart';
import 'seat_setup_screen.dart';
import 'game_protocol_screen.dart';
import 'saved_protocols_screen.dart';
import 'settings_screen.dart';
import 'club_requests_screen.dart';
import '../../domain/rules/game_history.dart';
import '../../services/club_service.dart';
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
  bool _isPresident = false;
  Map<String, dynamic>? _user;

  GameData _gameData = GameData();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadUserData();
      _loadPendingRequestsCount();
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    print('hi');
    _loadUserData(); // ✅ Перезагружаем при каждом показе
  }

  Future<void> _loadUserData() async {
    final token = await AuthService.getToken();
    if (token != null) {
      final result = await AuthService.getMe(token);
      print('📦 User data: $result');
      if (result['success']) {
        final user = result['user'];
        print('📦 User object: ${user.toJson()}'); // ✅ Используй toJson
        setState(() {
          _user = {
            'username': user.nickname ?? 'Пользователь', // ✅ nickname
            'email': user.email ?? '',
            'avatarUrl': user.avatarUrl,
          };
        });
      }
    }
  }

  Future<void> _loadPendingRequestsCount() async {
    // ✅ Получаем текущего пользователя
    final token = await AuthService.getToken();
    if (token == null) {
      setState(() => _isPresident = false);
      ref.read(pendingRequestsProvider.notifier).state = 0;
      return;
    }

    final clubResult = await ClubService.getCurrentClub();
    print('📦 clubResult: $clubResult');

    if (clubResult['success'] && clubResult['club'] != null) {
      final club = clubResult['club'];

      // ✅ Получаем user_id из токена
      final userResult = await AuthService.getMe(token);
      final currentUserId =
          userResult['success'] ? userResult['user']?.id : null;

      // ✅ Вычисляем is_president на клиенте
      final isPresident = currentUserId != null &&
          club['president_id'].toString() == currentUserId.toString();
      print('📦 currentUserId: $currentUserId');
      print('📦 president_id: ${club['president_id']}');
      print('📦 isPresident: $isPresident');

      setState(() {
        _isPresident = isPresident;
      });

      if (isPresident) {
        final result = await ClubService.getPendingRequestsCount();
        if (mounted) {
          final count = result['success'] ? (result['count'] ?? 0) : 0;
          ref.read(pendingRequestsProvider.notifier).state = count;
        }
      } else {
        ref.read(pendingRequestsProvider.notifier).state = 0;
      }
    } else {
      setState(() {
        _isPresident = false;
      });
      ref.read(pendingRequestsProvider.notifier).state = 0;
    }
  }

  void _updateGameData(GameData newData) {
    setState(() {
      _gameData = newData;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    // ✅ Читаем из провайдера
    final pendingRequestsCount = ref.watch(pendingRequestsProvider);

    // ✅ Подписываемся на изменения gameViewModel
    ref.listen<GameState>(gameViewModelProvider, (previous, next) {
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
        onNewGame: _onNewGame,
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
        appBar: AppBar(
          title: const Text('Главная'),
          backgroundColor: theme.appBarTheme.backgroundColor,
          foregroundColor: theme.appBarTheme.foregroundColor,
          actions: [
            // ✅ ИКОНКА УВЕДОМЛЕНИЙ — ТОЛЬКО ДЛЯ ПРЕЗИДЕНТА
            if (_isPresident) ...[
              if (pendingRequestsCount > 0)
                Stack(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.notifications_active,
                          color: Colors.orange),
                      onPressed: () {
                        context.push('/club-requests');
                      },
                      tooltip: 'Заявки в клуб',
                    ),
                    Positioned(
                      right: 4,
                      top: 4,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: const BoxDecoration(
                          color: Colors.red,
                          shape: BoxShape.circle,
                        ),
                        child: Text(
                          pendingRequestsCount > 9
                              ? '9+'
                              : '$pendingRequestsCount',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              if (pendingRequestsCount == 0)
                IconButton(
                  icon: const Icon(Icons.notifications_outlined),
                  onPressed: () {
                    context.push('/club-requests');
                  },
                  tooltip: 'Заявки в клуб',
                ),
            ],
            // ✅ АВАТАРКА + НИКНЕЙМ ВМЕСТО КНОПКИ НАСТРОЕК
            GestureDetector(
              onTap: () => context.push('/'),
              child: Padding(
                padding: const EdgeInsets.only(right: 16, left: 8),
                child: Row(
                  children: [
                    Text(
                      _user?['username'] ?? 'Профиль',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color:
                            theme.textTheme.titleLarge?.color ?? Colors.white,
                      ),
                    ),
                    const SizedBox(width: 8),
                    CircleAvatar(
                      radius: 16,
                      backgroundColor: Colors.orange.shade200,
                      backgroundImage: _user?['avatarUrl'] != null &&
                              _user!['avatarUrl'].isNotEmpty
                          ? NetworkImage(_user!['avatarUrl'])
                          : null,
                      child: _user?['avatarUrl'] == null ||
                              _user!['avatarUrl'].isEmpty
                          ? Text(
                              _user?['username']
                                      ?.substring(0, 1)
                                      .toUpperCase() ??
                                  '?',
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                            )
                          : null,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
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
    final judgeName = _gameData.judgeName;
    final vm = ref.read(gameViewModelProvider.notifier);
    vm.resetGame();
    final newGameData = GameData(
      judgeName: judgeName,
    );
    _updateGameData(newGameData);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('🔄 Новая игра создана!'),
        backgroundColor: Colors.green,
        duration: Duration(seconds: 2),
      ),
    );
  }
}
