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
                width: 180,
                height: 180,
                decoration: BoxDecoration(
                  color: isDark ? Colors.grey.shade700 : Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(100),
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
                child: GestureDetector(
                  onTap: () {
                    // Можно показать информацию о президенте
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                            'Президент: ${club?['president_name'] ?? 'Неизвестен'}'),
                        backgroundColor: Colors.orange,
                      ),
                    );
                  },
                  child: Container(
                    padding: const EdgeInsets.all(2),
                    decoration: BoxDecoration(
                      color: isDark ? Colors.white,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: theme.scaffoldBackgroundColor,
                        width: 2,
                      ),
                    ),
                    child: CircleAvatar(
                      radius: 37,
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
              ),
              // 🔥 БЕЙДЖ "ИГРЫ" (снизу слева)
              Positioned(
                bottom: -8,
                left: -8,
                child: _buildBadge(
                  context,
                  icon: Mdi.clipboardList,
                  count: gamesCount,
                  label: 'Игр',
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
              ),
              // 🔥 БЕЙДЖ "РЕЗИДЕНТЫ" (снизу справа)
              Positioned(
                bottom: -8,
                right: -8,
                child: _buildBadge(
                  context,
                  icon: Mdi.accountGroup,
                  count: club?['members_count'] ?? 0,
                  label: 'Резид.',
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

                // 🔥 ОПИСАНИЕ
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

                // 🔥 АДРЕС
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

  // 🔥 МЕТОД ДЛЯ СОЗДАНИЯ БЕЙДЖА
  Widget _buildBadge(
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
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: theme.primaryColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: theme.scaffoldBackgroundColor,
            width: 2,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: Colors.white,
              size: 12,
            ),
            const SizedBox(width: 4),
            Text(
              '$count',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 11,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(width: 2),
            Text(
              label,
              style: TextStyle(
                color: Colors.white.withOpacity(0.8),
                fontSize: 9,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
