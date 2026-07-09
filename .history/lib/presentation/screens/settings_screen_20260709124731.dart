// lib/presentation/screens/settings_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../application/providers/theme_provider.dart';
import '../../services/auth_service.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  bool _showHints = true;

  @override
  Widget build(BuildContext context) {
    final isDark = ref.watch(themeProvider);

    return Scaffold(
      backgroundColor: isDark ? Colors.black87 : Colors.grey.shade100,
      appBar: AppBar(
        title: const Text('Настройки'),
        backgroundColor: isDark ? Colors.grey.shade900 : Colors.white,
        foregroundColor: isDark ? Colors.white : Colors.black,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (context.mounted) {
                context.go('/lobby');
              }
            });
          },
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // ✅ КНОПКА ПРОФИЛЬ
            _buildSettingsTile(
              context,
              title: 'Профиль',
              subtitle: 'Управление профилем и клубом',
              icon: Icons.person,
              isDark: isDark,
              onTap: () {
                context.go('/ediprofile');
              },
            ),
            // Тёмная тема
            _buildSettingsTile(
              context,
              title: 'Тёмная тема',
              subtitle: 'Включить тёмную тему',
              icon: Icons.dark_mode,
              isDark: isDark,
              trailing: Switch(
                value: isDark,
                onChanged: (value) {
                  ref.read(themeProvider.notifier).state = value;
                },
                activeColor: Colors.orange,
              ),
              onTap: () {
                ref.read(themeProvider.notifier).state = !isDark;
              },
            ),
            // Подсказки
            _buildSettingsTile(
              context,
              title: 'Подсказки',
              subtitle: 'Показывать подсказки в игре',
              icon: Icons.lightbulb_outline,
              isDark: isDark,
              trailing: Switch(
                value: _showHints,
                onChanged: (value) {
                  setState(() {
                    _showHints = value;
                  });
                },
                activeColor: Colors.orange,
              ),
              onTap: () {
                setState(() {
                  _showHints = !_showHints;
                });
              },
            ),
            // Проверить обновления
            _buildSettingsTile(
              context,
              title: 'Проверить обновления',
              subtitle: 'Проверить наличие новой версии',
              icon: Icons.update,
              isDark: isDark,
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Проверка обновлений...'),
                    backgroundColor: Colors.orange,
                  ),
                );
              },
            ),
            // О приложении
            _buildSettingsTile(
              context,
              title: 'О приложении',
              subtitle: 'Версия 1.7.4',
              icon: Icons.info_outline,
              isDark: isDark,
              onTap: () {
                _showAboutDialog(context, isDark);
              },
            ),
            // Сменить пароль
            _buildSettingsTile(
              context,
              title: 'Сменить пароль',
              subtitle: 'Изменить текущий пароль',
              icon: Icons.lock_outline,
              isDark: isDark,
              onTap: () {
                context.go('/change-password');
              },
            ),
            const Divider(color: Colors.grey, height: 32),
            // Выйти
            _buildSettingsTile(
              context,
              title: 'Выйти',
              subtitle: 'Выйти из аккаунта',
              icon: Icons.logout,
              isDark: isDark,
              iconColor: Colors.red,
              textColor: Colors.red,
              onTap: () {
                _showLogoutDialog(context);
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingsTile(
    BuildContext context, {
    required String title,
    required String subtitle,
    required IconData icon,
    required bool isDark,
    Widget? trailing,
    required VoidCallback onTap,
    Color? iconColor,
    Color? textColor,
  }) {
    return Card(
      color: isDark ? Colors.grey.shade800 : Colors.white,
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Icon(
          icon,
          color: iconColor ?? Colors.orange,
        ),
        title: Text(
          title,
          style: TextStyle(
            color: textColor ?? (isDark ? Colors.white : Colors.black87),
          ),
        ),
        subtitle: Text(
          subtitle,
          style: TextStyle(
            color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
          ),
        ),
        trailing:
            trailing ?? const Icon(Icons.arrow_forward_ios, color: Colors.grey),
        onTap: onTap,
      ),
    );
  }

  void _showAboutDialog(BuildContext context, bool isDark) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: isDark ? Colors.grey.shade800 : Colors.white,
        title: Text(
          'О приложении',
          style: TextStyle(color: isDark ? Colors.white : Colors.black87),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Mafia Help',
              style: TextStyle(
                color: isDark ? Colors.white : Colors.black87,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Версия: 1.7.4',
              style: TextStyle(color: isDark ? Colors.white70 : Colors.black54),
            ),
            const SizedBox(height: 8),
            Text(
              'Приложение для судьи спортивной мафии',
              style: TextStyle(color: isDark ? Colors.white70 : Colors.black54),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'Закрыть',
              style: TextStyle(color: Colors.orange),
            ),
          ),
        ],
      ),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: isDark ? Colors.grey.shade800 : Colors.white,
        title: Text(
          'Выйти из аккаунта?',
          style: TextStyle(
            color: isDark ? Colors.white : Colors.black87,
          ),
        ),
        content: Text(
          'Вы уверены, что хотите выйти?',
          style: TextStyle(
            color: isDark ? Colors.white70 : Colors.black54,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Отмена',
              style: TextStyle(
                color: isDark ? Colors.grey : Colors.grey.shade600,
              ),
            ),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await AuthService.logout();
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
