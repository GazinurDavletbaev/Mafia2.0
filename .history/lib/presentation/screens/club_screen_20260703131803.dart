// lib/presentation/screens/club_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../services/update_service.dart';
import 'saved_protocols_screen.dart';
import 'settings_screen.dart';

class ClubScreen extends ConsumerStatefulWidget {
  const ClubScreen({super.key});

  @override
  ConsumerState<ClubScreen> createState() => _ClubScreenState();
}

class _ClubScreenState extends ConsumerState<ClubScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        UpdateService.checkForUpdate(context);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    // Заглушка с данными (позже будет из базы)
    final List<Map<String, dynamic>> players = [
      {'name': 'Алексей', 'games': 12, 'points': 45, 'place': 1},
      {'name': 'Дмитрий', 'games': 10, 'points': 38, 'place': 2},
      {'name': 'Сергей', 'games': 8, 'points': 30, 'place': 3},
      {'name': 'Иван', 'games': 7, 'points': 22, 'place': 4},
      {'name': 'Петр', 'games': 5, 'points': 15, 'place': 5},
      {'name': 'Михаил', 'games': 3, 'points': 8, 'place': 6},
      {'name': 'Андрей', 'games': 2, 'points': 4, 'place': 7},
    ];

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: theme.appBarTheme.backgroundColor,
        title: Text(
          'Рейтинг клуба',
          style: TextStyle(color: theme.appBarTheme.foregroundColor),
        ),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.folder_open, color: Colors.orange),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const SavedProtocolsScreen(),
                ),
              );
            },
            tooltip: 'Сохранённые игры',
          ),
          IconButton(
            icon: const Icon(Icons.settings, color: Colors.orange),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const SettingsScreen(),
                ),
              );
            },
            tooltip: 'Настройки',
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 8),
            const Text(
              'Топ игроков',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.orange,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'По количеству очков',
              style: TextStyle(
                fontSize: 14,
                color: isDark ? Colors.grey : Colors.grey.shade600,
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: ListView.builder(
                itemCount: players.length,
                itemBuilder: (context, index) {
                  final player = players[index];
                  final place = player['place'];
                  final isTop = place <= 3;

                  return Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: isDark ? Colors.grey.shade800 : Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isTop
                            ? Colors.orange
                            : (isDark ? Colors.grey.shade700 : Colors.grey.shade300),
                        width: isTop ? 2 : 1,
                      ),
                      boxShadow: isTop
                          ? [
                              BoxShadow(
                                color: Colors.orange.withOpacity(0.2),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ]
                          : null,
                    ),
                    child: Row(
                      children: [
                        // Место
                        Container(
                          width: 32,
                          height: 32,
                          decoration: BoxDecoration(
                            color: _getPlaceColor(place),
                            shape: BoxShape.circle,
                          ),
                          child: Center(
                            child: Text(
                              '$place',
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        // Имя
                        Expanded(
                          child: Text(
                            player['name'],
                            style: TextStyle(
                              color: isDark ? Colors.white : Colors.black87,
                              fontSize: 16,
                              fontWeight: isTop ? FontWeight.bold : FontWeight.normal,
                            ),
                          ),
                        ),
                        // Игры
                        Text(
                          '${player['games']} игр',
                          style: TextStyle(
                            color: isDark ? Colors.grey : Colors.grey.shade600,
                            fontSize: 12,
                          ),
                        ),
                        const SizedBox(width: 12),
                        // Очки
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: isTop
                                ? Colors.orange.withOpacity(0.2)
                                : (isDark ? Colors.grey.shade700 : Colors.grey.shade200),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            '${player['points']}',
                            style: TextStyle(
                              color: isTop ? Colors.orange : (isDark ? Colors.white : Colors.black87),
                              fontWeight: isTop ? FontWeight.bold : FontWeight.normal,
                              fontSize: 16,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getPlaceColor(int place) {
    switch (place) {
      case 1:
        return Colors.orange.shade700;
      case 2:
        return Colors.grey.shade600;
      case 3:
        return Colors.brown.shade600;
      default:
        return Colors.grey.shade500;
    }
  }
}