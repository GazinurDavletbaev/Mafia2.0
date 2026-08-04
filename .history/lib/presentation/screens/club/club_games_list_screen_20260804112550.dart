// lib/presentation/screens/club/club_games_list_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../services/club_service.dart';

class ClubGamesListScreen extends ConsumerStatefulWidget {
  final int clubId;
  final String clubTitle;

  const ClubGamesListScreen({
    super.key,
    required this.clubId,
    required this.clubTitle,
  });

  @override
  ConsumerState<ClubGamesListScreen> createState() =>
      _ClubGamesListScreenState();
}

class _ClubGamesListScreenState extends ConsumerState<ClubGamesListScreen> {
  List<Map<String, dynamic>> _games = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadGames();
  }

  Future<void> _loadGames() async {
    setState(() => _isLoading = true);
    final result = await ClubService.getClubGames(widget.clubId);

    if (result['success']) {
      List data = [];
      if (result['data'] != null) {
        data = result['data'] as List;
      } else if (result['clubs'] != null) {
        data = result['clubs'] as List;
      }
      setState(() {
        _games = data.cast<Map<String, dynamic>>();
      });
    }
    setState(() => _isLoading = false);
  }

  Future<void> _toggleGameRating(int gameId, bool currentValue) async {
    final result = await ClubService.toggleGameRating(gameId);
    if (result['success']) {
      setState(() {
        final index = _games.indexWhere((g) => g['id'] == gameId);
        if (index != -1) {
          _games[index]['counts_in_rating'] = result['data']['counts_in_rating'];
        }
      });
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
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('❌ ${result['error']}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final primaryColor = theme.primaryColor;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text('Игры клуба "${widget.clubTitle}"'),
        backgroundColor: theme.appBarTheme.backgroundColor,
        foregroundColor: theme.appBarTheme.foregroundColor,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadGames,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _games.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.sports_score,
                        size: 64,
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
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _games.length,
                  itemBuilder: (context, index) {
                    final game = _games[index];
                    final countsInRating = game['counts_in_rating'] ?? true;

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
                            color: primaryColor.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Center(
                            child: Text(
                              '${game['game_number'] ?? '?'}',
                              style: TextStyle(
                                color: primaryColor,
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
                            if (!countsInRating)
                              Container(
                                margin: const EdgeInsets.only(top: 4),
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
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
                                countsInRating ? Icons.remove_circle_outline : Icons.add_circle_outline,
                                color: countsInRating ? Colors.red : Colors.green,
                              ),
                              onPressed: () => _toggleGameRating(game['id'], countsInRating),
                              tooltip: countsInRating ? 'Исключить из рейтинга' : 'Вернуть в рейтинг',
                            ),
                            const SizedBox(width: 4),
                            Text(
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
                          ],
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}