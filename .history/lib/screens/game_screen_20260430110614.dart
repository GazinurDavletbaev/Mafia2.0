import 'package:flutter/material.dart';



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

            // Две колонки игроков (слева и справа)
            Expanded(
              child: Row(
                children: [
                  // Левая сторона (места 5,4,3,2,1 сверху вниз)
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _buildPlayerCard(5),
                        _buildPlayerCard(4),
                        _buildPlayerCard(3),
                        _buildPlayerCard(2),
                        _buildPlayerCard(1),
                      ],
                    ),
                  ),

                  const SizedBox(width: 20),

                  // Правая сторона (места 6,7,8,9,10 сверху вниз)
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _buildPlayerCard(6),
                        _buildPlayerCard(7),
                        _buildPlayerCard(8),
                        _buildPlayerCard(9),
                        _buildPlayerCard(10),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Нижняя панель с таймером
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

  Widget _buildPlayerCard(int seatNumber) {
    return Card(
      color: Colors.grey[800],
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircleAvatar(
              radius: 28,
              backgroundColor: Colors.grey[600],
              child: Text(
                '$seatNumber',
                style: const TextStyle(fontSize: 18, color: Colors.white),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                'Игрок $seatNumber',
                style: const TextStyle(color: Colors.white, fontSize: 14),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
