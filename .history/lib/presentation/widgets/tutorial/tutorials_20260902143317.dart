// lib/presentation/widgets/tutorial/tutorials.dart
import 'package:flutter/material.dart';

class TutorialStep {
  final String id;
  final String title;
  final String description;
  final IconData icon;
  final GlobalKey? targetKey;
  final Offset? customPosition;
  final double? width;
  final double? height;
  final Color backgroundColor;
  final Color textColor;

  const TutorialStep({
    required this.id,
    required this.title,
    required this.description,
    required this.icon,
    this.targetKey,
    this.customPosition,
    this.width,
    this.height,
    this.backgroundColor = Colors.deepPurple,
    this.textColor = Colors.white,
  });
}

// 🔥 ВСЕ ПОДСКАЗКИ В ОДНОМ МЕСТЕ
class Tutorials {
  // ============================================================
  // КЛУБ (ClubScreen)
  // ============================================================
  static final List<TutorialStep> clubSteps = [
    TutorialStep(
      id: 'club_residents',
      title: 'Резиденты клуба',
      description: 'Здесь отображаются все участники клуба.',
      icon: Icons.people_alt_rounded,
      backgroundColor: Colors.deepPurple,
      width: 260,
      height: 100,
    ),
    TutorialStep(
      id: 'club_games',
      title: 'История игр',
      description: 'Все игры клуба собраны здесь.',
      icon: Icons.sports_score_rounded,
      backgroundColor: Colors.orange.shade700,
      width: 240,
      height: 90,
    ),
    TutorialStep(
      id: 'club_search',
      title: 'Найти клуб',
      description: 'Нажмите сюда, чтобы найти и вступить в клуб.',
      icon: Icons.search_rounded,
      backgroundColor: Colors.blue.shade700,
      width: 250,
      height: 190,
      customPosition: const Offset(100, 600),
    ),
  ];

  // ============================================================
  // ИГРА (GameScreen)
  // ============================================================
  static final List<TutorialStep> gameSteps = [
    TutorialStep(
      id: 'game_player6_foul',
      title: 'Следите за фолами!',
      description: 'У игрока 6 уже 3 фола. Следующий фол удалит его из игры.',
      icon: Icons.warning_amber_rounded,
      backgroundColor: Colors.red.shade700,
      width: 280,
      height: 120,
    ),
    TutorialStep(
      id: 'game_best_move',
      title: 'Лучший ход',
      description: 'Нажмите на цифры, чтобы отметить трёх подозреваемых.',
      icon: Icons.gavel_rounded,
      backgroundColor: Colors.blue.shade700,
      width: 260,
      height: 110,
    ),
    TutorialStep(
      id: 'game_voting',
      title: 'Голосование',
      description: 'Распределите голоса между кандидатами.',
      icon: Icons.how_to_vote_rounded,
      backgroundColor: Colors.green.shade700,
      width: 260,
      height: 100,
    ),
  ];

  // ============================================================
  // ЛОББИ (LobbyScreen)
  // ============================================================
  static final List<TutorialStep> lobbySteps = [
    TutorialStep(
      id: 'lobby_profile',
      title: 'Ваш профиль',
      description: 'Нажмите сюда, чтобы редактировать профиль.',
      icon: Icons.person_rounded,
      backgroundColor: Colors.purple.shade700,
      width: 240,
      height: 90,
      customPosition: const Offset(100, 600),
    ),
  ];

  // 🔥 МЕТОД ДЛЯ ПОЛУЧЕНИЯ ПОДСКАЗОК ПО ЭКРАНУ
  static List<TutorialStep> getSteps(String screen) {
    switch (screen) {
      case 'club':
        return clubSteps;
      case 'game':
        return gameSteps;
      case 'lobby':
        return lobbySteps;
      default:
        return [];
    }
  }
}
