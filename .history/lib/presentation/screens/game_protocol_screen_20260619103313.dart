import 'package:flutter/material.dart';
import '../../domain/rules/game_history.dart';
import '../state/game_state.dart';

class GameProtocolScreen extends StatefulWidget {
  final GameHistory gameHistory;
  final GameState gameState;

  const GameProtocolScreen({
    super.key,
    required this.gameHistory,
    required this.gameState,
  });

  @override
  State<GameProtocolScreen> createState() => _GameProtocolScreenState();
}

class _GameProtocolScreenState extends State<GameProtocolScreen> {
  final List<TextEditingController> _noteControllers =
      List.generate(5, (_) => TextEditingController());
  String _protestText = 'Нет';

  List<int> _points = [];
  List<double> _bonusPoints = [];

  @override
  void initState() {
    super.initState();
    _bonusPoints = List.generate(10, (_) => 0.0);

    final isRedWon = widget.gameState.winner == 'red';
    _points = widget.gameState.players.map((p) {
      if (!p.isAlive) return 0;
      if (isRedWon) {
        return p.team == 'red' ? 1 : 0;
      } else {
        return p.team == 'black' ? 1 : 0;
      }
    }).toList();
  }

  @override
  void dispose() {
    for (var c in _noteControllers) {
      c.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black87,
      appBar: AppBar(
        title: const Text('Протокол игры'),
        backgroundColor: Colors.grey.shade900,
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _saveProtocol,
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildHeader(),
          const SizedBox(height: 16),
          _buildPlayersTable(),
          const SizedBox(height: 16),
          _buildInfoRow(),
          const SizedBox(height: 16),
          _buildVotingTable(),
          const SizedBox(height: 16),
          _buildJudge(),
          const SizedBox(height: 16),
          _buildNotes(),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Card(
      color: Colors.grey.shade800,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'ТУРНИР СТАДИЯ',
                  style: TextStyle(
                    color: Colors.orange,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'ДАТА: ${widget.gameState.gameDate?.toString().substring(0, 10) ?? DateTime.now().toString().substring(0, 10)}',
                  style: const TextStyle(color: Colors.white, fontSize: 14),
                ),
              ],
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  'СТОЛ № ${widget.gameState.tableNumber ?? 1}',
                  style: const TextStyle(color: Colors.white, fontSize: 14),
                ),
                Text(
                  'ИГРА № ${widget.gameState.gameNumber ?? 1}',
                  style: const TextStyle(color: Colors.white, fontSize: 14),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlayersTable() {
    return Card(
      color: Colors.grey.shade800,
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
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Table(
                border:
                    TableBorder.all(color: Colors.grey.shade600, width: 0.5),
                columnWidths: const {
                  0: FixedColumnWidth(28),
                  1: FixedColumnWidth(80),
                  2: FixedColumnWidth(32),
                  3: FixedColumnWidth(36),
                  4: FixedColumnWidth(40),
                  5: FixedColumnWidth(50),
                },
                children: [
                  TableRow(
                    decoration: BoxDecoration(color: Colors.grey.shade700),
                    children: [
                      _tableCell('№', isHeader: true),
                      _tableCell('Игрок', isHeader: true),
                      _tableCell('Роль', isHeader: true),
                      _tableCell('Фолы', isHeader: true),
                      _tableCell('Баллы', isHeader: true),
                      _tableCell('Доп.', isHeader: true),
                    ],
                  ),
                  ...widget.gameState.players.asMap().entries.map((entry) {
                    final index = entry.key;
                    final p = entry.value;
                    return TableRow(
                      children: [
                        _tableCell('${p.seatNumber}'),
                        _tableCell(p.name),
                        _tableCell(_getRoleShort(p.role)),
                        _tableCell('${p.fouls}'),
                        _buildPointsCell(index),
                        _buildBonusPointsCell(index),
                      ],
                    );
                  }).toList(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBonusPointsCell(int index) {
    final bonusValues = [0.0, 0.1, 0.2, 0.3, 0.4, 0.5, 0.6, 0.7];
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 0, horizontal: 0),
      child: SizedBox(
        height: 24,
        width: 44,
        child: DropdownButtonHideUnderline(
          child: DropdownButton<double>(
            value: _bonusPoints[index],
            dropdownColor: Colors.grey.shade800,
            style: const TextStyle(color: Colors.white, fontSize: 11),
            isExpanded: true,
            icon: const SizedBox.shrink(),
            items: bonusValues.map((value) {
              return DropdownMenuItem<double>(
                value: value,
                child: Center(
                  child: Text(
                    value == 0 ? '0' : value.toStringAsFixed(1),
                    style: const TextStyle(fontSize: 11, color: Colors.white),
                    textAlign: TextAlign.center,
                  ),
                ),
              );
            }).toList(),
            onChanged: (newValue) {
              setState(() {
                _bonusPoints[index] = newValue!;
              });
            },
          ),
        ),
      ),
    );
  }

  Widget _buildPointsCell(int index) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 0, horizontal: 0),
      child: Container(
        height: 24,
        alignment: Alignment.center,
        child: Text(
          '${_points[index]}',
          style: const TextStyle(color: Colors.white, fontSize: 11),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

  Widget _tableCell(String text, {bool isHeader = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 2),
      child: Text(
        text,
        style: TextStyle(
          color: isHeader ? Colors.orange : Colors.white,
          fontWeight: isHeader ? FontWeight.bold : FontWeight.normal,
          fontSize: 11,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget _buildInfoRow() {
    final winner = widget.gameState.winner == 'red' ? 'КРАСНЫЕ' : 'ЧЁРНЫЕ';
    final winnerColor =
        widget.gameState.winner == 'red' ? Colors.red : Colors.black;

    final nightActions = widget.gameState.nightActions ?? [];
    final shoots = <String>[];
    for (int i = 0; i < nightActions.length; i += 3) {
      final kill = nightActions[i];
      shoots.add('${kill == 0 || kill == -1 ? '0' : kill}');
    }

    final bestMove = widget.gameState.partialBestMove;
    String bestMoveText;
    String bestPlayer;
    if (bestMove.isNotEmpty && bestMove.length >= 3) {
      bestMoveText = bestMove.join('  ');
      final nightActions2 = widget.gameState.nightActions ?? [];
      bestPlayer = nightActions2.length >= 3 ? '${nightActions2[0]}' : '0';
    } else {
      bestMoveText = '_  _  _';
      bestPlayer = '0';
    }

    return Card(
      color: Colors.grey.shade800,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            _infoRow('ПОБЕДИВШАЯ КОМАНДА', winner, color: winnerColor),
            Divider(color: Colors.grey.shade600, height: 8),
            _infoRow('СТРЕЛЬБА', shoots.isEmpty ? 'Нет' : shoots.join(' → ')),
            Divider(color: Colors.grey.shade600, height: 8),
            _infoRow('ПРОТЕСТ', _protestText, isEditable: true),
            Divider(color: Colors.grey.shade600, height: 8),
            _infoRow('ЛУЧШИЙ ХОД', '$bestMoveText',
                suffix: '  Игрок № $bestPlayer'),
          ],
        ),
      ),
    );
  }

  Widget _infoRow(String label, String value,
      {Color? color, bool isEditable = false, String? suffix}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          SizedBox(
            width: 110,
            child: Text(
              label,
              style: const TextStyle(
                color: Colors.orange,
                fontSize: 13,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Expanded(
            child: isEditable
                ? TextField(
                    style: const TextStyle(color: Colors.white, fontSize: 13),
                    decoration: InputDecoration(
                      hintText: 'Нет',
                      hintStyle: TextStyle(color: Colors.grey.shade600),
                      border: InputBorder.none,
                      isDense: true,
                      contentPadding: EdgeInsets.zero,
                    ),
                    onChanged: (value) {
                      _protestText = value.isEmpty ? 'Нет' : value;
                    },
                  )
                : Row(
                    children: [
                      Text(
                        value,
                        style: TextStyle(
                          color: color ?? Colors.white,
                          fontSize: 13,
                          fontWeight: color != null
                              ? FontWeight.bold
                              : FontWeight.normal,
                        ),
                      ),
                      if (suffix != null) ...[
                        const SizedBox(width: 12),
                        Text(
                          suffix,
                          style: const TextStyle(
                            color: Colors.white70,
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

  Widget _buildVotingTable() {
    final voteHistory = widget.gameState.voteHistory;
    final totalDays = widget.gameState.currentDay + 1;

    if (voteHistory.isEmpty) {
      return Card(
        color: Colors.grey.shade800,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Голосования',
                style: TextStyle(
                  color: Colors.orange,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              ...List.generate(totalDays, (index) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Голосование ${index + 1}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey.shade600),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Row(
                          children: [
                            const Expanded(
                              flex: 2,
                              child: Text(
                                'Нет голосования',
                                style: TextStyle(
                                    color: Colors.white70, fontSize: 12),
                              ),
                            ),
                            Expanded(
                              flex: 1,
                              child: Container(
                                alignment: Alignment.centerRight,
                                child: const Text(
                                  'Результат: 0',
                                  style: TextStyle(
                                    color: Colors.red,
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              }),
            ],
          ),
        ),
      );
    }

    return Card(
      color: Colors.grey.shade800,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Голосования',
              style: TextStyle(
                color: Colors.orange,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            ...voteHistory.asMap().entries.map((entry) {
              final index = entry.key;
              final vote = entry.value;
              final candidates = vote.keys.toList();
              final votes = vote.values.toList();
              final maxVotes =
                  votes.isNotEmpty ? votes.reduce((a, b) => a > b ? a : b) : 0;
              final winners = <int>[];
              for (int i = 0; i < candidates.length; i++) {
                if (votes[i] == maxVotes && maxVotes > 0) {
                  winners.add(candidates[i]);
                }
              }

              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Голосование ${index + 1}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey.shade600),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            flex: 2,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Игрок',
                                  style: TextStyle(
                                    color: Colors.orange,
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                ...candidates.map((seat) => Padding(
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 2),
                                      child: Text(
                                        '$seat',
                                        style: const TextStyle(
                                            color: Colors.white, fontSize: 12),
                                      ),
                                    )),
                              ],
                            ),
                          ),
                          Expanded(
                            flex: 2,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Голоса',
                                  style: TextStyle(
                                    color: Colors.orange,
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                ...votes.map((v) => Padding(
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 2),
                                      child: Text(
                                        '$v',
                                        style: const TextStyle(
                                            color: Colors.white, fontSize: 12),
                                      ),
                                    )),
                              ],
                            ),
                          ),
                          Expanded(
                            flex: 1,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Результат',
                                  style: TextStyle(
                                    color: Colors.orange,
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  winners.isEmpty ? '0' : winners.join(','),
                                  style: TextStyle(
                                    color: winners.isNotEmpty
                                        ? Colors.yellow
                                        : Colors.red,
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildJudge() {
    return Card(
      color: Colors.grey.shade800,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'СУДЬЯ:',
              style: TextStyle(color: Colors.orange, fontSize: 16),
            ),
            Text(
              widget.gameState.judgeName ?? '___________________',
              style: const TextStyle(color: Colors.white, fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNotes() {
    return Card(
      color: Colors.grey.shade800,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'ПОЯСНЕНИЯ К ДОПОЛНИТЕЛЬНЫМ БАЛЛАМ И ШТРАФАМ',
              style: TextStyle(
                color: Colors.orange,
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            ...List.generate(5, (index) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Row(
                  children: [
                    Text(
                      '${index + 1}. ',
                      style:
                          const TextStyle(color: Colors.white70, fontSize: 12),
                    ),
                    Expanded(
                      child: TextField(
                        controller: _noteControllers[index],
                        style:
                            const TextStyle(color: Colors.white, fontSize: 12),
                        decoration: InputDecoration(
                          hintText: '___________________',
                          hintStyle: TextStyle(color: Colors.grey.shade600),
                          border: InputBorder.none,
                          isDense: true,
                          contentPadding: EdgeInsets.zero,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  String _getRoleShort(String role) {
    switch (role) {
      case 'don':
        return 'Д';
      case 'mafia':
        return 'Ч';
      case 'sheriff':
        return 'Ш';
      case 'citizen':
        return 'К';
      default:
        return '?';
    }
  }

  void _saveProtocol() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Сохранение протокола в разработке')),
    );
  }
}
