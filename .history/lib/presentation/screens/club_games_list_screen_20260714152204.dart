// lib/presentation/screens/club_games_list_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../services/club_service.dart';

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
    final data = result['data'] as List? ?? [];
    _games = data.cast<Map<String, dynamic>>();
  }
  setState(() => _isLoading = false);
}

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text('Игры клуба "${widget.clubTitle}"'),
        backgroundColor: theme.appBarTheme.backgroundColor,
        foregroundColor: theme.appBarTheme.foregroundColor,
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
                    final date = game['game_date'] != null
                        ? DateTime.parse(game['game_date'])
                            .toString()
                            .substring(0, 10)
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
                            color: Colors.orange.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Center(
                            child: Text(
                              '${game['game_number'] ?? '?'}',
                              style: const TextStyle(
                                color: Colors.orange,
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
                ),
    );
  }
}