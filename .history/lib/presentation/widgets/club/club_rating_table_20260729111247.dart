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
      return _buildEmptyState(isDark);
    }

    return Card(
      color: theme.cardColor,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            LayoutBuilder(
              builder: (context, constraints) {
                final totalWidth = constraints.maxWidth;
                final fixedWidths = 30 + 40 + 50 + 50 + 50 + 50 + 50;
                final nameWidth = totalWidth - fixedWidths - 10;

                return Table(
                  border: TableBorder.all(
                    color: isDark ? Colors.grey.shade600 : Colors.grey.shade300,
                    width: 0.5,
                  ),
                  columnWidths: {
                    0: const FixedColumnWidth(30),
                    1: FixedColumnWidth(nameWidth > 80 ? nameWidth : 80),
                    2: const FixedColumnWidth(50),
                    3: const FixedColumnWidth(50),
                    4: const FixedColumnWidth(50),
                    5: const FixedColumnWidth(50),
                    6: const FixedColumnWidth(50),
                  },
                  children: [
                    _buildHeader(),
                    ...players.asMap().entries.map((entry) {
                      final index = entry.key;
                      final player = entry.value;
                      final total = (player['points'] ?? 0) + (player['bonus'] ?? 0);
                      final isTop = index < 3;

                      return _buildRow(index, player, total, isTop);
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

  TableRow _buildHeader() {
    return TableRow(
      children: [
        _cell('№', isHeader: true),
        _cell('Игрок', isHeader: true),
        _cell('Игр', isHeader: true, align: TextAlign.center),
        _cell('Побед', isHeader: true, align: TextAlign.center),
        _cell('Очки', isHeader: true, align: TextAlign.center),
        _cell('Бонус', isHeader: true, align: TextAlign.center),
        _cell('Всего', isHeader: true, align: TextAlign.center),
      ],
    );
  }

  TableRow _buildRow(int index, Map<String, dynamic> player, int total, bool isTop) {
    return TableRow(
      children: [
        _cell('${index + 1}', isTop: isTop),
        _cell(
          player['username'] ?? 'Игрок',
          isTop: isTop,
          fontWeight: isTop ? FontWeight.bold : FontWeight.normal,
        ),
        _cell('${player['games_played'] ?? 0}', align: TextAlign.center, isTop: isTop),
        _cell(
          '${player['wins'] ?? 0}',
          align: TextAlign.center,
          isTop: isTop,
          color: Colors.amber.shade700,
        ),
        _cell('${player['points'] ?? 0}', align: TextAlign.center, isTop: isTop),
        _cell(
          '${player['bonus'] ?? 0}',
          align: TextAlign.center,
          isTop: isTop,
          color: (player['bonus'] ?? 0) > 0
              ? Colors.green
              : (player['bonus'] ?? 0) < 0
                  ? Colors.red
                  : null,
        ),
        _cell(total.toString(), align: TextAlign.center, isTop: isTop, fontWeight: FontWeight.bold),
      ],
    );
  }

  Widget _cell(
    BuildContext co
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

  Widget _buildEmptyState(bool isDark) {
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
}