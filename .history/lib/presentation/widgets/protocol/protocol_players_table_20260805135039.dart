import 'package:flutter/material.dart';
import 'package:mafia_help/data/local/models/player_model.dart';
import 'package:mafia_help/presentation/state/game_state.dart';

class ProtocolPlayersTable extends StatelessWidget {
  final GameState gameState;
  final Function(int, String) onRemovedRuleChanged;
  final Function(int, double) onBonusChanged;
  final Function(PlayerModel, String) onNoteAdded;
  final Function(int, double) onBonusNoteAdded;

  const ProtocolPlayersTable({
    super.key,
    required this.gameState,
    required this.onRemovedRuleChanged,
    required this.onBonusChanged,
    required this.onNoteAdded,
    required this.onBonusNoteAdded,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Card(
      color: isDark ? Colors.grey.shade800 : Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'ИГРОКИ',
              style: TextStyle(
                color: Colors.orange,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 6),
            LayoutBuilder(
              builder: (context, constraints) {
                final totalWidth = constraints.maxWidth;
                final fixedWidths = 28 + 40 + 45 + 50 + 50;
                final nameWidth = totalWidth - fixedWidths - 10;

                return Table(
                  border: TableBorder.all(
                    color: isDark ? Colors.grey.shade600 : Colors.grey.shade300,
                    width: 0.5,
                  ),
                  columnWidths: {
                    0: const FixedColumnWidth(28),
                    1: FixedColumnWidth(nameWidth > 80 ? nameWidth : 80),
                    2: const FixedColumnWidth(40),
                    3: const FixedColumnWidth(45),
                    4: const FixedColumnWidth(50),
                    5: const FixedColumnWidth(50),
                  },
                  children: [
                    TableRow(
                      decoration: BoxDecoration(
                        color: isDark ? Colors.grey.shade700 : Colors.grey.shade200,
                      ),
                      children: [
                        _tableCell(context, '№', isHeader: true),
                        _tableCell(context, 'Игрок', isHeader: true),
                        _tableCell(context, 'Роль', isHeader: true),
                        _tableCell(context, 'Фолы', isHeader: true),
                        _tableCell(context, 'Баллы', isHeader: true),
                        _tableCell(context, 'Доп.', isHeader: true),
                      ],
                    ),
                    ...gameState.players.asMap().entries.map((entry) {
                      final index = entry.key;
                      final p = entry.value;
                      return TableRow(
                        children: [
                          _tableCell(context, '${p.seatNumber}'),
                          _tableCell(context, p.name),
                          _tableCell(context, _getRoleShort(p.role)),
                          _tableCell(context, '${p.fouls}'),
                          _buildPointsCell(context, index),
                          _buildBonusPointsCell(context, index, p),
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

  Widget _buildPointsCell(BuildContext context, int index) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final isRedWon = gameState.winner == 'red';
    final points = gameState.players[index].team == (isRedWon ? 'red' : 'black') ? 1 : 0;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 0, horizontal: 0),
      child: Container(
        height: 24,
        alignment: Alignment.center,
        child: Text(
          '$points',
          style: TextStyle(
            color: isDark ? Colors.white : Colors.black87,
            fontSize: 11,
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

  Widget _buildBonusPointsCell(BuildContext context, int index, PlayerModel player) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final isRemoved = gameState.removedPlayers.any((rp) => rp.seatNumber == player.seatNumber);
    final hasPpk = gameState.ppkPlayerSeat == player.seatNumber;

    if (hasPpk) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 0, horizontal: 0),
        child: Container(
          height: 24,
          alignment: Alignment.center,
          child: Text(
            '-1',
            style: TextStyle(
              color: Colors.red,
              fontSize: 11,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      );
    }

    if (isRemoved) {
      return _buildRemovedDropdown(context, index, player, isDark);
    }

    return _buildBonusDropdown(context, index, isDark);
  }

  Widget _buildRemovedDropdown(BuildContext context, int index, PlayerModel player, bool isDark) {
    final ruleOptions = ['п.8.4.1', 'п.8.4.2', 'п.8.4.3', 'п.8.5.1', 'п.8.5.2'];

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 0, horizontal: 0),
      child: Container(
        height: 24,
        alignment: Alignment.center,
        child: Container(
          width: 52,
          alignment: Alignment.center,
          child: DropdownButton<String>(
            value: null,
            dropdownColor: isDark ? Colors.grey.shade800 : Colors.white,
            style: TextStyle(
              color: isDark ? Colors.white : Colors.black87,
              fontSize: 11,
              fontWeight: FontWeight.bold,
            ),
            hint: Text(
              '-0.5',
              style: TextStyle(
                color: Colors.red,
                fontSize: 11,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            icon: const SizedBox.shrink(),
            underline: const SizedBox.shrink(),
            isDense: true,
            isExpanded: true,
            alignment: AlignmentDirectional.center,
            items: ruleOptions.map((rule) {
              return DropdownMenuItem<String>(
                value: rule,
                alignment: AlignmentDirectional.center,
                child: Text(
                  rule,
                  style: TextStyle(
                    fontSize: 11,
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                  textAlign: TextAlign.center,
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
              );
            }).toList(),
            onChanged: (newValue) {
              if (newValue != null && newValue.isNotEmpty) {
                onRemovedRuleChanged(player.seatNumber, newValue);
                onNoteAdded(player, newValue);
              }
            },
          ),
        ),
      ),
    );
  }

  Widget _buildBonusDropdown(BuildContext context, int index, bool isDark) {
    final bonusValues = [0.0, 0.1, 0.2, 0.3, 0.4, 0.5, 0.6, 0.7];

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 0, horizontal: 0),
      child: SizedBox(
        height: 24,
        width: 44,
        child: DropdownButtonHideUnderline(
          child: DropdownButton<double>(
            value: 0.0,
            dropdownColor: isDark ? Colors.grey.shade800 : Colors.white,
            style: TextStyle(
              color: isDark ? Colors.white : Colors.black87,
              fontSize: 11,
            ),
            isExpanded: true,
            icon: const SizedBox.shrink(),
            items: bonusValues.map((value) {
              return DropdownMenuItem<double>(
                value: value,
                child: Center(
                  child: Text(
                    value == 0 ? '0' : value.toStringAsFixed(1),
                    style: TextStyle(
                      fontSize: 11,
                      color: isDark ? Colors.white : Colors.black87,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              );
            }).toList(),
            onChanged: (newValue) {
              if (newValue != null) {
                onBonusChanged(index, newValue);
                onBonusNoteAdded(index, newValue);
              }
            },
          ),
        ),
      ),
    );
  }

  Widget _tableCell(BuildContext context, String text, {bool isHeader = false}) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 4),
      child: Text(
        text,
        style: TextStyle(
          color: isHeader
              ? Colors.orange
              : (isDark ? Colors.white : Colors.black87),
          fontWeight: isHeader ? FontWeight.bold : FontWeight.normal,
          fontSize: 12,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }

  String _getRoleShort(String role) {
    switch (role) {
      case 'don': return 'Д';
      case 'mafia': return 'Ч';
      case 'sheriff': return 'Ш';
      case 'citizen': return 'К';
      default: return '?';
    }
  }
}