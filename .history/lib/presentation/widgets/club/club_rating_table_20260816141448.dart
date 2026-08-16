// lib/presentation/widgets/club/club_rating_table.dart
import 'package:flutter/material.dart';

class ClubRatingTable extends StatelessWidget {
  final List<Map<String, dynamic>> players;

  const ClubRatingTable({
    super.key,
    required this.players,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    if (players.isEmpty) {
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
              'В этом месяце игр не проводилось',
              style: TextStyle(
                color: isDark ? Colors.grey : Colors.grey.shade600,
                fontSize: 16,
              ),
            ),
          ],
        ),
      );
    }

    return Card(
      color: theme.cardColor,
      margin: const EdgeInsets.all(20),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
      elevation: 4,
      shadowColor: Colors.white.withOpacity(0.3),
      child: Padding(
        padding: const EdgeInsets.all(6),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            LayoutBuilder(
              builder: (context, constraints) {
                return Table(
                  columnWidths: {
                    0: const FlexColumnWidth(0.5), // №
                    1: const FlexColumnWidth(3),   // Никнейм + аватарка
                    2: const FlexColumnWidth(0.5), // И
                    3: const FlexColumnWidth(0.5), // П
                    4: const FlexColumnWidth(0.5), // Б
                    5: const FlexColumnWidth(0.7), // Д
                    6: const FlexColumnWidth(0.6), // О
                  },
                  children: [
                    TableRow(
                      children: [
                        _cell(context, '№',
                            isHeader: true, align: TextAlign.center),
                        _cell(context, 'Никнейм',
                            isHeader: true, align: TextAlign.center),
                        _cell(context, 'И',
                            isHeader: true, align: TextAlign.center),
                        _cell(context, 'П',
                            isHeader: true, align: TextAlign.center),
                        _cell(context, 'Б',
                            isHeader: true, align: TextAlign.center),
                        _cell(context, 'Д',
                            isHeader: true, align: TextAlign.center),
                        _cell(context, 'О',
                            isHeader: true, align: TextAlign.center),
                      ],
                    ),
                    ...players.asMap().entries.map((entry) {
                      final index = entry.key;
                      final player = entry.value;
                      final total =
                          (player['points'] ?? 0) + (player['bonus'] ?? 0);
                      final isTop = index < 3;

                      return TableRow(
                        children: [
                          _cell(context, '${index + 1}',
                              isTop: isTop, align: TextAlign.center),
                          _buildPlayerCell(
                            context,
                            player['username'] ?? 'Игрок',
                            player['avatar_url'] as String?,
                            isTop: isTop,
                          ),
                          _cell(
                            context,
                            '${player['games_played'] ?? 0}',
                            align: TextAlign.center,
                            isTop: isTop,
                          ),
                          _cell(
                            context,
                            '${player['wins'] ?? 0}',
                            align: TextAlign.center,
                            isTop: isTop,
                          ),
                          _cell(
                            context,
                            '${player['points'] ?? 0}',
                            align: TextAlign.center,
                            isTop: isTop,
                          ),
                          _cell(
                            context,
                            '${player['bonus'] ?? 0}',
                            align: TextAlign.center,
                            isTop: isTop,
                            color: (player['bonus'] ?? 0) > 0
                                ? Colors.green
                                : (player['bonus'] ?? 0) < 0
                                    ? Colors.red
                                    : null,
                          ),
                          _cell(
                            context,
                            total.toString(),
                            align: TextAlign.center,
                            isTop: isTop,
                            color: Colors.amber.shade700,
                            fontWeight: FontWeight.bold,
                          ),
                        ],
                      );
                    }).toList(),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  // 🔥 ЯЧЕЙКА С АВАТАРКОЙ И НИКНЕЙМОМ
  Widget _buildPlayerCell(
    BuildContext context,
    String username,
    String? avatarUrl, {
    bool isTop = false,
  }) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 4),
      child: Row(
        children: [
          // 🔥 АВАТАРКА
          CircleAvatar(
            radius: 14,
            backgroundColor: isDark ? Colors.grey.shade700 : Colors.grey.shade300,
            backgroundImage: avatarUrl != null && avatarUrl.isNotEmpty
                ? NetworkImage(avatarUrl)
                : null,
            child: avatarUrl == null || avatarUrl.isEmpty
                ? Text(
                    username.substring(0, 1).toUpperCase(),
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white : Colors.black87,
                    ),
                  )
                : null,
          ),
          const SizedBox(width: 8),
          // 🔥 НИКНЕЙМ
          Expanded(
            child: Text(
              username,
              style: TextStyle(
                color: isDark ? Colors.white : Colors.black87,
                fontWeight: isTop ? FontWeight.bold : FontWeight.normal,
                fontSize: 13,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _cell(
    BuildContext context,
    String text, {
    bool isHeader = false,
    bool isTop = false,
    TextAlign align = TextAlign.left,
    Color? color,
    FontWeight fontWeight = FontWeight.normal,
  }) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 4),
      child: Text(
        text,
        style: TextStyle(
          color: color ??
              (isHeader
                  ? theme.primaryColor
                  : (isDark ? Colors.white : Colors.black87)),
          fontWeight: isHeader || fontWeight == FontWeight.bold
              ? FontWeight.bold
              : FontWeight.normal,
          fontSize: isHeader ? 12 : 13,
        ),
        textAlign: align,
      ),
    );
  }
}