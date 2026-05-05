import 'package:mafia_help/application/providers/game_state_provider.dart';
import 'package:mafia_help/domain/repositories/game_repository.dart';

class DealRolesUsecase {
  final GameRepository _repository;
  final GameStateNotifier _notifier;

  DealRolesUsecase({
    required GameRepository repository,
    required GameStateNotifier notifier,
  }) : _repository = repository,
       _notifier = notifier;

  Future<void> call() async {
    // Состав ролей: 1 дон, 2 мафии, 1 шериф, 6 мирных
    const roles = [
      'don', 'mafia', 'mafia',  // чёрные (3)
      'sheriff',                 // красный (1)
      'citizen', 'citizen', 'citizen', 'citizen', 'citizen', 'citizen' // мирные (6)
    ];
    
    // Соответствующие команды
    const teams = [
      'black', 'black', 'black',  // чёрные
      'red',                       // шериф — красный
      'red', 'red', 'red', 'red', 'red', 'red'  // мирные — красные
    ];
    
    // Перемешиваем списки вместе
    final combined = List.generate(roles.length, (i) => (role: roles[i], team: teams[i]));
    combined.shuffle();
    
    final shuffledRoles = combined.map((e) => e.role).toList();
    final shuffledTeams = combined.map((e) => e.team).toList();
    
    // Назначаем роли игрокам
    final players = await _repository.getAllPlayers();
    for (int i = 0; i < players.length; i++) {
      final player = players[i];
      final updatedPlayer = player.copyWith(
        role: shuffledRoles[i],
        team: shuffledTeams[i],
      );
      await _repository.updatePlayer(updatedPlayer);
      _notifier.updatePlayerInState(updatedPlayer);
    }
  }
}