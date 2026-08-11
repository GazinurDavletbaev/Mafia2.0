// lib/presentation/screens/lobby/lobby_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:mafia_help/application/providers/game_provider.dart';
import 'package:mafia_help/application/providers/notification_provider.dart';
import 'package:mafia_help/application/providers/club_provider.dart';
import 'package:mafia_help/application/providers/user_provider.dart';
import 'package:mafia_help/presentation/state/game_state.dart';
import 'package:mafia_help/presentation/viewmodel/game_viewmodel.dart';
import 'package:mafia_help/presentation/widgets/app_bottom_nav.dart';
import 'package:mafia_help/services/auth_service.dart';
import 'lobby_data.dart';
import 'lobby_pages.dart';

class LobbyScreen extends ConsumerStatefulWidget {
  const LobbyScreen({super.key});

  @override
  ConsumerState<LobbyScreen> createState() => _LobbyScreenState();
}

class _LobbyScreenState extends ConsumerState<LobbyScreen> {
  int _selectedIndex = 0;
  GameData _gameData = GameData();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initGameData();
      ref.read(savedGameIdProvider.notifier).state = null;
      ref.invalidate(userProvider);
      ref.invalidate(clubProvider);
      ref.invalidate(pendingRequestsProvider);
    });
  }

  void _initGameData() {
    setState(() {
      _gameData = LobbyData.createInitial(ref);
    });
  }

  void _updateGameData(GameData newData) {
    setState(() {
      _gameData = newData;
    });
  }

  void _onNewGame() {
    ref.read(savedGameIdProvider.notifier).state = null;
    final vm = ref.read(gameViewModelProvider.notifier);
    vm.resetGame();

    final newGameData = GameData(
      judgeName: LobbyData.getJudgeName(ref),
      tournamentName: 'РЕЙТИНГ',
      stageName: LobbyData.getCurrentStage(),
    );
    _updateGameData(newGameData);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('🔄 Новая игра создана!'),
        backgroundColor: Theme.of(context).primaryColor,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  grey.shade600 : Colors.grey.shade400,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            // 🔥 ПРОФИЛЬ
            ListTile(
              leading: CircleAvatar(
                radius: 24,
                backgroundColor: theme.primaryColor.withOpacity(0.2),
                backgroundImage:
                    user?['avatarUrl'] != null && user!['avatarUrl'].isNotEmpty
                        ? NetworkImage(user['avatarUrl'])
                        : null,
                child: user?['avatarUrl'] == null || user!['avatarUrl'].isEmpty
                    ? Text(
                        user?['username']?.substring(0, 1).toUpperCase() ?? '?',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: isDark ? Colors.white : Colors.black87,
                        ),void _showProfileMenu(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final user = ref.read(userProvider).value;
    final pendingCount = ref.read(pendingRequestsProvider).value ?? 0;

    showModalBottomSheet(
      context: context,
      backgroundColor: theme.scaffoldBackgroundColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // 🔥 ВЕРХНЯЯ ПОЛОСА
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.symmetric(vertical: 8),
              decoration: BoxDecoration(
                color: isDark ? Colors.
                      )
                    : null,
              ),
              title: Text(
                user?['username'] ?? 'Профиль',
                style: TextStyle(
                  color: theme.textTheme.titleLarge?.color,
                  fontWeight: FontWeight.bold,
                ),
              ),
              subtitle: Text(
                user?['email'] ?? 'Нет email',
                style: TextStyle(
                  color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
                ),
              ),
              onTap: () {
                Navigator.pop(context);
                context.push('/edit-profile');
              },
            ),
            const Divider(),
            // 🔥 КЛУБ
            ListTile(
              leading: Icon(Icons.people, color: theme.primaryColor),
              title: Text(
                'Клуб',
                style: TextStyle(color: theme.textTheme.titleLarge?.color),
              ),
              onTap: () {
                Navigator.pop(context);
                context.push('/profile');
              },
            ),
            // 🔥 ЗАЯВКИ (с бейджем)
            ListTile(
              leading: Stack(
                clipBehavior: Clip.none,
                children: [
                  Icon(Icons.notifications, color: theme.primaryColor),
                  if (pendingCount > 0)
                    Positioned(
                      right: -6,
                      top: -6,
                      child: Container(
                        padding: const EdgeInsets.all(2),
                        constraints: const BoxConstraints(
                          minWidth: 14,
                          minHeight: 14,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.red,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          pendingCount > 9 ? '9+' : '$pendingCount',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 9,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                ],
              ),
              title: Text(
                'Заявки в клуб',
                style: TextStyle(color: theme.textTheme.titleLarge?.color),
              ),
              onTap: () {
                Navigator.pop(context);
                context.push('/club-requests');
              },
            ),
            // 🔥 НАСТРОЙКИ
            ListTile(
              leading: Icon(Icons.settings, color: theme.primaryColor),
              title: Text(
                'Настройки',
                style: TextStyle(color: theme.textTheme.titleLarge?.color),
              ),
              onTap: () {
                Navigator.pop(context);
                context.push('/settings');
              },
            ),
            const Divider(),
            // 🔥 ВЫХОД
            ListTile(
              leading: const Icon(Icons.logout, color: Colors.red),
              title: const Text(
                'Выйти',
                style: TextStyle(color: Colors.red),
              ),
              onTap: () {
                Navigator.pop(context);
                _showLogoutDialog(context);
              },
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    final theme = Theme.of(context);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: theme.scaffoldBackgroundColor,
        title: const Text('Выход из аккаунта'),
        content: const Text('Вы уверены, что хотите выйти?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Отмена',
              style: TextStyle(color: theme.primaryColor),
            ),
          ),
          TextButton(
            onPressed: () async {
              await AuthService.logout();
              ref.invalidate(userProvider);
              ref.invalidate(clubProvider);
              if (context.mounted) {
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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    ref.listen<GameState>(gameViewModelProvider, (previous, next) {
      if (_selectedIndex == 2 || _selectedIndex == 3) {
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

    ref.listen(pendingRequestsProvider, (previous, next) {
      setState(() {});
    });

    final pages = LobbyPages.getPages(
      gameData: _gameData,
      onSettingsChanged: _updateGameData,
      onNewGame: _onNewGame,
      onNamesChanged: _updateGameData,
      onGameStateChanged: _updateGameData,
      onSwitchToTab: (index) {
        setState(() {
          _selectedIndex = index;
        });
      },
    );

    return SafeArea(
      child: Scaffold(
        backgroundColor: theme.scaffoldBackgroundColor,
        body: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.only(bottom: 50),
              child: pages[_selectedIndex],
            ),
            Positioned(
              bottom: 3,
              left: 0,
              right: 0,
              child: AppBottomNav(
                currentIndex: _selectedIndex,
                onTap: (index) {
                  if (index == 4) {
                    // 🔥 ОТКРЫВАЕМ ПРОФИЛЬНОЕ МЕНЮ
                    _showProfileMenu(context);
                  } else {
                    setState(() {
                      _selectedIndex = index;
                    });
                    ref.invalidate(pendingRequestsProvider);
                  }
                },
                phase: _gameData.gameState.currentPhase,
                currentDay: _gameData.gameState.currentDay,
              ),
            ),
          ],
        ),
      ),
    );
  }
}