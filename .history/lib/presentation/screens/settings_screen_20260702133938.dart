// lib/presentation/screens/settings_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../application/providers/theme_provider.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = ref.watch(themeProvider);

    return Scaffold(
      backgroundColor: isDark ? Colors.black87 : Colors.grey.shade100,
      appBar: AppBar(
        title: const Text('Настройки'),
        backgroundColor: isDark ? Colors.grey.shade900 : Colors.white,
        foregroundColor: isDark ? Colors.white : Colors.black,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Card(
              color: isDark ? Colors.grey.shade800 : Colors.white,
              child: ListTile(
                leading: const Icon(Icons.dark_mode, color: Colors.orange),
                title: Text(
                  'Тёмная тема',
                  style: TextStyle(color: isDark ? Colors.white : Colors.black87),
                ),
                subtitle: Text(
                  'Включить тёмную тему',
                  style: TextStyle(color: isDark ? Colors.grey.shade400 : Colors.grey.shade600),
                ),
                trailing: Switch(
                  value: isDark,
                  onChanged: (value) {
                    ref.read(themeProvider.notifier).state = value;
                  },
                  activeColor: Colors.orange,
                ),
              ),
            ),
            // ... остальные настройки
          ],
        ),
      ),
    );
  }
}