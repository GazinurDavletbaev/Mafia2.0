import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mafia_help/data/local/sources/game_local_source.dart';
import 'package:mafia_help/data/repositories/game_repository_impl.dart';
import 'package:mafia_help/domain/repositories/game_repository.dart';

final gameLocalSourceProvider = Provider<GameLocalSource>((ref) {
  throw UnimplementedError('Must be overridden in main.dart');
});

final gameRepositoryProvider = Provider<GameRepository>((ref) {
  final localSource = ref.read(gameLocalSourceProvider);
  final notifier = ref.read(gameStateProvider.notifier);
  return GameRepositoryImpl(
    localSource: localSource,
    notifier: notifier,
  );
});