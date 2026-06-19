import 'package:flutter/material.dart';
import '../../domain/rules/game_history.dart';
import '../state/game_state.dart';

class GameProtocolScreen extends StatelessWidget {
  final GameHistory gameHistory;
  final GameState gameState;

  const GameProtocolScreen({
    super.key,
    required this.gameHistory,
    required this.gameState,
  });

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
          _buildWinner(),
          const SizedBox(height: 16),
          _buildBestMove(),
          const SizedBox(height: 16),
          _buildShootAndProtest(),
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
                  'ДАТА: ${gameState.gameDate?.toString().substring(0, 10) ?? DateTime.now().toString().substring(0, 10)}',
                  style: const TextStyle(color: Colors.white, fontSize: 14),
                ),
              ],
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  'СТОЛ № ${gameState.tableNumber ?? 1}',
                  style: const TextStyle(color: Colors.white, fontSize: 14),
                ),
                Text(
                  'ИГРА № ${gameState.gameNumber ?? 1}',
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
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Игроки',
              style: TextStyle(
                color: Colors.orange,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Table(
              border: TableBorder.all(color: Colors.grey.shade600),
              columnWidths: const {
                0: FixedColumnWidth(30),
                1: FixedColumnWidth(80),
                2: FixedColumnWidth(60),
                3: FixedColumnWidth(40),
                4: FixedColumnWidth(50),
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
                ...gameState.players.map((p) => TableRow(
                      children: [
                        _tableCell('${p.seatNumber}'),
                        _tableCell(p.name),
                        _tableCell(_getRoleName(p.role)),
                        _tableCell('${p.fouls}'),
                        _tableCell('0'),
                        _tableCell('0'),
                      ],
                    )),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWinner() {
    final winner = gameState.winner == 'red' ? '🔴 КРАСНЫЕ' : '⚫ ЧЁРНЫЕ';
    return Card(
      color: Colors.grey.shade800,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'ПОБЕДИВШАЯ КОМАНДА: ',
              style: TextStyle(color: Colors.white, fontSize: 16),
            ),
            Text(
              winner,
              style: TextStyle(
                color: gameState.winner == 'red' ? Colors.red : Colors.black,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBestMove() {
    final bestMove = gameState.partialBestMove;
    if (bestMove.isEmpty) return const SizedBox.shrink();

    final nightActions = gameState.nightActions ?? [];
    int? killedPlayer;
    if (nightActions.length >= 3) {
      killedPlayer = nightActions[0];
    }

    return Card(
      color: Colors.grey.shade800,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Лучший ход',
              style: TextStyle(
                color: Colors.orange,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '${bestMove.join(', ')}',
              style: const TextStyle(color: Colors.white, fontSize: 16),
            ),
            if (killedPlayer != null)
              Text(
                'Игрок № $killedPlayer',
                style: const TextStyle(color: Colors.white70, fontSize: 14),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildShootAndProtest() {
    return Card(
      color: Colors.grey.shade800,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'СТРЕЛЬБА',
                    style: TextStyle(color: Colors.orange, fontSize: 16),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    gameState.hasKillInLastNight ? 'Была' : 'Не было',
                    style: const TextStyle(color: Colors.white, fontSize: 14),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  const Text(
                    'ПРОТЕСТ',
                    style: TextStyle(color: Colors.orange, fontSize: 16),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Нет',
                    style: TextStyle(color: Colors.white, fontSize: 14),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVotingTable() {
    final voteHistory = gameState.voteHistory;
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
                    ...candidates.asMap().entries.map((c) {
                      final seat = c.value;
                      final voteCount = votes[c.key];
                      return Padding(
                        padding: const EdgeInsets.only(left: 8),
                        child: Text(
                          'Игрок $seat: $voteCount голосов',
                          style: const TextStyle(color: Colors.white70),
                        ),
                      );
                    }).toList(),
                    const Divider(color: Colors.grey),
                  ],
                ),
              );
            }).toList(),
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
              gameState.judgeName ?? '___________________',
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
            const Text(
              '1. ______________________________',
              style: TextStyle(color: Colors.white70, fontSize: 12),
            ),
            const Text(
              '2. ______________________________',
              style: TextStyle(color: Colors.white70, fontSize: 12),
            ),
            const Text(
              '3. ______________________________',
              style: TextStyle(color: Colors.white70, fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }

  Widget _tableCell(String text, {bool isHeader = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 4),
      child: Text(
        text,
        style: TextStyle(
          color: isHeader ? Colors.orange : Colors.white,
          fontWeight: isHeader ? FontWeight.bold : FontWeight.normal,
          fontSize: 12,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }

  String _getRoleName(String role) {
    switch (role) {
      case 'don':
        return 'Дон';
      case 'mafia':
        return 'Мафия';
      case 'sheriff':
        return 'Шериф';
      case 'citizen':
        return 'Мирный';
      default:
        return role;
    }
  }

  void _saveProtocol() {
    // TODO: сохранить протокол в файл
  }
}
