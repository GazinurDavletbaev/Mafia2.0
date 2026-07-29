// lib/presentation/screens/lobby/lobby_bottom_nav.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mafia_help/application/providers/notification_provider.dart';

class LobbyBottomNav extends ConsumerWidget {
  final int currentIndex;
  final Function(int) onTap;

  const LobbyBottomNav({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);

    return BottomNavigationBar(
      currentIndex: currentIndex,
      onTap: (index) {
        onTap(index);
        ref.invalidate(pendingRequestsProvider);
      },
      backgroundColor: theme.bottomNavigationBarTheme.backgroundColor,
      selectedItemColor: theme.bottomNavigationBarTheme.selectedItemColor,
      unselectedItemColor: theme.bottomNavigationBarTheme.unselectedItemColor,
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
    );
  }
}
