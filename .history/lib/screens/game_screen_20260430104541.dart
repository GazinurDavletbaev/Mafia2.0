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
            // Верхняя панель с фазой и кругом
            Container(
              height: 80,
              color: Colors.grey[900],
              child: const Center(
                child: Text(
                  'Фаза: Ночь | Круг 1',
                  style: TextStyle(color: Colors.white, fontSize: 20),
                ),
              ),
            ),
            const SizedBox(height: 20),
            
            // Сетка игроков 5x2
            Expanded(
              child: Column(
                children: [
                  // Верхний ряд (места 1-5)
                  Expanded(
                    child: Row(
                      children: List.generate(5, (index) => _buildPlayerCard(index + 1)),
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Нижний ряд (места 6-10)
                  Expanded(
                    child: Row(
                      children: List.generate(5, (index) => _buildPlayerCard(index + 6)),
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 20),
            
            // Нижняя панель с таймером и кнопками
            Container(
              height: 120,
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
    return Expanded(
      child: Card(
        color: Colors.grey[800],
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircleAvatar(
              radius: 30,
              backgroundColor: Colors.grey[600],
              child: Text(
                '$seatNumber',
                style: const TextStyle(fontSize: 20, color: Colors.white),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Игрок $seatNumber',
              style: const TextStyle(color: Colors.white, fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }
}