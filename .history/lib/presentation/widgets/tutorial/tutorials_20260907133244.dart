// lib/presentation/widgets/tutorial/tutorials.dart
import 'package:flutter/material.dart';
import 'package:mdi_plus/mdi_plus.dart';

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
  // 👋 ПУСТОЙ КЛУБ (noclub) — ПРИВЕТСТВИЕ + СОЗДАТЬ КЛУБ
  // ============================================================
  static final List<TutorialStep> noclubSteps = [
    // 1️⃣ ПРИВЕТСТВИЕ
    TutorialStep(
      id: 'welcome',
      title: 'Добро пожаловать в Mafia Help! 🎭',
      description:
          'Здесь вы можете стать\nпрезидентом своего\nсобственного клуба или\nрезидентом уже действующего.\nВести полноценный рейтинг клуба\nи просматривать свои сыгранные игры\nДавайте покажем, как всё работает!',
      icon: Icons.emoji_emotions_rounded,
      backgroundColor: Colors.green.withOpacity(0.5),
      width: 290,
      height: 220,
      // customPosition не нужен — будет по центру
    ),
    // 2️⃣ СОЗДАТЬ КЛУБ
    TutorialStep(
      id: 'club_create',
      title: 'Создайте свой клуб!',
      description: 'Нажмите сюда, чтобы создать собственный клуб.',
      icon: Icons.add_rounded,
      backgroundColor: Colors.green.withOpacity(0.5),
      width: 280,
      height: 120,
    ),
  ];

  // ============================================================
  // 🎯 КЛУБ (ClubScreen) — есть клуб
  // ============================================================
  static final List<TutorialStep> clubSteps = [
    TutorialStep(
      id: 'club_residents',
      title: 'Резиденты клуба',
      description: 'Здесь отображаются все участники клуба.',
      icon: Icons.people_alt_rounded,
      backgroundColor: Colors.deepPurple.withOpacity(0.5),
      width: 260,
      height: 100,
    ),
    TutorialStep(
      id: 'club_games',
      title: 'История игр',
      description: 'Все игры клуба собраны здесь.',
      icon: Icons.sports_score_rounded,
      backgroundColor: Colors.deepPurple.shade700.withOpacity(0.5),
      width: 240,
      height: 90,
    ),
    TutorialStep(
      id: 'club_search',
      title: 'Найти клуб',
      description: 'Нажмите сюда, чтобы найти и вступить в клуб.',
      icon: Icons.search_rounded,
      backgroundColor: Colors.blue.shade700.withOpacity(0.5),
      width: 230,
      height: 110,
    ),
  ];

  // ============================================================
  // 🎯 НАВБАР В ЛОББИ (подсказки для кнопок)
  // ============================================================
  static final List<TutorialStep> lobbyNavSteps = [
    TutorialStep(
      id: 'sitting',
      title: 'Фаза рассадки игроков',
      description: 'Игра начнется когда\nрассадите всех игроков за столом',
      icon: Mdi.accountGroupOutline,
      backgroundColor: Colors.orange.shade700.withOpacity(0.5),
      width: 280,
      height: 120,
    ),
    TutorialStep(
      id: 'game',
      title: 'Начнем игру',
      description: 'Полный цикл игры\nбез бумаги и ручки',
      icon: Mdi.brain,
      backgroundColor: Colors.deepPurple.shade700.withOpacity(0.5),
      width: 280,
      height: 120,
    ),
    TutorialStep(
      id: 'protocol',
      title: 'Протокол игры',
      description:
          'Протокол игры в реальном\nвремени возможность сохранить\nв телефон, в рейтинг или сформировать\nexcel файл и распечатать\nв бумажном виде',
      icon: Mdi.listBox,
      backgroundColor: Colors.blue.shade700.withOpacity(0.5),
      width: 280,
      height: 190,
    ),
  ];

  // ============================================================
  // 🎯 ИГРА (GameScreen)
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
  // 🎯 ЛОББИ (LobbyScreen) — профиль
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

  // ============================================================
  // 🔥 МЕТОД ДЛЯ ПОЛУЧЕНИЯ ПОДСКАЗОК ПО ЭКРАНУ
  // ============================================================
  static List<TutorialStep> getSteps(String screen) {
    switch (screen) {
      case 'noclub':
        return noclubSteps;
      case 'club':
        return clubSteps;
      case 'lobby_nav':
        return lobbyNavSteps;
      case 'game':
        return gameSteps;
      case 'lobby':
        return lobbySteps;
      default:
        return [];
    }
  }
}
