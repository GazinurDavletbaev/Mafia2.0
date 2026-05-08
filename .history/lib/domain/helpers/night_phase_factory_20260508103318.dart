import 'package:mafia_help/data/local/models/phase.dart';
import 'package:mafia_help/data/local/models/sub_phase.dart';
import 'package:mafia_help/presentation/state/game_state.dart';

class NightPhaseFactory {
  /// Создаёт ночь 1 (особенная, без стрельбы)
  static GameState createFirstNight(GameState state) {
    return state.copyWith(
      currentPhase: Phase.night,
      currentSubPhase: SubPhase.roleDistribution,
      currentSubPhaseIndex: 0,
      currentDay: 0,
      hasKillInLastNight: false,
      nominatedSeats: [],
      votes: {},
      eliminationVotes: 0,
    );
  }

  /// Создаёт обычную ночь (со стрельбой)
  static GameState createRegularNight(GameState state, {required int day}) {
    return state.copyWith(
      currentPhase: Phase.night,
      currentSubPhase: SubPhase.mafiaShoot,
      currentSubPhaseIndex: 0,
      currentDay: day,
      nominatedSeats: [],
      votes: {},
      eliminationVotes: 0,
    );
  }
}