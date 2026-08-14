// lib/presentation/widgets/club/club_games_table.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class ClubGamesTable extends StatelessWidget {
  final List<Map<String, dynamic>> games;
  final bool isDark;

  const ClubGamesTable({
    super.key,
    required this.games,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    if (games.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.sports_score,
              size: 48,
              color: isDark ? Colors.grey.shade600 : Colors.grey.shade400,
            ),
            const SizedBox(height: 16),
            Text(
              'Игр пока нет',
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
      itemCount: games.length,
      itemBuilder: (context, index) {
        final game = games[index];
        final date = game['game_date'] != null
            ? DateTime.parse(game['game_date']).toString().substring(0, 10)
            : 'Дата неизвестна';
        final winner = game['winner'] == 'red'
            ? '🔴 Красные'
            : game['winner'] == 'black'
                ? '⚫ Чёрные'
                : 'Ничья';

        return Card(
          color: isDark ? Colors.grey.shade800 : Colors.white,
          margin: const EdgeInsets.only(bottom: 8),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: ListTile(
            onTap: () {
              context.push(
                '/game-protocol-view',
                extra: game['id'],
              );
            },
            leading: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor.withOpacity(0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Center(
                child: Text(
                  '${game['game_number'] ?? '?'}',
                  style: TextStyle(
                    color: Theme.of(context).primaryColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
            ),
            title: Text(
              '${game['tournament'] ?? 'Турнир'} — ${game['stage'] ?? 'Стадия'}',
              style: TextStyle(
                color: isDark ? Colors.white : Colors.black87,
                fontWeight: FontWeight.w600,
              ),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Стол ${game['table_number'] ?? '?'} • $date',
                  style: TextStyle(
                    color: isDark ? Colors.grey : Colors.grey.shade600,
                    fontSize: 12,
                  ),
                ),
                Text(
                  'Судья: ${game['judge_name'] ?? 'Неизвестен'}',
                  style: TextStyle(
                    color: isDark ? Colors.grey : Colors.grey.shade600,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
            trailing: Text(
              winner,
              style: TextStyle(
                color: game['winner'] == 'red'
                    ? Colors.red
                    : game['winner'] == 'black'
                        ? Colors.black
                        : Colors.grey,
                fontWeight: FontWeight.bold,
                fontSize: 13,
              ),
            ),
          ),
        );
      },
    );
  }
}