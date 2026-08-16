// lib/presentation/screens/game/game_protocol_view_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mafia_help/services/club_service.dart';

class GameProtocolViewScreen extends ConsumerStatefulWidget {
  final int? gameId;
  final Map<String, dynamic>? gameData;

  const GameProtocolViewScreen({
    super.key,
    this.gameId,
    this.gameData,
  });

  @override
  ConsumerState<GameProtocolViewScreen> createState() =>
      _GameProtocolViewScreenState();
}

class _GameProtocolViewScreenState
    extends ConsumerState<GameProtocolViewScreen> {
  Map<String, dynamic>? _gameData;
  bool _isLoading = true;
  String? _error;
  bool _isFromServer = false;

  @override
  void initState() {
    super.initState();

    if (widget.gameData != null) {
      _gameData = widget.gameData;
      _isLoading = false;
    } else if (widget.gameId != null) {
      _isFromServer = true;
      _loadGame();
    } else {
      _error = 'Нет данных для отображения';
      _isLoading = false;
    }
  }

  Future<void> _loadGame() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    final result = await ClubService.getGame(widget.gameId!);

    if (result['success']) {
      setState(() {
        _gameData = result['data'];
        _isLoading = false;
      });
    } else {
      setState(() {
        _error = result['error'] ?? 'Ошибка загрузки';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('Протокол игры'),
        backgroundColor: theme.appBarTheme.backgroundColor,
        foregroundColor: theme.appBarTheme.foregroundColor,
        actions: [
          if (_isFromServer)
            IconButton(
              icon: Icon(Icons.refresh,
                  color: isDark ? Colors.white : Colors.black87),
              onPressed: _loadGame,
            ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.error_outline,
                        size: 64,
                        color: Colors.red.shade300,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        _error!,
                        style: TextStyle(
                          color: isDark ? Colors.white70 : Colors.black54,
                          fontSize: 16,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      if (_isFromServer) ...[
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: _loadGame,
                          child: const Text('Повторить'),
                        ),
                      ],
                    ],
                  ),
                )
              : _gameData == null
                  ? const Center(child: Text('Нет данных'))
                  : _buildContent(),
    );
  }

  Widget _buildContent() {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final game = _gameData!;
    final primaryColor = theme.primaryColor;

    final startTime = game['date'] != null
        ? DateTime.tryParse(game['date'].toString())
        : null;
    final endTime = DateTime.now();

    final players = game['players'] as List? ?? [];
    final nightActions = game['night_actions'] as List? ?? [];
    final voteHistory = game['vote_history'] != null
        ? Map<String, dynamic>.from(game['vote_history'] as Map)
        : <String, dynamic>{};

    final winner = game['winner'] == 'red'
        ? 'КРАСНЫЕ'
        : game['winner'] == 'black'
            ? 'ЧЁРНЫЕ'
            : 'НИЧЬЯ';
    final winnerColor = game['winner'] == 'red'
        ? Colors.red
        : game['winner'] == 'black'
            ? Colors.black
            : Colors.grey;

    return SingleChildScrollView(
      padding: const EdgeInsets.only(top: 16, left: 16, right: 16, bottom: 100),
      child: Column(
        children: [
          // ============================================================
          // HEADER
          // ============================================================
          Card(
            color: theme.cardColor,
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
                      _buildLabel(context, 'ТУРНИР'),
                      const SizedBox(width: 6),
                      Expanded(
                        child: _buildValue(
                          context,
                          game['tournament'] ?? 'РЕЙТИНГ',
                        ),
                      ),
                      const SizedBox(width: 20),
                      _buildLabel(context, 'СТАДИЯ'),
                      const SizedBox(width: 6),
                      Expanded(
                        child: _buildValue(context, game['stage'] ?? ''),
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
                          _buildLabel(context, 'ДАТА:'),
                          const SizedBox(width: 6),
                          _buildValue(
                            context,
                            startTime != null
                                ? startTime.toString().substring(0, 10)
                                : DateTime.now().toString().substring(0, 10),
                            width: 120,
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          _buildLabel(context, 'СТОЛ №'),
                          const SizedBox(width: 4),
                          _buildValue(
                            context,
                            '${game['table'] ?? 1}',
                            width: 40,
                          ),
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
                          _buildLabel(context, 'ВРЕМЯ:'),
                          const SizedBox(width: 6),
                          _buildValue(
                            context,
                            startTime != null
                                ? '${startTime.hour.toString().padLeft(2, '0')}:${startTime.minute.toString().padLeft(2, '0')}'
                                : '--:--',
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
                          _buildValue(
                            context,
                            '${endTime.hour.toString().padLeft(2, '0')}:${endTime.minute.toString().padLeft(2, '0')}',
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          _buildLabel(context, 'ИГРА №'),
                          const SizedBox(width: 4),
                          _buildValue(
                            context,
                            '${game['game'] ?? 1}',
                            width: 40,
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Судья: ${game['judge'] ?? 'Неизвестен'}',
                    style: TextStyle(
                      color: isDark ? Colors.white70 : Colors.black54,
                      fontSize: 14,
                    ),
                  ),
                  if (game['best_move'] != null &&
                      game['best_move'].toString().isNotEmpty)
                    Text(
                      'Лучший ход: ${game['best_move']}',
                      style: TextStyle(
                        color: isDark ? Colors.white70 : Colors.black54,
                        fontSize: 14,
                      ),
                    ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 2),

          // ============================================================
          // ИГРОКИ
          // ============================================================
          Card(
            color: theme.cardColor,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: BorderSide(
                color: isDark ? Colors.grey.shade700 : Colors.grey.shade300,
                width: 0.5,
              ),
            ),
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
                        border: TableBorder(
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
                          // Заголовок
                          TableRow(
                            decoration: BoxDecoration(
                              border: Border(
                                bottom: BorderSide(
                                  color: isDark
                                      ? Colors.grey.shade600
                                      : Colors.grey.shade400,
                                  width: 1,
                                ),
                              ),
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
                          // Игроки
                          ...players.map((p) {
                            final isRedWon = game['winner'] == 'red';
                            final points = (isRedWon &&
                                        (p['role'] == 'citizen' ||
                                            p['role'] == 'sheriff')) ||
                                    (!isRedWon &&
                                        (p['role'] == 'mafia' ||
                                            p['role'] == 'don'))
                                ? 1
                                : 0;
                            final bonus = (p['bonus'] ?? 0.0).toDouble();
                            final isRemoved = p['rule'] != null &&
                                p['rule'].toString().isNotEmpty;
                            final hasPpk = false;

                            return TableRow(
                              children: [
                                _tableCell(context, '${p['seat']}'),
                                _tableCell(context, p['name'] ?? ''),
                                _buildRoleCell(context, p['role'], isDark),
                                _tableCell(context, '${p['fouls'] ?? 0}'),
                                _tableCell(context, '$points'),
                                _buildBonusCell(
                                  context,
                                  bonus,
                                  isRemoved,
                                  hasPpk,
                                  isDark,
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
          ),

          const SizedBox(height: 2),

          // ============================================================
          // INFO ROW
          // ============================================================
          Card(
            color: theme.cardColor,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: BorderSide(
                color: isDark ? Colors.grey.shade700 : Colors.grey.shade300,
                width: 0.5,
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                children: [
                  _infoRow(
                    context,
                    'ПОБЕДИВШАЯ КОМАНДА    ',
                    winner,
                    color: winnerColor,
                  ),
                  Divider(
                    color: isDark ? Colors.grey.shade600 : Colors.grey.shade300,
                    height: 16,
                  ),
                  _infoRow(
                    context,
                    'ЛУЧШИЙ ХОД    ',
                    game['best_move'] ?? '_  _  _',
                  ),
                  Divider(
                    color: isDark ? Colors.grey.shade600 : Colors.grey.shade300,
                    height: 8,
                  ),
                  _infoRow(
                    context,
                    'СУДЬЯ      ',
                    game['judge'] ?? 'Неизвестен',
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
                  if (nightActions.isEmpty)
                    const Text(
                      'Нет данных',
                      style: TextStyle(color: Colors.white70, fontSize: 12),
                    )
                  else
                    _buildNightActionsTable(context, nightActions, isDark),
                ],
              ),
            ),
          ),

          const SizedBox(height: 2),

          // ============================================================
          // VOTING TABLE
          // ============================================================
          _buildVotingTable(context, voteHistory, isDark),
        ],
      ),
    );
  }

  // ============================================================
  // HELPER WIDGETS
  // ============================================================

  Widget _buildLabel(BuildContext context, String text) {
    final theme = Theme.of(context);
    final primaryColor = theme.primaryColor;

    return Text(
      text,
      style: TextStyle(
        color: primaryColor,
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

  Widget _buildRoleCell(BuildContext context, String? role, bool isDark) {
    Color bgColor;
    String short;

    switch (role) {
      case 'citizen':
        bgColor = Colors.red.withOpacity(0.7);
        short = 'К';
        break;
      case 'mafia':
        bgColor = Colors.black;
        short = 'Ч';
        break;
      case 'sheriff':
        bgColor = Colors.orange.withOpacity(0);
        short = 'Ш';
        break;
      case 'don':
        bgColor = Colors.purple;
        short = 'Д';
        break;
      default:
        bgColor = Colors.grey;
        short = '?';
    }

    final textColor = isDark ? Colors.white : Colors.black;

    return Container(
      width: 30,
      height: 24,
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Center(
        child: Text(
          short,
          style: TextStyle(
            color: textColor,
            fontWeight: FontWeight.bold,
            fontSize: 12,
          ),
        ),
      ),
    );
  }

  Widget _buildBonusCell(
    BuildContext context,
    double bonus,
    bool isRemoved,
    bool hasPpk,
    bool isDark,
  ) {
    String text;
    Color? color;

    if (hasPpk) {
      text = '-1';
      color = Colors.red;
    } else if (isRemoved) {
      text = '-0.5';
      color = Colors.red;
    } else if (bonus == 0) {
      text = '0';
      color = null;
    } else {
      text = bonus.toStringAsFixed(1);
      color = bonus > 0 ? Colors.green : Colors.red;
    }

    return Container(
      height: 24,
      alignment: Alignment.center,
      child: Text(
        text,
        style: TextStyle(
          color: color ?? (isDark ? Colors.white : Colors.black87),
          fontSize: 11,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _infoRow(BuildContext context, String label, String value,
      {Color? color}) {
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
            child: Text(
              value,
              style: TextStyle(
                color: color ?? (isDark ? Colors.white : Colors.black87),
                fontSize: 13,
                fontWeight: color != null ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNightActionsTable(
    BuildContext context,
    List<dynamic> nightActions,
    bool isDark,
  ) {
    return Container(
      width: double.infinity,
      child: Table(
        border: TableBorder.all(
          color: isDark ? Colors.grey.shade600 : Colors.grey.shade300,
          width: 0.5,
        ),
        columnWidths: {
          0: const FixedColumnWidth(50),
          for (int i = 0; i < nightActions.length; i++)
            i + 1: const FixedColumnWidth(40),
        },
        children: [
          TableRow(
            decoration: BoxDecoration(
              color: isDark ? Colors.grey.shade700 : Colors.grey.shade200,
            ),
            children: [
              _tableCell(context, 'Ночь', isHeader: true),
              ...nightActions.map(
                  (n) => _tableCell(context, '${n['night']}', isHeader: true)),
            ],
          ),
          TableRow(
            children: [
              _tableCell(context, 'Стрельба', isHeader: true),
              ...nightActions
                  .map((n) => _tableCell(context, _getNightValue(n['kill']))),
            ],
          ),
          TableRow(
            children: [
              _tableCell(context, 'Дон', isHeader: true),
              ...nightActions
                  .map((n) => _tableCell(context, _getNightValue(n['don']))),
            ],
          ),
          TableRow(
            children: [
              _tableCell(context, 'Шериф', isHeader: true),
              ...nightActions.map(
                  (n) => _tableCell(context, _getNightValue(n['sheriff']))),
            ],
          ),
        ],
      ),
    );
  }

  String _getNightValue(dynamic value) {
    if (value == null) return '0';
    final v = value is int ? value : int.tryParse(value.toString()) ?? 0;
    return v == 0 || v == -1 ? '0' : v.toString();
  }

  // ============================================================
  // VOTING TABLE
  // ============================================================

  Widget _buildVotingTable(
    BuildContext context,
    Map<String, dynamic> voteHistory,
    bool isDark,
  ) {
    if (voteHistory.isEmpty) {
      return Card(
        color: Theme.of(context).cardColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(
            color: isDark ? Colors.grey.shade700 : Colors.grey.shade300,
            width: 0.5,
          ),
        ),
        child: const Padding(
          padding: EdgeInsets.all(16),
          child: Text(
            'Голосования не проводились',
            style: TextStyle(color: Colors.white),
          ),
        ),
      );
    }

    final days = voteHistory.keys.toList()
      ..sort((a, b) => int.parse(a).compareTo(int.parse(b)));

    return Card(
      color: Theme.of(context).cardColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: isDark ? Colors.grey.shade700 : Colors.grey.shade300,
          width: 0.5,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Голосования',
              style: TextStyle(
                color: Theme.of(context).primaryColor,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            ...days.map((dayKey) {
              final dayData = voteHistory[dayKey] as Map<String, dynamic>;
              final day = int.parse(dayKey);
              final voteNumber = day + 1;
              final rounds = dayData['rounds'] as List? ?? [];
              final result = dayData['result'] as List? ?? [];
              final eliminationVotes = dayData['eliminationVotes'] ?? 0;

              return Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    border: Border.all(
                      color:
                          isDark ? Colors.grey.shade600 : Colors.grey.shade300,
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
                      if (rounds.isEmpty) ...[
                        const Text(
                          'На голосование никто не выставлен',
                          style: TextStyle(
                            color: Colors.orange,
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
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
                              '0',
                              style: TextStyle(
                                color: isDark ? Colors.white54 : Colors.black38,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ] else ...[
                        ...rounds.asMap().entries.map((entry) {
                          final roundIndex = entry.key;
                          final round = entry.value as Map<String, dynamic>;
                          final label =
                              roundIndex == 0 ? 'Игрок' : 'Переголосование';
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 6),
                            child: _buildVoteRow(
                              context,
                              label,
                              round,
                              roundIndex,
                              isDark,
                            ),
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
                              result.isNotEmpty ? result.join(', ') : '0',
                              style: TextStyle(
                                color: result.isNotEmpty
                                    ? Colors.green
                                    : (isDark
                                        ? Colors.white54
                                        : Colors.black38),
                                fontSize: 14,
                                fontWeight: result.isNotEmpty
                                    ? FontWeight.bold
                                    : FontWeight.normal,
                              ),
                            ),
                          ],
                        ),
                      ],
                      if (eliminationVotes > 0)
                        Text(
                          'Голосование за подъём: $eliminationVotes',
                          style: TextStyle(
                            color: Theme.of(context).primaryColor,
                            fontSize: 12,
                          ),
                        ),
                    ],
                  ),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildVoteRow(
    BuildContext context,
    String label,
    Map<String, dynamic> votes,
    int roundIndex,
    bool isDark,
  ) {
    final sortedKeys = votes.keys.toList()
      ..sort((a, b) => int.parse(a).compareTo(int.parse(b)));

    final String firstRowLabel = roundIndex == 0 ? 'Игрок' : 'Пере-';
    final String secondRowLabel = roundIndex == 0 ? 'Голоса' : 'голос.';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            SizedBox(
              width: 60,
              child: Text(
                firstRowLabel,
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
                  player,
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
                secondRowLabel,
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
                final value = votes[player] ?? 0;
                return Text(
                  '$value',
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
}
