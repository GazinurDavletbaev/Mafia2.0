enum MainPhase { night, day }

enum SubPhase {
  // Ночь (первая)
  roleDistribution,   // раздача ролей
  contract,           // договорка (мафия знакомится) 60 сек
  sheriffLook,        // шериф осматривает город 20 сек
  
  // Ночь (обычная, со 2-й)
  mafiaShoot,         // стрельба мафии
  donCheck,           // проверка дона
  sheriffCheck,       // проверка шерифа
  
  // День
  speeches,           // речи игроков (60 сек каждый)
  voting,             // голосование (подсчёт голосов)
  revote,             // переголосование (30 сек на кандидата)
  eliminationVote,    // голосование за подъём (выгнать всех)
  finalWord,          // заключительная минута (выбывшим)
  bestMove,           // лучший ход (только после 1-й ночи, если было убийство)
}

class PhaseConfig {
  final MainPhase mainPhase;
  final List<SubPhase> subPhases;
  final bool isFirstNight;     // true = первая ночь (раздача, договорка, осмотр)
  final bool hasKill;          // было ли убийство в предыдущую ночь (для bestMove)

  const PhaseConfig({
    required this.mainPhase,
    required this.subPhases,
    this.isFirstNight = false,
    this.hasKill = false,
  });

  // Фабрики для разных типов фаз
  factory PhaseConfig.firstNight() {
    return const PhaseConfig(
      mainPhase: MainPhase.night,
      subPhases: [
        SubPhase.roleDistribution,
        SubPhase.contract,
        SubPhase.sheriffLook,
      ],
      isFirstNight: true,
    );
  }

  factory PhaseConfig.regularNight() {
    return const PhaseConfig(
      mainPhase: MainPhase.night,
      subPhases: [
        SubPhase.mafiaShoot,
        SubPhase.donCheck,
        SubPhase.sheriffCheck,
      ],
    );
  }

  factory PhaseConfig.day({required bool hasKillFromPreviousNight}) {
    final subPhases = <SubPhase>[
      SubPhase.speeches,
      SubPhase.voting,
    ];
    
    // Если было убийство в предыдущую ночь, добавляем bestMove в начало дня
    if (hasKillFromPreviousNight) {
      subPhases.insert(0, SubPhase.bestMove);
    }
    
    return PhaseConfig(
      mainPhase: MainPhase.day,
      subPhases: subPhases,
      hasKill: hasKillFromPreviousNight,
    );
  }
}