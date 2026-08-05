// lib/presentation/widgets/protocol/protocol_header.dart

import 'package:flutter/material.dart';
import 'package:mafia_help/presentation/state/game_state.dart';

class ProtocolHeader extends StatelessWidget {
  final GameState gameState;

  const ProtocolHeader({super.key, required this.gameState});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final startTime = gameState.gameDate;
    final endTime = DateTime.now();

    return Card(
      color: isDark ? Colors.grey.shade800 : Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: isDark ? Colors.grey.shade700 : Colors.grey.shade300,
          width: 0.5,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                _buildLabel('ТУРНИР'),
                const SizedBox(width: 6),
                Expanded(child: _buildValue(context, gameState.tournamentName ?? 'РЕЙТИНГ')),
                const SizedBox(width: 20),
                _buildLabel('СТАДИЯ'),
                const SizedBox(width: 6),
                Expanded(child: _buildValue(context, gameState.stageName ?? '')),
              ],
            ),
            const SizedBox(height: 12),
            Divider(
              color: isDark ? Colors.grey.shade700 : Colors.grey.shade300,
              height: 1,
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    _buildLabel('ДАТА:'),
                    const SizedBox(width: 6),
                    _buildValue(
                      context,
                      gameState.gameDate?.toString().substring(0, 10) ??
                          DateTime.now().toString().substring(0, 10),
                      width: 120,
                    ),
                  ],
                ),
                Row(
                  children: [
                    _buildLabel('СТОЛ №'),
                    const SizedBox(width: 4),
                    _buildValue(context, '${gameState.tableNumber ?? 1}', width: 40),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    _buildLabel('ВРЕМЯ:'),
                    const SizedBox(width: 6),
                    _buildValue(context, startTime != null ? _formatTime(startTime) : '--:--'),
                    const SizedBox(width: 8),
                    Text(
                      '—',
                      style: TextStyle(
                        color: isDark ? Colors.grey.shade500 : Colors.grey.shade400,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(width: 8),
                    _buildValue(context, _formatTime(endTime)),
                  ],
                ),
                Row(
                  children: [
                    _buildLabel('ИГРА №'),
                    const SizedBox(width: 4),
                    _buildValue(context, '${gameState.gameNumber ?? 1}', width: 40),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Text(
      text,
      style: const TextStyle(
        color: Colors.orange,
        fontSize: 14,
        fontWeight: FontWeight.bold,
        letterSpacing: 0.5,
      ),
    );
  }

  Widget _buildValue(BuildContext context, String text, {double? width}) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return SizedBox(
      width: width,
      child: Text(
        text,
        style: TextStyle(
          color: isDark ? Colors.white : Colors.black87,
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  String _formatTime(DateTime time) {
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
  }
}