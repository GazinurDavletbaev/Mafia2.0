// lib/presentation/screens/club_members_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../services/club_service.dart';

class ClubMembersScreen extends ConsumerStatefulWidget {
  const ClubMembersScreen({super.key});

  @override
  ConsumerState<ClubMembersScreen> createState() => _ClubMembersScreenState();
}

class _ClubMembersScreenState extends ConsumerState<ClubMembersScreen> {
  List<Map<String, dynamic>> _members = [];
  List<Map<String, dynamic>> _judges = [];
  bool _isLoading = true;
  Map<String, dynamic>? _club;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);

    final clubResult = await ClubService.getCurrentClub();
    if (clubResult['success'] && clubResult['club'] != null) {
      _club = clubResult['club'];

      final membersResult = await ClubService.getClubMembers(_club!['id']);
      if (membersResult['success']) {
        _members = (membersResult['members'] as List? ?? [])
            .cast<Map<String, dynamic>>();
        _judges = (membersResult['judges'] as List? ?? [])
            .cast<Map<String, dynamic>>();
      }
    }

    setState(() => _isLoading = false);
  }

  Future<void> _removeMember(int userId) async {
    if (_club == null) return;

    final result = await ClubService.removeMember(_club!['id'], userId);
    if (result['success']) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Участник удалён из клуба'),
          backgroundColor: Colors.green,
        ),
      );
      _loadData();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result['error'] ?? 'Ошибка'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _promoteToJudge(int userId) async {
    if (_club == null) return;

    final result = await ClubService.promoteToJudge(_club!['id'], userId);
    if (result['success']) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Пользователь назначен судьёй'),
          backgroundColor: Colors.green,
        ),
      );
      _loadData();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result['error'] ?? 'Ошибка'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _demoteFromJudge(int userId) async {
    if (_club == null) return;

    final result = await ClubService.demoteFromJudge(_club!['id'], userId);
    if (result['success']) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Судья снят с должности'),
          backgroundColor: Colors.orange,
        ),
      );
      _loadData();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result['error'] ?? 'Ошибка'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final primaryColor = theme.primaryColor;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
            _club != null ? 'Участники "${_club!['title']}"' : 'Участники'),
        backgroundColor: theme.appBarTheme.backgroundColor,
        foregroundColor: theme.appBarTheme.foregroundColor,
        actions: [
          IconButton(
            icon: const Icon(Icons.person_add),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content:
                      Text('Поиск пользователей для добавления (в разработке)'),
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
          : DefaultTabController(
              length: 2,
              child: Column(
                children: [
                  TabBar(
                    tabs: [
                      Tab(text: 'Участники (${_members.length})'),
                      Tab(text: 'Судьи (${_judges.length})'),
                    ],
                    labelColor: primaryColor,
                    unselectedLabelColor:
                        isDark ? Colors.grey : Colors.grey.shade600,
                    indicatorColor: primaryColor,
                  ),
                  Expanded(
                    child: TabBarView(
                      children: [
                        _members.isEmpty
                            ? _buildEmptyState(isDark, 'Участников пока нет')
                            : ListView.builder(
                                padding: const EdgeInsets.all(16),
                                itemCount: _members.length,
                                itemBuilder: (context, index) {
                                  final member = _members[index];
                                  return _buildMemberCard(member, isDark);
                                },
                              ),
                        _judges.isEmpty
                            ? _buildEmptyState(isDark, 'Судей пока нет')
                            : ListView.builder(
                                padding: const EdgeInsets.all(16),
                                itemCount: _judges.length,
                                itemBuilder: (context, index) {
                                  final judge = _judges[index];
                                  return _buildJudgeCard(judge, isDark);
                                },
                              ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildEmptyState(bool isDark, String text) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.people_outline,
            size: 64,
            color: isDark ? Colors.grey.shade600 : Colors.grey.shade400,
          ),
          const SizedBox(height: 16),
          Text(
            text,
            style: TextStyle(
              color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMemberCard(Map<String, dynamic> member, bool isDark) {
    final theme = Theme.of(context);
    final primaryColor = theme.primaryColor;
    final isPresident = member['is_president'] == true;
    final isJudge = member['is_judge'] == true;

    return Card(
      color: isDark ? Colors.grey.shade800 : Colors.white,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: isPresident
            ? BorderSide(color: primaryColor, width: 2)
            : BorderSide.none,
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: CircleAvatar(
          backgroundColor: isPresident ? primaryColor : Colors.grey.shade300,
          child: Text(
            member['username']?.substring(0, 1).toUpperCase() ?? '?',
            style: TextStyle(
              color: isPresident ? Colors.white : Colors.black87,
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
                  fontWeight: isPresident ? FontWeight.bold : FontWeight.normal,
                  color: theme.textTheme.bodyLarge?.color ?? Colors.white,
                ),
              ),
            ),
            if (isPresident) ...[
              const SizedBox(width: 4),
              Icon(
                Icons.star,
                color: primaryColor,
                size: 18,
              ),
            ],
            if (isJudge && !isPresident) ...[
              const SizedBox(width: 4),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
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
            color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
            fontSize: 13,
          ),
        ),
        trailing: isPresident
            ? null
            : PopupMenuButton<String>(
                icon: const Icon(Icons.more_vert),
                onSelected: (value) async {
                  if (value == 'remove') {
                    final confirm = await _showConfirmDialog(
                      context,
                      'Удалить участника',
                      'Вы уверены, что хотите удалить ${member['username']} из клуба?',
                    );
                    if (confirm) {
                      _removeMember(member['id']);
                    }
                  } else if (value == 'promote') {
                    _promoteToJudge(member['id']);
                  }
                },
                itemBuilder: (context) => [
                  if (!isJudge)
                    const PopupMenuItem(
                      value: 'promote',
                      child: Row(
                        children: [
                          Icon(Icons.gavel, color: Colors.blue, size: 20),
                          SizedBox(width: 8),
                          Text('Назначить судьёй'),
                        ],
                      ),
                    ),
                  const PopupMenuItem(
                    value: 'remove',
                    child: Row(
                      children: [
                        Icon(Icons.remove_circle, color: Colors.red, size: 20),
                        SizedBox(width: 8),
                        Text('Удалить из клуба'),
                      ],
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  Widget _buildJudgeCard(Map<String, dynamic> judge, bool isDark) {
    final theme = Theme.of(context);
    final primaryColor = theme.primaryColor;
    final isPresident = judge['is_president'] == true;

    return Card(
      color: isDark ? Colors.grey.shade800 : Colors.white,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: isPresident
            ? BorderSide(color: primaryColor, width: 2)
            : const BorderSide(color: Colors.blue, width: 1),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: CircleAvatar(
          backgroundColor: isPresident ? primaryColor : Colors.blue,
          child: Text(
            judge['username']?.substring(0, 1).toUpperCase() ?? '?',
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        title: Row(
          children: [
            Expanded(
              child: Text(
                judge['username'] ?? 'Неизвестен',
                style: TextStyle(
                  fontWeight: isPresident ? FontWeight.bold : FontWeight.normal,
                  color: theme.textTheme.bodyLarge?.color ?? Colors.white,
                ),
              ),
            ),
            if (isPresident) ...[
              const SizedBox(width: 4),
              Icon(
                Icons.star,
                color: primaryColor,
                size: 18,
              ),
            ],
            if (!isPresident) ...[
              const SizedBox(width: 4),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
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
          judge['email'] ?? '',
          style: TextStyle(
            color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
            fontSize: 13,
          ),
        ),
        trailing: isPresident
            ? null
            : IconButton(
                icon: const Icon(Icons.person_remove, color: Colors.orange),
                onPressed: () async {
                  final confirm = await _showConfirmDialog(
                    context,
                    'Снять с должности судьи',
                    'Вы уверены, что хотите снять ${judge['username']} с должности судьи?',
                  );
                  if (confirm) {
                    _demoteFromJudge(judge['id']);
                  }
                },
                tooltip: 'Снять с должности судьи',
              ),
      ),
    );
  }

  Future<bool> _showConfirmDialog(
      BuildContext context, String title, String message) async {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
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
}