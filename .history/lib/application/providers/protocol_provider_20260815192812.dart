import 'package:mafia_help/domain/usecases/check_game_exists_usecase.dart';

final checkGameExistsUsecaseProvider = Provider<CheckGameExistsUsecase>((ref) {
  return CheckGameExistsUsecase(ref.read(protocolRepositoryProvider));
});