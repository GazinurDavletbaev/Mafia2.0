// lib/presentation/screens/create_club_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../services/club_service.dart';

class CreateClubScreen extends ConsumerStatefulWidget {
  const CreateClubScreen({super.key});

  @override
  ConsumerState<CreateClubScreen> createState() => _CreateClubScreenState();
}

class _CreateClubScreenState extends ConsumerState<CreateClubScreen> {
  final _titleController = TextEditingController();
  final _cityController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _titleController.dispose();
    _cityController.dispose();
    super.dispose();
  }

  Future<void> _createClub() async {
    final title = _titleController.text.trim();
    final city = _cityController.text.trim();

    if (title.isEmpty) {
      _showSnackBar('Введите название клуба', Colors.red);
      return;
    }

    setState(() => _isLoading = true);

    final result = await ClubService.createClub(
      title: title,
      city: city.isNotEmpty ? city : null,
    );

    setState(() => _isLoading = false);

    if (result['success']) {
      _showSnackBar('Клуб успешно создан!', Colors.green);
      // Возвращаемся в профиль
      Future.delayed(const Duration(seconds: 1), () {
        if (mounted) {
          context.go('/settings');
        }
      });
    } else {
      _showSnackBar(result['error'] ?? 'Ошибка создания клуба', Colors.red);
    }
  }

  void _showSnackBar(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: const TextStyle(color: Colors.white)),
        backgroundColor: color,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('Создать клуб'),
        backgroundColor: theme.appBarTheme.backgroundColor,
        foregroundColor: theme.appBarTheme.foregroundColor,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Icon(Icons.group_add, size: 64, color: Colors.orange),
            const SizedBox(height: 16),
            Text(
              'Создайте свой клуб',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: theme.textTheme.titleLarge?.color ?? Colors.white,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Станьте президентом клуба и управляйте им',
              style: TextStyle(
                color: isDark ? Colors.grey : Colors.grey.shade600,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 32),

            // Название клуба
            TextField(
              controller: _titleController,
              style: TextStyle(
                color: theme.textTheme.bodyLarge?.color ?? Colors.white,
              ),
              decoration: InputDecoration(
                labelText: 'Название клуба *',
                labelStyle: TextStyle(
                  color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
                ),
                hintText: 'Например: Мафия Питера',
                hintStyle: TextStyle(
                  color: isDark ? Colors.grey.shade600 : Colors.grey.shade400,
                ),
                filled: true,
                fillColor: isDark ? Colors.grey.shade800 : Colors.grey.shade200,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                prefixIcon: const Icon(Icons.emoji_events, color: Colors.orange),
              ),
            ),
            const SizedBox(height: 16),

            // Город
            TextField(
              controller: _cityController,
              style: TextStyle(
                color: theme.textTheme.bodyLarge?.color ?? Colors.white,
              ),
              decoration: InputDecoration(
                labelText: 'Город (необязательно)',
                labelStyle: TextStyle(
                  color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
                ),
                hintText: 'Например: Москва',
                hintStyle: TextStyle(
                  color: isDark ? Colors.grey.shade600 : Colors.grey.shade400,
                ),
                filled: true,
                fillColor: isDark ? Colors.grey.shade800 : Colors.grey.shade200,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                prefixIcon: const Icon(Icons.location_city, color: Colors.orange),
              ),
            ),
            const SizedBox(height: 24),

            // Кнопка создания
            SizedBox(
              width: double.infinity,
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : ElevatedButton(
                      onPressed: _createClub,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orange,
                        foregroundColor: Colors.black,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'Создать клуб',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
            ),
            const SizedBox(height: 12),

            // Кнопка назад
            TextButton(
              onPressed: () => context.go('/settings'),
              child: const Text(
                '← Вернуться в профиль',
                style: TextStyle(color: Colors.grey),
              ),
            ),
          ],
        ),
      ),
    );
  }
}