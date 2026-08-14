// lib/presentation/widgets/club/club_members_table.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mafia_help/services/club_service.dart';
import 'package:mafia_help/application/providers/club_provider.dart';

class ClubMembersTable extends ConsumerStatefulWidget {
  final List<Map<String, dynamic>> members;
  final bool isDark;
  final int clubId;

  const ClubMembersTable({
    super.key,
    required this.members,
    required this.isDark,
    required this.clubId,
  });

  @override
  ConsumerState<ClubMembersTable> createState() => _ClubMembersTableState();
}

class _ClubMembersTableState extends ConsumerState<ClubMembersTable> {
  Map<String, dynamic>? _myClub;

  @override
  void initState() {
    super.initState();
    _loadMyClub();
  }

  Future<void> _loadMyClub() async {
    final clubResult = await ClubService.getCurrentClub();
    if (clubResult['success'] && clubResult['club'] != null) {
      setState(() {
        _myClub = clubResult['club'];
      });
    }
  }

  List<Map<String, dynamic>> _getSortedMembers() {
    final List<Map<String, dynamic>> sorted = List.from(widget.members);

    sorted.sort((a, b) {
      // 1️⃣ Президент всегда первый
      final bool aIsPresident = a['is_president'] == true;
      final bool bIsPresident = b['is_president'] == true;
      if (aIsPresident && !bIsPresident) return -1;
      if (!aIsPresident && bIsPresident) return 1;

      // 2️⃣ Судьи после президента
      final bool aIsJudge = a['is_judge'] == true;
      final bool bIsJudge = b['is_judge'] == true;
      if (aIsJudge && !bIsJudge) return -1;
      if (!aIsJudge && bIsJudge) return 1;

      // 3️⃣ Остальные по алфавиту
      final String aName = (a['username'] ?? '').toLowerCase();
      final String bName = (b['username'] ?? '').toLowerCase();
      return aName.compareTo(bName);
    });

    return sorted;
  }

  Future<void> _promoteToJudge(int userId) async {
    final result = await ClubService.promoteToJudge(widget.clubId, userId);
    if (result['success']) {
      ref.invalidate(clubProvider);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ Пользователь назначен судьёй'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ ${result['error'] ?? 'Ошибка'}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _demoteFromJudge(int userId) async {
    final result = await ClubService.demoteFromJudge(widget.clubId, userId);
    if (result['success']) {
      ref.invalidate(clubProvider);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ Судья снят с должности'),
            backgroundColor: Colors.orange,
          ),
        );
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ ${result['error'] ?? 'Ошибка'}'),
            backgroundColor: Colors.red,
          ),
        );
      }
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
      ref.invalidate(clubProvider);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ Участник удалён из клуба'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ ${result['error'] ?? 'Ошибка'}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = widget.isDark;
    final primaryColor = theme.primaryColor;

    final sortedMembers = _getSortedMembers();

    final bool isPresident = _myClub != null &&
        _myClub!['president_id'] != null &&
        _myClub!['president_id'] ==
            widget.members.firstWhere(
              (m) => m['is_president'] == true,
              orElse: () => {'id': null},
            )['id'];

    if (widget.members.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.people_outline,
              size: 48,
              color: isDark ? Colors.grey.shade600 : Colors.grey.shade400,
            ),
            const SizedBox(height: 16),
            Text(
              'В клубе пока нет участников',
              style: TextStyle(
                color: isDark ? Colors.grey : Colors.grey.shade600,
                fontSize: 16,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(30),
      itemCount: sortedMembers.length,
      itemBuilder: (context, index) {
        final member = sortedMembers[index];
        final isPresidentUser = member['is_president'] == true;
        final isJudge = member['is_judge'] == true;
        final isCurrentUser = member['id'] == _myClub?['president_id'];
        final avatarUrl = member['avatar_url'] as String?;

        return Card(
          color: isDark ? Colors.grey.shade950 : Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: isPresidentUser
                ? BorderSide(color: primaryColor, width: 2)
                : isJudge
                    ? const BorderSide(color: Colors.blue, width: 1)
                    : BorderSide.none,
          ),
          child: ListTile(
            leading: CircleAvatar(
              radius: 20,
              backgroundColor: isPresidentUser
                  ? primaryColor
                  : isJudge
                      ? Colors.blue
                      : Colors.grey.shade300,
              backgroundImage: avatarUrl != null && avatarUrl.isNotEmpty
                  ? NetworkImage(avatarUrl)
                  : null,
              child: avatarUrl == null || avatarUrl.isEmpty
                  ? Text(
                      member['username']?.substring(0, 1).toUpperCase() ?? '?',
                      style: TextStyle(
                        color: isPresidentUser || isJudge
                            ? Colors.white
                            : Colors.black87,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    )
                  : null,
            ),
            title: Row(
              children: [
                Expanded(
                  child: Text(
                    member['username'] ?? 'Неизвестен',
                    style: TextStyle(
                      fontWeight:
                          isPresidentUser ? FontWeight.bold : FontWeight.normal,
                      color: isDark ? Colors.white : Colors.black87,
                    ),
                  ),
                ),
                const SizedBox(width: 4),
                if (isPresidentUser)
                  _buildStatusChip('Президент', primaryColor),
                if (isJudge && !isPresidentUser)
                  _buildStatusChip('Судья', Colors.blue),
              ],
            ),
            subtitle: const SizedBox.shrink(),
            trailing: isPresidentUser
                ? Icon(Icons.star, color: primaryColor, size: 20)
                : isPresident && !isCurrentUser
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
                                      color: Colors.orange, size: 20),
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
    );
  }

  Widget _buildStatusChip(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 10,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
