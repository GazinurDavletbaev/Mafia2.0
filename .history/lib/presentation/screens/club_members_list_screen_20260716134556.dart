// lib/presentation/screens/club_members_list_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../services/club_service.dart';
import '../../application/providers/club_provider.dart';

class ClubMembersListScreen extends ConsumerStatefulWidget {
  final int clubId;
  final String clubTitle;

  const ClubMembersListScreen({
    super.key,
    required this.clubId,
    required this.clubTitle,
  });

  @override
  ConsumerState<ClubMembersListScreen> createState() =>
      _ClubMembersListScreenState();
}

class _ClubMembersListScreenState extends ConsumerState<ClubMembersListScreen> {
  List<Map<String, dynamic>> _members = [];
  Map<String, dynamic>? _myClub;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);

    // Получаем текущий клуб пользователя (чтобы узнать президент ли он)
    final clubResult = await ClubService.getCurrentClub();
    if (clubResult['success'] && clubResult['club'] != null) {
      _myClub = clubResult['club'];
    }

    // Получаем участников
    final result = await ClubService.getClubMembers(widget.clubId);
    if (result['success']) {
      _members =
          (result['members'] as List? ?? []).cast<Map<String, dynamic>>();
    }

    setState(() => _isLoading = false);
  }

  Future<void> _promoteToJudge(int userId) async {
    final result = await ClubService.promoteToJudge(widget.clubId, userId);
    if (result['success']) {
      // ✅ Обновляем провайдер
      ref.invalidate(clubProvider);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('✅ Пользователь назначен судьёй'),
          backgroundColor: Colors.green,
        ),
      );
      _loadData();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('❌ ${result['error'] ?? 'Ошибка'}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _demoteFromJudge(int userId) async {
    final result = await ClubService.demoteFromJudge(widget.clubId, userId);
    if (result['success']) {
      // ✅ Обновляем провайдер
      ref.invalidate(clubProvider);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('✅ Судья снят с должности'),
          backgroundColor: Colors.orange,
        ),
      );
      _loadData();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('❌ ${result['error'] ?? 'Ошибка'}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _removeMember(int userId) async {
    final confirm = await _showConfirmDialog(
      context,
      'Удалить участника',
      'Вы уверены, что хотите удалить этого участника из клуба?',
    );
    if (!confirm) return;

    final result = await ClubService.removeMember(widget.clubId, userId);
    if (result['success']) {
      // ✅ Обновляем провайдер
      ref.invalidate(clubProvider);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('✅ Участник удалён из клуба'),
          backgroundColor: Colors.green,
        ),
      );
      _loadData();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('❌ ${result['error'] ?? 'Ошибка'}'),
          backgroundColor: Colors.red,
        ),
      );
    }
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
              style: TextStyle(
                color: isDark ? Colors.white : Colors.black87,
              ),
            ),
            content: Text(
              message,
              style: TextStyle(
                color: isDark ? Colors.white70 : Colors.black54,
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: Text(
                  'Отмена',
                  style: TextStyle(
                    color: isDark ? Colors.grey : Colors.grey.shade600,
                  ),
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

    final isPresident = _myClub != null && _myClub!['president_id'] != null;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          'Участники "${widget.clubTitle}"',
          style: TextStyle(
            color: isDark ? Colors.white : Colors.black87,
          ),
        ),
        backgroundColor: theme.appBarTheme.backgroundColor,
        foregroundColor: theme.appBarTheme.foregroundColor,
        actions: [
          if (isPresident)
            IconButton(
              icon: const Icon(Icons.person_add),
              onPressed: () {
                // TODO: поиск пользователей для добавления
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Поиск пользователей (в разработке)'),
                    backgroundColor: Colors.orange,
                  ),
                );
              },
              tooltip: 'Добавить участника',
            ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _members.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.people_outline,
                        size: 64,
                        color: isDark
                            ? Colors.grey.shade600
                            : Colors.grey.shade400,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'В клубе пока нет участников!',
                        style: TextStyle(
                          color: isDark ? Colors.grey : Colors.grey.shade600,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _members.length,
                  itemBuilder: (context, index) {
                    final member = _members[index];
                    final isPresidentUser = member['is_president'] == true;
                    final isJudge = member['is_judge'] == true;

                    return Card(
                      color: isDark ? Colors.grey.shade800 : Colors.white,
                      margin: const EdgeInsets.only(bottom: 8),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                        side: isPresidentUser
                            ? const BorderSide(color: Colors.orange, width: 2)
                            : isJudge
                                ? const BorderSide(color: Colors.blue, width: 1)
                                : BorderSide.none,
                      ),
                      child: ListTile(
                        contentPadding: const EdgeInsets.all(12),
                        leading: CircleAvatar(
                          backgroundColor: isPresidentUser
                              ? Colors.orange
                              : isJudge
                                  ? Colors.blue
                                  : Colors.grey.shade300,
                          child: Text(
                            member['username']?.substring(0, 1).toUpperCase() ??
                                '?',
                            style: TextStyle(
                              color: isPresidentUser || isJudge
                                  ? Colors.white
                                  : Colors.black87,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        title: Row(
                          children: [
                            Expanded(
                              child: Text(
                                member['username'] ?? 'Неизвестен',
                                style: TextStyle(
                                  fontWeight: isPresidentUser
                                      ? FontWeight.bold
                                      : FontWeight.normal,
                                  color: isDark ? Colors.white : Colors.black87,
                                ),
                              ),
                            ),
                            if (isPresidentUser) ...[
                              const SizedBox(width: 4),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.orange.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: const Text(
                                  'Президент',
                                  style: TextStyle(
                                    color: Colors.orange,
                                    fontSize: 10,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
                            if (isJudge && !isPresidentUser) ...[
                              const SizedBox(width: 4),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.blue.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: const Text(
                                  'Судья',
                                  style: TextStyle(
                                    color: Colors.blue,
                                    fontSize: 10,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                        subtitle: Text(
                          member['email'] ?? '',
                          style: TextStyle(
                            color: isDark
                                ? Colors.grey.shade400
                                : Colors.grey.shade600,
                            fontSize: 12,
                          ),
                        ),
                        trailing: isPresidentUser
                            ? const Icon(Icons.star,
                                color: Colors.orange, size: 20)
                            : isPresident
                                ? PopupMenuButton<String>(
                                    icon: const Icon(Icons.more_vert),
                                    onSelected: (value) {
                                      if (value == 'promote') {
                                        _promoteToJudge(member['id']);
                                      } else if (value == 'demote') {
                                        _demoteFromJudge(member['id']);
                                      } else if (value == 'remove') {
                                        _removeMember(member['id']);
                                      }
                                    },
                                    itemBuilder: (context) => [
                                      if (!isJudge)
                                        const PopupMenuItem(
                                          value: 'promote',
                                          child: Row(
                                            children: [
                                              Icon(Icons.gavel,
                                                  color: Colors.blue, size: 20),
                                              SizedBox(width: 8),
                                              Text('Назначить судьёй'),
                                            ],
                                          ),
                                        ),
                                      if (isJudge)
                                        const PopupMenuItem(
                                          value: 'demote',
                                          child: Row(
                                            children: [
                                              Icon(Icons.person_remove,
                                                  color: Colors.orange,
                                                  size: 20),
                                              SizedBox(width: 8),
                                              Text('Снять с должности судьи'),
                                            ],
                                          ),
                                        ),
                                      const PopupMenuItem(
                                        value: 'remove',
                                        child: Row(
                                          children: [
                                            Icon(Icons.remove_circle,
                                                color: Colors.red, size: 20),
                                            SizedBox(width: 8),
                                            Text('Удалить из клуба'),
                                          ],
                                        ),
                                      ),
                                    ],
                                  )
                                : null,
                      ),
                    );
                  },
                ),
    );
  }
}
