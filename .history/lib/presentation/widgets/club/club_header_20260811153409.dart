// lib/presentation/widgets/club/club_header.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:mafia_help/presentation/widgets/app_card.dart';
import 'package:mafia_help/presentation/widgets/app_text.dart';
import 'club_join_button.dart';
import 'package:mdi_plus/mdi_plus.dart';

class ClubHeader extends StatelessWidget {
  final Map<String, dynamic>? club;
  final int? myClubId;
  final int gamesCount;
  final VoidCallback onRefresh;

  const ClubHeader({
    super.key,
    required this.club,
    required this.myClubId,
    required this.gamesCount,
    required this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return AppCard(
      isDark: isDark,
      padding: const EdgeInsets.all(16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 🔥 ЛЕВАЯ ЧАСТЬ: АВАТАРКА КЛУБА
          Stack(
            clipBehavior: Clip.none,
            children: [
              // Аватарка клуба
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  color: isDark ? Colors.grey.shade700 : Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(16),
                  image:
                      club?['logo_url'] != null && club!['logo_url'].isNotEmpty
                          ? DecorationImage(
                              image: NetworkImage(club!['logo_url']),
                              fit: BoxFit.cover,
                            )
                          : null,
                ),
                child: club?['logo_url'] == null || club!['logo_url'].isEmpty
                    ? Image.asset(
                        'assets/mafia_logo.png',
                        width: 50,
                        height: 50,
                        fit: BoxFit.contain,
                      )
                    : null,
              ),
              // 🔥 БЕЙДЖ ПРЕЗИДЕНТА (сверху справа)
              Positioned(
                top: -8,
                right: -8,
                child: Container(
                  padding: const EdgeInsets.all(2),
                  decoration: BoxDecoration(
                    color: Colors.orange,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: theme.scaffoldBackgroundColor,
                      width: 2,
                    ),
                  ),
                  child: CircleAvatar(
                    radius: 16,
                    backgroundColor:
                        isDark ? Colors.grey.shade700 : Colors.grey.shade300,
                    backgroundImage: club?['president_avatar'] != null &&
                            club!['president_avatar'].toString().isNotEmpty
                        ? NetworkImage(club!['president_avatar'])
                        : null,
                    child: club?['president_avatar'] == null ||
                            club!['president_avatar'].toString().isEmpty
                        ? Text(
                            club?['president_name']
                                    ?.substring(0, 1)
                                    .toUpperCase() ??
                                '?',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: isDark ? Colors.white : Colors.black87,
                            ),
                          )
                        : null,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(width: 16),

          // 🔥 ПРАВАЯ ЧАСТЬ: ИНФОРМАЦИЯ
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 🔥 НАЗВАНИЕ КЛУБА
                Text(
                  club?['title'] ?? 'Клуб',
                  style: AppText.title(isDark: isDark),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),

                // 🔥 ОПИСАНИЕ И АДРЕС
                if (club?['description'] != null &&
                    club!['description'].isNotEmpty)
                  Text(
                    club!['description'],
                    style: TextStyle(
                      color:
                          isDark ? Colors.grey.shade400 : Colors.grey.shade600,
                      fontSize: 13,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                const SizedBox(height: 2),
                Text(
                  '📍 ${club?['city'] ?? 'Город не указан'}',
                  style: TextStyle(
                    color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
                    fontSize: 13,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 8),

                // 🔥 СТАТИСТИКА: ИГРЫ + РЕЗИДЕНТЫ
                Row(
                  children: [
                    _buildStatChip(
                      context,
                      icon: Mdi.clipboardList,
                      count: gamesCount,
                      label: 'Игры',
                      onTap: () {
                        context.push(
                          '/club-games-list',
                          extra: {
                            'clubId': club!['id'],
                            'clubTitle': club?['title'] ?? 'Клуб',
                          },
                        );
                      },
                    ),
                    const SizedBox(width: 8),
                    _buildStatChip(
                      context,
                      icon: Mdi.accountGroup,
                      count: club?['members_count'] ?? 0,
                      label: 'Резиденты',
                      onTap: () {
                        context.push(
                          '/club-members-list',
                          extra: {
                            'clubId': club!['id'],
                            'clubTitle': club?['title'] ?? 'Клуб',
                          },
                        );
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 8),

                // 🔥 КНОПКА "ПОДАТЬ ЗАЯВКУ"
                SizedBox(
                  width: double.infinity,
                  child: ClubJoinButton(
                    club: club,
                    myClubId: myClubId,
                    onJoin: onRefresh,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatChip(
    BuildContext context, {
    required IconData icon,
    required int count,
    required String label,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: theme.primaryColor.withOpacity(0.1),
          borderRadius: BorderRadius.circular(25),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: theme.primaryColor, size: 16),
            const SizedBox(width: 6),
            Text(
              '$count',
              style: TextStyle(
                color: isDark ? Colors.white : Colors.black87,
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(
                color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
