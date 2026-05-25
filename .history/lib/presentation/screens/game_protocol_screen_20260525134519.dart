import 'package:flutter/material.dart';

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
            onPressed: () {
              // Сохранить протокол в файл/поделиться
              _saveProtocol();
            },
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Общая информация
          _buildSection('Общая информация', [
            'Дата: ${DateTime.now().toString().substring(0, 16)}',
            'Победитель: ${gameState.winner == 'red' ? 'Красные' : 'Чёрные'}',
            'Всего ходов: ${gameHistory.states.length}',
          ]),
          
          // Раздача ролей
          _buildSection('Раздача ролей', 
            gameState.players.map((p) => 'Место ${p.seatNumber}: ${_getRoleName(p.role)}').toList()
          ),
          
          // Ночные действия из nightActions
          _buildSection('Ночные действия', _buildNightActions(gameState.nightActions ?? [])),
          
          // Голосования (из voteHistory)
          _buildSection('Голосования', _buildVoteHistory(gameState.voteHistory)),
          
          // Best move (из partialBestMove)
          if (gameState.partialBestMove.isNotEmpty)
            _buildSection('Лучший ход', [
              'Выбранные игроки: ${gameState.partialBestMove.join(', ')}'
            ]),
          
          // Фолы
          _buildSection('Фолы',
            gameState.players.where((p) => p.fouls > 0).map((p) => 
              'Место ${p.seatNumber} (${p.name}) - ${p.fouls} фол(а/ов)'
            ).toList()
          ),
        ],
      ),
    );
  }

  Widget _buildSection(String title, List<String> items) {
    if (items.isEmpty) return const SizedBox.shrink();
    return Card(
      color: Colors.grey.shade800,
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.orange)),
            const SizedBox(height: 8),
            ...items.map((item) => Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Text(item, style: const TextStyle(color: Colors.white)),
            )),
          ],
        ),
      ),
    );
  }

  String _getRoleName(String role) {
    switch (role) {
      case 'don': return 'Дон';
      case 'mafia': return 'Мафия';
      case 'sheriff': return 'Шериф';
      case 'citizen': return 'Мирный';
      default: return role;
    }
  }

  List<String> _buildNightActions(List<int> nightActions) {
    final List<String> result = [];
    for (int i = 0; i < nightActions.length; i += 3) {
      final nightNum = i ~/ 3;
      final kill = nightActions[i];
      final donCheck = nightActions[i + 1];
      final sheriffCheck = nightActions[i + 2];
      result.add('Ночь $nightNum: убийство ${kill == 0 ? "промах" : "игрок $kill"}, дон → $donCheck, шериф → $sheriffCheck');
    }
    return result;
  }

  List<String> _buildVoteHistory(List<Map<int, int>> voteHistory) {
    // TODO: форматировать историю голосований
    return ['В разработке'];
  }

  void _saveProtocol() {
    // TODO: сохранить протокол в файл (например, .txt или .json)
  }
}