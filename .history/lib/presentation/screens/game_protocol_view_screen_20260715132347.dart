// lib/presentation/screens/game_protocol_view_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../services/club_service.dart';

class GameProtocolViewScreen extends ConsumerStatefulWidget {
  final int gameId;

  const GameProtocolViewScreen({
    super.key,
    required this.gameId,
  });

  @override
  ConsumerState<GameProtocolViewScreen> createState() =>
      _GameProtocolViewScreenState();
}

class _GameProtocolViewScreenState
    extends ConsumerState<GameProtocolViewScreen> {
  Map<String, dynamic>? _gameData;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadGame();
  }

  Future<void> _loadGame() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    final result = await ClubService.getGame(widget.gameId);

    if (result['success']) {
      setState(() {
        _gameData = result['data'];
        _isLoading = false;
      });
    } else {
      setState(() {
        _error = result['error'] ?? 'Ошибка загрузки';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('Протокол игры'),
        backgroundColor: theme.appBarTheme.backgroundColor,
        foregroundColor: theme.appBarTheme.foregroundColor,
        actions: [
          IconButton(
            icon: Icon(Icons.refresh, color: isDark ? Colors.white : Colors.black87),
            onPressed: _loadGame,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.error_outline,
                        size: 64,
                        color: Colors.red.shade300,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        _error!,
                        style: TextStyle(
                          color: isDark ? Colors.white70 : Colors.black54,
                          fontSize: 16,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _loadGame,
                        child: const Text('Повторить'),
                      ),
                    ],
                  ),
                )
              : _gameData == null
                  ? const Center(child: Text('Нет данных'))
                  : _buildContent(),
    );
  }

  Widget _buildContent() {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final game = _gameData!;

    final date = game['date'] != null
        ? game['date'].toString().substring(0, 10)
        : 'Дата неизвестна';
    final time = game['time'] ?? '';
    final winner = game['winner'] == 'red'
        ? '🔴 Красные'
        : game['winner'] == 'black'
            ? '⚫ Чёрные'
            : 'Ничья';

    final players = game['players'] as List? ?? [];
    final nightActions = game['night_actions'] as List? ?? [];
    final voteHistory = game['vote_history'] as Map? ?? {};

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Шапка
          _buildHeader(game, date, time, winner, isDark),
          const SizedBox(height: 16),

          // Игроки
          _buildPlayersTable(players, isDark),
          const SizedBox(height: 16),

          // Ночные действия
          if (nightActions.isNotEmpty) _buildNightActions(nightActions, isDark),
          const SizedBox(height: 16),

          // Голосования
          if (voteHistory.isNotEmpty) _buildVoteHistory(voteHistory, isDark),
        ],
      ),
    );
  }

  Widget _buildHeader(Map<String, dynamic> game, String date, String time, String winner, bool isDark) {
    return Card(
      color: isDark ? Colors.grey.shade800 : Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    '${game['tournament'] ?? 'Турнир'} — ${game['stage'] ?? 'Стадия'}',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white : Colors.black87,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: game['winner'] == 'red'
                        ? Colors.red.shade100
                        : game['winner'] == 'black'
                            ? Colors.grey.shade300
                            : Colors.grey.shade200,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    winner,
                    style: TextStyle(
                      color: game['winner'] == 'red'
                          ? Colors.red.shade800
                          : game['winner'] == 'black'
                              ? Colors.black87
                              : Colors.grey.shade600,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _buildInfoChip(Icons.calendar_today, date),
                _buildInfoChip(Icons.access_time, time),
                _buildInfoChip(Icons.table_chart, 'Стол ${game['table'] ?? '?'}'),
                _buildInfoChip(Icons.numbers, 'Игра ${game['game'] ?? '?'}'),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Судья: ${game['judge'] ?? 'Неизвестен'}',
              style: TextStyle(
                color: isDark ? Colors.white70 : Colors.black54,
                fontSize: 14,
              ),
            ),
            if (game['best_move'] != null && game['best_move'].toString().isNotEmpty)
              Text(
                'Лучший ход: ${game['best_move']}',
                style: TextStyle(
                  color: isDark ? Colors.white70 : Colors.black54,
                  fontSize: 14,
                ),
              ),
            if (game['protest'] != null && game['protest'].toString().isNotEmpty)
              Text(
                'Протест: ${game['protest']}',
                style: const TextStyle(color: Colors.orange, fontSize: 14),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoChip(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: Colors.grey.shade600),
          const SizedBox(width: 4),
          Text(label, style: const TextStyle(fontSize: 12)),
        ],
      ),
    );
  }

  Widget _buildPlayersTable(List<dynamic> players, bool isDark) {
    return Card(
      color: isDark ? Colors.grey.shade800 : Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Игроки',
              style: TextStyle(
                color: Colors.orange,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            // Заголовки
            Row(
              children: [
                const SizedBox(width: 28),
                const SizedBox(width: 8),
                Expanded(child: Text('Игрок', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Colors.grey))),
                const SizedBox(width: 8),
                SizedBox(width: 24, child: Text('Роль', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Colors.grey), textAlign: TextAlign.center)),
                const SizedBox(width: 8),
                SizedBox(width: 30, child: Text('Ф', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Colors.grey), textAlign: TextAlign.center)),
                const SizedBox(width: 8),
                SizedBox(width: 30, child: Text('Очки', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Colors.grey), textAlign: TextAlign.center)),
              ],
            ),
            const Divider(height: 8),
            ...players.map((player) => _buildPlayerRow(player, isDark)),
          ],
        ),
      ),
    );
  }

  Widget _buildPlayerRow(Map<String, dynamic> player, bool isDark) {
    final roleShort = {
      'don': 'Д',
      'mafia': 'Ч',
      'sheriff': 'Ш',
      'citizen': 'К',
    }[player['role']] ?? '?';

    final isRemoved = player['rule'] != null && player['rule'].toString().isNotEmpty;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              color: Colors.orange.withOpacity(0.2),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Center(
              child: Text(
                '${player['seat']}',
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              player['name'] ?? 'Игрок',
              style: TextStyle(
                color: isDark ? Colors.white : Colors.black87,
                fontWeight: FontWeight.w500,
                fontSize: 13,
              ),
            ),
          ),
          Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              color: {
                'don': Colors.purple.shade100,
                'mafia': Colors.red.shade100,
                'sheriff': Colors.green.shade100,
                'citizen': Colors.blue.shade100,
              }[player['role']],
              borderRadius: BorderRadius.circular(4),
            ),
            child: Center(
              child: Text(
                roleShort,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: {
                    'don': Colors.purple.shade800,
                    'mafia': Colors.red.shade800,
                    'sheriff': Colors.green.shade800,
                    'citizen': Colors.blue.shade800,
                  }[player['role']],
                  fontSize: 11,
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          SizedBox(
            width: 30,
            child: Text(
              '${player['fouls'] ?? 0}',
              style: TextStyle(
                color: isDark ? Colors.white70 : Colors.black54,
                fontSize: 12,
                textAlign: TextAlign.center,
              ),
            ),
          ),
          const SizedBox(width: 8),
          SizedBox(
            width: 30,
            child: Text(
              '${player['points'] ?? 0}',
              style: TextStyle(
                color: isDark ? Colors.white : Colors.black87,
                fontWeight: FontWeight.bold,
                fontSize: 13,
                textAlign: TextAlign.center,
              ),
            ),
          ),
          if (player['bonus'] != null && player['bonus'] != 0)
            Padding(
              padding: const EdgeInsets.only(left: 4),
              child: Text(
                '(${player['bonus']})',
                style: TextStyle(
                  color: player['bonus'] > 0 ? Colors.green : Colors.red,
                  fontSize: 11,
                ),
              ),
            ),
          if (isRemoved)
            Padding(
              padding: const EdgeInsets.only(left: 4),
              child: Text('🚫', style: TextStyle(fontSize: 12, color: Colors.red.shade400)),
            ),
        ],
      ),
    );
  }

  Widget _buildNightActions(List<dynamic> nightActions, bool isDark) {
    return Card(
      color: isDark ? Colors.grey.shade800 : Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Ночные действия',
              style: TextStyle(
                color: Colors.orange,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            // Заголовки
            Row(
              children: [
                const SizedBox(width: 60),
                const SizedBox(width: 8),
                Expanded(child: Text('Стрельба', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Colors.grey))),
                const SizedBox(width: 8),
                Expanded(child: Text('Дон', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Colors.grey))),
                const SizedBox(width: 8),
                Expanded(child: Text('Шериф', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Colors.grey))),
              ],
            ),
            const Divider(height: 8),
            ...nightActions.map((action) => _buildNightActionRow(action, isDark)),
          ],
        ),
      ),
    );
  }

  Widget _buildNightActionRow(Map<String, dynamic> action, bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          Container(
            width: 60,
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: Colors.grey.shade200,
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              'Ночь ${action['night']}',
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(child: _buildNightValue(action['kill'])),
          const SizedBox(width: 8),
          Expanded(child: _buildNightValue(action['don'])),
          const SizedBox(width: 8),
          Expanded(child: _buildNightValue(action['sheriff'])),
        ],
      ),
    );
  }

  Widget _buildNightValue(int? value) {
    if (value != null && value > 0) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
        decoration: BoxDecoration(
          color: Colors.orange.shade100,
          borderRadius: BorderRadius.circular(4),
        ),
        child: Text(
          '$value',
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
        ),
      );
    } else {
      return Text(
        '—',
        style: TextStyle(color: Colors.grey.shade400, fontSize: 13),
      );
    }
  }

  Widget _buildVoteHistory(Map<String, dynamic> voteHistory, bool isDark) {
    final days = voteHistory.keys.toList()..sort((a, b) => int.parse(a).compareTo(int.parse(b)));

    return Card(
      color: isDark ? Colors.grey.shade800 : Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Голосования',
              style: TextStyle(
                color: Colors.orange,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            ...days.map((dayKey) {
              final dayData = voteHistory[dayKey] as Map<String, dynamic>;
              return _buildVoteDay(dayKey, dayData, isDark);
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildVoteDay(String dayKey, Map<String, dynamic> dayData, bool isDark) {
    final day = int.parse(dayKey);
    final rounds = dayData['rounds'] as List? ?? [];
    final result = dayData['result'] as List? ?? [];
    final eliminationVotes = dayData['eliminationVotes'] ?? 0;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border.all(
          color: isDark ? Colors.grey.shade700 : Colors.grey.shade300,
        ),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'День ${day + 1}',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : Colors.black87,
            ),
          ),
          const SizedBox(height: 8),
          if (rounds.isNotEmpty) ...[
            // Основное голосование
            _buildVoteRound('Голосование', rounds[0] as Map<String, dynamic>, isDark),
            
            // Переголосования
            if (rounds.length > 1)
              for (int i = 1; i < rounds.length; i++)
                _buildVoteRound('Переголосование ${i}', rounds[i] as Map<String, dynamic>, isDark),
          ],
          
          // Результат
          const SizedBox(height: 4),
          Row(
            children: [
              Text(
                'Результат: ',
                style: TextStyle(
                  color: isDark ? Colors.white70 : Colors.black54,
                  fontSize: 13,
                ),
              ),
              Text(
                result.isNotEmpty ? result.join(', ') : '0',
                style: TextStyle(
                  color: result.isNotEmpty ? Colors.green : Colors.grey,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ],
          ),
          
          if (eliminationVotes > 0)
            Text(
              'Голосование за подъём: $eliminationVotes',
              style: const TextStyle(
                color: Colors.orange,
                fontSize: 13,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildVoteRound(String title, Map<String, dynamic> votes, bool isDark) {
    final entries = votes.entries.toList()..sort((a, b) => int.parse(a.key).compareTo(int.parse(b.key)));

    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              title,
              style: TextStyle(
                color: isDark ? Colors.white70 : Colors.black54,
                fontSize: 12,
              ),
            ),
          ),
          Expanded(
            child: Wrap(
              spacing: 12,
              runSpacing: 4,
              children: entries.map((entry) {
                return Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 24,
                      height: 24,
                      decoration: BoxDecoration(
                        color: Colors.orange.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Center(
                        child: Text(
                          entry.key,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade200,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        '${entry.value}',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                          color: isDark ? Colors.white : Colors.black87,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                  ],
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}