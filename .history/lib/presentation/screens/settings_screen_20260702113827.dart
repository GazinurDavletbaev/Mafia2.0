// lib/presentation/screens/settings_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Провайдер для темы
final themeProvider =
    StateProvider<bool>((ref) => false); // false = светлая, true = тёмная

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  bool _isDarkTheme = false;
  bool _showHints = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black87,
      appBar: AppBar(
        title: const Text('Настройки'),
        backgroundColor: Colors.grey.shade900,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            _buildSettingsTile(
              title: 'Тёмная тема',
              subtitle: 'Включить тёмную тему',
              icon: Icons.dark_mode,
              trailing: Switch(
                value: _isDarkTheme,
                onChanged: (value) {
                  setState(() {
                    _isDarkTheme = value;
                  });
                  // TODO: применить тему
                },
                activeColor: Colors.orange,
              ),
              onTap: () {
                setState(() {
                  _isDarkTheme = !_isDarkTheme;
                });
              },
            ),
            _buildSettingsTile(
              title: 'Подсказки',
              subtitle: 'Показывать подсказки в игре',
              icon: Icons.lightbulb_outline,
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
            _buildSettingsTile(
              title: 'Проверить обновления',
              subtitle: 'Проверить наличие новой версии',
              icon: Icons.update,
              onTap: () {
                // TODO: проверка обновлений
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Проверка обновлений...'),
                    backgroundColor: Colors.orange,
                  ),
                );
              },
            ),
            _buildSettingsTile(
              title: 'О приложении',
              subtitle: 'Версия 1.7.4',
              icon: Icons.info_outline,
              onTap: () {
                _showAboutDialog(context);
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingsTile({
    required String title,
    required String subtitle,
    required IconData icon,
    Widget? trailing,
    required VoidCallback onTap,
  }) {
    return Card(
      color: Colors.grey.shade800,
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Icon(icon, color: Colors.orange),
        title: Text(
          title,
          style: const TextStyle(color: Colors.white),
        ),
        subtitle: Text(
          subtitle,
          style: TextStyle(color: Colors.grey.shade400),
        ),
        trailing:
            trailing ?? const Icon(Icons.arrow_forward_ios, color: Colors.grey),
        onTap: onTap,
      ),
    );
  }

  void _showAboutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.grey.shade800,
        title: const Text(
          'О приложении',
          style: TextStyle(color: Colors.white),
        ),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Mafia Help',
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Версия: 1.7.4',
              style: TextStyle(color: Colors.white70),
            ),
            SizedBox(height: 8),
            Text(
              'Приложение для судьи спортивной мафии',
              style: TextStyle(color: Colors.white70),
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
}
