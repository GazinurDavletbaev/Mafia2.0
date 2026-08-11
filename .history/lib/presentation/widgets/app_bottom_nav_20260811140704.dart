// lib/presentation/widgets/app_bottom_nav.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mafia_help/application/providers/club_provider.dart';
import 'package:mafia_help/application/providers/notification_provider.dart';
import 'package:mafia_help/application/providers/user_provider.dart';
import 'package:mafia_help/data/local/models/phase.dart';
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

    final userAsync = ref.watch(userProvider);

    return Container(
      height: 50,
      margin: const EdgeInsets.symmetric(horizontal: 40, vertical: 4),
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
          _buildNavItem(context, Mdi.home, 'Клуб', 0),
          _buildNavItem(context, Mdi.accountGroupOutline, 'Рассадка', 1),
          _buildNavItem(context, Mdi.brain, 'Игра', 2),
          _buildNavItem(context, Mdi.listBox, 'Протокол', 3),
          // 🔥 5-Й ЭЛЕМЕНТ — АВАТАРКА С МЕНЮ
          _buildAvatarItem(context, ref, userAsync, pendingCount),
        ],
      ),
    );
  }

  Widget _buildNavItem(
    BuildContext context,
    IconData icon,
    String label,
    int index,
  ) {
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
            Icon(icon, size: 22, color: itemColor),
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

  Widget _buildAvatarItem(
    BuildContext context,
    WidgetRef ref,
    AsyncValue<Map<String, dynamic>?> userAsync,
    int pendingCount,
  ) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final isSelected = currentIndex == 4;

    return GestureDetector(
      onTap: () => onTap(4),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
        decoration: BoxDecoration(
          color: isSelected
              ? theme.primaryColor.withOpacity(0.15)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(50),
        ),
        child: userAsync.when(
          data: (user) => Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Stack(
                clipBehavior: Clip.none,
                children: [
                  CircleAvatar(
                    radius: 14,
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
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: isDark ? Colors.white : Colors.black87,
                            ),
                          )
                        : null,
                  ),
                  // 🔥 БЕЙДЖ НА АВАТАРКЕ
                  if (pendingCount > 0)
                    Positioned(
                      right: -4,
                      top: -4,
                      child: Container(
                        constraints: const BoxConstraints(
                          minWidth: 16,
                          minHeight: 10,
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
                          pendingCount > 9 ? '9+' : '$pendingCount',
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
              const SizedBox(height: 2),
              Text(
                'Профиль',
                style: TextStyle(
                  fontSize: 9,
                  fontWeight: FontWeight.w500,
                  color: isSelected
                      ? theme.primaryColor
                      : theme.bottomNavigationBarTheme.unselectedItemColor ??
                          Colors.grey.shade400,
                ),
              ),
            ],
          ),
          loading: () => const SizedBox(
            width: 30,
            child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
          ),
          error: (err, stack) => Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircleAvatar(
                radius: 14,
                backgroundColor: Colors.red.withOpacity(0.2),
                child: const Icon(Icons.error, size: 16, color: Colors.red),
              ),
              const SizedBox(height: 2),
              Text(
                'Ошибка',
                style: TextStyle(
                  fontSize: 9,
                  fontWeight: FontWeight.w500,
                  color: isSelected ? Colors.red : Colors.grey.shade400,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
