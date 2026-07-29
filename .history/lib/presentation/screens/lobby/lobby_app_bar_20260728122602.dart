// lib/presentation/screens/lobby/lobby_app_bar.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:mafia_help/application/providers/club_provider.dart';
import 'package:mafia_help/application/providers/user_provider.dart';
import 'package:mafia_help/services/auth_service.dart';

class LobbyAppBar extends ConsumerWidget implements PreferredSizeWidget {
  final bool hasClub;
  final bool isPresident;
  final int pendingRequestsCount;

  const LobbyAppBar({
    super.key,
    required this.hasClub,
    required this.isPresident,
    required this.pendingRequestsCount,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);

    return AppBar(
      title: const Text('рек'),
      backgroundColor: theme.appBarTheme.backgroundColor,
      foregroundColor: theme.appBarTheme.foregroundColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          bottom: Radius.circular(16), // ← скругление снизу
        ),
      ),
      actions: [
        if (hasClub && isPresident) ...[
          if (pendingRequestsCount > 0)
            Stack(
              children: [
                IconButton(
                  icon: Icon(
                    Icons.notifications_active,
                    color: theme.primaryColor,
                  ),
                  onPressed: () => context.push('/club-requests'),
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
                      pendingRequestsCount > 9 ? '9+' : '$pendingRequestsCount',
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
              icon: Icon(
                Icons.notifications_outlined,
                color: theme.primaryColor,
              ),
              onPressed: () => context.push('/club-requests'),
              tooltip: 'Заявки в клуб',
            ),
        ],
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
              CircleAvatar(
                radius: 16,
                backgroundColor: theme.primaryColor.withOpacity(0.2),
                backgroundImage:
                    user?['avatarUrl'] != null && user!['avatarUrl'].isNotEmpty
                        ? NetworkImage(user['avatarUrl'])
                        : null,
                child: user?['avatarUrl'] == null || user!['avatarUrl'].isEmpty
                    ? Text(
                        user?['username']?.substring(0, 1).toUpperCase() ?? '?',
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
              SizedBox(width: 12),
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

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
