// lib/domain/rules/phase_rules.dart

import '../entities/phase_stack.dart';
import '../entities/sub_phase.dart';

class PhaseRules {
  // Списки фаз
  static const List<Night0Phase> night0Order = [
    Night0Phase.roleDistribution,
    Night0Phase.contract,
    Night0Phase.sheriffLook,
    Night0Phase.freeSeating,
  ];
  
  static const List<NightPhase> nightOrder = [
    NightPhase.mafiaShoot,
    NightPhase.donCheck,
    NightPhase.sheriffCheck,
  ];
  
  static const List<DayPhase> dayOrder = [
    DayPhase.speeches,
    DayPhase.voting,
    DayPhase.revote,
    DayPhase.tieBreak,
    DayPhase.eliminationVote,
    DayPhase.finalWord,
  ];
  
  // Получить следующую фазу
  dynamic getNextPhase(PhaseStack stack, bool isNight0Completed) {
    // Стек пустой
    if (stack.isEmpty) {
      // Если ночь 0 уже прошла → начинаем день 0
      if (isNight0Completed) {
        return dayOrder[0];
      }
      // Иначе начало игры → ночь 0
      return night0Order[0];
    }
    
    final current = stack.current;
    
    // Ночь 0
    if (current is Night0Phase) {
      final index = night0Order.indexOf(current);
      if (index + 1 < night0Order.length) {
        return night0Order[index + 1];
      }
      // Конец ночи 0
      return null;
    }
    
    // День
    if (current is DayPhase) {
      final index = dayOrder.indexOf(current);
      if (index + 1 < dayOrder.length) {
        return dayOrder[index + 1];
      }
      // Конец дня → ночь
      return nightOrder[0];
    }
    
    // Ночь 1+
    if (current is NightPhase) {
      final index = nightOrder.indexOf(current);
      if (index + 1 < nightOrder.length) {
        return nightOrder[index + 1];
      }
      // Конец ночи → день
      return dayOrder[0];
    }
    
    return null;
  }
  
  // Получить предыдущую фазу (по сути просто pop)
  // Вся логика уже в стеке
}