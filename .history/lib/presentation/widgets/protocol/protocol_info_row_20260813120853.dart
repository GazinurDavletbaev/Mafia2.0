// lib/presentation/widgets/protocol/protocol_info_row.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mafia_help/application/providers/user_provider.dart';
import 'package:mafia_help/presentation/state/game_state.dart';

class ProtocolInfoRow extends ConsumerWidget {
  final GameState gameState;

  const ProtocolInfoRow({super.key, required this.gameState});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final primaryColor = theme.primaryColor;
    final winner = gameState.winner == 'red' ? 'КРАСНЫЕ' : 'ЧЁРНЫЕ';
    final winnerColor = gameState.winner == 'red' ? Colors.red : Colors.black;
    final userAsync = ref.watch(userProvider);

    final nightActions = gameState.nightActions ?? [];
    final List<Map<String, dynamic>> nights = [];
    for (int i = 0; i < nightActions.length; i += 3) {
      final nightNum = (i ~/ 3) + 1;
      final kill = nightActions[i];
      final donCheck = nightActions[i + 1];
      final sheriffCheck = nightActions[i + 2];
      nights.add({
        'night': nightNum,
        'kill': kill == 0 || kill == -1 ? '0' : '$kill',
        'don': donCheck == 0 || donCheck == -1 ? '0' : '$donCheck',
        'sheriff':
            sheriffCheck == 0 || sheriffCheck == -1 ? '0' : '$sheriffCheck',
      });
    }

    final bestMove = gameState.partialBestMove;
    String bestMoveText;
    String bestPlayer;
    if (bestMove.isNotEmpty && bestMove.length >= 3) {
      bestMoveText = bestMove.join('  ');
      final nightActions2 = gameState.nightActions ?? [];
      bestPlayer = nightActions2.length >= 3 ? '${nightActions2[0]}' : '0';
    } else {
      bestMoveText = '_  _  _';
      bestPlayer = '0';
    }

    return Card(
      
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            _infoRow(context, 'ПОБЕДИВШАЯ КОМАНДА    ', winner,
                color: winnerColor),
            Divider(
              color: isDark ? Colors.grey.shade600 : Colors.grey.shade300,
              height: 16,
            ),
            _infoRow(context, 'ПРОТЕСТ     ', 'Нет', isEditable: true),
            Divider(
              color: isDark ? Colors.grey.shade600 : Colors.grey.shade300,
              height: 8,
            ),
            _infoRow(context, 'ЛУЧШИЙ ХОД    ', '$bestMoveText',
                suffix: '  Игрок № $bestPlayer'),
            Divider(
              color: isDark ? Colors.grey.shade600 : Colors.grey.shade300,
              height: 8,
            ),
            _infoRow(
              context,
              'СУДЬЯ      ',
              userAsync.when(
                data: (user) => user?['username'] ?? 'Неизвестен',
                loading: () => 'loading',
                error: (err, stack) => 'error',
              ),
            ),
            Divider(
              color: isDark ? Colors.grey.shade600 : Colors.grey.shade300,
              height: 8,
            ),
            Text(
              'НОЧНЫЕ ДЕЙСТВИЯ',
              style: TextStyle(
                color: primaryColor,
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            if (nights.isEmpty)
              const Text(
                'Нет данных',
                style: TextStyle(color: Colors.white70, fontSize: 12),
              )
            else
              _buildNightActionsTable(context, nights, isDark),
          ],
        ),
      ),
    );
  }

  Widget _buildNightActionsTable(
      BuildContext context, List<Map<String, dynamic>> nights, bool isDark) {
    final theme = Theme.of(context);
    final primaryColor = theme.primaryColor;

    return Container(
      width: double.infinity,
      child: Table(
        border: TableBorder.all(
          color: isDark ? Colors.grey.shade600 : Colors.grey.shade300,
          width: 0.5,
        ),
        columnWidths: {
          0: const FixedColumnWidth(50),
          for (int i = 0; i < nights.length; i++)
            i + 1: const FixedColumnWidth(40),
        },
        children: [
          TableRow(
            decoration: BoxDecoration(
              color: isDark ? Colors.grey.shade700 : Colors.grey.shade200,
            ),
            children: [
              _tableCell(context, 'Ночь', isHeader: true),
              ...nights
                  .map((n) =>
                      _tableCell(context, '${n['night']}', isHeader: true))
                  .toList(),
            ],
          ),
          TableRow(
            children: [
              _tableCell(context, 'Стрельба', isHeader: true),
              ...nights
                  .map((n) => _tableCell(context, n['kill'] as String))
                  .toList(),
            ],
          ),
          TableRow(
            children: [
              _tableCell(context, 'Дон', isHeader: true),
              ...nights
                  .map((n) => _tableCell(context, n['don'] as String))
                  .toList(),
            ],
          ),
          TableRow(
            children: [
              _tableCell(context, 'Шериф', isHeader: true),
              ...nights
                  .map((n) => _tableCell(context, n['sheriff'] as String))
                  .toList(),
            ],
          ),
        ],
      ),
    );
  }

  Widget _tableCell(BuildContext context, String text,
      {bool isHeader = false}) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final primaryColor = theme.primaryColor;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 4),
      child: Text(
        text,
        style: TextStyle(
          color: isHeader
              ? primaryColor
              : (isDark ? Colors.white : Colors.black87),
          fontWeight: isHeader ? FontWeight.bold : FontWeight.normal,
          fontSize: 12,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget _infoRow(
    BuildContext context,
    String label,
    String value, {
    Color? color,
    bool isEditable = false,
    String? suffix,
  }) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final primaryColor = theme.primaryColor;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          Text(
            label,
            style: TextStyle(
              color: primaryColor,
              fontSize: 13,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Row(
              children: [
                Text(
                  value,
                  style: TextStyle(
                    color: color ?? (isDark ? Colors.white : Colors.black87),
                    fontSize: 13,
                    fontWeight:
                        color != null ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
                if (suffix != null) ...[
                  const SizedBox(width: 12),
                  Text(
                    suffix,
                    style: TextStyle(
                      color: isDark ? Colors.white70 : Colors.black54,
                      fontSize: 13,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
