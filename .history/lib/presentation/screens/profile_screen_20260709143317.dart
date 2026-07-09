// lib/presentation/screens/profile_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../services/auth_service.dart';
import '../../services/club_service.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  Map<String, dynamic>? _user;
  Map<String, dynamic>? _currentClub;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    setState(() => _isLoading = true);

    final token = await AuthService.getToken();
    if (token != null) {
      final userResult = await AuthService.getMe(token);
      if (userResult['success']) {
        final user = userResult['user'];
        _user = {
          'username': user.nickname,
          'email': user.email,
          'id': user.id,
        };
      }

      final clubResult = await ClubService.getMyClubs();
      if (clubResult['success'] && clubResult['clubs'] != null) {
        final clubs =
            (clubResult['clubs'] as List?)?.cast<Map<String, dynamic>>() ?? [];
        if (clubs.isNotEmpty) {
          _currentClub = {
            'id': clubs[0]['id'],
            'title': clubs[0]['title'],
            'is_president':
                clubs[0]['president_id'] == _user?['id'], // ✅ ДОБАВЛЕНО
          };
        }
      }
    }

    setState(() => _isLoading = false);
  }

  Future<void> _leaveClub() async {
    if (_currentClub == null) return;

    final isPresident = _currentClub?['is_president'] == true;

    // ✅ Если президент — показываем строгое предупреждение
    if (isPresident) {
      final confirm = await _showPresidentLeaveWarning();
      if (!confirm) return;
    } else {
      // ✅ Обычный участник — просто подтверждение
      final confirm = await _showConfirmDialog(
        context,
        'Выйти из клуба',
        'Вы уверены, что хотите покинуть клуб "${_currentClub!['title']}"?',
      );
      if (!confirm) return;
    }

    // ✅ Отправляем запрос на сервер
    final result = await ClubService.leaveClub(_currentClub!['id']);

    if (result['success']) {
      setState(() => _currentClub = null);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(isPresident
              ? 'Клуб удалён. Все данные стёрты.'
              : 'Вы вышли из клуба'),
          backgroundColor: Colors.green,
        ),
      );
      _loadProfile();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result['error'] ?? 'Ошибка'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

// ✅ НОВЫЙ МЕТОД — строгое предупреждение для президента
  Future<bool> _showPresidentLeaveWarning() async {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return await showDialog<bool>(
          context: context,
          barrierDismissible: false,
          builder: (context) => AlertDialog(
            backgroundColor: isDark ? Colors.grey.shade900 : Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            title: Row(
              children: [
                const Icon(Icons.warning_amber_rounded,
                    color: Colors.red, size: 28),
                const SizedBox(width: 12),
                Text(
                  '⚠️ Внимание!',
                  style: TextStyle(
                    color: isDark ? Colors.white : Colors.black87,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Вы покидаете клуб как президент.',
                  style: TextStyle(
                    color: isDark ? Colors.white : Colors.black87,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'Это приведёт к безвозвратному удалению:',
                  style: TextStyle(
                    color: isDark ? Colors.white70 : Colors.black54,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '• Все игры клуба\n'
                  '• Статистика игроков\n'
                  '• Список участников\n'
                  '• Рейтинг клуба',
                  style: TextStyle(
                    color: isDark ? Colors.grey : Colors.grey.shade600,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.red.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.red.withOpacity(0.3)),
                  ),
                  child: const Text(
                    'Восстановление будет невозможно!',
                    style: TextStyle(
                      color: Colors.red,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: Text(
                  'Отмена',
                  style: TextStyle(
                    color: isDark ? Colors.grey : Colors.grey.shade600,
                    fontSize: 16,
                  ),
                ),
              ),
              ElevatedButton(
                onPressed: () => Navigator.pop(context, true),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                ),
                child: const Text('Да, удалить всё'),
              ),
            ],
          ),
        ) ??
        false;
  }

  Future<bool> _showConfirmDialog(
      BuildContext context, String title, String message) async {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            backgroundColor: isDark ? Colors.grey.shade800 : Colors.white,
            title: Text(
              title,
              style: TextStyle(color: isDark ? Colors.white : Colors.black87),
            ),
            content: Text(
              message,
              style: TextStyle(color: isDark ? Colors.white70 : Colors.black54),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: Text(
                  'Отмена',
                  style: TextStyle(
                      color: isDark ? Colors.grey : Colors.grey.shade600),
                ),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text(
                  'Подтвердить',
                  style: TextStyle(color: Colors.red),
                ),
              ),
            ],
          ),
        ) ??
        false;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('Профиль'),
        backgroundColor: theme.appBarTheme.backgroundColor,
        foregroundColor: theme.appBarTheme.foregroundColor,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/lobby'),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadProfile,
            tooltip: 'Обновить',
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  // ===== АВАТАР =====
                  Center(
                    child: CircleAvatar(
                      radius: 60,
                      backgroundColor: Colors.orange.shade200,
                      child: Text(
                        _user?['username']?.substring(0, 1).toUpperCase() ??
                            '?',
                        style: const TextStyle(
                            fontSize: 36, color: Colors.black87),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Center(
                    child: Text(
                      _user?['username'] ?? 'Пользователь',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color:
                            theme.textTheme.titleLarge?.color ?? Colors.white,
                      ),
                    ),
                  ),
                  Center(
                    child: Text(
                      _user?['email'] ?? 'email@example.com',
                      style: TextStyle(
                        color: isDark ? Colors.grey : Colors.grey.shade600,
                        fontSize: 14,
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),

                  // ===== ТЕКУЩИЙ КЛУБ =====
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color:
                          isDark ? Colors.grey.shade800 : Colors.grey.shade200,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Текущий клуб',
                                style: TextStyle(
                                  color: isDark
                                      ? Colors.grey.shade400
                                      : Colors.grey.shade600,
                                  fontSize: 12,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                _currentClub?['title'] ?? 'Не состоите в клубе',
                                style: TextStyle(
                                  color: _currentClub != null
                                      ? Colors.orange
                                      : Colors.grey,
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              if (_currentClub?['is_official'] == true) ...[
                                const SizedBox(height: 4),
                                Row(
                                  children: [
                                    const Icon(Icons.verified,
                                        color: Colors.orange, size: 16),
                                    const SizedBox(width: 4),
                                    Text(
                                      'Официальный клуб',
                                      style: TextStyle(
                                        color: Colors.orange,
                                        fontSize: 12,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ],
                          ),
                        ),
                        if (_currentClub != null)
                          IconButton(
                            icon: const Icon(Icons.exit_to_app,
                                color: Colors.red),
                            onPressed: _leaveClub,
                            tooltip: 'Выйти из клуба',
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // ===== КНОПКИ =====

                  // Найти и вступить в клуб
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () => context.push('/club-select'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orange,
                        foregroundColor: Colors.black,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      icon: const Icon(Icons.search),
                      label: const Text('Найти и вступить в клуб'),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Создать клуб (если нет клуба)
                  if (_currentClub == null)
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: () => context.push('/create-club'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.orange,
                          side: const BorderSide(color: Colors.orange),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        icon: const Icon(Icons.add_circle),
                        label: const Text('Создать клуб'),
                      ),
                    ),

                  const SizedBox(height: 12),

                  // ===== УПРАВЛЕНИЕ КЛУБОМ (только для президента) =====
                  if (_currentClub != null &&
                      _currentClub?['is_president'] == true) ...[
                    const Divider(),
                    const SizedBox(height: 8),
                    Text(
                      'Управление клубом',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color:
                            theme.textTheme.titleLarge?.color ?? Colors.white,
                      ),
                    ),
                    const SizedBox(height: 8),
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: () => context.push('/club-requests'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.blue,
                          side: const BorderSide(color: Colors.blue),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        icon: const Icon(Icons.pending_actions),
                        label: const Text('Заявки в клуб'),
                      ),
                    ),
                    const SizedBox(height: 8),
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: () => context.push('/club-members'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.green,
                          side: const BorderSide(color: Colors.green),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        icon: const Icon(Icons.people),
                        label: const Text('Участники клуба'),
                      ),
                    ),
                  ],
                ],
              ),
            ),
    );
  }
}
