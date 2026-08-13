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
import 'package:mafia_help/services/club_service.dart';
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

  void _showProfileMenu(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final user = ref.read(userProvider).value;
    final pendingCount = ref.read(pendingRequestsProvider).value ?? 0;
    final club = ref.read(clubProvider).value;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.5,
        minChildSize: 0.35,
        maxChildSize: 0.7,
        expand: false,
        builder: (context, scrollController) => Container(
          decoration: BoxDecoration(
            color: theme.scaffoldBackgroundColor,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.3),
                blurRadius: 30,
                offset: const Offset(0, -10),
              ),
            ],
          ),
          child: Column(
            children: [
              // 🔥 ИНДИКАТОР
              Container(
                margin: const EdgeInsets.only(top: 12, bottom: 8),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: isDark ? Colors.grey.shade600 : Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),

              // 🔥 ПРОФИЛЬ (ШАПКА)
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      theme.primaryColor.withOpacity(0.15),
                      theme.primaryColor.withOpacity(0.05),
                    ],
                  ),
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(24),
                    topRight: Radius.circular(24),
                  ),
                ),
                child: Row(
                  children: [
                    // 🔥 АВАТАРКА
                    Stack(
                      clipBehavior: Clip.none,
                      children: [
                        Container(
                          width: 64,
                          height: 64,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: theme.primaryColor,
                              width: 2,
                            ),
                            image: user?['avatarUrl'] != null &&
                                    user!['avatarUrl'].isNotEmpty
                                ? DecorationImage(
                                    image: NetworkImage(user['avatarUrl']),
                                    fit: BoxFit.cover,
                                  )
                                : null,
                          ),
                          child: user?['avatarUrl'] == null ||
                                  user!['avatarUrl'].isEmpty
                              ? Center(
                                  child: Text(
                                    user?['username']
                                            ?.substring(0, 1)
                                            .toUpperCase() ??
                                        '?',
                                    style: TextStyle(
                                      fontSize: 28,
                                      fontWeight: FontWeight.bold,
                                      color: isDark
                                          ? Colors.white
                                          : Colors.black87,
                                    ),
                                  ),
                                )
                              : null,
                        ),
                        if (pendingCount > 0)
                          Positioned(
                            right: -2,
                            top: -2,
                            child: Container(
                              padding: const EdgeInsets.all(4),
                              constraints: const BoxConstraints(
                                minWidth: 20,
                                minHeight: 20,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.red,
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: theme.scaffoldBackgroundColor,
                                  width: 2,
                                ),
                              ),
                              child: Text(
                                pendingCount > 9 ? '9+' : '$pendingCount',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(width: 16),
                    // 🔥 ИМЯ И EMAIL
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            user?['username'] ?? 'Профиль',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: theme.textTheme.titleLarge?.color,
                            ),
                          ),
                          Text(
                            user?['email'] ?? 'Нет email',
                            style: TextStyle(
                              fontSize: 13,
                              color: isDark
                                  ? Colors.grey.shade400
                                  : Colors.grey.shade600,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: theme.primaryColor.withOpacity(0.15),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.verified_user,
                                  size: 12,
                                  color: theme.primaryColor,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  'Резидент',
                                  style: TextStyle(
                                    fontSize: 10,
                                    color: theme.primaryColor,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    // 🔥 КНОПКА РЕДАКТИРОВАНИЯ
                    IconButton(
                      onPressed: () {
                        Navigator.pop(context);
                        context.push('/edit-profile');
                      },
                      style: IconButton.styleFrom(
                        backgroundColor: theme.primaryColor.withOpacity(0.1),
                      ),
                      icon: Icon(
                        Icons.edit,
                        color: theme.primaryColor,
                        size: 20,
                      ),
                    ),
                  ],
                ),
              ),

              const Divider(height: 1),

              // 🔥 ПУНКТЫ МЕНЮ
              Expanded(
                child: ListView(
                  controller: scrollController,
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  children: [
                    _buildMenuItem(
                      context,
                      icon: Icons.people,
                      label: 'Мой клуб',
                      subtitle: club?['title'] ?? 'Нет клуба',
                      onTap: () {
                        Navigator.pop(context);
                        context.push('/profile');
                      },
                    ),
                    _buildMenuItem(
                      context,
                      icon: Icons.notifications,
                      label: 'Заявки в клуб',
                      subtitle: pendingCount > 0
                          ? '${pendingCount} новая заявка'
                          : 'Нет заявок',
                      onTap: () {
                        Navigator.pop(context);
                        context.push('/club-requests');
                      },
                      badge: pendingCount > 0 ? pendingCount : null,
                    ),
                    _buildMenuItem(
                      context,
                      icon: Icons.settings,
                      label: 'Настройки',
                      subtitle: 'Тема, подсказки, обновления',
                      onTap: () {
                        Navigator.pop(context);
                        context.push('/settings');
                      },
                    ),
                    _buildMenuItem(
                      context,
                      icon: Icons.info_outline,
                      label: 'О приложении',
                      subtitle: 'Версия 1.8.5',
                      onTap: () {
                        Navigator.pop(context);
                        _showAboutDialog(context);
                      },
                    ),
                    const Divider(height: 20),
                    _buildMenuItem(
                      context,
                      icon: Icons.logout,
                      label: 'Выйти',
                      subtitle: 'Выйти из аккаунта',
                      onTap: () {
                        Navigator.pop(context);
                        _showLogoutDialog(context);
                      },
                      isDestructive: true,
                    ),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMenuItem(
    BuildContext context, {
    required IconData icon,
    required String label,
    String? subtitle,
    required VoidCallback onTap,
    int? badge,
    bool isDestructive = false,
  }) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final color = isDestructive ? Colors.red : theme.primaryColor;

    return ListTile(
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(
          icon,
          color: color,
          size: 22,
        ),
      ),
      title: Text(
        label,
        style: TextStyle(
          color: isDestructive ? Colors.red : theme.textTheme.titleLarge?.color,
          fontWeight: FontWeight.w500,
        ),
      ),
      subtitle: subtitle != null
          ? Text(
              subtitle,
              style: TextStyle(
                color: isDark ? Colors.grey.shade500 : Colors.grey.shade600,
                fontSize: 12,
              ),
            )
          : null,
      trailing: badge != null
          ? Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.red,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                badge > 9 ? '9+' : '$badge',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            )
          : Icon(
              Icons.chevron_right,
              color: isDark ? Colors.grey.shade600 : Colors.grey.shade400,
              size: 20,
            ),
      onTap: onTap,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
    );
  }

  void _showAboutDialog(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: theme.scaffoldBackgroundColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Column(
          children: [
            Image.asset(
              'assets/logo_new.png',
              height: 80,
            ),
            const SizedBox(height: 8),
            Text(
              'Mafia Help',
              style: TextStyle(
                color: theme.textTheme.titleLarge?.color,
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Версия 1.8.5',
              style: TextStyle(
                color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Приложение для судьи спортивной мафии',
              style: TextStyle(
                color: isDark ? Colors.grey.shade300 : Colors.grey.shade700,
                fontSize: 14,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
        actions: [
          Center(
            child: TextButton(
              onPressed: () => Navigator.pop(context),
              style: TextButton.styleFrom(
                foregroundColor: theme.primaryColor,
              ),
              child: const Text('Закрыть'),
            ),
          ),
        ],
      ),
    );
  }

void _onStartGame() {
  setState(() {
    _selectedIndex = 2;  // Переключаемся на вкладку "Игра"
  });
}

  void _showLogoutDialog(BuildContext context) {
    final theme = Theme.of(context);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: theme.scaffoldBackgroundColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
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
