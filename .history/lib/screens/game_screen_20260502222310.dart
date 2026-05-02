import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mafia_help/providers/game_provider.dart';
import 'package:mafia_help/providers/phase_provider.dart';
import 'package:mafia_help/models/phase_config.dart';
import '../models/player_model.dart';
import 'package:pie_menu/pie_menu.dart';

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
                  _getPhaseDisplayName(currentSubPhase),
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

            // Нижняя панель — кнопка смены фаз
            // Нижняя панель — одна область, разделённая на две невидимые кнопки
            Container(
              height: 70,
              margin: const EdgeInsets.only(top: 16),
              child: Stack(
                children: [
                  // Две невидимые кнопки (левая и правая половины)
                  Row(
                    children: [
                      // Левая половина (назад)
                      Expanded(
                        child: GestureDetector(
                          onTap: () => goToPreviousSubPhase(ref),
                          child: Container(
                            color: Colors.transparent, // невидимая
                          ),
                        ),
                      ),
                      // Правая половина (далее)
                      Expanded(
                        child: GestureDetector(
                          onTap: () => goToNextSubPhase(ref),
                          child: Container(
                            color: Colors.transparent, // невидимая
                          ),
                        ),
                      ),
                    ],
                  ),
                  // Текст поверх кнопок (по центру)
                  Center(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                      decoration: BoxDecoration(
                        color: Colors.grey[900],
                        borderRadius: BorderRadius.circular(30),
                      ),
                      child: Text(
                        _getPhaseDisplayName(currentSubPhase),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
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
  
  return PieMenu(
    actions: [
      PieAction(
        tooltip: Text('Убить', style: TextStyle(color: Colors.white)),
        onSelect: () {
          print('Убить игрока ${player.seatNumber}');
          gameNotifier.setAlive(player.seatNumber, false);
        },
        child: Icon(Icons.hear, color: Colors.red, size: 28),
      ),
      PieAction(
        tooltip: Text('Оживить', style: TextStyle(color: Colors.white)),
        onSelect: () {
          print('Оживить игрока ${player.seatNumber}');
          gameNotifier.setAlive(player.seatNumber, true);
        },
        child: Icon(Icons.favorite, color: Colors.green, size: 28),
      ),
      PieAction(
        tooltip: Text('Выставить', style: TextStyle(color: Colors.white)),
        onSelect: () {
          print('Выставить игрока ${player.seatNumber}');
          gameNotifier.addNomination(player.seatNumber);
        },
        child: Icon(Icons.flag, color: Colors.orange, size: 28),
      ),
      PieAction(
        tooltip: Text('Снять', style: TextStyle(color: Colors.white)),
        onSelect: () {
          print('Снять выставление игрока ${player.seatNumber}');
          gameNotifier.removeNomination(player.seatNumber);
        },
        child: Icon(Icons.cancel, color: Colors.grey, size: 28),
      ),
    ],
    onTap: () {
      gameNotifier.addFoul(player.seatNumber);
    },
    child: Card(
      color: player.isSpeaking ? Colors.green[800] : Colors.grey[800],
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
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

  // Функция перевода подфазы в русское название
  String _getPhaseDisplayName(SubPhase phase) {
    switch (phase) {
      // Ночь (первая)
      case SubPhase.roleDistribution:
        return 'РАЗДАЧА РОЛЕЙ';
      case SubPhase.contract:
        return 'ДОГОВОРКА';
      case SubPhase.sheriffLook:
        return 'ШЕРИФ ОСМАТРИВАЕТ';
      // Ночь (обычная)
      case SubPhase.mafiaShoot:
        return 'СТРЕЛЬБА МАФИИ';
      case SubPhase.donCheck:
        return 'ПРОВЕРКА ДОНА';
      case SubPhase.sheriffCheck:
        return 'ПРОВЕРКА ШЕРИФА';
      // День
      case SubPhase.bestMove:
        return 'ЛУЧШИЙ ХОД';
      case SubPhase.speeches:
        return 'РЕЧИ (ДЕНЬ)';
      case SubPhase.voting:
        return 'ГОЛОСОВАНИЕ';
      case SubPhase.revote:
        return 'ПЕРЕГОЛОСОВАНИЕ (30С)';
      case SubPhase.eliminationVote:
        return 'ГОЛОСОВАНИЕ ЗА ПОДЪЁМ';
      case SubPhase.finalWord:
        return 'ЗАКЛЮЧИТЕЛЬНАЯ МИНУТА';
      default:
        return 'ФАЗА';
    }
  }
}