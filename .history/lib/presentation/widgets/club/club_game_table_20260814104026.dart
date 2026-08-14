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

  Map<String, List<Map<String, dynamic>>> _groupGamesByDate() {
    final Map<String, List<Map<String, dynamic>>> grouped = {};

    for (final game in _games) {
      final date = game['game_date'] != null
          ? DateTime.parse(game['game_date']).toString().substring(0, 10)
          : 'Дата неизвестна';

      if (!grouped.containsKey(date)) {
        grouped[date] = [];
      }
      grouped[date]!.add(game);
    }

    final sortedKeys = grouped.keys.toList()
      ..sort((a, b) {
        if (a == 'Дата неизвестна') return 1;
        if (b == 'Дата неизвестна') return -1;
        return b.compareTo(a);
      });

    final sortedGrouped = <String, List<Map<String, dynamic>>>{};
    for (final key in sortedKeys) {
      sortedGrouped[key] = grouped[key]!;
    }

    return sortedGrouped;
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

    final groupedGames = _groupGamesByDate();

    return ListView.builder(
      padding: const EdgeInsets.all(8),
      itemCount: groupedGames.keys.length,
      itemBuilder: (context, dateIndex) {
        final date = groupedGames.keys.elementAt(dateIndex);
        final gamesForDate = groupedGames[date]!;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 10),
              child: Text(
                date,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : Colors.black87,
                ),
              ),
            ),
            ...gamesForDate.map((game) {
              final countsInRating = game['counts_in_rating'] ?? true;

              return Card(
                color: isDark ? Colors.grey.shade900 : Colors.white,
                margin: const EdgeInsets.only(bottom: 2),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: ListTile(
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  onTap: () {
                    context.push(
                      '/game-protocol-view',
                      extra: game['id'],
                    );
                  },
                  // 🔥 ЛЕВАЯ ИКОНКА: КРАСНЫЙ/ЧЁРНЫЙ КВАДРАТ
                  leading: Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: game['winner'] == 'red'
                          ? Colors.red
                          : game['winner'] == 'black'
                              ? Colors.black
                              : Colors.grey,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Center(
                      child: Text(
                        game['winner'] == 'red'
                            ? '🔴'
                            : game['winner'] == 'black'
                                ? '⬛'
                                : '?',
                        style: const TextStyle(
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ),
                  // 🔥 НАЗВАНИЕ (МЕНЬШЕ)
                  title: Text(
                    '${game['tournament'] ?? 'Турнир'} — ${game['stage'] ?? 'Стадия'}',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: isDark ? Colors.white : Colors.black87,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  // 🔥 ИНФО В ОДНУ СТРОКУ
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Стол ${game['table_number'] ?? '?'} • Игра ${game['game_number'] ?? '?'} • Судья: ${game['judge_name'] ?? 'Неизвестен'}',
                        style: TextStyle(
                          fontSize: 12,
                          color: isDark ? Colors.grey : Colors.grey.shade600,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (!countsInRating)
                        Container(
                          margin: const EdgeInsets.only(top: 2),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 2),
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
                  trailing: IconButton(
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
                    constraints: const BoxConstraints(),
                    padding: EdgeInsets.zero,
                    iconSize: 24,
                  ),
                ),
              );
            }).toList(),
          ],
        );
      },
    );
  }
}
