import '../../data/local/models/sub_phase.dart';
import '../entities/phase_stack.dart';

class PhaseRules {
  static const List<SubPhase> night0Order = [
    SubPhase.roleDistribution,
    SubPhase.contract,
    SubPhase.sheriffLook,
    SubPhase.freeSeating,
  ];
  
  static const List<SubPhase> nightOrder = [
    SubPhase.mafiaShoot,
    SubPhase.donCheck,
    SubPhase.sheriffCheck,
  ];
  
  static const List<SubPhase> dayOrder = [
    SubPhase.speeches,
    SubPhase.voting,
    SubPhase.revote,
    SubPhase.tieBreak,
    SubPhase.eliminationVote,
    SubPhase.finalWord,
  ];
  
  SubPhase? getNextPhase(PhaseStack stack, bool isNight0Completed) {
    if (stack.isEmpty) {
      if (isNight0Completed) return dayOrder[0];
      return night0Order[0];
    }
    
    final current = stack.current;
    
    if (night0Order.contains(current)) {
      final index = night0Order.indexOf(current);
      if (index + 1 < night0Order.length) {
        return night0Order[index + 1];
      }
      return null;
    }
    
    if (dayOrder.contains(current)) {
      final index = dayOrder.indexOf(current);
      if (index + 1 < dayOrder.length) {
        return dayOrder[index + 1];
      }
      return nightOrder[0];
    }
    
    if (nightOrder.contains(current)) {
      final index = nightOrder.indexOf(current);
      if (index + 1 < nightOrder.length) {
        return nightOrder[index + 1];
      }
      return dayOrder[0];
    }
    
    return null;
  }
}