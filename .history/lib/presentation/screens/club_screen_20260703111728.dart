import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../services/update_service.dart';
import 'game_screen.dart';
import 'game_settings_screen.dart';
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

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: theme.appBarTheme.backgroundColor,
        title: Text(
          'Mafia Help',
          style: TextStyle(color: theme.appBarTheme.foregroundColor),
        ),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.orange),
          onPressed: () {
            context.go('/login');
          },
          tooltip: 'Назад на экран входа',
        ),
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
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'MAFIA HELP',
                style: TextStyle(
                  color: theme.textTheme.titleLarge?.color ?? Colors.white,
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 4,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Спортивная мафия',
                style: TextStyle(
                  color: isDark ? Colors.grey : Colors.grey.shade600,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 60),
              _buildMenuButton(
                context,
                icon: Icons.people,
                title: 'Новая игра',
                subtitle: 'С настройками и вводом игроков',
                onTap: _startRealGame,
              ),
              const SizedBox(height: 16),
              _buildMenuButton(
                context,
                icon: Icons.emoji_events,
                title: 'Рейтинг',
                subtitle: 'Статистика игроков',
                onTap: _showRating,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMenuButton(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: onTap,
        style: ElevatedButton.styleFrom(
          backgroundColor: isDark ? Colors.grey.shade800 : Colors.grey.shade200,
          foregroundColor: isDark ? Colors.white : Colors.black87,
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: Row(
          children: [
            Icon(icon, size: 28, color: Colors.orange),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white : Colors.black87,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 12,
                      color:
                          isDark ? Colors.grey.shade400 : Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              size: 20,
              color: isDark ? Colors.grey : Colors.grey.shade600,
            ),
          ],
        ),
      ),
    );
  }

  void _showRating() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Рейтинг в разработке')),
    );
  }
}
