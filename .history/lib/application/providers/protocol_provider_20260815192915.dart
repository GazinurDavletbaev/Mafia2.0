// lib/application/providers/protocol_providers.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mafia_help/data/local/sources/protocol_local_source.dart';
import 'package:mafia_help/domain/usecases/check_game_exists_usecase.dart';

final protocolLocalSourceProvider = Provider<ProtocolLocalSource>((ref) {
  final source = ProtocolLocalSource();
  source.init();
  return source;
});

final checkGameExistsUsecaseProvider = Provider<CheckGameExistsUsecase>((ref) {
  return CheckGameExistsUsecase(ref.read(protocolLocalSourceProvider));
});