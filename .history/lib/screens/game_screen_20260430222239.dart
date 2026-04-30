import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mafia_help/providers/game_provider.dart';
import 'package:mafia_help/providers/phase_provider.dart';
import 'package:mafia_help/state/game_state.dart';

import '../models/player_model.dart';

class GameScreen extends ConsumerWidget {
  const GameScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final gameState = ref.watch(gameStateProvider);
    final currentSubPhase = getCurrentSubPhase(ref);
    final players = gameState.players;

    return Scaffold(
      backgroundColor: Colors.black87,
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Верхняя панель с фазой
            Container(
              height: 70,
              color: Colors.grey[900],
              child: Center(
                child: Text(
                  '$currentSubPhase | День ${gameState.currentDay}',
                  style: const TextStyle(color: Colors.white, fontSize: 20),
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Список кандидатов (если есть)
            if (gameState.nominatedSeats.isNotEmpty)
              Container(
                height: 50,
                color: Colors.grey[800],
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: gameState.nominatedSeats.length,
                  itemBuilder: (context, index) {
                    final seat = gameState.nominatedSeats[index];
                    return GestureDetector(
                      onTap: () {
                        // TODO: открыть калькулятор для ввода голосов
                      },
                      child: Container(
                        width: 60,
                        margin: const EdgeInsets.all(4),
                        color: Colors.orange,
                        child: Center(child: Text('$seat')),
                      ),
                    );
                  },
                ),
              ),
            const SizedBox(height: 10),

            // Две колонки игроков
            Expanded(
              child: Row(
                children: [
                  // Левая сторона (места 5,4,3,2,1)
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _buildPlayerCard(players.where((p) => p.seatNumber == 5).first, ref),
                        _buildPlayerCard(players.where((p) => p.seatNumber == 4).first, ref),
                        _buildPlayerCard(players.where((p) => p.seatNumber == 3).first, ref),
                        _buildPlayerCard(players.where((p) => p.seatNumber == 2).first, ref),
                        _buildPlayerCard(players.where((p) => p.seatNumber == 1).first, ref),
                      ],
                    ),
                  ),
                  const SizedBox(width: 20),
                  // Правая сторона (места 6,7,8,9,10)
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _buildPlayerCard(players.where((p) => p.seatNumber == 6).first, ref),
                        _buildPlayerCard(players.where((p) => p.seatNumber == 7).first, ref),
                        _buildPlayerCard(players.where((p) => p.seatNumber == 8).first, ref),
                        _buildPlayerCard(players.where((p) => p.seatNumber == 9).first, ref),
                        _buildPlayerCard(players.where((p) => p.seatNumber == 10).first, ref),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Нижняя панель (кнопка смены фаз)
            // Нижняя панель — кнопка смены фаз
          Container(
            height: 70,
            margin: const EdgeInsets.only(top: 16),
            child: Row(
              children: [
                // Левая половина (назад)
                Expanded(
                  child: GestureDetector(
                    onTap: () => goToPreviousSubPhase(ref),
                    child: Container(
                      color: Colors.grey[800],
                      alignment: Alignment.center,
                      child: Text(
                        _getPhaseDisplayName(currentSubPhase),
                        style: const TextStyle(color: Colors.white70, fontSize: 16),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                ),
                // Правая половина (далее)
                Expanded(
                  child: GestureDetector(
                    onTap: () => goToNextSubPhase(ref),
                    child: Container(
                      color: Colors.grey[850],
                      alignment: Alignment.center,
                      child: Text(
                        _getPhaseDisplayName(currentSubPhase),
                        style: const TextStyle(color: Colors.white, fontSize: 16),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlayerCard(PlayerModel player, WidgetRef ref) {
    final gameNotifier = ref.read(gameStateProvider.notifier);
    
    return GestureDetector(
      onTap: () {
        // Обычный тап: добавить фол
        gameNotifier.addFoul(player.seatNumber);
      },
      onLongPress: () {
        // Долгое нажатие: показать меню
        _showPlayerMenu(ref, player);
      },
      child: Card(
        color: player.isSpeaking ? Colors.green[800] : Colors.grey[800],
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Аватарка с номером
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
      ),
    );
  }

  void _showPlayerMenu(WidgetRef ref, PlayerModel player) {
    // TODO: показать меню действий (Убить, Проверить, Выставить, Снять и т.д.)
    print('Долгое нажатие на игрока ${player.seatNumber}');
  }
}