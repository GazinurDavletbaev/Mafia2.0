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
          _buildNotes(),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    final startTime = widget.gameState.gameDate;
    final endTime = DateTime.now();

    return Card(
      color: Colors.grey.shade800,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey.shade700, width: 0.5),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Первая строка: ТУРНИР и СТАДИЯ
            Row(
              children: [
                _buildLabel('ТУРНИР'),
                const SizedBox(width: 6),
                Expanded(
                  child: _buildValue(
                    widget.gameState.tournamentName ?? '__________',
                  ),
                ),
                const SizedBox(width: 20),
                _buildLabel('СТАДИЯ'),
                const SizedBox(width: 6),
                Expanded(
                  child: _buildValue(
                    widget.gameState.stageName ?? '__________',
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            // Разделитель
            Divider(color: Colors.grey.shade700, height: 1),
            const SizedBox(height: 12),
            // Вторая строка: ДАТА и СТОЛ №
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    _buildLabel('ДАТА:'),
                    const SizedBox(width: 6),
                    _buildValue(
                      widget.gameState.gameDate?.toString().substring(0, 10) ??
                          DateTime.now().toString().substring(0, 10),
                    ),
                  ],
                ),
                Row(
                  children: [
                    _buildLabel('СТОЛ №'),
                    const SizedBox(width: 4),
                    _buildValue('${widget.gameState.tableNumber ?? 1}'),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 8),
            // Третья строка: ВРЕМЯ и ИГРА №
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    _buildLabel('ВРЕМЯ:'),
                    const SizedBox(width: 6),
                    _buildValue(
                      startTime != null ? _formatTime(startTime) : '--:--',
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '—',
                      style: TextStyle(
                        color: Colors.grey.shade500,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(width: 8),
                    _buildValue(_formatTime(endTime)),
                  ],
                ),
                Row(
                  children: [
                    _buildLabel('ИГРА №'),
                    const SizedBox(width: 4),
                    _buildValue('${widget.gameState.gameNumber ?? 1}'),
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

  Widget _buildValue(String text) {
    return Text(
      text,
      style: const TextStyle(
        color: Colors.white,
        fontSize: 14,
        fontWeight: FontWeight.w500,
      ),
    );
  }

  String _formatTime(DateTime time) {
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
  }

  Widget _buildVotingTable() {
    final voteHistory = widget.gameState.voteHistory;

    if (voteHistory.isEmpty) {
      return Card(
        color: Colors.grey.shade800,
        child: const Padding(
          padding: EdgeInsets.all(16),
          child: Text(
            'Голосования не проводились',
            style: TextStyle(color: Colors.white),
          ),
        ),
      );
    }

    final Map<int, List<Map<int, int>>> groupedVotes = {};
    for (var record in voteHistory) {
      final day = record[11] ?? 0;
      if (!groupedVotes.containsKey(day)) {
        groupedVotes[day] = [];
      }
      groupedVotes[day]!.add(record);
    }

    final sortedDays = groupedVotes.keys.toList()..sort();

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
            ...sortedDays.map((day) {
              final records = groupedVotes[day]!;
              return Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'День $day',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    ...records.asMap().entries.map((entry) {
                      final roundIndex = entry.key;
                      final record = entry.value;

                      final votes = <int, int>{};
                      final winners = <int>[];
                      for (var key in record.keys) {
                        if (key != 11 && (key < 12 || key > 15)) {
                          votes[key] = record[key]!;
                        }
                        if (key >= 12 && key <= 15) {
                          winners.add(record[key]!);
                        }
                      }

                      final candidates = votes.keys.toList()..sort();

                      String roundTitle;
                      if (roundIndex == 0) {
                        roundTitle = 'Голосование';
                      } else if (roundIndex == 1) {
                        roundTitle = 'Переголосование';
                      } else {
                        roundTitle = 'Голосование за подъём';
                      }

                      // ============ ГОЛОСОВАНИЕ ЗА ПОДЪЁМ ============
                      if (roundIndex == 2) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                roundTitle,
                                style: const TextStyle(
                                  color: Colors.white70,
                                  fontSize: 12,
                                  fontStyle: FontStyle.italic,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  border:
                                      Border.all(color: Colors.grey.shade600),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const Text(
                                      'Результат:',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 13,
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      winners.isEmpty ? '0' : winners.join(','),
                                      style: TextStyle(
                                        color: winners.isEmpty
                                            ? Colors.red
                                            : Colors.green,
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        );
                      }

                      // ============ ГОЛОСОВАНИЕ И ПЕРЕГОЛОСОВАНИЕ ============
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              roundTitle,
                              style: const TextStyle(
                                color: Colors.white70,
                                fontSize: 12,
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                border: Border.all(color: Colors.grey.shade600),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Table(
                                border: TableBorder.all(
                                    color: Colors.grey.shade600),
                                columnWidths: const {
                                  0: FixedColumnWidth(50),
                                  1: FixedColumnWidth(50),
                                  2: FixedColumnWidth(70),
                                },
                                children: [
                                  TableRow(
                                    decoration: BoxDecoration(
                                        color: Colors.grey.shade700),
                                    children: [
                                      _tableCell('Игрок', isHeader: true),
                                      _tableCell('Голоса', isHeader: true),
                                      _tableCell('Результат', isHeader: true),
                                    ],
                                  ),
                                  ...candidates.map((seat) {
                                    final voteCount = votes[seat] ?? 0;
                                    final isWinner = winners.contains(seat);
                                    return TableRow(
                                      children: [
                                        _tableCell('$seat'),
                                        _tableCell('$voteCount'),
                                        _tableCell(
                                          isWinner ? '$seat' : '0',
                                          isWinner: isWinner,
                                        ),
                                      ],
                                    );
                                  }).toList(),
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    }),
                  ],
                ),
              );
            }),
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

  Widget _tableCell(String text,
      {bool isHeader = false, bool isWinner = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 4),
      child: Text(
        text,
        style: TextStyle(
          color: isHeader
              ? Colors.orange
              : (isWinner ? Colors.green : Colors.white),
          fontWeight:
              isHeader || isWinner ? FontWeight.bold : FontWeight.normal,
          fontSize: 12,
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
    final fullNights = (nightActions.length ~/ 3) * 3;
    for (int i = 0; i < fullNights; i += 3) {
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

    final judgeName = widget.gameState.judgeName ?? '___________________';

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
            Divider(color: Colors.grey.shade600, height: 8),
            _infoRow('СУДЬЯ', judgeName),
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

    if (voteHistory.isEmpty) {
      return Card(
        color: Colors.grey.shade800,
        child: const Padding(
          padding: EdgeInsets.all(16),
          child: Text(
            'Голосования не проводились',
            style: TextStyle(color: Colors.white),
          ),
        ),
      );
    }

    // Группируем по дням (ключ 11)
    final Map<int, List<Map<int, int>>> groupedVotes = {};
    for (var record in voteHistory) {
      final day = record[11] ?? 0;
      if (!groupedVotes.containsKey(day)) {
        groupedVotes[day] = [];
      }
      groupedVotes[day]!.add(record);
    }

    // Сортируем по дням
    final sortedDays = groupedVotes.keys.toList()..sort();

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
            ...sortedDays.map((day) {
              final records = groupedVotes[day]!;
              return Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'День $day',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    ...records.asMap().entries.map((entry) {
                      final roundIndex = entry.key;
                      final record = entry.value;

                      // Извлекаем голоса кандидатов (все ключи кроме 11 и 12-15)
                      final votes = <int, int>{};
                      final winners = <int>[];
                      for (var key in record.keys) {
                        if (key != 11 && (key < 12 || key > 15)) {
                          votes[key] = record[key]!;
                        }
                        if (key >= 12 && key <= 15) {
                          winners.add(record[key]!);
                        }
                      }

                      final candidates = votes.keys.toList()..sort();
                      final maxVotes = votes.isNotEmpty
                          ? votes.values.reduce((a, b) => a > b ? a : b)
                          : 0;

                      String roundTitle;
                      if (roundIndex == 0) {
                        roundTitle = 'Голосование';
                      } else if (roundIndex == 1) {
                        roundTitle = 'Переголосование';
                      } else {
                        roundTitle = 'Голосование за подъём';
                      }

                      return Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              roundTitle,
                              style: const TextStyle(
                                color: Colors.white70,
                                fontSize: 12,
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                border: Border.all(color: Colors.grey.shade600),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Table(
                                border: TableBorder.all(
                                    color: Colors.grey.shade600),
                                columnWidths: const {
                                  0: FixedColumnWidth(50),
                                  1: FixedColumnWidth(50),
                                  2: FixedColumnWidth(70),
                                },
                                children: [
                                  TableRow(
                                    decoration: BoxDecoration(
                                        color: Colors.grey.shade700),
                                    children: [
                                      _tableCell('Игрок', isHeader: true),
                                      _tableCell('Голоса', isHeader: true),
                                      _tableCell('Результат', isHeader: true),
                                    ],
                                  ),
                                  ...candidates.map((seat) {
                                    final voteCount = votes[seat] ?? 0;
                                    final isWinner = winners.contains(seat);
                                    return TableRow(
                                      children: [
                                        _tableCell('$seat'),
                                        _tableCell('$voteCount'),
                                        _tableCell(
                                          isWinner ? '$seat' : '0',
                                          isWinner: isWinner,
                                        ),
                                      ],
                                    );
                                  }).toList(),
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    }),
                  ],
                ),
              );
            }),
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
