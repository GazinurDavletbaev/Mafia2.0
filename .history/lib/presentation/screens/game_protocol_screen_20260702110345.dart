import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

import 'package:flutter/material.dart';
import 'package:mafia_help/data/local/models/player_model.dart';
import 'package:mafia_help/presentation/screens/saved_protocols_screen.dart';
import 'package:mafia_help/presentation/state/vote_day.dart';
import 'package:path_provider/path_provider.dart';
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
  // ✅ 10 полей для пояснений
  final List<TextEditingController> _noteControllers =
      List.generate(10, (_) => TextEditingController());
  final TextEditingController _protestCommentController =
      TextEditingController();
  String _protestText = 'Нет';

  List<int> _points = [];
  List<double> _bonusPoints = [];
  final Map<int, String> _removedRuleMap = {};

  // Контроллеры для редактируемых полей
  final _tournamentController = TextEditingController();
  final _stageController = TextEditingController();
  final _tableController = TextEditingController();
  final _gameController = TextEditingController();
  final _dateController = TextEditingController();
  final _judgeController = TextEditingController();
  final _bestMoveController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // ===== ВЫВОД voteHistory =====
    print('=== PROTOCOL SCREEN: voteHistory ===');
    print('voteHistory: ${widget.gameState.voteHistory}');
    print('voteHistory:');
    if (widget.gameState.voteHistory.isEmpty) {
      print('  (пусто)');
    } else {
      widget.gameState.voteHistory.forEach((day, voteDay) {
        print('  День $day:');
        print('    rounds:');
        for (var i = 0; i < voteDay.rounds.length; i++) {
          print('      Раунд ${i + 1}: ${voteDay.rounds[i]}');
        }
        print('    eliminated: ${voteDay.eliminated}');
        print('    eliminationVotes: ${voteDay.eliminationVotes}');
        print('    result: ${voteDay.result}');
      });
    }
    print('========================================');

    // ===== КОНЕЦ ЛОГОВ =====
    _bonusPoints = List.generate(10, (_) => 0.0);
    // Заполняем контроллеры
    _tournamentController.text = widget.gameState.tournamentName ?? '';
    _stageController.text = widget.gameState.stageName ?? '';
    _tableController.text = '${widget.gameState.tableNumber ?? 1}';
    _gameController.text = '${widget.gameState.gameNumber ?? 1}';
    _dateController.text =
        widget.gameState.gameDate?.toString().substring(0, 10) ??
            DateTime.now().toString().substring(0, 10);
    _judgeController.text = widget.gameState.judgeName ?? '';
    _bestMoveController.text = widget.gameState.partialBestMove.join(', ');

    final isRedWon = widget.gameState.winner == 'red';
    _points = widget.gameState.players.map((p) {
      if (isRedWon) {
        return p.team == 'red' ? 1 : 0;
      } else {
        return p.team == 'black' ? 1 : 0;
      }
    }).toList();
    for (var p in widget.gameState.removedPlayers) {
      _removedRuleMap[p.seatNumber] = '';
    }
  }

  @override
  void dispose() {
    for (var c in _noteControllers) {
      c.dispose();
    }
    _protestCommentController.dispose();
    _tournamentController.dispose();
    _stageController.dispose();
    _tableController.dispose();
    _gameController.dispose();
    _dateController.dispose();
    _judgeController.dispose();
    _bestMoveController.dispose();
  }

  Widget _buildEditableField(TextEditingController controller,
      {double? width}) {
    return SizedBox(
      width: width,
      child: TextField(
        controller: controller,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
        decoration: InputDecoration(
          border: InputBorder.none,
          isDense: true,
          contentPadding: EdgeInsets.zero,
          hintStyle: TextStyle(color: Colors.grey.shade600),
        ),
      ),
    );
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
            icon: const Icon(Icons.folder_open),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const SavedProtocolsScreen(),
                ),
              );
            },
          ),
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
            Row(
              children: [
                _buildLabel('ТУРНИР'),
                const SizedBox(width: 6),
                Expanded(
                  child: _buildEditableField(_tournamentController),
                ),
                const SizedBox(width: 20),
                _buildLabel('СТАДИЯ'),
                const SizedBox(width: 6),
                Expanded(
                  child: _buildEditableField(_stageController),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Divider(color: Colors.grey.shade700, height: 1),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    _buildLabel('ДАТА:'),
                    const SizedBox(width: 6),
                    _buildEditableField(_dateController, width: 120),
                  ],
                ),
                Row(
                  children: [
                    _buildLabel('СТОЛ №'),
                    const SizedBox(width: 4),
                    _buildEditableField(_tableController, width: 40),
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
                    _buildEditableField(_gameController, width: 40),
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
            LayoutBuilder(
              builder: (context, constraints) {
                final totalWidth = constraints.maxWidth;
                final fixedWidths = 28 + 40 + 45 + 50 + 50;
                final nameWidth = totalWidth - fixedWidths - 10;

                return Table(
                  border:
                      TableBorder.all(color: Colors.grey.shade600, width: 0.5),
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
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBonusPointsCell(int index) {
    final player = widget.gameState.players[index];
    final isRemoved = widget.gameState.removedPlayers
        .any((p) => p.seatNumber == player.seatNumber);

    final ruleOptions = [
      'п.8.4.1',
      'п.8.4.2',
      'п.8.4.3',
      'п.8.5.1',
      'п.8.5.2',
    ];

    if (isRemoved) {
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
              dropdownColor: Colors.grey.shade800,
              style: const TextStyle(
                color: Colors.white,
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
              items: ruleOptions.map((rule) {
                return DropdownMenuItem<String>(
                  value: rule,
                  alignment: AlignmentDirectional.center,
                  child: Text(
                    rule,
                    style: const TextStyle(fontSize: 11, color: Colors.white),
                    textAlign: TextAlign.center,
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                );
              }).toList(),
              onChanged: (newValue) {
                setState(() {
                  _removedRuleMap[player.seatNumber] = newValue ?? '';
                  if (newValue != null && newValue.isNotEmpty) {
                    _addRemovedNote(player, newValue);
                  }
                });
              },
            ),
          ),
        ),
      );
    }

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
                _addBonusNote(index, newValue);
              });
            },
          ),
        ),
      ),
    );
  }

  void _addRemovedNote(PlayerModel player, String rule) {
    final note =
        'Игрок ${player.seatNumber} (${player.name}) был удален по $rule.';

    // Проверяем, есть ли уже запись об этом игроке
    for (int i = 0; i < _noteControllers.length; i++) {
      final text = _noteControllers[i].text;
      if (text.contains('Игрок ${player.seatNumber}') &&
          text.contains('удален')) {
        // Обновляем существующую запись
        _noteControllers[i].text = note;
        return;
      }
    }

    // Ищем свободную строку
    for (int i = 0; i < _noteControllers.length; i++) {
      if (_noteControllers[i].text.isEmpty) {
        _noteControllers[i].text = note;
        return;
      }
    }

    // Если все заняты — добавляем в первую пустую
    for (int i = 0; i < _noteControllers.length; i++) {
      if (_noteControllers[i].text.isEmpty) {
        _noteControllers[i].text = note;
        return;
      }
    }
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
            _infoRow('ПОБЕДИВШАЯ КОМАНДА    ', winner, color: winnerColor),
            Divider(color: Colors.grey.shade600, height: 16),
            _infoRow(
              'ПРОТЕСТ     ',
              _protestText,
              isEditable: true,
              controller: null,
            ),
            Divider(color: Colors.grey.shade600, height: 8),
            _infoRow('ЛУЧШИЙ ХОД    ', '$bestMoveText',
                suffix: '  Игрок № $bestPlayer'),
            Divider(color: Colors.grey.shade600, height: 8),
            _infoRow('СУДЬЯ      ', judgeName),
            Divider(color: Colors.grey.shade600, height: 8),
            const Text(
              'НОЧНЫЕ ДЕЙСТВИЯ',
              style: TextStyle(
                color: Colors.orange,
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
              Container(
                width: double.infinity,
                child: Table(
                  border:
                      TableBorder.all(color: Colors.grey.shade600, width: 0.5),
                  columnWidths: {
                    0: const FixedColumnWidth(50),
                    for (int i = 0; i < nights.length; i++)
                      i + 1: const FixedColumnWidth(40),
                  },
                  children: [
                    TableRow(
                      decoration: BoxDecoration(color: Colors.grey.shade700),
                      children: [
                        _tableCell('Ночь', isHeader: true),
                        ...nights
                            .map((n) =>
                                _tableCell('${n['night']}', isHeader: true))
                            .toList(),
                      ],
                    ),
                    TableRow(
                      children: [
                        _tableCell('Стрельба', isHeader: true),
                        ...nights
                            .map((n) => _tableCell(n['kill'] as String))
                            .toList(),
                      ],
                    ),
                    TableRow(
                      children: [
                        _tableCell('Дон', isHeader: true),
                        ...nights
                            .map((n) => _tableCell(n['don'] as String))
                            .toList(),
                      ],
                    ),
                    TableRow(
                      children: [
                        _tableCell('Шериф', isHeader: true),
                        ...nights
                            .map((n) => _tableCell(n['sheriff'] as String))
                            .toList(),
                      ],
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _infoRow(
    String label,
    String value, {
    Color? color,
    bool isEditable = false,
    String? suffix,
    TextEditingController? controller,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          Text(
            label,
            style: const TextStyle(
              color: Colors.orange,
              fontSize: 13,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: isEditable
                ? TextField(
                    controller: controller,
                    style: const TextStyle(color: Colors.white, fontSize: 13),
                    decoration: InputDecoration(
                      hintText: 'Нет',
                      hintStyle: TextStyle(color: Colors.grey.shade600),
                      border: InputBorder.none,
                      isDense: true,
                      contentPadding: EdgeInsets.zero,
                    ),
                    onChanged: (value) {
                      if (controller == null) {
                        setState(() {
                          _protestText = value.isEmpty ? 'Нет' : value;
                        });
                      }
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

    final days = voteHistory.keys.toList()..sort();

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
            ...days.map((day) {
              final dayData = voteHistory[day]!;
              final voteNumber = day + 1;
              return _buildVoteDayCard(day, dayData, voteNumber);
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildVoteDayCard(int day, VoteDay dayData, int voteNumber) {
    print('=== VOTEDAY $day ===');
    print('rounds: ${dayData.rounds}');
    print('result: ${dayData.result}');
    print('eliminated: ${dayData.eliminated}');
    print('eliminationVotes: ${dayData.eliminationVotes}');
    print('================================');
    final hasVoting = dayData.rounds.isNotEmpty;
    final hasResult = dayData.result.isNotEmpty;
    final lastRoundPlayers =
        hasVoting ? dayData.rounds.last.keys.toSet() : <int>{};
    // Проверяем, входит ли каждый игрок из result в список lastRoundPlayers
    final isRemoval = hasResult &&
        dayData.result.any((seat) => !lastRoundPlayers.contains(seat));
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade600),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              'ГОЛОСОВАНИЕ $voteNumber',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            if (hasVoting && is) ...[
              ...dayData.rounds.asMap().entries.map((entry) {
                final roundIndex = entry.key;
                final round = entry.value;
                final label = roundIndex == 0 ? 'Игрок' : 'Переголосование';
                return Padding(
                  padding: const EdgeInsets.only(bottom: 6),
                  child: _buildVoteRow(label, round, roundIndex),
                );
              }),
              const Divider(color: Colors.grey),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    'Результат: ',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 12,
                    ),
                  ),
                  Text(
                    dayData.result.isNotEmpty ? dayData.result.join(', ') : '0',
                    style: TextStyle(
                      color: dayData.result.isNotEmpty
                          ? Colors.green
                          : Colors.white54,
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
              const Text(
                'Удалены:',
                style: TextStyle(
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
                style: const TextStyle(
                  color: Colors.orange,
                  fontSize: 12,
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildVoteRow(String label, Map<int, int> votes, int roundIndex) {
    final sortedKeys = votes.keys.toList()..sort();

    final String firstRowLabel;
    final String secondRowLabel;

    if (roundIndex == 0) {
      firstRowLabel = 'Игрок';
      secondRowLabel = 'Голоса';
    } else {
      firstRowLabel = 'Пере-';
      secondRowLabel = 'голос.';
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            SizedBox(
              width: 60,
              child: Text(
                '$firstRowLabel',
                style: const TextStyle(
                  color: Colors.white70,
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
                  style: const TextStyle(
                    color: Colors.white,
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
                '$secondRowLabel',
                style: const TextStyle(
                  color: Colors.white70,
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
                  style: const TextStyle(
                    color: Colors.white,
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
            // ✅ 10 полей для пояснений
            ...List.generate(10, (index) {
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
            const SizedBox(height: 16),
            const Divider(color: Colors.grey),
            const SizedBox(height: 8),
            // ✅ Комментарий к протесту
            const Text(
              'КОММЕНТАРИЙ К ПРОТЕСТУ:',
              style: TextStyle(
                color: Colors.orange,
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            TextField(
              controller: _protestCommentController,
              style: const TextStyle(color: Colors.white, fontSize: 12),
              decoration: InputDecoration(
                hintText: 'Введите комментарий к протесту...',
                hintStyle: TextStyle(color: Colors.grey.shade600),
                border: InputBorder.none,
                isDense: true,
                contentPadding: EdgeInsets.zero,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _addBonusNote(int index, double value) {
    if (value == 0) return;

    final player = widget.gameState.players[index];
    final note =
        'Игрок ${player.seatNumber} (${player.name}) получил ${value.toStringAsFixed(1)} балла.';

    // ✅ Проверяем, есть ли уже запись об этом игроке
    for (int i = 0; i < _noteControllers.length; i++) {
      final text = _noteControllers[i].text;
      if (text.contains('Игрок ${player.seatNumber}') &&
          text.contains('получил')) {
        // Обновляем существующую запись
        _noteControllers[i].text = note;
        return;
      }
    }

    // ✅ Ищем ПЕРВУЮ ПОЛНОСТЬЮ ПУСТУЮ строку
    for (int i = 0; i < _noteControllers.length; i++) {
      if (_noteControllers[i].text.isEmpty) {
        _noteControllers[i].text = note;
        return;
      }
    }

    // ✅ Если все строки заняты — добавляем в первую строку, которая НЕ начинается с "Игрок"
    for (int i = 0; i < _noteControllers.length; i++) {
      final text = _noteControllers[i].text;
      if (!text.startsWith('Игрок')) {
        // Добавляем новую запись в конец существующего текста
        _noteControllers[i].text = text.isEmpty ? note : '$text\n$note';
        return;
      }
    }
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

  void _saveProtocol() async {
    final startTime = widget.gameState.gameDate;
    final endTime = DateTime.now();
    final timeString = startTime != null
        ? '${_formatTime(startTime)} — ${_formatTime(endTime)}'
        : '00:00 — 00:00';

    // ✅ Собираем данные из всех контроллеров
    final notes = _noteControllers.map((c) => c.text).toList();
    final protestComment = _protestCommentController.text;

    final data = {
      'tournament': _tournamentController.text,
      'stage': _stageController.text,
      'table': _tableController.text,
      'game': _gameController.text,
      'date': _dateController.text,
      'judge': _judgeController.text,
      'bestMove': _bestMoveController.text,
      'protest': _protestText,
      'winner': widget.gameState.winner,
      'time': timeString,
      'players': widget.gameState.players.map((p) {
        final isRemoved = widget.gameState.removedPlayers
            .any((rp) => rp.seatNumber == p.seatNumber);
        final bonus = isRemoved ? -0.5 : _bonusPoints[p.seatNumber - 1];
        final rule = isRemoved ? (_removedRuleMap[p.seatNumber] ?? '') : '';

        return {
          'seat': p.seatNumber,
          'name': p.name,
          'role': p.role,
          'fouls': p.fouls,
          'points': _points[p.seatNumber - 1],
          'bonus': bonus,
          'rule': rule,
        };
      }).toList(),
      'nightActions': widget.gameState.nightActions ?? [],
      'voteHistory': widget.gameState.voteHistory.map((day, dayData) {
        final rounds = dayData.rounds.map((round) {
          return round.map((key, value) => MapEntry(key.toString(), value));
        }).toList();

        return MapEntry(day.toString(), {
          'rounds': rounds,
          'eliminated': dayData.eliminated,
          'eliminationVotes': dayData.eliminationVotes,
          'result': dayData.result,
        });
      }),
      // ✅ Новые поля
      'notes': notes,
      'protestComment': protestComment,
    };

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: CircularProgressIndicator(),
      ),
    );
    print('=== SENDING DATA ===');
    print(jsonEncode(data));
    print('====================');
    try {
      final url =
          Uri.parse('http://161.104.46.234:8001/generate-protocol-excel');
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(data),
      );

      Navigator.pop(context);

      if (response.statusCode == 200) {
        final bytes = response.bodyBytes;
        final directory = await getApplicationDocumentsDirectory();
        final fileName =
            '${_dateController.text}_${_formatTime(DateTime.now()).replaceAll(':', '-')}_${_tableController.text}_${_gameController.text}.xlsx';
        final path = '${directory.path}/$fileName';
        final file = File(path);
        await file.writeAsBytes(bytes);

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('✅ Протокол сохранён'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ Ошибка: ${response.statusCode}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('❌ Ошибка: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}
