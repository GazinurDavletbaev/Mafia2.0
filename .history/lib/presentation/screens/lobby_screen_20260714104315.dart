import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:mafia_help/application/providers/notification_provider.dart';
import 'package:mafia_help/application/providers/user_provider.dart';
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

  GameData _gameData = GameData();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadPendingRequestsCount();
    });
  }

  Future<void> _loadPendingRequestsCount() async {
    final token = await AuthService.getToken();
    if (token == null) {
      setState(() => _isPresident = false);
      ref.read(pendingRequestsProvider.notifier).state = 0;
      return;
    }

    final clubResult = await ClubService.getCurrentClub();

    if (clubResult['success'] && clubResult['club'] != null) {
      final club = clubResult['club'];

      final userResult = await AuthService.getMe(token);
      final currentUserId =
          userResult['success'] ? userResult['user']?.id : null;

      final isPresident = currentUserId != null &&
          club['president_id'].toString() == currentUserId.toString();

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

    final pendingRequestsCount = ref.watch(pendingRequestsProvider);
    final userAsync = ref.watch(userProvider);

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
            PopupMenuButton<String>(
              offset: const Offset(0, 40),
              color: Theme.of(context).scaffoldBackgroundColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              onSelected: (value) {
                switch (value) {
                  case 'profile':
                    context.push('/edit-profile');
                    break;
                  case 'club':
                    context.push('/profile');
                    break;
                  case 'settings':
                    context.push('/settings');
                    break;
                  case 'logout':
                    _showLogoutDialog();
                    break;
                }
              },
              child: userAsync.when(
                data: (user) => Padding(
                  padding: const EdgeInsets.only(right: 16, left: 8),
                  child: Row(
                    children: [
                      Text(
                        user?['username'] ?? 'Профиль',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: Theme.of(context)
                                  .textTheme
                                  .titleLarge
                                  ?.color ??
                              Colors.white,
                        ),
                      ),
                      const SizedBox(width: 8),
                      CircleAvatar(
                        radius: 16,
                        backgroundColor: Colors.orange.shade200,
                        backgroundImage: user?['avatarUrl'] != null &&
                                user!['avatarUrl'].isNotEmpty
                            ? NetworkImage(user!['avatarUrl'])
                            : null,
                        child: user?['avatarUrl'] == null ||
                                user!['avatarUrl'].isEmpty
                            ? Text(
                                user?['username']
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
                loading: () => const SizedBox(
                  width: 40,
                  child: Center(child: CircularProgressIndicator()),
                ),
                error: (err, stack) => const Icon(
                  Icons.error,
                  color: Colors.red,
                ),
              ),
              itemBuilder: (context) => [
                const PopupMenuItem(
                  value: 'profile',
                  child: Row(
                    children: [
                      Icon(Icons.person, color: Colors.orange),
                      SizedBox(width: 12),
                      Text('Профиль'),
                    ],
                  ),
                ),
                const PopupMenuItem(
                  value: 'club',
                  child: Row(
                    children: [
                      Icon(Icons.people, color: Colors.orange),
                      SizedBox(width: 12),
                      Text('Клуб'),
                    ],
                  ),
                ),
                const PopupMenuItem(
                  value: 'settings',
                  child: Row(
                    children: [
                      Icon(Icons.settings, color: Colors.orange),
                      SizedBox(width: 12),
                      Text('Настройки'),
                    ],
                  ),
                ),
                const PopupMenuItem(
                  value: 'logout',
                  child: Row(
                    children: [
                      Icon(Icons.logout, color: Colors.red),
                      SizedBox(width: 12),
                      Text('Выйти', style: TextStyle(color: Colors.red)),
                    ],
                  ),
                ),
              ],
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

  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        title: const Text('Выход из аккаунта'),
        content: const Text('Вы уверены, что хотите выйти?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Отмена'),
          ),
          TextButton(
            onPressed: () async {
              await AuthService.logout();
              if (mounted) {
                context.go('/login');
              }
            },
            child: const Text(
              'Выйти',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
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