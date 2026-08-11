import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:mafia_help/application/providers/notification_provider.dart';
import 'package:mafia_help/application/providers/user_provider.dart';
import 'package:mafia_help/application/providers/club_provider.dart';
import 'package:mafia_help/data/local/models/phase.dart';
import 'package:mafia_help/services/auth_service.dart';
import 'package:mdi_plus/mdi_plus.dart';

class AppBottomNav extends ConsumerWidget {
  final int currentIndex;
  final Function(int) onTap;
  final Phase? phase;
  final int? currentDay;

  const AppBottomNav({
    super.key,
    required this.currentIndex,
    required this.onTap,
    this.phase,
    this.currentDay,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final pendingRequestsAsync = ref.watch(pendingRequestsProvider);
    final pendingCount = pendingRequestsAsync.when(
      data: (count) => count,
      loading: () => 0,
      error: (_, __) => 0,
    );

    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          height: 50,
          margin: const EdgeInsets.symmetric(horizontal: 3, vertical: 4),
          decoration: BoxDecoration(
            color: isDark ? Colors.grey.shade900 : theme.colorScheme.surface,
            borderRadius: BorderRadius.circular(50),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 10,
                offset: const Offset(0, -2),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildNavItem(context, Mdi.home, 'Клуб', 0,
                  badgeCount: pendingCount),
              _buildNavItem(context, Mdi.accountGroupOutline, 'Рассадка', 1),
              _buildNavItem(context, Mdi.brain, 'Игра', 2),
              _buildNavItem(context, Mdi.listBox, 'Протокол', 3),
              _buildProfileButton(context, ref),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildNavItem(
    BuildContext context,
    IconData icon,
    String label,
    int index, {
    int badgeCount = 0,
  }) {
    final theme = Theme.of(context);
    final isSelected = currentIndex == index;
    final Color itemColor = isSelected
        ? theme.primaryColor
        : theme.bottomNavigationBarTheme.unselectedItemColor ??
            Colors.grey.shade400;

    return GestureDetector(
      onTap: () => onTap(index),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
        decoration: BoxDecoration(
          color: isSelected
              ? theme.primaryColor.withOpacity(0.15)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(50),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Stack(
              children: [
                Icon(icon, size: 22, color: itemColor),
                if (badgeCount > 0)
                  Positioned(
                    right: -6,
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
                          color: theme.colorScheme.surface,
                          width: 2,
                        ),
                      ),
                      child: Text(
                        '$badgeCount',
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
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(
                fontSize: 9,
                fontWeight: FontWeight.w500,
                color: itemColor,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileButton(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final userAsync = ref.watch(userProvider);

    return GestureDetector(
      onTap: () => _showProfileMenu(context, ref),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
        child: userAsync.when(
          data: (user) => CircleAvatar(
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
          loading: () => const SizedBox(
            width: 32,
            height: 32,
            child: Center(
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
          ),
          error: (err, stack) => Icon(
            Icons.error,
            color: theme.colorScheme.error,
          ),
        ),
      ),
    );
  }

  void _showProfileMenu(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final userAsync = ref.read(userProvider);
    final user = userAsync.valueOrNull;

    showModalBottomSheet(
      context: context,
      backgroundColor: theme.scaffoldBackgroundColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Информация о пользователе
            if (user != null)
              Container(
                padding: const EdgeInsets.all(16),
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: theme.primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 24,
                      backgroundColor: theme.primaryColor.withOpacity(0.2),
                      backgroundImage: user['avatarUrl'] != null &&
                              user['avatarUrl'].isNotEmpty
                          ? NetworkImage(user['avatarUrl'])
                          : null,
                      child: user['avatarUrl'] == null ||
                              user['avatarUrl'].isEmpty
                          ? Text(
                              user['username']?.substring(0, 1).toUpperCase() ??
                                  '?',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            )
                          : null,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            user['username'] ?? 'Пользователь',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: theme.textTheme.titleLarge?.color,
                            ),
                          ),
                          if (user['email'] != null)
                            Text(
                              user['email'],
                              style: TextStyle(
                                fontSize: 12,
                                color: theme.textTheme.bodyMedium?.color,
                              ),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            // Кнопки меню
            _buildMenuItem(
              context,
              icon: Icons.person,
              label: 'Профиль',
              onTap: () {
                Navigator.pop(context);
                context.push('/edit-profile');
              },
            ),
            _buildMenuItem(
              context,
              icon: Icons.people,
              label: 'Клуб',
              onTap: () {
                Navigator.pop(context);
                context.push('/profile');
              },
            ),
            _buildMenuItem(
              context,
              icon: Icons.settings,
              label: 'Настройки',
              onTap: () {
                Navigator.pop(context);
                context.push('/settings');
              },
            ),
            const Divider(height: 24),
            _buildMenuItem(
              context,
              icon: Icons.logout,
              label: 'Выйти',
              color: Colors.red,
              onTap: () async {
                Navigator.pop(context);
                await AuthService.logout();
                ref.invalidate(userProvider);
                ref.invalidate(clubProvider);
                if (context.mounted) {
                  context.go('/login');
                }
              },
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuItem(
    BuildContext context, {
    required IconData icon,
    required String label,
    Color? color,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);
    final textColor =
        color ?? theme.textTheme.bodyLarge?.color ?? Colors.black87;

    return ListTile(
      leading: Icon(icon, color: textColor),
      title: Text(
        label,
        style: TextStyle(
          color: textColor,
          fontSize: 16,
        ),
      ),
      onTap: onTap,
    );
  }
}
