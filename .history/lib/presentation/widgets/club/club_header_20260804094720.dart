import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:mafia_help/presentation/widgets/app_card.dart';
import 'package:mafia_help/presentation/widgets/app_text.dart';
import 'club_join_button.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';

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

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: AppCard(
            isDark: isDark,
            child: Column(
              children: [
                Container(
                  width: 90,
                  height: 90,
                  decoration: BoxDecoration(
                    color: isDark ? Colors.grey.shade700 : Colors.grey.shade200,
                    borderRadius: BorderRadius.circular(14),
                    image: club?['logo_url'] != null &&
                            club!['logo_url'].isNotEmpty
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
                const SizedBox(height: 8),
                Text(
                  club?['title'] ?? 'Клуб',
                  style: AppText.title(isDark: isDark),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  '📍 ${club?['city'] ?? 'Город не указан'}',
                  style: AppText.small(isDark: isDark),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            children: [
              _buildPresidentCard(context),
              const SizedBox(height: 8),
              _buildStatsCard(context),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPresidentCard(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return AppCard(
      isDark: isDark,
      padding: const EdgeInsets.all(12),
      margin: EdgeInsets.zero,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircleAvatar(
            radius: 21,
            backgroundColor:
                isDark ? Colors.grey.shade700 : Colors.grey.shade300,
            backgroundImage: club?['president_avatar'] != null &&
                    club!['president_avatar'].toString().isNotEmpty
                ? NetworkImage(club!['president_avatar'])
                : null,
            child: club?['president_avatar'] == null ||
                    club!['president_avatar'].toString().isEmpty
                ? Text(
                    club?['president_name']?.substring(0, 1).toUpperCase() ??
                        '?',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white : Colors.black87,
                    ),
                  )
                : null,
          ),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                club?['president_name'] ?? 'Неизвестен',
                style: AppText.subtitle(isDark: isDark),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 2),
              Text(
                'Президент',
                style: AppText.accent(isDark: isDark),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatsCard(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return AppCard(
      isDark: isDark,
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      margin: EdgeInsets.zero,
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildStatItem(
                context,
                icon: MdiIcons.clipboardList,
                count: gamesCount,
                label: 'Игры',
                route: '/club-games-list',
              ),
              const SizedBox(width: 12),
              _buildStatItem(
                context,
                icon: MdiIcons.accountGroup,
                count: club?['members_count'] ?? 0,
                label: 'Резиденты',
                route: '/club-members-list',
              ),
            ],
          ),
          const SizedBox(height: 8),
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
    );
  }

  Widget _buildStatItem(
    BuildContext context, {
    required IconData icon,
    required int count,
    required String label,
    required String route,
  }) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return GestureDetector(
      onTap: () {
        context.push(
          route,
          extra: {
            'clubId': club!['id'],
            'clubTitle': club?['title'] ?? 'Клуб',
          },
        );
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: theme.primaryColor.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Icon(icon, color: theme.primaryColor, size: 24),
            const SizedBox(width: 8),
            Text(
              '$count',
              style: AppText.button(isDark: isDark),
            ),
          ],
        ),
      ),
    );
  }
}
