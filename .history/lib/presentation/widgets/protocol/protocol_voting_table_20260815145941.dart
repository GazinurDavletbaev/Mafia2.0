// lib/presentation/widgets/protocol/protocol_voting_table.dart

import 'package:flutter/material.dart';
import 'package:mafia_help/presentation/state/game_state.dart';
import 'package:mafia_help/presentation/state/vote_day.dart';

class ProtocolVotingTable extends StatelessWidget {
  final GameState gameState;

  const ProtocolVotingTable({super.key, required this.gameState});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final primaryColor = theme.primaryColor;
    final voteHistory = gameState.voteHistory;

    print('=== ProtocolVotingTable.build ===');
    print('voteHistory: $voteHistory');
    print('voteHistory keys: ${voteHistory.keys}');
    print('voteHistory entries:');
    voteHistory.forEach((day, dayData) {
      print('  День $day:');
      print('    rounds: ${dayData.rounds}');
      print('    result: ${dayData.result}');
      print('    eliminated: ${dayData.eliminated}');
      print('    eliminationVotes: ${dayData.eliminationVotes}');
    });
    print('====================================');

    if (voteHistory.isEmpty) {
      return Card(
        color: theme.cardColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(
            color: isDark ? Colors.grey.shade700 : Colors.grey.shade300,
            width: 0.5,
          ),
        ),
        child: const Padding(
          padding: EdgeInsets.all(16),
          child: Text(
            'Голосования не проводились',
            style: TextStyle(color: Colors.white),
          ),
        ),
      );
    }

    final days = voteHistory.keys.toList()..sort();

    return Card(
      color: theme.cardColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: isDark ? Colors.grey.shade700 : Colors.grey.shade300,
          width: 0.5,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Голосования',
              style: TextStyle(
                color: primaryColor,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            ...days.map((day) {
              final dayData = voteHistory[day]!;
              final voteNumber = day + 1;
              return _buildVoteDayCard(
                  context, day, dayData, voteNumber, isDark);
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildVoteDayCard(
    BuildContext context,
    int day,
    VoteDay dayData,
    int voteNumber,
    bool isDark,
  ) {
    final theme = Theme.of(context);
    final primaryColor = theme.primaryColor;
    final hasVoting = dayData.rounds.isNotEmpty;
    final hasResult = dayData.result.isNotEmpty;

    print('=== _buildVoteDayCard для дня $day ===');
    print('  dayData.rounds: ${dayData.rounds}');
    print('  dayData.result: ${dayData.result}');
    print('  dayData.eliminated: ${dayData.eliminated}');
    print('  dayData.eliminationVotes: ${dayData.eliminationVotes}');
    print('  hasVoting: $hasVoting');
    print('  hasResult: $hasResult');
    print('=======================================');

    // 🔥 СЛУЧАЙ 1: НИКТО НЕ ВЫСТАВЛЕН
    if (!hasVoting && !hasResult) {
      return _buildEmptyVoteCard(context, voteNumber, isDark);
    }

    // 🔥 СЛУЧАЙ 2: УДАЛЕНИЕ БЕЗ ГОЛОСОВАНИЯ
    if (!hasVoting && hasResult) {
      return _buildRemovalOnlyCard(context, voteNumber, dayData, isDark);
    }

    // 🔥 СЛУЧАЙ 3: ОБЫЧНОЕ ГОЛОСОВАНИЕ
    return _buildVoteCard(context, voteNumber, dayData, isDark);
  }

  // 🔥 КАРТОЧКА: НИКТО НЕ ВЫСТАВЛЕН
  Widget _buildEmptyVoteCard(BuildContext context, int voteNumber, bool isDark) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          border: Border.all(
            color: isDark ? Colors.grey.shade600 : Colors.grey.shade300,
          ),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              'ГОЛОСОВАНИЕ $voteNumber',
              style: TextStyle(
                color: isDark ? Colors.white : Colors.black87,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Игрок',
                  style: TextStyle(
                    color: isDark ? Colors.white70 : Colors.black54,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  '—',
                  style: TextStyle(
                    color: isDark ? Colors.white70 : Colors.black54,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Голоса',
                  style: TextStyle(
                    color: isDark ? Colors.white70 : Colors.black54,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  '—',
                  style: TextStyle(
                    color: isDark ? Colors.white70 : Colors.black54,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
            const Divider(color: Colors.grey),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Результат: ',
                  style: TextStyle(
                    color: isDark ? Colors.white70 : Colors.black54,
                    fontSize: 12,
                  ),
                ),
                Text(
                  '0',
                  style: TextStyle(
                    color: isDark ? Colors.white54 : Colors.black38,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // 🔥 КАРТОЧКА: УДАЛЕНИЕ БЕЗ ГОЛОСОВАНИЯ
  Widget _buildRemovalOnlyCard(
    BuildContext context,
    int voteNumber,
    VoteDay dayData,
    bool isDark,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          border: Border.all(
            color: isDark ? Colors.grey.shade600 : Colors.grey.shade300,
          ),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              'ГОЛОСОВАНИЕ $voteNumber',
              style: TextStyle(
                color: isDark ? Colors.white : Colors.black87,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Удаление: ${dayData.result.join(", ")}',
              style: TextStyle(
                color: Colors.red,
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 🔥 КАРТОЧКА: ОБЫЧНОЕ ГОЛОСОВАНИЕ
  Widget _buildVoteCard(
  BuildContext context,
  int voteNumber,
  VoteDay dayData,
  bool isDark,
) {
  final rounds = dayData.rounds;

  // 🔥 ПЕРВЫЙ РАУНД
  final Map<int, int> firstRound = rounds.isNotEmpty
      ? Map<int, int>.from(rounds[0])
      : <int, int>{};
  final List<int> firstRoundKeys = firstRound.keys.toList()..sort();

  return Padding(
    padding: const EdgeInsets.only(bottom: 16),
    child: Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border.all(
          color: isDark ? Colors.grey.shade600 : Colors.grey.shade300,
        ),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            'ГОЛОСОВАНИЕ $voteNumber',
            style: TextStyle(
              color: isDark ? Colors.white : Colors.black87,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),

          // 🔥 ПЕРВЫЙ РАУНД
          _buildRoundRow('Игрок', firstRoundKeys, firstRound, isDark, showValue: true),
          _buildRoundRow('Голоса', firstRoundKeys, firstRound, isDark, showValue: true),
          const SizedBox(height: 4),

          // 🔥 ЕСЛИ ЕСТЬ ПЕРЕГОЛОСОВАНИЯ
          if (rounds.length > 1) {
            final Map<int, int> secondRound = Map<int, int>.from(rounds[1]);
            final List<int> secondKeys = secondRound.keys.toList()..sort();

            _buildRoundRow('Пере-', secondKeys, secondRound, isDark, showValue: true),
            _buildRoundRow('голос.', secondKeys, secondRound, isDark, showValue: true),
            const SizedBox(height: 4),

            // 🔥 СЛЕДУЮЩИЕ РАУНДЫ (только цифры)
            if (rounds.length > 2) {
              for (int i = 2; i < rounds.length; i++) {
                final Map<int, int> round = Map<int, int>.from(rounds[i]);
                final List<int> keys = round.keys.toList()..sort();
                _buildRoundRow('', keys, round, isDark, showValue: true);
                _buildRoundRow('', keys, round, isDark, showValue: true);
                const SizedBox(height: 4);
              }
            }
          },

          const Divider(color: Colors.grey),

          // 🔥 РЕЗУЛЬТАТ
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Результат: ',
                style: TextStyle(
                  color: isDark ? Colors.white70 : Colors.black54,
                  fontSize: 12,
                ),
              ),
              Text(
                dayData.result.isNotEmpty ? dayData.result.join(', ') : '0',
                style: TextStyle(
                  color: dayData.result.isNotEmpty
                      ? Colors.green
                      : (isDark ? Colors.white54 : Colors.black38),
                  fontSize: 14,
                  fontWeight: dayData.result.isNotEmpty
                      ? FontWeight.bold
                      : FontWeight.normal,
                ),
              ),
            ],
          ),

          if (dayData.eliminationVotes > 0)
            Text(
              'Голосование за подъём: ${dayData.eliminationVotes}',
              style: TextStyle(
                color: Theme.of(context).primaryColor,
                fontSize: 12,
              ),
            ),
        ],
      ),
    ),
  );
}
  // 🔥 СТРОКА ДЛЯ РАУНДА
  Widget _buildRoundRow(
    String label,
    List<int> keys,
    Map<int, int> round,
    bool isDark, {
    bool showValue = true,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 1),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // 🔥 ЛЕЙБЛ (если есть)
          if (label.isNotEmpty)
            SizedBox(
              width: 45,
              child: Text(
                label,
                style: TextStyle(
                  color: isDark ? Colors.white70 : Colors.black54,
                  fontSize: 11,
                ),
                textAlign: TextAlign.left,
              ),
            ),

          // 🔥 ЗНАЧЕНИЯ
          ...keys.map((key) {
            final value = round[key] ?? 0;
            final displayValue = showValue
                ? (value == 0 ? '0' : value.toString())
                : (value == 0 ? '-' : value.toString());

            return Container(
              width: 30,
              alignment: Alignment.center,
              child: Text(
                displayValue,
                style: TextStyle(
                  color: isDark ? Colors.white : Colors.black87,
                  fontSize: 11,
                ),
              ),
            );
          }),
        ],
      ),
    );
  }
}