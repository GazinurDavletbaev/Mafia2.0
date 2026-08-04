// lib/presentation/widgets/app_bottom_nav.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mafia_help/application/providers/notification_provider.dart';
import 'package:mafia_help/data/local/models/phase.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';

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

    final pendingRequestsAsync = ref.watch(pendingRequestsProvider);
    final pendingCount = pendingRequestsAsync.when(
      data: (count) => count,
      loading: () => 0,
      error: (_, __) => 0,
    );

    return Stack(
      clipBehavior: Clip.none,
      children: [
        // 🔥 НАВИГАЦИЯ
        Container(
          height: 55,
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
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
              _buildNavItem(context, MdiIcons.home, 'Клуб', 0,
                  badgeCount: pendingCount),
              _buildNavItem(
                  context, MdiIcons.accountGroupOutline, 'Рассадка', 1),
              _buildNavItem(context, MdiIcons.brain, 'Игра', 2),
              _buildNavItem(context, MdiIcons.protocol, 'Протокол', 3),
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
            Colors.grey.shade600;

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
}
