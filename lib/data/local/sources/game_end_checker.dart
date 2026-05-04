import '../../../presentation/state/game_state.dart';

enum WinReason {
  allBlackDead,      // все чёрные мертвы → победа красных
  redLessOrEqual,    // красных ≤ чёрных → победа чёрных
  lessThan3Players,  // живых игроков меньше 3 → победа чёрных (кроме случая, когда чёрных 0)
}

class GameEndChecker {
  /// Проверяет, окончена ли игра, и возвращает победителя (если есть)
  /// Возвращает:
  /// - null - игра продолжается
  /// - 'red' - победили красные
  /// - 'black' - победили чёрные
  static String? checkWinner(GameState gameState) {
    final blackAlive = gameState.blackAlive;
    final redAlive = gameState.redAlive;
    final totalAlive = gameState.totalAlive;

    // Условие 1: Все чёрные мертвы → победа красных
    if (blackAlive == 0) {
      return 'red';
    }

    // Условие 2: Красных ≤ чёрных → победа чёрных
    if (redAlive <= blackAlive) {
      return 'black';
    }

    // Условие 3: Живых игроков меньше 3 → победа чёрных
    // (но если чёрных 0, то сработало бы условие 1)
    if (totalAlive < 3) {
      return 'black';
    }

    // Игра продолжается
    return null;
  }

  /// Возвращает причину победы (для сообщения судье)
  static WinReason? getWinReason(GameState gameState) {
    final blackAlive = gameState.blackAlive;
    final redAlive = gameState.redAlive;
    final totalAlive = gameState.totalAlive;

    if (blackAlive == 0) {
      return WinReason.allBlackDead;
    }
    
    if (redAlive <= blackAlive) {
      return WinReason.redLessOrEqual;
    }
    
    if (totalAlive < 3) {
      return WinReason.lessThan3Players;
    }
    
    return null;
  }

  /// Формирует текст сообщения для судьи
  static String getWinMessage(String winnerTeam, WinReason? reason) {
    final teamName = winnerTeam == 'red' ? 'КРАСНЫЕ (мирные)' : 'ЧЁРНЫЕ (мафия)';
    
    String reasonText = '';
    if (reason == WinReason.allBlackDead) {
      reasonText = 'Все чёрные игроки выбыли';
    } else if (reason == WinReason.redLessOrEqual) {
      reasonText = 'Красных ≤ чёрных';
    } else if (reason == WinReason.lessThan3Players) {
      reasonText = 'За столом осталось меньше 3 игроков';
    }
    
    return 'Игра окончена!\nПобедила команда $teamName.\n$reasonText\n\nПерейти к заполнению бланка?';
  }

  /// Проверяет, нужно ли предложить завершить игру в текущей фазе
  /// Некоторые фазы не должны прерывать игру (раздача ролей, договорка и т.д.)
  static bool canEndGameInCurrentPhase(String subPhaseName) {
    // Исключаем фазы, в которых игра не должна завершаться
    final noEndPhases = [
      'roleDistribution',  // раздача ролей
      'contract',          // договорка
      'sheriffLook',       // шериф осматривает город
    ];
    
    return !noEndPhases.contains(subPhaseName);
  }
}