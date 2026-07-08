// lib/presentation/screens/club_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../services/update_service.dart';
import 'saved_protocols_screen.dart';
import 'settings_screen.dart';

class ClubScreen extends ConsumerStatefulWidget {
  const ClubScreen({super.key});

  @override
  ConsumerState<ClubScreen> createState() => _ClubScreenState();
}

class _ClubScreenState extends ConsumerState<ClubScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        UpdateService.checkForUpdate(context);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final players = _generatePlayers(40);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: Column(
        children: [
          Container(),
          const Divider(height: 1,),
          SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ========== ШАПКА КЛУБА ==========
            _buildClubHeader(),
            const SizedBox(height: 20),

            // ========== СТАТИСТИКА ==========
            _buildClubStats(),
            const SizedBox(height: 20),

            // ========== РЕЙТИНГ ==========
            _buildRatingTable(players),
            const SizedBox(height: 16),
          ],
        ),
      ),
    ],
    
  }

  Widget _buildClubHeader() {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Row(
      children: [
        // Логотип клуба
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            color: isDark ? Colors.grey.shade800 : Colors.grey.shade200,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Image.asset(
            'assets/mafia_logo.png',
            width: 60,
            height: 60,
            fit: BoxFit.contain,
          ),
        ),
        const SizedBox(width: 16),
        // Информация о клубе
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'MAFIA HELP',
                style: TextStyle(
                  color: isDark ? Colors.white : Colors.black87,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                'Когда я читаю книгу, книга получает знания :) !',
                style: TextStyle(
                  color: isDark ? Colors.grey : Colors.grey.shade600,
                  fontSize: 12,
                  fontStyle: FontStyle.italic,
                ),
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      color:
                          isDark ? Colors.grey.shade700 : Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Image.asset(
                      'assets/mafia_logo.png',
                      width: 18,
                      height: 18,
                      fit: BoxFit.contain,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Google',
                    style: TextStyle(
                      color: isDark ? Colors.white : Colors.black87,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.orange.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.orange, width: 0.5),
                    ),
                    child: const Text(
                      'Президент',
                      style: TextStyle(
                        color: Colors.orange,
                        fontSize: 10,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildClubStats() {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Row(
      children: [
        _buildStatCard(
          icon: Icons.emoji_events,
          value: '1',
          label: 'место в рейтинге',
          color: Colors.orange,
        ),
        const SizedBox(width: 12),
        _buildStatCard(
          icon: Icons.people,
          value: '40',
          label: 'резидентов клуба',
          color: Colors.blue,
        ),
      ],
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required String value,
    required String label,
    required Color color,
  }) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isDark ? Colors.grey.shade800 : Colors.grey.shade100,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: color.withOpacity(0.15),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    value,
                    style: TextStyle(
                      color: isDark ? Colors.white : Colors.black87,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    label,
                    style: TextStyle(
                      color: isDark ? Colors.grey : Colors.grey.shade600,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRatingTable(List<Map<String, dynamic>> players) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        border: Border.all(
          color: isDark ? Colors.grey.shade700 : Colors.grey.shade300,
        ),
        borderRadius: BorderRadius.circular(8),
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: DataTable(
          columnSpacing: 12,
          horizontalMargin: 12,
          headingRowColor: WidgetStateProperty.resolveWith<Color>(
            (_) => isDark ? Colors.grey.shade800 : Colors.grey.shade200,
          ),
          headingTextStyle: TextStyle(
            color: Colors.orange,
            fontWeight: FontWeight.bold,
            fontSize: 12,
          ),
          dataTextStyle: TextStyle(
            color: isDark ? Colors.white : Colors.black87,
            fontSize: 11,
          ),
          columns: const [
            DataColumn(label: Text('№')),
            DataColumn(label: Text('Игрок')),
            DataColumn(label: Text('Игры'), numeric: true),
            DataColumn(label: Text('Победы'), numeric: true),
            DataColumn(label: Text('Баллы'), numeric: true),
            DataColumn(label: Text('Доп.'), numeric: true),
            DataColumn(label: Text('ЛХ'), numeric: true),
          ],
          rows: players.asMap().entries.map((entry) {
            final index = entry.key;
            final player = entry.value;
            final place = index + 1;
            final isTop = place <= 3;

            return DataRow(
              color: WidgetStateProperty.resolveWith<Color>(
                (_) {
                  if (isTop) {
                    return Colors.orange.withOpacity(0.1);
                  }
                  return Colors.transparent;
                },
              ),
              cells: [
                DataCell(
                  Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      color: _getPlaceColor(place),
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        '$place',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 11,
                        ),
                      ),
                    ),
                  ),
                ),
                DataCell(
                  Text(
                    player['name'],
                    style: TextStyle(
                      fontWeight: isTop ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                ),
                DataCell(Text('${player['games']}')),
                DataCell(Text('${player['wins']}')),
                DataCell(
                  Text(
                    '${player['points']}',
                    style: TextStyle(
                      fontWeight: isTop ? FontWeight.bold : FontWeight.normal,
                      color: isTop ? Colors.orange : null,
                    ),
                  ),
                ),
                DataCell(Text('${player['bonus']}')),
                DataCell(Text('${player['bestMove']}')),
              ],
            );
          }).toList(),
        ),
      ),
    );
  }

  List<Map<String, dynamic>> _generatePlayers(int count) {
    final names = [
      'Алексей',
      'Дмитрий',
      'Сергей',
      'Иван',
      'Петр',
      'Михаил',
      'Андрей',
      'Николай',
      'Олег',
      'Владимир',
      'Артем',
      'Максим',
      'Антон',
      'Егор',
      'Роман',
      'Денис',
      'Виктор',
      'Юрий',
      'Анатолий',
      'Константин',
      'Вячеслав',
      'Григорий',
      'Павел',
      'Василий',
      'Тимофей',
      'Илья',
      'Никита',
      'Матвей',
      'Захар',
      'Ярослав',
      'Степан',
      'Кирилл',
      'Александр',
      'Евгений',
      'Глеб',
      'Даниил',
      'Федор',
      'Лев',
      'Марк',
      'Борис',
    ];

    final players = <Map<String, dynamic>>[];
    for (int i = 0; i < count && i < names.length; i++) {
      final games = 5 + (i % 10);
      final wins = (games * 0.4 + (i % 5)).round();
      final points = games * 2 + (i % 7);
      final bonus = (i % 5) * 0.1;
      final bestMove = 1 + (i % 9);

      players.add({
        'name': names[i % names.length],
        'games': games,
        'wins': wins,
        'points': points,
        'bonus': bonus.toStringAsFixed(1),
        'bestMove': bestMove,
      });
    }
    return players;
  }

  Color _getPlaceColor(int place) {
    switch (place) {
      case 1:
        return Colors.orange.shade700;
      case 2:
        return Colors.grey.shade600;
      case 3:
        return Colors.brown.shade600;
      default:
        return Colors.grey.shade500;
    }
  }
}
