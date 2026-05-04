import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mafia_help/data/local/sources/game_local_source.dart';

final gameLocalSourceProvider = Provider<GameLocalSource>((ref) {
  throw UnimplementedError('Must be overridden in main.dart');
});