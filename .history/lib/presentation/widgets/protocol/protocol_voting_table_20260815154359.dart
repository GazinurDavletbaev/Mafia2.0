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
    final lastRoundPlayers =
        hasVoting ? dayData.rounds.last.keys.toSet() : <int>{};
    final isRemoval = hasResult &&
        dayData.result.any((seat) => !lastRoundPlayers.contains(seat));

    final isEmptyDay = !hasVoting && !hasResult;

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

            if (isEmptyDay) ...[
              const Text(
                'На голосование никто не выставлен',
                style: TextStyle(
                  color: Colors.orange,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
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
            ] else if (!hasVoting && hasResult) ...[
              const SizedBox(height: 4),
              Text(
                'Удаление: ${dayData.result.join(", ")}',
                style: TextStyle(
                  color: Colors.red,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ] else if (hasVoting && !isRemoval) ...[
              // 🔥 ФИЛЬТРУЕМ ПОВТОРЯЮЩИЕСЯ РАУНДЫ
              final List<Map<int, int>> filteredRounds = [];
              final Set<String> seen = {};

              for (final round in dayData.rounds) {
                final List<int> keys = round.keys.toList()..sort();
                final List<int> values = round.values.toList()..sort();
                final String roundKey = '$keys-$values';

                if (!seen.contains(roundKey)) {
                  seen.add(roundKey);
                  filteredRounds.add(round);
                }
              }

              ...filteredRounds.asMap().entries.map((entry) {
                final int roundIndex = entry.key;
                final Map<int, int> round = entry.value;
                final String label = roundIndex == 0 ? 'Игрок' : 'Переголосование';
                return Padding(
                  padding: const EdgeInsets.only(bottom: 6),
                  child: _buildVoteRow(context, label, round, roundIndex, isDark),
                );
              }),
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
            ] else ...[
              const SizedBox(height: 4),
              Text(
                'Удалены:',
                style: const TextStyle(
                  color: Colors.red,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                dayData.result.isNotEmpty ? dayData.result.join(', ') : '0',
                style: const TextStyle(
                  color: Colors.red,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],

            if (dayData.eliminationVotes > 0)
              Text(
                'Голосование за подъём: ${dayData.eliminationVotes}',
                style: TextStyle(
                  color: primaryColor,
                  fontSize: 12,
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyVoteRow(bool isDark) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 60,
            child: Text(
              'Игрок',
              style: TextStyle(
                color: isDark ? Colors.white70 : Colors.black54,
                fontSize: 12,
              ),
              textAlign: TextAlign.left,
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
    );
  }

  Widget _buildVoteRow(
    BuildContext context,
    String label,
    Map<int, int> votes,
    int roundIndex,
    bool isDark,
  ) {
    final sortedKeys = votes.keys.toList()..sort();

    final String firstRowLabel = roundIndex == 0 ? 'Игрок' : 'Пере-';
    final String secondRowLabel = roundIndex == 0 ? 'Голоса' : 'голос.';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            SizedBox(
              width: 60,
              child: Text(
                firstRowLabel,
                style: TextStyle(
                  color: isDark ? Colors.white70 : Colors.black54,
                  fontSize: 12,
                ),
                textAlign: TextAlign.left,
              ),
            ),
            const SizedBox(width: 8),
            Wrap(
              spacing: 12,
              children: sortedKeys.map((player) {
                return Text(
                  '$player',
                  style: TextStyle(
                    color: isDark ? Colors.white : Colors.black87,
                    fontSize: 12,
                  ),
                );
              }).toList(),
            ),
          ],
        ),
        const SizedBox(height: 2),
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            SizedBox(
              width: 60,
              child: Text(
                secondRowLabel,
                style: TextStyle(
                  color: isDark ? Colors.white70 : Colors.black54,
                  fontSize: 12,
                ),
                textAlign: TextAlign.left,
              ),
            ),
            const SizedBox(width: 8),
            Wrap(
              spacing: 12,
              children: sortedKeys.map((player) {
                return Text(
                  '${votes[player]}',
                  style: TextStyle(
                    color: isDark ? Colors.white : Colors.black87,
                    fontSize: 12,
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ],
    );
  }
}