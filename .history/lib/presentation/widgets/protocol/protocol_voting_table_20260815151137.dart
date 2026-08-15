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
    final hasVoting = dayData.rounds.isNotEmpty;
    final hasResult = dayData.result.isNotEmpty;

    if (!hasVoting && !hasResult) {
      return _buildEmptyVoteCard(context, voteNumber, isDark);
    }

    if (!hasVoting && hasResult) {
      return _buildRemovalOnlyCard(context, voteNumber, dayData, isDark);
    }

    return _buildVoteCard(context, voteNumber, dayData, isDark);
  }

  Widget _buildEmptyVoteCard(
      BuildContext context, int voteNumber, bool isDark) {
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
            _buildRoundRow('Игрок', const <int, int>{}, isDark, true),
            _buildRoundRow('Голоса', const <int, int>{}, isDark, true),
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

  Widget _buildVoteCard(
    BuildContext context,
    int voteNumber,
    VoteDay dayData,
    bool isDark,
  ) {
    final rounds = dayData.rounds;

    final Map<int, int> firstRound =
        rounds.isNotEmpty ? Map<int, int>.from(rounds[0]) : <int, int>{};

    final List<Widget> children = [];

    children.add(Text(
      'ГОЛОСОВАНИЕ $voteNumber',
      style: TextStyle(
        color: isDark ? Colors.white : Colors.black87,
        fontSize: 16,
        fontWeight: FontWeight.bold,
      ),
      textAlign: TextAlign.center,
    ));

    children.add(const SizedBox(height: 8));

    children.add(_buildRoundRow('Игрок', firstRound, isDark, true));
    children.add(_buildRoundRow('Голоса', firstRound, isDark, true));

    if (rounds.length > 1) {
      children.add(const SizedBox(height: 4));
      for (int i = 1; i < rounds.length; i++) {
        final Map<int, int> round = Map<int, int>.from(rounds[i]);
        children.add(_buildRoundRow('Пере-', round, isDark, true));
        children.add(_buildRoundRow('голос.', round, isDark, true));
      }
    }

    children.add(const Divider(color: Colors.grey));

    children.add(Row(
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
            fontWeight:
                dayData.result.isNotEmpty ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ],
    ));

    if (dayData.eliminationVotes > 0) {
      children.add(Text(
        'Голосование за подъём: ${dayData.eliminationVotes}',
        style: TextStyle(
          color: Theme.of(context).primaryColor,
          fontSize: 12,
        ),
      ));
    }

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
          children: children,
        ),
      ),
    );
  }

  Widget _buildRoundRow(
    String label,
    Map<int, int> round,
    bool isDark,
    bool showValue,
  ) {
    final allSeats = List.generate(10, (i) => i + 1);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 1),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          if (label.isNotEmpty)
            SizedBox(
              width: 50,
              child: Text(
                label,
                style: TextStyle(
                  color: isDark ? Colors.white70 : Colors.black54,
                  fontSize: 11,
                ),
                textAlign: TextAlign.left,
              ),
            ),
          ...allSeats.map((seat) {
            final hasVote = round.containsKey(seat);
            final value = round[seat] ?? 0;

            String displayValue;
            if (!hasVote) {
              displayValue = '-';
            } else {
              displayValue = value.toString();
            }

            return Container(
              width: ,
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
