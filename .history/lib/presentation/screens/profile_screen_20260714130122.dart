// lib/presentation/screens/profile_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../services/auth_service.dart';
import '../../services/club_service.dart';
import 'create_club_screen.dart';
import 'edit_club_screen.dart';
import 'club_screen.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  Map<String, dynamic>? _user;
  Map<String, dynamic>? _club;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);

    final token = await AuthService.getToken();
    if (token != null) {
      final userResult = await AuthService.getMe(token);
      if (userResult['success']) {
        final user = userResult['user'];
        _user = {
          'id': user.id,
          'username': user.nickname,
          'email': user.email,
          'avatarUrl': user.avatarUrl,
        };
          ref.invalidate(clubProvider); // ✅ Перезагружаем клуб

      }

      final clubResult = await ClubService.getCurrentClub();
      print('📦 Club result: $clubResult'); // ✅ ДОБАВЬ

      if (clubResult['success'] && clubResult['club'] != null) {
        _club = clubResult['club'];
        print('📦 _club: $_club'); // ✅ ДОБАВЬ
        
      }
    }
    
    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    // ✅ Если нет клуба — предлагаем создать
    if (_club == null || _club!['id'] == null) {
      return _buildNoClubScreen(theme, isDark);
    }

    // ✅ Если президент — показываем редактирование
    final isPresident =
        _club?['president_id'].toString() == _user?['id'].toString();
    if (isPresident) {
      return EditClubScreen(club: _club!);
    }

    // ✅ Обычный участник — просмотр клуба
    return _buildClubViewScreen(theme, isDark);
  }

  Widget _buildNoClubScreen(ThemeData theme, bool isDark) {
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('Клуб'),
        backgroundColor: theme.appBarTheme.backgroundColor,
        foregroundColor: theme.appBarTheme.foregroundColor,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.group_off,
                size: 80,
                color: isDark ? Colors.grey.shade600 : Colors.grey.shade400,
              ),
              const SizedBox(height: 16),
              Text(
                'У вас нет клуба',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: theme.textTheme.titleLarge?.color ?? Colors.white,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Создайте свой клуб или вступите в существующий',
                style: TextStyle(
                  color: isDark ? Colors.grey : Colors.grey.shade600,
                  fontSize: 14,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: () {
                  context.push('/create-club');
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                  foregroundColor: Colors.black,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Создать клуб',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(height: 12),
              TextButton(
                onPressed: () => context.push('/club-select'),
                child: Text(
                  'Найти клуб для вступления',
                  style: TextStyle(
                    color: isDark ? Colors.grey : Colors.grey.shade600,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildClubViewScreen(ThemeData theme, bool isDark) {
    final members = _club?['members'] as List? ?? [];
    final presidentName = _club?['president_name'] ?? 'Неизвестен';
    final clubName = _club?['title'] ?? 'Клуб';
    final clubLogo = _club?['logo_url'];
    print("zaebal nahyy");
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('Мой клуб'),
        backgroundColor: theme.appBarTheme.backgroundColor,
        foregroundColor: theme.appBarTheme.foregroundColor,
        actions: [
          IconButton(
            icon: const Icon(Icons.exit_to_app, color: Colors.red),
            onPressed: () => _showLeaveDialog(),
            tooltip: 'Покинуть клуб',
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Аватарка клуба
            Center(
              child: CircleAvatar(
                radius: 60,
                backgroundColor: Colors.orange.shade200,
                backgroundImage: clubLogo != null && clubLogo.isNotEmpty
                    ? NetworkImage(clubLogo)
                    : null,
                child: clubLogo == null || clubLogo.isEmpty
                    ? Text(
                        clubName.substring(0, 1).toUpperCase(),
                        style: const TextStyle(
                          fontSize: 36,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      )
                    : null,
              ),
            ),
            const SizedBox(height: 8),
            Center(
              child: Text(
                clubName,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: theme.textTheme.titleLarge?.color ?? Colors.white,
                ),
              ),
            ),
            const SizedBox(height: 4),
            Center(
              child: Text(
                'Президент: $presidentName',
                style: TextStyle(
                  color: isDark ? Colors.grey : Colors.grey.shade600,
                  fontSize: 14,
                ),
              ),
            ),
            const SizedBox(height: 24),
            const Divider(),
            const SizedBox(height: 16),

            // Участники
            Text(
              'Участники (${members.length})',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: theme.textTheme.titleLarge?.color ?? Colors.white,
              ),
            ),
            const SizedBox(height: 12),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: members.length,
              itemBuilder: (context, index) {
                final member = members[index];
                final isPresident = member['is_president'] ?? false;
                return ListTile(
                  leading: CircleAvatar(
                    radius: 20,
                    backgroundColor: Colors.orange.shade200,
                    child: Text(
                      member['username']?.substring(0, 1).toUpperCase() ?? '?',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                  ),
                  title: Text(
                    member['username'] ?? 'Неизвестный',
                    style: TextStyle(
                      color: theme.textTheme.bodyLarge?.color ?? Colors.white,
                    ),
                  ),
                  trailing: isPresident
                      ? const Icon(Icons.star, color: Colors.orange, size: 20)
                      : null,
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showLeaveDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        title: const Text('Покинуть клуб?'),
        content: const Text('Вы уверены, что хотите покинуть клуб?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Отмена'),
          ),
          TextButton(
            onPressed: () async {
              final result = await ClubService.leaveClub(_club!['id']);
              if (result['success']) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Вы покинули клуб'),
                      backgroundColor: Colors.green,
                    ),
                  );
                  _loadData();
                }
              } else {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(result['error'] ?? 'Ошибка'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              }
            },
            child: const Text(
              'Покинуть',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }
}
