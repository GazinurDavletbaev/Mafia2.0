// lib/presentation/screens/settings_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../application/providers/theme_provider.dart';
import '../../services/auth_service.dart';
import '../../services/club_service.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _showHints = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = ref.watch(themeProvider);

    return Scaffold(
      backgroundColor: isDark ? Colors.black87 : Colors.grey.shade100,
      appBar: AppBar(
        title: const Text('Настройки'),
        backgroundColor: isDark ? Colors.grey.shade900 : Colors.white,
        foregroundColor: isDark ? Colors.white : Colors.black,
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Профиль'),
            Tab(text: 'Общие'),
          ],
          labelColor: Colors.orange,
          unselectedLabelColor: isDark ? Colors.grey : Colors.grey.shade600,
          indicatorColor: Colors.orange,
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // ✅ ВКЛАДКА "ПРОФИЛЬ"
          ProfileTab(isDark: isDark),
          
          // ✅ ВКЛАДКА "ОБЩИЕ" (старые настройки)
          GeneralSettingsTab(
            isDark: isDark,
            showHints: _showHints,
            onHintsChanged: (value) {
              setState(() {
                _showHints = value;
              });
            },
          ),
        ],
      ),
    );
  }
}

// ============================================================
// ✅ ВКЛАДКА "ПРОФИЛЬ"
// ============================================================
class ProfileTab extends ConsumerStatefulWidget {
  final bool isDark;

  const ProfileTab({super.key, required this.isDark});

  @override
  ConsumerState<ProfileTab> createState() => _ProfileTabState();
}

class _ProfileTabState extends ConsumerState<ProfileTab> {
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
        _user = userResult['user'];
      }

      // Загружаем текущий клуб
      final clubResult = await ClubService.getMyClubs();
if (clubResult['success'] && clubResult['clubs'] != null) {
  final clubs = (clubResult['clubs'] as List?)?.cast<Map<String, dynamic>>() ?? [];
  if (clubs.isNotEmpty) {
    _currentClub = clubs[0];
  }
}
    }

    setState(() => _isLoading = false);
  }

  Future<void> _leaveClub() async {
    if (_currentClub == null) return;

    final result = await ClubService.leaveClub(_currentClub!['id']);
    if (result['success']) {
      setState(() => _currentClub = null);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Вы вышли из клуба'), backgroundColor: Colors.green),
      );
      _loadProfile();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(result['error'] ?? 'Ошибка'), backgroundColor: Colors.red),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = widget.isDark;

    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // ===== АВАТАР =====
          Center(
            child: CircleAvatar(
              radius: 50,
              backgroundColor: Colors.orange.shade200,
              child: Text(
                _user?['username']?.substring(0, 1).toUpperCase() ?? '?',
                style: const TextStyle(fontSize: 32, color: Colors.black87),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Center(
            child: Text(
              _user?['username'] ?? 'Пользователь',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : Colors.black87,
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
              color: isDark ? Colors.grey.shade800 : Colors.grey.shade200,
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
                          color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _currentClub?['title'] ?? 'Не состоите в клубе',
                        style: TextStyle(
                          color: _currentClub != null ? Colors.orange : Colors.grey,
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                if (_currentClub != null)
                  IconButton(
                    icon: const Icon(Icons.exit_to_app, color: Colors.red),
                    onPressed: _leaveClub,
                    tooltip: 'Выйти из клуба',
                  ),
              ],
            ),
          ),
          const SizedBox(height: 16),

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
          if (_currentClub != null && _currentClub?['is_president'] == true) ...[
            const Divider(),
            const SizedBox(height: 8),
            Text(
              'Управление клубом',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : Colors.black87,
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
    );
  }
}

// ============================================================
// ✅ ВКЛАДКА "ОБЩИЕ НАСТРОЙКИ"
// ============================================================
class GeneralSettingsTab extends ConsumerWidget {
  final bool isDark;
  final bool showHints;
  final Function(bool) onHintsChanged;

  const GeneralSettingsTab({
    super.key,
    required this.isDark,
    required this.showHints,
    required this.onHintsChanged,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
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
              value: showHints,
              onChanged: (value) {
                onHintsChanged(value);
              },
              activeColor: Colors.orange,
            ),
            onTap: () {
              onHintsChanged(!showHints);
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
        trailing: trailing ?? const Icon(Icons.arrow_forward_ios, color: Colors.grey),
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