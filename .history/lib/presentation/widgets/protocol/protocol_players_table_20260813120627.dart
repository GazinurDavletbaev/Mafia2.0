// lib/presentation/widgets/protocol/protocol_players_table.dart
import 'package:flutter/material.dart';
import 'package:mafia_help/data/local/models/player_model.dart';
import 'package:mafia_help/domain/constants/protocol_constants.dart';
import 'package:mafia_help/domain/helpers/protocol_helper.dart';
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
    final primaryColor = theme.primaryColor;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(4),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            LayoutBuilder(
              builder: (context, constraints) {
                final totalWidth = constraints.maxWidth;
                final fixedWidths = 28 + 40 + 45 + 50 + 50;
                final nameWidth = totalWidth - fixedWidths - 10;

                return Table(
                  // 🔥 УБИРАЕМ border
                  border: TableBorder(
                    // 🔥 ТОЛЬКО НИЖНЯЯ ГРАНИЦА У ЗАГОЛОВКА
                    horizontalInside: BorderSide.none,
                    verticalInside: BorderSide.none,
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
                    _buildHeaderRow(context),
                    ...gameState.players
                        .map((p) => _buildPlayerRow(context, p)),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  // ===== ЗАГОЛОВОК =====
  TableRow _buildHeaderRow(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return TableRow(
      children: [
        _tableCell(context, '№', isHeader: true),
        _tableCell(context, 'Игрок', isHeader: true),
        _tableCell(context, 'Роль', isHeader: true),
        _tableCell(context, 'Фолы', isHeader: true),
        _tableCell(context, 'Баллы', isHeader: true),
        _tableCell(context, 'Доп.', isHeader: true),
      ],
    );
  }

  // ===== СТРОКА ИГРОКА =====
  TableRow _buildPlayerRow(BuildContext context, PlayerModel player) {
    final index = player.seatNumber - 1;
    final points = ProtocolHelper.calculatePoints(player, gameState.winner);
    final isRemoved = ProtocolHelper.isRemoved(player, gameState);
    final hasPpk = ProtocolHelper.hasPpk(player, gameState);

    return TableRow(
      children: [
        _tableCell(context, '${player.seatNumber}'),
        _tableCell(context, player.name),
        _tableCell(context, ProtocolHelper.getRoleShort(player.role)),
        _tableCell(context, '${player.fouls}'),
        _buildPointsCell(context, points),
        _buildBonusCell(context, index, player, isRemoved, hasPpk),
      ],
    );
  }

  // ===== ЯЧЕЙКА ОЧКИ =====
  Widget _buildPointsCell(BuildContext context, int points) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      height: 24,
      alignment: Alignment.center,
      child: Text(
        '$points',
        style: TextStyle(
          color: isDark ? Colors.white : Colors.black87,
          fontSize: 11,
        ),
      ),
    );
  }

  // ===== ЯЧЕЙКА БОНУСЫ =====
  Widget _buildBonusCell(
    BuildContext context,
    int index,
    PlayerModel player,
    bool isRemoved,
    bool hasPpk,
  ) {
    if (hasPpk) {
      return _buildPpkCell(context);
    }
    if (isRemoved) {
      return _buildRemovedDropdown(context, player);
    }
    return _buildBonusDropdown(context, index);
  }

  // ===== ППК =====
  Widget _buildPpkCell(BuildContext context) {
    return Container(
      height: 24,
      alignment: Alignment.center,
      child: const Text(
        '-1',
        style: TextStyle(
          color: Colors.red,
          fontSize: 11,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  // ===== ДРОПДАУН ДЛЯ УДАЛЁННЫХ =====
  Widget _buildRemovedDropdown(BuildContext context, PlayerModel player) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
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
          hint: const Text(
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
          items: ProtocolConstants.removalRules.map((rule) {
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
    );
  }

  // ===== ДРОПДАУН ДЛЯ БОНУСОВ =====
  Widget _buildBonusDropdown(BuildContext context, int index) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return SizedBox(
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
          items: ProtocolConstants.bonusValues.map((value) {
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
    );
  }

  // ===== БАЗОВАЯ ЯЧЕЙКА =====
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
}
