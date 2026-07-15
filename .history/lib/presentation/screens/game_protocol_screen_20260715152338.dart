import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mafia_help/application/providers/club_provider.dart';
import 'package:mafia_help/application/providers/game_provider.dart';
import 'package:mafia_help/application/providers/user_provider.dart';
import 'package:mafia_help/data/local/models/player_model.dart';
import 'package:mafia_help/presentation/screens/saved_protocols_screen.dart';
import 'package:mafia_help/presentation/state/vote_day.dart';
import 'package:mafia_help/services/auth_service.dart';
import 'package:path_provider/path_provider.dart';
import '../../domain/rules/game_history.dart';
import '../state/game_state.dart';

class GameProtocolScreen extends ConsumerStatefulWidget {
  final GameHistory gameHistory;
  final GameState gameState;

  const GameProtocolScreen({
    super.key,
    required this.gameHistory,
    required this.gameState,
  });

  @override
  ConsumerState<GameProtocolScreen> createState() => _GameProtocolScreenState();
}

class _GameProtocolScreenState extends ConsumerState<GameProtocolScreen> {
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
    super.dispose(); // ✅ ДОБАВЬ ЭТУ СТРОКУ
  }

  Widget _buildEditableField(TextEditingController controller,
      {double? width}) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return SizedBox(
      width: width,
      child: TextField(
        controller: controller,
        style: TextStyle(
          color: theme.textTheme.bodyLarge?.color ?? Colors.white,
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
        decoration: InputDecoration(
          border: InputBorder.none,
          isDense: true,
          contentPadding: EdgeInsets.zero,
          hintStyle: TextStyle(
            color: isDark ? Colors.grey.shade600 : Colors.grey.shade400,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final savedGameId = ref.watch(savedGameIdProvider);
    final savedGameIdNotifier = ref.read(savedGameIdProvider.notifier);
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('Протокол игры'),
        backgroundColor: theme.appBarTheme.backgroundColor,
        foregroundColor: theme.appBarTheme.foregroundColor,
        actions: [
          IconButton(
            icon: Icon(
              Icons.folder_open,
              color: isDark ? Colors.white : Colors.black87,
            ),
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
            icon: Icon(
              Icons.save,
              color: isDark ? Colors.white : Colors.black87,
            ),
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
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final startTime = widget.gameState.gameDate;
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
                      theme,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '—',
                      style: TextStyle(
                        color: isDark
                            ? Colors.grey.shade500
                            : Colors.grey.shade400,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(width: 8),
                    _buildValue(_formatTime(endTime), theme),
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

  Widget _buildValue(String text, ThemeData theme) {
    final isDark = theme.brightness == Brightness.dark;

    return Text(
      text,
      style: TextStyle(
        color: isDark ? Colors.white : Colors.black87,
        fontSize: 14,
        fontWeight: FontWeight.w500,
      ),
    );
  }

  String _formatTime(DateTime time) {
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
  }

  Widget _buildPlayersTable() {
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
                        color: isDark
                            ? Colors.grey.shade700
                            : Colors.grey.shade200,
                      ),
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
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
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

    for (int i = 0; i < _noteControllers.length; i++) {
      final text = _noteControllers[i].text;
      if (text.contains('Игрок ${player.seatNumber}') &&
          text.contains('удален')) {
        _noteControllers[i].text = note;
        return;
      }
    }

    for (int i = 0; i < _noteControllers.length; i++) {
      if (_noteControllers[i].text.isEmpty) {
        _noteControllers[i].text = note;
        return;
      }
    }

    for (int i = 0; i < _noteControllers.length; i++) {
      if (_noteControllers[i].text.isEmpty) {
        _noteControllers[i].text = note;
        return;
      }
    }
  }

  Widget _buildPointsCell(int index) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 0, horizontal: 0),
      child: Container(
        height: 24,
        alignment: Alignment.center,
        child: Text(
          '${_points[index]}',
          style: TextStyle(
            color: isDark ? Colors.white : Colors.black87,
            fontSize: 11,
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

  Widget _tableCell(String text,
      {bool isHeader = false, bool isWinner = false}) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 4),
      child: Text(
        text,
        style: TextStyle(
          color: isHeader
              ? Colors.orange
              : (isWinner
                  ? Colors.green
                  : (isDark ? Colors.white : Colors.black87)),
          fontWeight:
              isHeader || isWinner ? FontWeight.bold : FontWeight.normal,
          fontSize: 12,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget _buildInfoRow() {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final winner = widget.gameState.winner == 'red' ? 'КРАСНЫЕ' : 'ЧЁРНЫЕ';
    final winnerColor =
        widget.gameState.winner == 'red' ? Colors.red : Colors.black;
    final userAsync = ref.watch(userProvider);

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

    return Card(
      color: isDark ? Colors.grey.shade800 : Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            _infoRow('ПОБЕДИВШАЯ КОМАНДА    ', winner, color: winnerColor),
            Divider(
              color: isDark ? Colors.grey.shade600 : Colors.grey.shade300,
              height: 16,
            ),
            _infoRow(
              'ПРОТЕСТ     ',
              _protestText,
              isEditable: true,
              controller: null,
            ),
            Divider(
              color: isDark ? Colors.grey.shade600 : Colors.grey.shade300,
              height: 8,
            ),
            _infoRow('ЛУЧШИЙ ХОД    ', '$bestMoveText',
                suffix: '  Игрок № $bestPlayer'),
            Divider(
              color: isDark ? Colors.grey.shade600 : Colors.grey.shade300,
              height: 8,
            ),
            _infoRow(
              'СУДЬЯ      ',
              userAsync.when(
                  data: (user) => user?['username'],
                  loading: () => 'loading',
                  error: (err, stack) => 'error'),
            ),
            Divider(
              color: isDark ? Colors.grey.shade600 : Colors.grey.shade300,
              height: 8,
            ),
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
                        color: isDark
                            ? Colors.grey.shade700
                            : Colors.grey.shade200,
                      ),
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
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

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
                    style: TextStyle(
                      color: isDark ? Colors.white : Colors.black87,
                      fontSize: 13,
                    ),
                    decoration: InputDecoration(
                      hintText: 'Нет',
                      hintStyle: TextStyle(
                        color: isDark
                            ? Colors.grey.shade600
                            : Colors.grey.shade400,
                      ),
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
                          color:
                              color ?? (isDark ? Colors.white : Colors.black87),
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

  Widget _buildVotingTable() {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final voteHistory = widget.gameState.voteHistory;
    if (voteHistory.isEmpty) {
      return Card(
        color: isDark ? Colors.grey.shade800 : Colors.white,
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
      color: isDark ? Colors.grey.shade800 : Colors.white,
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
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
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
    final isRemoval = hasResult &&
        dayData.result.any((seat) => !lastRoundPlayers.contains(seat));

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
            if (hasVoting && !isRemoval) ...[
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
                      fontWeight: dayData.result.isNotEmpty
                          ? FontWeight.bold
                          : FontWeight.normal,
                    ),
                  ),
                ],
              ),
            ] else ...[
              const SizedBox(height: 4),
              Text(
                'Удалены:',
                style: const TextStyle(
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
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
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
                style: TextStyle(
                  color: isDark ? Colors.white70 : Colors.black54,
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
                  style: TextStyle(
                    color: isDark ? Colors.white : Colors.black87,
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
                style: TextStyle(
                  color: isDark ? Colors.white70 : Colors.black54,
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
                  style: TextStyle(
                    color: isDark ? Colors.white : Colors.black87,
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
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Card(
      color: isDark ? Colors.grey.shade800 : Colors.white,
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
            ...List.generate(10, (index) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Row(
                  children: [
                    Text(
                      '${index + 1}. ',
                      style: TextStyle(
                        color: isDark ? Colors.white70 : Colors.black54,
                        fontSize: 12,
                      ),
                    ),
                    Expanded(
                      child: TextField(
                        controller: _noteControllers[index],
                        style: TextStyle(
                          color: isDark ? Colors.white : Colors.black87,
                          fontSize: 12,
                        ),
                        decoration: InputDecoration(
                          hintText: '___________________',
                          hintStyle: TextStyle(
                            color: isDark
                                ? Colors.grey.shade600
                                : Colors.grey.shade400,
                          ),
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
            const Text(
              'КОММЕНТАРИЙ К ПРОТЕСТУ:',
              style: TextStyle(
                color: Colors.orange,
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            ConstrainedBox(
              constraints: const BoxConstraints(
                maxHeight: 120,
              ),
              child: TextFormField(
                controller: _protestCommentController,
                style: TextStyle(
                  color: isDark ? Colors.white : Colors.black87,
                  fontSize: 12,
                ),
                maxLines: null,
                expands: true,
                decoration: InputDecoration(
                  hintText: 'Введите комментарий к протесту...',
                  hintStyle: TextStyle(
                    color: isDark ? Colors.grey.shade600 : Colors.grey.shade400,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(
                      color:
                          isDark ? Colors.grey.shade600 : Colors.grey.shade300,
                    ),
                  ),
                  filled: true,
                  fillColor: isDark
                      ? Colors.grey.shade700.withOpacity(0.3)
                      : Colors.grey.shade200.withOpacity(0.5),
                  contentPadding: const EdgeInsets.all(8),
                ),
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

    for (int i = 0; i < _noteControllers.length; i++) {
      final text = _noteControllers[i].text;
      if (text.contains('Игрок ${player.seatNumber}') &&
          text.contains('получил')) {
        _noteControllers[i].text = note;
        return;
      }
    }

    for (int i = 0; i < _noteControllers.length; i++) {
      if (_noteControllers[i].text.isEmpty) {
        _noteControllers[i].text = note;
        return;
      }
    }

    for (int i = 0; i < _noteControllers.length; i++) {
      final text = _noteControllers[i].text;
      if (!text.startsWith('Игрок')) {
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
    final theme = Theme.of(context);
    final startTime = widget.gameState.gameDate;
    final endTime = DateTime.now();
    final timeString = startTime != null
        ? '${_formatTime(startTime)} — ${_formatTime(endTime)}'
        : '00:00 — 00:00';

    final notes = _noteControllers.map((c) => c.text).toList();
    final protestComment = _protestCommentController.text;

    // ========== 1. ПРОВЕРКА НА ДУБЛИКАТЫ ИМЁН ==========
    final playerNames =
        widget.gameState.players.map((p) => p.name.trim()).toList();
    final duplicates = <String>[];
    final seen = <String>{};

    for (final name in playerNames) {
      if (name.isEmpty) continue;
      if (seen.contains(name)) {
        duplicates.add(name);
      } else {
        seen.add(name);
      }
    }

    if (duplicates.isNotEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            '❌ Не может быть двух игроков с одинаковым именем: ${duplicates.join(", ")}',
          ),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 4),
        ),
      );
      return;
    }

    // ========== 2. ПОЛУЧАЕМ CLUB_ID ==========
    final clubAsync = ref.watch(clubProvider);
    final clubId = clubAsync.when(
      data: (club) => club?['id'] ?? 0,
      loading: () => 0,
      error: (_, __) => 0,
    );

    if (clubId == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('❌ Вы не состоите в клубе'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // ========== 3. ФОРМИРУЕМ ДАННЫЕ ==========
    final data = {
      'club_id': clubId,
      'tournament': _tournamentController.text,
      'stage': _stageController.text,
      'table': int.tryParse(_tableController.text) ?? 1,
      'game': int.tryParse(_gameController.text) ?? 1,
      'date': _dateController.text,
      'time': _formatTime(DateTime.now()),
      'judge': _judgeController.text,
      'bestMove': _bestMoveController.text,
      'protest': _protestText,
      'protestComment': protestComment,
      'winner': widget.gameState.winner,
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
      'notes': notes,
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
      // ========== 4. ПОЛУЧАЕМ ТОКЕН ==========
      final token = await AuthService.getToken();
      if (token == null) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('❌ Не авторизован'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      // ========== 5. СОХРАНЯЕМ ИЛИ ОБНОВЛЯЕМ ИГРУ ==========
      final savedGameId = ref.read(savedGameIdProvider);
    final savedGameIdNotifier = ref.read(savedGameIdProvider.notifier);

    String url;
    if (savedGameId != null) {
      url = 'http://161.104.46.234:8001/games/update/$savedGameId?token=$token';
      print('🔄 Обновляем игру ID: $savedGameId');
    } else {
      url = 'http://161.104.46.234:8001/games/save?token=$token';
      print('🆕 Создаём новую игру');
    }

      final saveResponse = await http.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(data),
      );

      print('📤 Save game status: ${saveResponse.statusCode}');
      print('📤 Save game body: ${saveResponse.body}');

      if (saveResponse.statusCode != 200) {
        Navigator.pop(context);
        final errorData = jsonDecode(saveResponse.body);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
                '❌ Ошибка сохранения: ${errorData['detail'] ?? 'Неизвестная ошибка'}'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      // ✅ Сохраняем game_id
      final responseData = jsonDecode(saveResponse.body);
    savedGameIdNotifier.state = responseData['game_id'];
    print('✅ Сохранён game_id: ${responseData['game_id']}');

      // ========== 6. ГЕНЕРИРУЕМ EXCEL ==========
      final excelResponse = await http.post(
        Uri.parse('http://161.104.46.234:8001/protocol/generate'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(data),
      );

      Navigator.pop(context);

      if (excelResponse.statusCode == 200) {
        final bytes = excelResponse.bodyBytes;
        final directory = await getApplicationDocumentsDirectory();
        final fileName =
            '${_dateController.text}_${_formatTime(DateTime.now()).replaceAll(':', '-')}_${_tableController.text}_${_gameController.text}.xlsx';
        final path = '${directory.path}/$fileName';
        final file = File(path);
        await file.writeAsBytes(bytes);

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ Игра сохранена в клуб и Excel создан!'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
                '⚠️ Игра сохранена, но Excel не создан: ${excelResponse.statusCode}'),
            backgroundColor: Colors.orange,
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
