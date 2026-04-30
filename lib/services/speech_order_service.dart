import 'package:mafia_help/state/game_state.dart';

class SpeechOrderService {
  // Определяет, кто начинает речь в текущем дне
  // firstSpeakerSeatFromPreviousDay - кто начинал в прошлый день (хранится в GameState)
  // aliveSeats - список живых мест (отсортированный по возрастанию)
  static int getFirstSpeakerSeat({
    required int firstSpeakerSeatFromPreviousDay,
    required List<int> aliveSeats,
  }) {
    if (firstSpeakerSeatFromPreviousDay == 0) {
      // Это первый день игры (нет предыдущего дня)
      // Начинаем с места 1, если его нет, то следующее живое
      return _findNextAlive(startSeat: 1, aliveSeats: aliveSeats);
    }

    // Следующий должен быть firstSpeakerSeatFromPreviousDay + 1 (по кругу)
    int nextCandidate = firstSpeakerSeatFromPreviousDay + 1;
    if (nextCandidate > 10) {
      nextCandidate = 1;
    }

    return _findNextAlive(startSeat: nextCandidate, aliveSeats: aliveSeats);
  }

  // Возвращает список живых мест в порядке выступлений
  // Начиная с firstSpeakerSeat, затем по кругу все остальные живые
  static List<int> getSeatsOrder({
    required int firstSpeakerSeat,
    required List<int> aliveSeats,
  }) {
    // Проверяем, что firstSpeakerSeat жив
    if (!aliveSeats.contains(firstSpeakerSeat)) {
      throw ArgumentError('firstSpeakerSeat $firstSpeakerSeat не в списке живых');
    }

    final result = <int>[];
    
    // Сортируем живые места по возрастанию
    final sortedAlive = List<int>.from(aliveSeats)..sort();
    
    // Находим индекс firstSpeakerSeat в отсортированном списке
    final startIndex = sortedAlive.indexOf(firstSpeakerSeat);
    
    // Собираем сначала от startIndex до конца, затем от начала до startIndex-1
    for (int i = startIndex; i < sortedAlive.length; i++) {
      result.add(sortedAlive[i]);
    }
    for (int i = 0; i < startIndex; i++) {
      result.add(sortedAlive[i]);
    }
    
    return result;
  }

  // Находит ближайшее живое место, начиная с startSeat и двигаясь вверх (1→10, затем 1 снова)
  static int _findNextAlive({
    required int startSeat,
    required List<int> aliveSeats,
  }) {
    if (aliveSeats.isEmpty) {
      throw ArgumentError('Нет живых игроков');
    }

    // Проверяем от startSeat до 10
    for (int seat = startSeat; seat <= 10; seat++) {
      if (aliveSeats.contains(seat)) {
        return seat;
      }
    }
    
    // Проверяем от 1 до startSeat-1
    for (int seat = 1; seat < startSeat; seat++) {
      if (aliveSeats.contains(seat)) {
        return seat;
      }
    }
    
    // fallback (не должно случиться, если aliveSeats не пуст)
    return aliveSeats.first;
  }

  // Обновляет firstSpeakerSeat для следующего дня
  // Правило: следующий день начинает тот, кто шёл после первого_говорящего_сегодня
  static int getNextDayFirstSpeaker({
    required int firstSpeakerSeatToday,
    required List<int> aliveSeats,
    required List<int> todayOrder, // порядок выступлений сегодня (все живые)
  }) {
    // Находим позицию firstSpeakerSeatToday в todayOrder
    final index = todayOrder.indexOf(firstSpeakerSeatToday);
    if (index == -1) {
      return firstSpeakerSeatToday; // fallback
    }
    
    // Следующий после него (или первый в списке, если он был последним)
    final nextIndex = (index + 1) % todayOrder.length;
    final nextSpeaker = todayOrder[nextIndex];
    
    return nextSpeaker;
  }
}