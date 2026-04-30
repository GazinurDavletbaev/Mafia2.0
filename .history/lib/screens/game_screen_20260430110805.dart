import 'package:flutter/material.dart';
import 'package:mafia_help/models/player_ui_model.dart';

// Временный список игроков для теста
final List<PlayerUIModel> testPlayers = [
  PlayerUIModel(seatNumber: 5, name: 'Игрок 5', isAlive: true, fouls: 0, isSpeaking: false),
  PlayerUIModel(seatNumber: 4, name: 'Игрок 4', isAlive: true, fouls: 0, isSpeaking: false),
  PlayerUIModel(seatNumber: 3, name: 'Игрок 3', isAlive: false, fouls: 0, isSpeaking: false),
  PlayerUIModel(seatNumber: 2, name: 'Игрок 2', isAlive: true, fouls: 2, isSpeaking: true),
  PlayerUIModel(seatNumber: 1, name: 'Игрок 1', isAlive: true, fouls: 0, isSpeaking: false),
  PlayerUIModel(seatNumber: 6, name: 'Игрок 6', isAlive: true, fouls: 0, isSpeaking: false),
  PlayerUIModel(seatNumber: 7, name: 'Игрок 7', isAlive: true, fouls: 1, isSpeaking: false),
  PlayerUIModel(seatNumber: 8, name: 'Игрок 8', isAlive: false, fouls: 0, isSpeaking: false),
  PlayerUIModel(seatNumber: 9, name: 'Игрок 9', isAlive: true, fouls: 0, isSpeaking: false),
  PlayerUIModel(seatNumber: 10, name: 'Игрок 10', isAlive: true, fouls: 0, isSpeaking: false),
];

class GameScreen extends StatelessWidget {
  const GameScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black87,
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Верхняя панель
            Container(
              height: 70,
              color: Colors.grey[900],
              child: const Center(
                child: Text(
                  'Фаза: Ночь | Круг 1',
                  style: TextStyle(color: Colors.white, fontSize: 20),
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Две колонки игроков
            Expanded(
              child: Row(
                children: [
                  // Левая сторона (места 5,4,3,2,1)
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _buildPlayerCard(testPlayers[0]), // место 5
                        _buildPlayerCard(testPlayers[1]), // место 4
                        _buildPlayerCard(testPlayers[2]), // место 3
                        _buildPlayerCard(testPlayers[3]), // место 2
                        _buildPlayerCard(testPlayers[4]), // место 1
                      ],
                    ),
                  ),
                  
                  const SizedBox(width: 20),
                  
                  // Правая сторона (места 6,7,8,9,10)
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _buildPlayerCard(testPlayers[5]), // место 6
                        _buildPlayerCard(testPlayers[6]), // место 7
                        _buildPlayerCard(testPlayers[7]), // место 8
                        _buildPlayerCard(testPlayers[8]), // место 9
                        _buildPlayerCard(testPlayers[9]), // место 10
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Нижняя панель
            Container(
              height: 100,
              color: Colors.grey[900],
              child: const Center(
                child: Text(
                  'Таймер: 60 сек | Кнопки действий',
                  style: TextStyle(color: Colors.white, fontSize: 16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlayerCard(PlayerUIModel player) {
    return Card(
      color: Colors.grey[800],
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Аватарка с номером и индикатором жив/мёртв
            Stack(
              children: [
                CircleAvatar(
                  radius: 28,
                  backgroundColor: Colors.grey[600],
                  child: Text(
                    '${player.seatNumber}',
                    style: const TextStyle(fontSize: 18, color: Colors.white),
                  ),
                ),
                if (!player.isAlive)
                  Positioned.fill(
                    child: Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.black.withOpacity(0.7),
                      ),
                      child: const Icon(Icons.close, color: Colors.red, size: 30),
                    ),
                  ),
              ],
            ),
            const SizedBox(width: 12),
            
            // Имя игрока
            Expanded(
              child: Text(
                player.name,
                style: TextStyle(
                  color: player.isAlive ? Colors.white : Colors.grey,
                  fontSize: 14,
                  decoration: player.isAlive ? null : TextDecoration.lineThrough,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            
            // Индикатор фолов
            if (player.fouls > 0)
              Container(
                padding: const EdgeInsets.all(4),
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.red,
                ),
                child: Text(
                  '${player.fouls}',
                  style: const TextStyle(color: Colors.white, fontSize: 12),
                ),
              ),
          ],
        ),
      ),
    );
  }
}