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
  final VoidCallback onGamesTap;
  final VoidCallback onMembersTap;
  final VoidCallback onMyClubTap;

  const ClubHeader({
    super.key,
    required this.club,
    required this.myClubId,
    required this.gamesCount,
    required this.onRefresh,
    required this.onGamesTap,
    required this.onMembersTap,
    required this.onMyClubTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final bool isMyClub = myClubId == club?['id'];
    final bool hasPendingRequest = club?['has_pending_request'] ?? false;
    final bool userHasClub = myClubId != null;

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

                  // 🔥 БЕЙДЖ 2: ИГРЫ КЛУБА (СПРАВА ПО ЦЕНТРУ)
                  Positioned(
                    top: 100,
                    right: -15,
                    child: _buildCircleBadge(
                      context,
                      icon: Mdi.clipboardList,
                      count: gamesCount,
                      color: theme.primaryColor,
                      onTap: onGamesTap,
                    ),
                  ),

                  // 🔥 БЕЙДЖ 3: РЕЗИДЕНТЫ (СПРАВА СНИЗУ)
                  Positioned(
                    bottom: -7,
                    right: 10,
                    child: _buildCircleBadge(
                      context,
                      icon: Mdi.accountGroup,
                      count: club?['members_count'] ?? 0,
                      color: theme.primaryColor,
                      onTap: onMembersTap,
                    ),
                  ),

                  // 🔥 БЕЙДЖ 4: ПОДАТЬ ЗАЯВКУ
                  Positioned(
                    bottom: -22,
                    left: 74,
                    child: GestureDetector(
                      onTap: () {
                        // 🔥 ЕСЛИ ГАЛОЧКА (МОЙ КЛУБ) — ВОЗВРАТ НА РЕЙТИНГ
                        if (isMyClub) {
                          
                          onMyClubTap();
                          return;
                        }
                        _handleJoinButtonTap(context);
                      },
                      child: _buildJoinButtonContent(context),
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
              size: 23,
            ),
            Positioned(
              bottom: 10,
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
                    fontSize: 15,
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

  // 🔥 КОНТЕНТ БЕЙДЖА ЗАЯВКИ
  Widget _buildJoinButtonContent(BuildContext context) {
    final theme = Theme.of(context);
    final int? currentClubId = club?['id'];

    final bool isMyClub = myClubId == currentClubId;
    final bool hasPendingRequest = club?['has_pending_request'] ?? false;

    Color color;
    IconData icon;

    if (isMyClub) {
      color = Colors.green;
      icon = Icons.check;
    } else if (hasPendingRequest) {
      color = Colors.orange;
      icon = Icons.hourglass_top;
    } else {
      color = theme.primaryColor;
      icon = Icons.add;
    }

    return Container(
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
      child: Icon(
        icon,
        color: Colors.white,
        size: 28,
      ),
    );
  }

  // 🔥 ЛОГИКА НАЖАТИЯ НА ЗАЯВКУ
  void _handleJoinButtonTap(BuildContext context) async {
    final int? currentClubId = club?['id'];
    final bool hasPendingRequest = club?['has_pending_request'] ?? false;
    final bool userHasClub = myClubId != null;

    if (userHasClub) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
              'ℹ️ Вы уже состоите в другом клубе. Выйдите из него, чтобы подать заявку.'),
          backgroundColor: Colors.orange,
          duration: Duration(seconds: 3),
        ),
      );
      return;
    }

    if (hasPendingRequest) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('⏳ Вы уже отправили заявку в этот клуб'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    try {
      final result = await ClubService.joinClub(currentClubId!);
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
            content: Text('❌ ${result['error'] ?? 'Неизвестная ошибка'}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('⚠️ Ошибка соединения. Проверьте интернет.'),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 4),
        ),
      );
    }
  }
}
