import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:mafia_help/application/providers/club_provider.dart';
import 'package:mafia_help/application/providers/user_provider.dart';
import 'package:mafia_help/services/auth_service.dart';

class LobbyAppBar extends ConsumerStatefulWidget
    implements PreferredSizeWidget {
  final bool hasClub;
  final bool isPresident;
  final int pendingRequestsCount;
  final List<String> messages;

  const LobbyAppBar({
    super.key,
    required this.hasClub,
    required this.isPresident,
    required this.pendingRequestsCount,
    this.messages = const [
      '🏆 Новости клуба',
      '📢 Анонсы турниров',
      '🎮 Игры клуба',
      '👥 Новые участники',
    ],
  });

  @override
  ConsumerState<LobbyAppBar> createState() => _LobbyAppBarState();

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

class _LobbyAppBarState extends ConsumerState<LobbyAppBar> {
  int _currentIndex = 0;
  late Timer _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 3), (timer) {
      if (mounted) {
        setState(() {
          _currentIndex = (_currentIndex + 1) % widget.messages.length;
        });
      }
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AppBar(
      title: Text(
        widget.messages[_currentIndex],
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
      ),
      backgroundColor: theme.appBarTheme.backgroundColor,
      foregroundColor: theme.appBarTheme.foregroundColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          bottom: Radius.circular(16),
        ),
      ),
      elevation: 0,
      actions: [
        // 🔥 ТОЛЬКО ПРОФИЛЬНОЕ МЕНЮ
        _buildProfileMenu(context, ref),
      ],
    );
  }

  Widget _buildProfileMenu(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final userAsync = ref.watch(userProvider);

    return PopupMenuButton<String>(
      offset: const Offset(0, 40),
      color: theme.scaffoldBackgroundColor,
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
          case 'requests':
            context.push('/club-requests');
            break;
          case 'settings':
            context.push('/settings');
            break;
          case 'logout':
            _showLogoutDialog(context, ref);
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
                  color: theme.textTheme.titleLarge?.color,
                ),
              ),
              const SizedBox(width: 8),
              // 🔥 АВАТАРКА С БЕЙДЖЕМ
              Stack(
                clipBehavior: Clip.none,
                children: [
                  CircleAvatar(
                    radius: 16,
                    backgroundColor: theme.primaryColor.withOpacity(0.2),
                    backgroundImage: user?['avatarUrl'] != null &&
                            user!['avatarUrl'].isNotEmpty
                        ? NetworkImage(user['avatarUrl'])
                        : null,
                    child: user?['avatarUrl'] == null ||
                            user!['avatarUrl'].isEmpty
                        ? Text(
                            user?['username']?.substring(0, 1).toUpperCase() ??
                                '?',
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          )
                        : null,
                  ),
                  // 🔥 БЕЙДЖ НА АВАТАРКЕ (ЕСЛИ ЕСТЬ ЗАЯВКИ)
                  if (widget.pendingRequestsCount > 0)
                    Positioned(
                      right: -4,
                      top: -4,
                      child: Container(
                        padding: const EdgeInsets.all(2),
                        constraints: const BoxConstraints(
                          minWidth: 14,
                          minHeight: 14,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.red,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: theme.scaffoldBackgroundColor,
                            width: 2,
                          ),
                        ),
                        child: Text(
                          widget.pendingRequestsCount > 9
                              ? '9+'
                              : '${widget.pendingRequestsCount}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 8,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
        loading: () => const SizedBox(
          width: 40,
          child: Center(child: CircularProgressIndicator()),
        ),
        error: (err, stack) => Icon(
          Icons.error,
          color: theme.colorScheme.error,
        ),
      ),
      itemBuilder: (context) => [
        PopupMenuItem(
          value: 'profile',
          child: Row(
            children: [
              Icon(Icons.person, color: theme.primaryColor),
              const SizedBox(width: 12),
              const Text('Профиль'),
            ],
          ),
        ),
        PopupMenuItem(
          value: 'club',
          child: Row(
            children: [
              Icon(Icons.people, color: theme.primaryColor),
              const SizedBox(width: 12),
              const Text('Клуб'),
            ],
          ),
        ),
        // 🔥 НОВЫЙ ПУНКТ "ЗАЯВКИ" С БЕЙДЖЕМ
        PopupMenuItem(
          value: 'requests',
          child: Row(
            children: [
              Stack(
                clipBehavior: Clip.none,
                children: [
                  Icon(Icons.notifications, color: theme.primaryColor),
                  if (widget.pendingRequestsCount > 0)
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
                          widget.pendingRequestsCount > 9
                              ? '9+'
                              : '${widget.pendingRequestsCount}',
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
              const SizedBox(width: 12),
              const Text('Заявки в клуб'),
            ],
          ),
        ),
        PopupMenuItem(
          value: 'settings',
          child: Row(
            children: [
              Icon(Icons.settings, color: theme.primaryColor),
              const SizedBox(width: 12),
              const Text('Настройки'),
            ],
          ),
        ),
        const PopupMenuItem(
          value: 'logout',
          child: Row(
            children: [
              Icon(Icons.logout, color: Colors.red),
              const SizedBox(width: 12),
              Text('Выйти', style: TextStyle(color: Colors.red)),
            ],
          ),
        ),
      ],
    );
  }

  void _showLogoutDialog(BuildContext context, WidgetRef ref) {
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
}
