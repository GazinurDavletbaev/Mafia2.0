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

            // Основная часть — два ряда (левая и правая сторона)
            Expanded(
              child: Row(
                children: [
                  // Левая сторона (места 1-5)
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _buildPlayerCard(5, isLeft: true), // дальний левый
                        _buildPlayerCard(4, isLeft: true),
                        _buildPlayerCard(3, isLeft: true),
                        _buildPlayerCard(2, isLeft: true),
                        _buildPlayerCard(1, isLeft: true), // ближний к судье
                      ],
                    ),
                  ),

                  // Судья в центре (пока заглушка)
                  Container(
                    width: 100,
                    margin: const EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                      color: Colors.blue[900],
                      borderRadius: BorderRadius.circular(50),
                    ),
                    child: const Center(
                      child: Text(
                        'СУДЬЯ',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),

                  // Правая сторона (места 6-10)
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _buildPlayerCard(6, isLeft: false), // ближний к судье
                        _buildPlayerCard(7, isLeft: false),
                        _buildPlayerCard(8, isLeft: false),
                        _buildPlayerCard(9, isLeft: false),
                        _buildPlayerCard(10, isLeft: false), // дальний правый
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

  Widget _buildPlayerCard(int seatNumber, {required bool isLeft}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Card(
        color: Colors.grey[800],
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircleAvatar(
                radius: 24,
                backgroundColor: Colors.grey[600],
                child: Text(
                  '$seatNumber',
                  style: const TextStyle(fontSize: 16, color: Colors.white),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Игрок $seatNumber',
                  style: const TextStyle(color: Colors.white, fontSize: 12),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
