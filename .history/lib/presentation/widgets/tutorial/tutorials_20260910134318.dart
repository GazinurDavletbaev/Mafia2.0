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
    TutorialStep(
      id: 'club_create',
      title: 'Создайте свой клуб!',
      description: 'Нажмите сюда, чтобы создать собственный клуб.',
      icon: Icons.add_rounded,
      backgroundColor: Colors.green.withOpacity(0.5),
      width: 280,
      height: 120,
    ),
    TutorialStep(
      id: 'club_first_result',
      title: 'Вступить в клуб',
      description:
          'Нажмите на клуб, чтобы посмотреть информацию и вступить.\nОписание:\nНазвание клуба, город\nНикнейм президента\nКоличество резидентов клуба\nЕсли подсвечен золотым значит\nклуб официально подтвержден',
      icon: Icons.people_alt_rounded,
      backgroundColor: Colors.green.withOpacity(0.5),
      width: 280,
      height: 220,
    ),
  ];

  // ============================================================
  // 🎯 КЛУБ (ClubScreen) — есть клуб
  // ============================================================
  static final List<TutorialStep> clubSteps = [
    TutorialStep(
      id: 'request',
      title: 'Отправить заявку',
      description:
          'Можете отправить одну заявку.\nМожете отозвать заявку.\nКак только президент клуба\nпримет ее вы станете резидентом\nданного клуба!',
      icon: Icons.people_alt_rounded,
      backgroundColor: Colors.green.withOpacity(0.5),
      width: 260,
      height: 160,
    ),
    TutorialStep(
      id: 'club_residents',
      title: 'Резиденты клуба',
      description: 'Здесь отображаются все участники клуба.',
      icon: Icons.people_alt_rounded,
      backgroundColor: Colors.green.withOpacity(0.5),
      width: 260,
      height: 100,
    ),
    TutorialStep(
      id: 'club_games',
      title: 'История игр',
      description: 'Все игры клуба собраны здесь.',
      icon: Icons.sports_score_rounded,
      backgroundColor: Colors.green.withOpacity(0.5),
      width: 240,
      height: 90,
    ),
    TutorialStep(
      id: 'month',
      title: 'Текущий месяц',
      description: 'Месяц и год текущего рейтинга',
      icon: Icons.sports_score_rounded,
      backgroundColor: Colors.green.withOpacity(0.5),
      width: 250,
      height: 110,
    ),
    TutorialStep(
      id: 'rating',
      title: 'Таблица рейтинга',
      description:
          'Свайп вправо -> прошлый месяц\nСвайп влево <- следующий месяц',
      icon: Icons.sports_score_rounded,
      backgroundColor: Colors.green.withOpacity(0.5),
      width: 250,
      height: 120,
    ),
    TutorialStep(
      id: 'club_search',
      title: 'Найти клуб',
      description: 'Нажмите сюда, чтобы найти и вступить в клуб.',
      icon: Icons.search_rounded,
      backgroundColor: Colors.green.withOpacity(0.5),
      width: 230,
      height: 110,
    ),
  ];

  // ============================================================
  // 🎯 НАВБАР В ЛОББИ (подсказки для кнопок)
  // ============================================================
  static final List<TutorialStep> lobbyNavSteps = [
    TutorialStep(
      id: 'welcome',
      title: 'Добро пожаловать в Mafia Help! 🎭',
      description:
          'Здесь вы можете стать\nпрезидентом своего\nсобственного клуба или\nрезидентом уже действующего.\nВести полноценный рейтинг клуба\nи просматривать свои сыгранные игры\nДавайте покажем, как всё работает!',
      icon: Icons.emoji_emotions_rounded,
      backgroundColor: Colors.green.withOpacity(0.5),
      width: 290,
      height: 220,
    ),
    TutorialStep(
      id: 'club',
      title: 'Ваш Клуб',
      description:
          'Здесь находиться ваш клуб,\nваша статистика, игры и рейтинг',
      icon: Mdi.home,
      backgroundColor: Colors.green.withOpacity(0.5),
      width: 280,
      height: 120,
    ),
    TutorialStep(
      id: 'sitting',
      title: 'Рассадка игроков',
      description: 'Игра начнется когда\nрассадите всех игроков за столом',
      icon: Mdi.accountGroupOutline,
      backgroundColor: Colors.green.withOpacity(0.5),
      width: 280,
      height: 120,
    ),
    TutorialStep(
      id: 'game',
      title: 'Начнем игру',
      description: 'Полный цикл игры\nбез бумаги и ручки',
      icon: Mdi.brain,
      backgroundColor: Colors.green.withOpacity(0.5),
      width: 280,
      height: 120,
    ),
    TutorialStep(
      id: 'protocol',
      title: 'Протокол игры',
      description:
          'Протокол игры в реальном\nвремени возможность сохранить\nв телефон, в рейтинг или сформировать\nexcel файл и распечатать\nв бумажном виде',
      icon: Mdi.listBox,
      backgroundColor: Colors.green.withOpacity(0.5),
      width: 280,
      height: 190,
    ),
  ];

// lib/presentation/widgets/tutorial/tutorials.dart

// ============================================================
// 🎯 ЭКРАН РАССАДКИ (SeatSetupScreen)
// ============================================================
  static final List<TutorialStep> seatSetupSteps = [
    // 1️⃣ ИГРОК
    TutorialStep(
      id: 'seat_player',
      title: 'Игроки за столом',
      description: 'Нажмите на игрока, чтобы\nназначить ему роль или удалить.',
      icon: Icons.person_rounded,
      backgroundColor: Colors.green.withOpacity(0.5),
      width: 260,
      height: 120,
    ),
    // 2️⃣ ТУРНИР
    TutorialStep(
      id: 'seat_tournament',
      title: 'Название турнира',
      description: 'Введите название турнира\n(например, "Кубок осени 2026").',
      icon: Icons.emoji_events_rounded,
      backgroundColor: Colors.green.withOpacity(0.5),
      width: 260,
      height: 120,
    ),
    TutorialStep(
      id: 'seat_stadia',
      title: 'Стадия турнира',
      description: 'Введите название турнира\n(например, "Кубок осени 2026").',
      icon: Icons.emoji_events_rounded,
      backgroundColor: Colors.green.withOpacity(0.5),
      width: 260,
      height: 120,
    ),
    // 3️⃣ СТОЛ
    TutorialStep(
      id: 'seat_table',
      title: 'Номер стола',
      description: 'Укажите номер стола\n(например, 1, 2, 3...).',
      icon: Icons.table_restaurant_rounded,
      backgroundColor: Colors.green.withOpacity(0.5),
      width: 260,
      height: 110,
    ),
    // 4️⃣ ИГРА
    TutorialStep(
      id: 'seat_game',
      title: 'Номер игры',
      description: 'Укажите номер игры\n(например, 1, 2, 3...).',
      icon: Icons.sports_esports_rounded,
      backgroundColor: Colors.green.withOpacity(0.5),
      width: 260,
      height: 110,
    ),
    // 5️⃣ ДАТА
    TutorialStep(
      id: 'seat_date',
      title: 'Дата и время',
      description: 'Нажмите, чтобы выбрать\nдату и время игры.',
      icon: Icons.calendar_today_rounded,
      backgroundColor: Colors.green.withOpacity(0.5),
      width: 260,
      height: 110,
    ),
    // 6️⃣ УДАЛИТЬ ИГРУ
    TutorialStep(
      id: 'seat_delete',
      title: 'Удалить игру',
      description: 'Нажмите, чтобы удалить\nвсех игроков за столом.',
      icon: Icons.delete_forever_rounded,
      backgroundColor: Colors.green.withOpacity(0.5),
      width: 260,
      height: 110,
    ),
  ];

  // ============================================================
// 🎯 ЭКРАН ИГРЫ (GameScreen)
// ============================================================
  static final List<TutorialStep> gameSteps = [
    // 1️⃣ НОМЕР ИГРОКА (на карточке игрока)
    TutorialStep(
      id: 'game_player_number',
      title: 'Номер игрока',
      description:
          'Каждый игрок имеет свой номер. Нажмите на карточку, чтобы выбрать игрока.',
      icon: Icons.numbers_rounded,
      backgroundColor: Colors.green.withOpacity(0.5),
      width: 260,
      height: 140,
    ),
    // 2️⃣ ФАЗА
    TutorialStep(
      id: 'game_phase',
      title: 'Текущая фаза',
      description: 'Здесь отображается текущая фаза игры и номер дня.',
      icon: Icons.flag_rounded,
      backgroundColor: Colors.green.withOpacity(0.5),
      width: 260,
      height: 140,
    ),
    // 3️⃣ ДЕНЬ
    TutorialStep(
      id: 'game_day',
      title: 'Номер дня',
      description: 'Показывает текущий день игры.',
      icon: Icons.calendar_today_rounded,
      backgroundColor: Colors.green.withOpacity(0.5),
      width: 240,
      height: 140,
    ),
    // 8️⃣ КАЛЬКУЛЯТОР
    TutorialStep(
      id: 'game_calculator',
      title: 'Калькулятор',
      description:
          'Используйте цифры для голосования, выбора лучшего хода или ночных действий.',
      icon: Icons.calculate_rounded,
      backgroundColor: Colors.green.withOpacity(0.5),
      width: 260,
      height: 140,
    ),
    // 4️⃣ ВПЕРЕД (→)
    TutorialStep(
      id: 'game_forward',
      title: 'Следующая фаза',
      description: 'Нажмите, чтобы перейти к следующей фазе игры.',
      icon: Icons.arrow_forward_rounded,
      backgroundColor: Colors.green.withOpacity(0.5),
      width: 240,
      height: 140,
    ),
    // 5️⃣ НАЗАД (←)
    TutorialStep(
      id: 'game_back',
      title: 'Предыдущая фаза',
      description: 'Нажмите, чтобы вернуться к предыдущей фазе.',
      icon: Icons.arrow_back_rounded,
      backgroundColor: Colors.green.withOpacity(0.5),
      width: 240,
      height: 140,
    ),
    // 6️⃣ РОЛИ (🎭)
    TutorialStep(
      id: 'game_roles',
      title: 'Показать роли',
      description: 'Нажмите, чтобы показать/скрыть роли всех игроков.',
      icon: Icons.theater_comedy_rounded,
      backgroundColor: Colors.green.withOpacity(0.5),
      width: 260,
      height: 110,
    ),
    // 7️⃣ ПРОМАХ (🙅)
    TutorialStep(
      id: 'game_miss',
      title: 'Промах',
      description: 'Нажмите, если мафия промахнулась.',
      icon: Icons.do_not_disturb_rounded,
      backgroundColor: Colors.green.withOpacity(0.5),
      width: 260,
      height: 140,
    ),
// 9️⃣ ГОЛОСОВАНИЕ
    TutorialStep(
      id: 'game_voting',
      title: 'Голосование',
      description:
          'В фазе голосования распределите голоса между кандидатами с помощью калькулятора.',
      icon: Icons.how_to_vote_rounded,
      backgroundColor: Colors.green.withOpacity(0.5),
      width: 280,
      height: 140,
    ),
    // 9️⃣ ГОЛОСОВАНИЕ
    TutorialStep(
      id: 'game_start',
      title: 'Начало игры',
      description:
          'Нажмите на первого игрока и покажите ему его роль прямо с экрана телефона, после 10 игрока нажимайте вперед! Желаем прекрасной игры и получить максимум удовольствия!',
      icon: Icons.how_to_vote_rounded,
      backgroundColor: Colors.green.withOpacity(0.5),
      width: 280,
      height: 180,
    ),
  ];
  static final List<TutorialStep> protocolSteps = [
    TutorialStep(
      id: 'protocol_ball',
      title: 'Дополнительные баллы',
      description:
          'Наградите игрока за хорошую игру. Ниже в пояснение напишите за что он их получил. Если игрок получил штраф, можете выбрать пункт правил по которому он его получил и так же ниже объясните что он сделал.',
      icon: Icons.add_rounded,
      backgroundColor: Colors.green.withOpacity(0.5),
      width: 280,
      height: 180,
    ),
    TutorialStep(
      id: 'protocol_server',
      title: 'Сохранить в рейтинг',
      description: 'Нажмите сюда, чтобы создать собственный клуб.',
      icon: Icons.add_rounded,
      backgroundColor: Colors.green.withOpacity(0.5),
      width: 280,
      height: 120,
    ),
    TutorialStep(
      id: 'protocol_local',
      title: 'Сохранить на телефон',
      description:
          'Нажмите на клуб, чтобы посмотреть информацию и вступить.\nОписание:\nНазвание клуба, город\nНикнейм президента\nКоличество резидентов клуба\nЕсли подсвечен золотым значит\nклуб официально подтвержден',
      icon: Icons.people_alt_rounded,
      backgroundColor: Colors.green.withOpacity(0.5),
      width: 280,
      height: 220,
    ),
    TutorialStep(
      id: 'protocol_file',
      title: 'Сохраненные игры',
      description:
          'Нажмите на клуб, чтобы посмотреть информацию и вступить.\nОписание:\nНазвание клуба, город\nНикнейм президента\nКоличество резидентов клуба\nЕсли подсвечен золотым значит\nклуб официально подтвержден',
      icon: Icons.people_alt_rounded,
      backgroundColor: Colors.green.withOpacity(0.5),
      width: 280,
      height: 220,
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
      case 'seat_setup': // ← НОВЫЙ КЕЙС
        return seatSetupSteps;
      case 'protocol':
        return protocolSteps;
      default:
        return [];
    }
  }
}
