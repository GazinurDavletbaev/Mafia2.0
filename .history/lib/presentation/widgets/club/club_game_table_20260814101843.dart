// lib/presentation/widgets/club/club_games_table.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:mafia_help/services/club_service.dart';

class ClubGamesTable extends StatefulWidget {
  final List<Map<String, dynamic>> games;
  final bool isDark;

  const ClubGamesTable({
    super.key,
    required this.games,
    required this.isDark,
  });

  @override
  State<ClubGamesTable> createState() => _ClubGamesTableState();
}

class _ClubGamesTableState extends State<ClubGamesTable> {
  late List<Map<String, dynamic>> _games;

  @override
  void initState() {
    super.initState();
    _games = List.from(widget.games);
  }

  @override
  void didUpdateWidget(covariant ClubGamesTable oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.games != widget.games) {
      _games = List.from(widget.games);
    }
  }

  Future<void> _toggleGameRating(int gameId, bool currentValue) async {
    final result = await ClubService.toggleGameRating(gameId);
    if (result['success']) {
      setState(() {
        final index = _games.indexWhere((g) => g['id'] == gameId);
        if (index != -1) {
          _games[index]['counts_in_rating'] =
              result['data']['counts_in_rating'];
        }
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              result['data']['counts_in_rating']
                  ? '✅ Игра учитывается в рейтинге'
                  : '⛔ Игра исключена из рейтинга',
            ),
            backgroundColor: Colors.green,
          ),
        );
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ ${result['error']}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = widget.isDark;
    final primaryColor = theme.primaryColor;

    if (_games.isEmpty) {
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
      padding: const EdgeInsets.all(20),
      itemCount: _games.length,
      itemBuilder: (context, index) {
        final game = _games[index];
        final countsInRating = game['counts_in_rating'] ?? true;

        final date = game['game_date'] != null
            ? DateTime.parse(game['game_date']).toString().substring(0, 10)
            : 'Дата неизвестна';

        return Card(
          color: isDark ? Colors.grey.shade900 : Colors.white,
          margin: const EdgeInsets.only(bottom: 2),
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
            // 🔥 ЛЕВАЯ ЧАСТЬ: ИНДИКАТОР ПОБЕДИТЕЛЯ
            leading: Container(
              width: 40,
              height: 40,
              child: Center(
                child: Text(
                  game['winner'] == 'red'
                      ? '🔴'
                      : game['winner'] == 'black'
                          ? '⚫'
                          : '?',
                  style: const TextStyle(
                    fontSize: 25,
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
                if (!countsInRating)
                  Container(
                    margin: const EdgeInsets.only(top: 4),
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.red.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: const Text(
                      'Исключена из рейтинга',
                      style: TextStyle(
                        color: Colors.red,
                        fontSize: 10,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
              ],
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: Icon(
                    countsInRating
                        ? Icons.remove_circle_outline
                        : Icons.add_circle_outline,
                    color: countsInRating ? Colors.red : Colors.green,
                  ),
                  onPressed: () =>
                      _toggleGameRating(game['id'], countsInRating),
                  tooltip: countsInRating
                      ? 'Исключить из рейтинга'
                      : 'Вернуть в рейтинг',
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
