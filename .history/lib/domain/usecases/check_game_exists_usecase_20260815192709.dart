// lib/domain/usecases/check_game_exists_usecase.dart
import 'package:mafia_help/domain/repositories/protocol_repository.dart';

class CheckGameExistsUsecase {
  final ProtocolRepository repository;

  CheckGameExistsUsecase(this.repository);

  Future<bool> execute({
    required DateTime date,
    required int table,
    required int game,
    int? excludeGameId,
  }) async {
    final protocols = await repository.getLocalProtocols();

    for (final protocol in protocols) {
      if (excludeGameId != null && protocol.gameId == excludeGameId) {
        continue;
      }

      final bool sameDate = protocol.date.year == date.year &&
          protocol.date.month == date.month &&
          protocol.date.day == date.day;

      final bool sameTable = protocol.table == table;
      final bool sameGame = protocol.game == game;

      if (sameDate && sameTable && sameGame) {
        return true;
      }
    }

    return false;
  }
}