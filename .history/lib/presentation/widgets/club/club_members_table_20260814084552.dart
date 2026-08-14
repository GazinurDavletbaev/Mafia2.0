// lib/presentation/widgets/club/club_members_table.dart
import 'package:flutter/material.dart';

class ClubMembersTable extends StatelessWidget {
  final List<Map<String, dynamic>> members;
  final bool isDark;

  const ClubMembersTable({
    super.key,
    required this.members,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).primaryColor;

    if (members.isEmpty) {
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
      padding: const EdgeInsets.all(8),
      itemCount: members.length,
      itemBuilder: (context, index) {
        final member = members[index];
        final isPresidentUser = member['is_president'] == true;
        final isJudge = member['is_judge'] == true;

        return Card(
          color: isDark ? Colors.grey.shade800 : Colors.white,
          margin: const EdgeInsets.only(bottom: 8),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: isPresidentUser
                ? BorderSide(color: primaryColor, width: 2)
                : isJudge
                    ? const BorderSide(color: Colors.blue, width: 1)
                    : BorderSide.none,
          ),
          child: ListTile(
            contentPadding: const EdgeInsets.all(12),
            leading: CircleAvatar(
              backgroundColor: isPresidentUser
                  ? primaryColor
                  : isJudge
                      ? Colors.blue
                      : Colors.grey.shade300,
              child: Text(
                member['username']?.substring(0, 1).toUpperCase() ?? '?',
                style: TextStyle(
                  color: isPresidentUser || isJudge ? Colors.white : Colors.black87,
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
                      fontWeight: isPresidentUser ? FontWeight.bold : FontWeight.normal,
                      color: isDark ? Colors.white : Colors.black87,
                    ),
                  ),
                ),
                if (isPresidentUser)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: primaryColor.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      'Президент',
                      style: TextStyle(
                        color: primaryColor,
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                if (isJudge && !isPresidentUser)
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
            ),
            subtitle: Text(
              member['email'] ?? '',
              style: TextStyle(
                color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
                fontSize: 12,
              ),
            ),
            trailing: isPresidentUser
                ? Icon(Icons.star, color: primaryColor, size: 20)
                : null,
          ),
        );
      },
    );
  }
}