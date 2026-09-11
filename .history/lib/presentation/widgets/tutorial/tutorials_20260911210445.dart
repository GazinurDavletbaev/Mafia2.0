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
          'Выберите любой клуб, чтобы посмотреть информацию и вступить.\nОписание:\nНазвание клуба, город\nНикнейм президента\nКоличество резидентов клуба\nЕсли подсвечен золотым значит\nклуб официально подтвержден',
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
          'Нажмите сюда чтобы отправить заявку в этот клуб. Второе нажатие отзовет заявку!',
      icon: Icons.people_alt_rounded,
      backgroundColor: Colors.green.withOpacity(0.5),
      width: 240,
      height: 120,
    ),
    TutorialStep(
      id: 'club_residents',
      title: 'Резиденты клуба',
      description: 'Нажмите сюда чтобы посмотреть всех участников.',
      icon: Icons.people_alt_rounded,
      backgroundColor: Colors.green.withOpacity(0.5),
      width: 240,
      height: 100,
    ),
    TutorialStep(
      id: 'club_games',
      title: 'Игры клуба',
      description: 'Нажмите сюда чтобы посмотреть все игры клуба.',
      icon: Mdi.clipboardTextClockOutline,
      backgroundColor: Colors.green.withOpacity(0.5),
      width: 200,
      height: 120,
    ),
    TutorialStep(
      id: 'month',
      title: 'Игровой месяц',
      description: 'Месяц и год текущего рейтинга',
      icon: Mdi.calendarMonth,
      backgroundColor: Colors.green.withOpacity(0.5),
      width: 220,
      height: 100,
    ),
    TutorialStep(
      id: 'rating',
      title: 'Таблица рейтинга',
      description:
          'Свайп вправо -> прошлый месяц\nСвайп влево <- следующий месяц',
      icon: Mdi.gestureSwipeHorizontal,
      backgroundColor: Colors.green.withOpacity(0.5),
      width: 250,
      height: 100,
    ),
    TutorialStep(
      id: 'club_search',
      title: 'Найти клуб',
      description: 'Нажмите сюда, чтобы найти и вступить в клуб.',
      icon: Icons.search_rounded,
      backgroundColor: Colors.green.withOpacity(0.5),
      width: 230,
      height: 100,
    ),
  ];

  // ============================================================
  // 🎯 НАВБАР В ЛОББИ (подсказки для кнопок)
  // ============================================================
  static final List<TutorialStep> lobbyNavSteps = [
    TutorialStep(
      id: 'welcome',
      title: '     Mafia Help!🎭\nДобро пожаловать!',
      description:
          'В вашем распоряжении полноценный помощник для клуба по спортинвой мафии играющий по правилам ФСМ. Подключите свой клуб, проводите игры, ведите рейтинг клуба. Создавайте турниры и смотрите свои игры. Давайте покажем, как всё работает!',
      icon: Icons.emoji_emotions_rounded,
      backgroundColor: Colors.blue.withOpacity(0.5),
      width: 260,
      height: 240,
    ),
    TutorialStep(
      id: 'club',
      title: 'Ваш Клуб',
      description:
          'Здесь находиться информация о вашем клубе, ваша статистика, игры и рейтинг',
      icon: Mdi.home,
      backgroundColor: Colors.green.withOpacity(0.5),
      width: 190,
      height: 140,
    ),
    TutorialStep(
      id: 'sitting',
      title: 'Рассадка\nигроков',
      description: 'Нажмите сюда и начните новую игру!',
      icon: Mdi.humanCapacityIncrease,
      backgroundColor: Colors.green.withOpacity(0.5),
      width: 180,
      height: 130,
    ),
    TutorialStep(
      id: 'game',
      title: 'Начало игры',
      description: 'Полный цикл игры\nбез бумаги и ручки',
      icon: Mdi.play,
      backgroundColor: Colors.green.withOpacity(0.5),
      width: 200,
      height: 100,
    ),
    TutorialStep(
      id: 'protocol',
      title: 'Протокол игры',
      description:
          'Протокол игры в реальном времени возможность сохранить в телефон, в рейтинг или сформировать excel файл и распечатать в бумажном виде',
      icon: Mdi.listBox,
      backgroundColor: Colors.green.withOpacity(0.5),
      width: 220,
      height: 180,
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
      title: 'Выбор игрока',
      description:
          'Нажмите на игрока и введите никнейм. Если вы судья то появится список игроков из вашего клуба!',
      icon: Icons.person_rounded,
      backgroundColor: Colors.green.withOpacity(0.5),
      width: 230,
      height: 140,
    ),
    // 2️⃣ ТУРНИР
    TutorialStep(
      id: 'seat_tournament',
      title: 'Название турнира',
      description:
          'На данный момент доступны только рейтинговые игры для клуба. Создание турниров в разработке...',
      icon: Icons.emoji_events_rounded,
      backgroundColor: Colors.green.withOpacity(0.5),
      width: 240,
      height: 140,
    ),
    TutorialStep(
      id: 'seat_stadia',
      title: 'Стадия турнира',
      description:
          'На данный момент доступны только рейтинговые игры для клуба. Создание турниров в разработке...',
      icon: Icons.emoji_events_rounded,
      backgroundColor: Colors.green.withOpacity(0.5),
      width: 230,
      height: 140,
    ),
    // 3️⃣ СТОЛ
    TutorialStep(
      id: 'seat_table',
      title: 'Номер стола',
      description: 'Нажмите и измените номер стола.',
      icon: Icons.table_restaurant_rounded,
      backgroundColor: Colors.green.withOpacity(0.5),
      width: 200,
      height: 100,
    ),
    // 4️⃣ ИГРА
    TutorialStep(
      id: 'seat_game',
      title: 'Номер игры',
      description:
          'Нажмите и измените номер игры. Игры с одинаковыми номерами стола и игры не сохраняются.',
      icon: Icons.sports_esports_rounded,
      backgroundColor: Colors.green.withOpacity(0.5),
      width: 220,
      height: 140,
    ),
    // 5️⃣ ДАТА
    TutorialStep(
      id: 'seat_date',
      title: 'Дата и время',
      description: 'Нажмите, чтобы выбрать\nдату и время игры.',
      icon: Icons.calendar_today_rounded,
      backgroundColor: Colors.green.withOpacity(0.5),
      width: 200,
      height: 100,
    ),
    // 6️⃣ УДАЛИТЬ ИГРУ
    TutorialStep(
      id: 'seat_delete',
      title: 'Удалить игру',
      description: 'Нажмите, чтобы удалить\nвсех игроков за столом.',
      icon: Icons.delete_forever_rounded,
      backgroundColor: Colors.green.withOpacity(0.5),
      width: 200,
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
          'Игроки расположены как за столом.\nОдно нажатие - фол.\nДолгое Нажатие - действия с игроком\nСвайп вправо - Удалить\nСвайп влево - Вернуть за стол\nСвайп вверх - выставить\nСвайп вниз - Убрать с голосования\n',
      icon: Mdi.numeric4Box,
      backgroundColor: Colors.green.withOpacity(0.5),
      width: 280,
      height: 220,
    ),
    // 2️⃣ ФАЗА
    TutorialStep(
      id: 'game_phase',
      title: 'Фаза игры',
      description:
          'По этой картинке можно понять текущую фазу игры - раздача карт',
      icon: Mdi.cards,
      backgroundColor: Colors.green.withOpacity(0.5),
      width: 200,
      height: 120,
    ),
    // 3️⃣ ДЕНЬ
    TutorialStep(
      id: 'game_day',
      title: 'День|Ночь',
      description: 'Номер дня и ночи.',
      icon: Mdi.themeLightDark,
      backgroundColor: Colors.green.withOpacity(0.5),
      width: 180,
      height: 90,
    ),
    // 8️⃣ КАЛЬКУЛЯТОР
    TutorialStep(
      id: 'game_calculator',
      title: 'Помощник',
      description:
          'Используйте для голосований, стрельбы, проверок и лх. Можете ставить фолы так же нажатием на цифру игрока.',
      icon: Icons.calculate_rounded,
      backgroundColor: Colors.green.withOpacity(0.5),
      width: 200,
      height: 180,
    ),
    // 4️⃣ ВПЕРЕД (→)
    TutorialStep(
      id: 'game_forward',
      title: 'Вперед',
      description: 'Нажмите, чтобы перейти к следующей фазе игры.',
      icon: Icons.arrow_forward_rounded,
      backgroundColor: Colors.green.withOpacity(0.5),
      width: 200,
      height: 100,
    ),
    // 5️⃣ НАЗАД (←)
    TutorialStep(
      id: 'game_back',
      title: 'Назад',
      description: 'Нажмите, чтобы вернуться на шаг назад. Ошибся, жми сюда!',
      icon: Icons.arrow_back_rounded,
      backgroundColor: Colors.green.withOpacity(0.5),
      width: 200,
      height: 120,
    ),
    // 6️⃣ РОЛИ (🎭)
    TutorialStep(
      id: 'game_roles',
      title: 'Показать роли',
      description: 'Нажмите, чтобы показать/скрыть роли всех игроков.',
      icon: Icons.theater_comedy_rounded,
      backgroundColor: Colors.green.withOpacity(0.5),
      width: 250,
      height: 100,
    ),
    // 7️⃣ ПРОМАХ (🙅)
    TutorialStep(
      id: 'game_miss',
      title: 'Промах',
      description: 'Нажмите, если мафия промахнулась.',
      icon: Icons.do_not_disturb_rounded,
      backgroundColor: Colors.green.withOpacity(0.5),
      width: 180,
      height: 100,
    ),
// 9️⃣ ГОЛОСОВАНИЕ
    TutorialStep(
      id: 'game_voting',
      title: 'Голосование',
      description:
          'Выставленные игроки появляются в центре стола в порядке выставления. Все автоматизировано под правила ФСМ. Если было удаление или выставлен один игрок в первый день - голосование не проводится. Голосование, переголосование, перестрелка, голосование за подъем все автоматизировано по правилам ФСМ... просто вводите голоса.',
      icon: Mdi.thumbsUpDown,
      backgroundColor: Colors.green.withOpacity(0.5),
      width: 230,
      height: 330,
    ),
    // 9️⃣ ГОЛОСОВАНИЕ
    TutorialStep(
      id: 'game_start',
      title: 'Начало игры',
      description:
          'Нажмите на первого игрока и покажите ему его роль прямо с экрана телефона, после 10 игрока нажимайте вперед, игра начилась. Пожелайте всем хорошей игры!',
      icon: Mdi.play,
      backgroundColor: Colors.green.withOpacity(0.5),
      width: 250,
      height: 180,
    ),
  ];
  static final List<TutorialStep> protocolSteps = [
    TutorialStep(
      id: 'protocol_ball',
      title: 'Допы',
      description:
          'Нажмите и выберите награду для игрока. Ниже в пояснение напишите за что он их получил.',
      icon: Mdi.emoticonHappy,
      backgroundColor: Colors.green.withOpacity(0.5),
      width: 200,
      height: 150,
    ),
    TutorialStep(
      id: 'protocol_penalty',
      title: 'Штраф',
      description:
          'Если стоит минус, нажмите и выберите пункт правил который он нарушил и так же ниже объясните что он сделал.',
      icon: Mdi.emoticonDead,
      backgroundColor: Colors.green.withOpacity(0.5),
      width: 200,
      height: 160,
    ),
    TutorialStep(
      id: 'protocol_server',
      title: 'Сохранить в рейтинг',
      description: 'Нажмите сюда, чтобы игра сохранилась в рейтинг клуба.',
      icon: Mdi.cloudArrowDown,
      backgroundColor: Colors.green.withOpacity(0.5),
      width: 270,
      height: 100,
    ),
    TutorialStep(
      id: 'protocol_local',
      title: 'Сохранить на телефон',
      description:
          'Нажмите сюда, чтобы сохранит игру на телефон. Нет интернета, жми сюда, потом загрузишь в рейтинг',
      icon: Mdi.harddiskPlus,
      backgroundColor: Colors.green.withOpacity(0.5),
      width: 280,
      height: 120,
    ),
    TutorialStep(
      id: 'protocol_file',
      title: 'Сохраненные игры',
      description:
          'Все ваши игры. Можете отправить игры в рейтинг или сделать ексель протокол и распечатать протокол ФСМ.',
      icon: Mdi.microsoftExcel,
      backgroundColor: Colors.green.withOpacity(0.5),
      width: 260,
      height: 140,
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
