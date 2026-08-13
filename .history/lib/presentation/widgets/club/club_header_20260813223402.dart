// lib/presentation/widgets/club/club_header.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:mafia_help/presentation/widgets/app_card.dart';
import 'package:mafia_help/presentation/widgets/app_text.dart';
import 'package:mafia_help/services/club_service.dart';
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

    final bool isMyClub = myClubId == club?['id'];
    final bool hasPendingRequest = club?['has_pending_request'] ?? false;

    return Column(
      children: [
        AppCard(
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
                      color:
                          isDark ? Colors.grey.shade700 : Colors.grey.shade200,
                      borderRadius: BorderRadius.circular(100),
                      image: club?['logo_url'] != null &&
                              club!['logo_url'].isNotEmpty
                          ? DecorationImage(
                              image: NetworkImage(club!['logo_url']),
                              fit: BoxFit.cover,
                            )
                          : null,
                    ),
                    child:
                        club?['logo_url'] == null || club!['logo_url'].isEmpty
                            ? Image.asset(
                                'assets/mafia_logo.png',
                                width: 50,
                                height: 50,
                                fit: BoxFit.contain,
                              )
                            : null,
                  ),

                  // 🔥 БЕЙДЖ 1: ПРЕЗИДЕНТ (СВЕРХУ СПРАВА)
                  Positioned(
                    top: -8,
                    right: -8,
                    child: GestureDetector(
                      onTap: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                                'Президент: ${club?['president_name'] ?? 'Неизвестен'}'),
                            backgroundColor: Colors.orange,
                          ),
                        );
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          color: isDark ? Colors.black : Colors.white,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: theme.scaffoldBackgroundColor,
                            width: 2,
                          ),
                        ),
                        child: CircleAvatar(
                          radius: 28,
                          backgroundColor: isDark
                              ? Colors.grey.shade700
                              : Colors.grey.shade300,
                          backgroundImage: club?['president_avatar'] != null &&
                                  club!['president_avatar']
                                      .toString()
                                      .isNotEmpty
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
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color:
                                        isDark ? Colors.white : Colors.black87,
                                  ),
                                )
                              : null,
                        ),
                      ),
                    ),
                  ),

                  // 🔥 БЕЙДЖ 2: ИГРЫ КЛУБА (СПРАВА ПО ЦЕНТРУ) — КРУГЛЫЙ С ИКОНКОЙ
                  Positioned(
                    top: 100,
                    right: -15,
                    child: _buildCircleBadge(
                      context,
                      icon: Mdi.clipboardList,
                      count: gamesCount,
                      color: theme.primaryColor,
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

                  // 🔥 БЕЙДЖ 3: РЕЗИДЕНТЫ (СПРАВА СНИЗУ) — КРУГЛЫЙ С ИКОНКОЙ
                  Positioned(
                    bottom: -10,
                    right: 10,
                    child: _buildCircleBadge(
                      context,
                      icon: Mdi.accountGroup,
                      count: club?['members_count'] ?? 0,
                      color: theme.primaryColor,
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

                  // 🔥 БЕЙДЖ 4: ПОДАТЬ ЗАЯВКУ (СНИЗУ ПО ЦЕНТРУ)
                  Positioned(
                    bottom: -8,
                    left: 50,
                    child: GestureDetector(
                      onTap: () async {
                        if (isMyClub) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Это ваш клуб'),
                              backgroundColor: Colors.green,
                            ),
                          );
                          return;
                        }

                        if (hasPendingRequest) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Заявка уже отправлена'),
                              backgroundColor: Colors.orange,
                            ),
                          );
                          return;
                        }

                        final result = await ClubService.joinClub(club!['id']);
                        if (result['success']) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('✅ Заявка отправлена!'),
                              backgroundColor: Colors.green,
                            ),
                          );
                          onRefresh();
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(result['error'] ?? 'Ошибка'),
                              backgroundColor: Colors.red,
                            ),
                          );
                        }
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: isMyClub
                              ? Colors.green
                              : hasPendingRequest
                                  ? Colors.orange
                                  : theme.primaryColor,
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
                              isMyClub
                                  ? Icons.check
                                  : hasPendingRequest
                                      ? Icons.hourglass_top
                                      : Icons.add,
                              color: Colors.white,
                              size: 16,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              isMyClub
                                  ? 'Ваш'
                                  : hasPendingRequest
                                      ? 'Заявка'
                                      : 'Заявка',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
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
                    Text(
                      club?['title'] ?? 'Клуб',
                      style: AppText.title(isDark: isDark),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(
                          Icons.star,
                          color: Colors.orange,
                          size: 14,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          club?['president_name'] ?? 'Президент не указан',
                          style: TextStyle(
                            color: isDark
                                ? Colors.grey.shade300
                                : Colors.grey.shade700,
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    if (club?['description'] != null &&
                        club!['description'].isNotEmpty)
                      Text(
                        club!['description'],
                        style: TextStyle(
                          color: isDark
                              ? Colors.grey.shade400
                              : Colors.grey.shade600,
                          fontSize: 13,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    const SizedBox(height: 2),
                    Text(
                      '📍 ${club?['city'] ?? 'Город не указан'}',
                      style: TextStyle(
                        color: isDark
                            ? Colors.grey.shade400
                            : Colors.grey.shade600,
                        fontSize: 13,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // 🔥 КРУГЛЫЙ БЕЙДЖ С ИКОНКОЙ
  Widget _buildCircleBadge(
    BuildContext context, {
    required IconData icon,
    required int count,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 42,
        height: 42,
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
          border: Border.all(
            color: Theme.of(context).scaffoldBackgroundColor,
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
        child: Stack(
          alignment: Alignment.center,
          children: [
            Icon(
              icon,
              color: Colors.white,
              size: 28,
            ),
            Positioned(
              bottom: 15,
              right: 0,
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: const BoxDecoration(
                  color: Colors.red,
                  shape: BoxShape.circle,
                ),
                child: Text(
                  '$count',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
